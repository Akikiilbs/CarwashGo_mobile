import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _id;
  String _name = "";
  String _email = "";
  String _phone = "";
  String _role = "";
  String _address = "";
  String _profilePhotoUrl = "";
  double? _latitude;
  double? _longitude;

  int? get id => _id;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get role => _role;
  String get address => _address;
  String get profilePhotoUrl => _profilePhotoUrl;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  void setUser({
    int? id,
    required String name,
    required String email,
    required String phone,
    String role = '',
    String address = '',
    String profilePhotoUrl = '',
    double? latitude,
    double? longitude,
  }) {
    _id = id;
    _name = name;
    _email = email;
    _phone = phone;

    // ✅ jangan timpa value lama dengan string kosong
    if (role.isNotEmpty) _role = role;
    if (address.isNotEmpty) _address = address;
    if (profilePhotoUrl.isNotEmpty) _profilePhotoUrl = profilePhotoUrl;
    if (latitude != null) _latitude = latitude;
    if (longitude != null) _longitude = longitude;

    notifyListeners();
  }

  void setAddress(String address, {double? latitude, double? longitude}) {
    _address = address;
    if (latitude != null) _latitude = latitude;
    if (longitude != null) _longitude = longitude;
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
    _latitude = null;
    _longitude = null;
    notifyListeners();
  }
}
