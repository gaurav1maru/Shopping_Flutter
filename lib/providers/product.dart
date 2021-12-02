import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@override this.id,
      @override this.title,
      @override this.description,
      @override this.price,
      @override this.imageUrl,
      this.isFavorite = false});

  void toggleFavoriteStatus(String authToken, String userId) async {
    final url = Uri.parse(
        'https://shopping-flutter-7dd86-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken');
    var oldStatus = isFavorite;
    /**optimistic updating */
    _setFavoriteValue(!isFavorite);

    try {
      final response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        _setFavoriteValue(oldStatus);
      }
    } catch (error) {
      _setFavoriteValue(oldStatus);
    }
  }

  void _setFavoriteValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }
}
