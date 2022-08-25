import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourtie;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourtie = false,
  });

  void _setFav(bool newValue) {
    isFavourtie = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    final oldStatus = isFavourtie;
    isFavourtie = !isFavourtie;
    notifyListeners();
    final url =
        "https://shoppingapp-2e7aa-default-rtdb.asia-southeast1.firebasedatabase.app/userFavourites/$userId/$id.json?auth=$authToken";
    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode(
          isFavourtie,
        ),
      );
      if (response.statusCode >= 400) {
        _setFav(oldStatus);
      }
    } catch (err) {
      _setFav(oldStatus);
    }
  }
}
