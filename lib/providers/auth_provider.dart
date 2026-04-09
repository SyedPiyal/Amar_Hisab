import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  static const String _usersBoxName = 'users';
  static const String _sessionBoxName = 'session';
  static const String _currentUserKey = 'currentUserId';

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkLoginStatus() async {
    final sessionBox = await Hive.openBox(_sessionBoxName);
    final currentUserId = sessionBox.get(_currentUserKey);

    if (currentUserId != null) {
      final usersBox = await Hive.openBox<User>(_usersBoxName);
      _currentUser = usersBox.get(currentUserId);
    }
    notifyListeners();
  }

  Future<bool> signup(String name, String email, String password) async {
    final usersBox = await Hive.openBox<User>(_usersBoxName);

    // Check if user already exists
    final exists = usersBox.values.any((user) => user.email == email);
    if (exists) return false;

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
    );

    await usersBox.put(newUser.id, newUser);

    // Auto-login after signup
    await _setSession(newUser);
    return true;
  }

  Future<bool> login(String email, String password) async {
    final usersBox = await Hive.openBox<User>(_usersBoxName);

    try {
      final user = usersBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );

      await _setSession(user);
      return true;
    } catch (e) {
      // User not found or incorrect password
      return false;
    }
  }

  Future<void> logout() async {
    final sessionBox = await Hive.openBox(_sessionBoxName);
    await sessionBox.delete(_currentUserKey);
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    if (_currentUser == null) return;
    
    final updatedUser = User(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      password: newPassword,
    );
    
    final usersBox = await Hive.openBox<User>(_usersBoxName);
    await usersBox.put(updatedUser.id, updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<void> updateUserProfile(String name, String email) async {
    if (_currentUser == null) return;

    final updatedUser = User(
      id: _currentUser!.id,
      name: name,
      email: email,
      password: _currentUser!.password,
    );

    final usersBox = await Hive.openBox<User>(_usersBoxName);
    await usersBox.put(updatedUser.id, updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<void> _setSession(User user) async {
    _currentUser = user;
    final sessionBox = await Hive.openBox(_sessionBoxName);
    await sessionBox.put(_currentUserKey, user.id);
    notifyListeners();
  }
}
