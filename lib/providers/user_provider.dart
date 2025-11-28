import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _name = "";
  String _email = "";
  String _phone = "";

  String get name => _name;
  String get email => _email;
  String get phone => _phone;

  /// Simpan data user dari Sign Up
  void setUser({
    required String name,
    required String email,
    required String phone,
  }) {
    _name = name;
    _email = email;
    _phone = phone;
    notifyListeners();
  }

  /// Reset user ketika logout
  void logout() {
    _name = "";
    _email = "";
    _phone = "";
    notifyListeners();
  }
}
