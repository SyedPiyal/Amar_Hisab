import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user.dart';
import '../../../services/sync_service.dart';

class AuthProvider with ChangeNotifier {
  static const String _usersBoxName = 'users';
  static const String _currentUserKey = 'currentUserId';
  static const String _isLoggedInKey = 'isLoggedIn';

  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final currentUserId = prefs.getString(_currentUserKey);

    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser != null) {
      await _loadUserData(firebaseUser.uid);
    } else if (isLoggedIn && currentUserId != null) {
      final usersBox = await Hive.openBox<User>(_usersBoxName);
      _currentUser = usersBox.get(currentUserId);
      if (_currentUser != null) {
        // Initialize Sync Service for the persisted user
        await SyncService().initialize(currentUserId);
      }
    }
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _currentUser = User(
          id: uid,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'],
          password: '',
        );
        
        final usersBox = await Hive.openBox<User>(_usersBoxName);
        await usersBox.put(uid, _currentUser!);
        
        await _setSession(_currentUser!);
        
        // Initialize Sync Service for the logged in user
        await SyncService().initialize(uid);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = authResult.user;
      if (firebaseUser != null) {
        final newUser = User(
          id: firebaseUser.uid,
          name: name,
          email: email,
          password: '',
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final usersBox = await Hive.openBox<User>(_usersBoxName);
        await usersBox.put(firebaseUser.uid, newUser);
        
        await _setSession(newUser);
        _isLoading = false;
        return true;
      }
      _isLoading = false;
      return false;
    } on auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      String message = 'একটি ত্রুটি ঘটেছে';
      if (e.code == 'email-already-in-use') {
        message = 'এই ইমেইলটি ইতিমধ্যে ব্যবহৃত হচ্ছে';
      } else if (e.code == 'weak-password') {
        message = 'পাসওয়ার্ডটি খুব দুর্বল';
      } else if (e.code == 'invalid-email') {
        message = 'সঠিক ইমেইল প্রদান করুন';
      } else if (e.code == 'unknown' && e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
        message = 'Firebase Console-এ Email/Password সুবিধা চালু করুন';
      }
      throw message;
    } catch (e) {
      _isLoading = false;
      debugPrint('Signup Error: $e');
      throw 'অ্যাকাউন্ট তৈরি করা সম্ভব হয়নি';
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = authResult.user;
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
        _isLoading = false;
        return true;
      }
      _isLoading = false;
      return false;
    } on auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      String message = 'লগইন ব্যর্থ হয়েছে';
      if (e.code == 'user-not-found') {
        message = 'এই ইমেইলে কোনো অ্যাকাউন্ট পাওয়া যায়নি';
      } else if (e.code == 'wrong-password') {
        message = 'ভুল পাসওয়ার্ড';
      } else if (e.code == 'invalid-email') {
        message = 'সঠিক ইমেইল প্রদান করুন';
      }
      throw message;
    } catch (e) {
      _isLoading = false;
      debugPrint('Login Error: $e');
      throw 'লগইন করা সম্ভব হয়নি';
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_currentUserKey);
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      debugPrint('Update Password Error: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(String name, String email, {String? phone}) async {
    if (_currentUser == null) return;

    try {
      final updateData = {
        'name': name,
        'email': email,
      };
      if (phone != null) {
        updateData['phone'] = phone;
      }

      await _firestore.collection('users').doc(_currentUser!.id).update(updateData);

      final updatedUser = User(
        id: _currentUser!.id,
        name: name,
        email: email,
        phone: phone ?? _currentUser!.phone,
        password: _currentUser!.password,
      );

      final usersBox = await Hive.openBox<User>(_usersBoxName);
      await usersBox.put(updatedUser.id, updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      rethrow;
    }
  }

  Future<void> _setSession(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_currentUserKey, user.id);
    notifyListeners();
  }
}
