import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _id;
  String _name = "";
  String _email = "";
  String _phone = "";
  String _role = "";

  int? get id => _id;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get role => _role;

  void setUser({
    int? id,
    required String name,
    required String email,
    required String phone,
    String role = '',
  }) {
    _id = id;
    _name = name;
    _email = email;
    _phone = phone;
    _role = role;
    notifyListeners();
  }

  void logout() {
    _id = null;
    _name = "";
    _email = "";
    _phone = "";
    _role = "";
    notifyListeners();
  }
}
