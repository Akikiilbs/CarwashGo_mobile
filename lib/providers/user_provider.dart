import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _id;
  String _name = "";
  String _email = "";
  String _phone = "";
  String _role = "";
  String _address = "";
  String _profilePhotoUrl = "";

  int? get id => _id;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get role => _role;
  String get address => _address;
  String get profilePhotoUrl => _profilePhotoUrl;

  void setUser({
    int? id,
    required String name,
    required String email,
    required String phone,
    String role = '',
    String address = '',
    String profilePhotoUrl = '',
  }) {
    _id = id;
    _name = name;
    _email = email;
    _phone = phone;

    // ✅ jangan timpa value lama dengan string kosong
    if (role.isNotEmpty) _role = role;
    if (address.isNotEmpty) _address = address;
    if (profilePhotoUrl.isNotEmpty) _profilePhotoUrl = profilePhotoUrl;

    notifyListeners();
  }

  void setAddress(String address) {
    _address = address;
    notifyListeners();
  }

  void setProfilePhotoUrl(String url) {
    _profilePhotoUrl = url;
    notifyListeners();
  }

  void logout() {
    _id = null;
    _name = "";
    _email = "";
    _phone = "";
    _role = "";
    _address = "";
    _profilePhotoUrl = "";
    notifyListeners();
  }
}
