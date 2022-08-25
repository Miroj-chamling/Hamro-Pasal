import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  late String _token;
  late DateTime _expiryDate = DateTime.now();
  late String _userId;
  Timer? _authTimre;
  late Map<String, dynamic> userData;

  bool get isAuth {
    return token != "";
  }

  String get token {
    if (_expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return "";
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String endPoint) async {
    final uri =
        "https://identitytoolkit.googleapis.com/v1/accounts:$endPoint?key=AIzaSyBt0Udfg0Rc9kBPjrJL0gf5aPopR0YbLBc";
    try {
      final respose = await http.post(
        Uri.parse(uri),
        body: json.encode(
          {
            "email": email,
            "password": password,
            "returnSecureToken": true,
          },
        ),
      );
      final responseData = json.decode(respose.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      _token = responseData["idToken"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData["expiresIn"],
          ),
        ),
      );
      _userId = responseData["localId"];
      _autoLogout();
      // final userData = json.encode({
      //   "token": _token,
      //   "userId": _userId,
      //   "expiryDate": _expiryDate.toIso8601String(),
      // });
      // final prefs = await SharedPreferences.getInstance();
      // prefs.setString("userData", userData);
      notifyListeners();
      // final prefs = await SharedPreferences.getInstance();
      // final userData = json.encode({
      //   "token": _token,
      //   "userId": _userId,
      //   "expiryDate": _expiryDate.toIso8601String(),
      // });
      //prefs.setString("userData", userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  // Future<bool> autoLogin() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (!prefs.containsKey("userData")) {
  //     return false;
  //   }
  //   final rawJson = prefs.getString("userData");
  //   Map<String, dynamic> extractedUserData = json.decode(rawJson.toString());
  //   final expiryDate =
  //       DateTime.parse(extractedUserData["expiryDate"].toString());
  //   if (expiryDate.isBefore(DateTime.now())) {
  //     return false;
  //   }
  //   _token = extractedUserData["token"].toString();
  //   print(_token);
  //   _userId = extractedUserData["userId"].toString();
  //   _expiryDate = _expiryDate;
  //   notifyListeners();
  //   _autoLogout();
  //   return true;
  // }

  void logout() {
    _token = "";
    _userId = "";
    _expiryDate = DateTime.now();
    if (_authTimre != null) {
      _authTimre!.cancel();
      _authTimre = null;
    }
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimre != null) {
      _authTimre!.cancel();
    }
    final _timeToExpire = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimre = Timer(Duration(seconds: _timeToExpire), () {
      logout();
    });
  }
}
