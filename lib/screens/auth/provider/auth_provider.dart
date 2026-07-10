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
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final currentUserId = prefs.getString(_currentUserKey);

      if (isLoggedIn && currentUserId != null) {
        final usersBox = await Hive.openBox<User>(_usersBoxName);
        _currentUser = usersBox.get(currentUserId);
        
        if (_currentUser != null) {
          await SyncService().initialize(currentUserId);
          notifyListeners();
          _refreshSessionInBackground();
          return;
        }
      }

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Auth Status Check Error: $e');
      _currentUser = null;
      notifyListeners();
    }
  }

  void _refreshSessionInBackground() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      _loadUserData(firebaseUser.uid).catchError((e) {
        debugPrint('Background session refresh failed: $e');
      });
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        final user = User(
          id: uid,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'],
          password: '',
        );
        await _setSession(user);
        await SyncService().initialize(uid);
      } else {
        final firebaseUser = _firebaseAuth.currentUser;
        if (firebaseUser != null) {
          final minimalUser = User(
            id: uid,
            name: firebaseUser.displayName ?? _currentUser?.name ?? '',
            email: firebaseUser.email ?? _currentUser?.email ?? '',
            password: '',
            phone: _currentUser?.phone,
          );
          await _setSession(minimalUser);
          await SyncService().initialize(uid);
        }
      }
    } catch (e) {
      debugPrint('Firestore User Sync Error: $e');
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

        await _setSession(newUser);
        await SyncService().initialize(firebaseUser.uid);
        _isLoading = false;
        return true;
      }
      _isLoading = false;
      return false;
    } on auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      throw e.message ?? 'একটি ত্রুটি ঘটেছে';
    } catch (e) {
      _isLoading = false;
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
        final initialUser = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? email,
          password: '',
        );
        await _setSession(initialUser);
        await SyncService().initialize(firebaseUser.uid);
        _loadUserData(firebaseUser.uid);
        _isLoading = false;
        return true;
      }
      _isLoading = false;
      return false;
    } on auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      throw e.message ?? 'লগইন ব্যর্থ হয়েছে';
    } catch (e) {
      _isLoading = false;
      throw 'লগইন করা সম্ভব হয়নি';
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_currentUserKey);
    SyncService().clearUid();
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
      final updateData = {'name': name, 'email': email};
      if (phone != null) updateData['phone'] = phone;
      await _firestore.collection('users').doc(_currentUser!.id).update(updateData);
      final updatedUser = User(
        id: _currentUser!.id,
        name: name,
        email: email,
        phone: phone ?? _currentUser!.phone,
        password: _currentUser!.password,
      );
      await _setSession(updatedUser);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _setSession(User user) async {
    _currentUser = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_currentUserKey, user.id);
      final usersBox = await Hive.openBox<User>(_usersBoxName);
      await usersBox.put(user.id, user);
    } catch (e) {
      debugPrint('Session Persistence Error: $e');
    }
    notifyListeners();
  }
}
