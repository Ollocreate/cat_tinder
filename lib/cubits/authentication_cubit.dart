import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthenticationStatus { authenticated, unauthenticated }

class User {
  final String name;
  final String password;

  User({required this.name, required this.password});
}

class AuthenticationCubit extends Cubit<AuthenticationStatus> {
  AuthenticationCubit() : super(AuthenticationStatus.unauthenticated) {
    loadUserFromPrefs();
  }

  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> checkAuthenticationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    final password = prefs.getString('user_password');

    if (name != null && password != null) {
      _currentUser = User(name: name, password: password);
      emit(AuthenticationStatus.authenticated);
    } else {
      emit(AuthenticationStatus.unauthenticated);
    }
  }

  Future<void> loginUser(User user, BuildContext context) async {
    if (user.name == 'admin' && user.password == 'password') {
      await _saveUserToPrefs(user);

      emit(AuthenticationStatus.authenticated);
    } else {
      _showErrorMessage(context, 'Wrong username or password');
    }
  }

  void logoutUser() {
    _currentUser = null;
    _removeUserFromPrefs();

    emit(AuthenticationStatus.unauthenticated);
  }

  Future<void> loadUserFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    final password = prefs.getString('user_password');
    final isAuthenticated = prefs.getBool('is_authenticated') ?? false;

    if (isAuthenticated && name != null && password != null) {
      _currentUser = User(name: name, password: password);
      emit(AuthenticationStatus.authenticated);
    } else {

      emit(AuthenticationStatus.unauthenticated);
    }
  }

  Future<void> _saveUserToPrefs(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_name', user.name);
    prefs.setString('user_password', user.password);
    prefs.setBool('is_authenticated', true);
  }

  Future<void> _removeUserFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user_name');
    prefs.remove('user_password');
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}