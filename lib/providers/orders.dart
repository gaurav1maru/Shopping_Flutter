import 'package:flutter/material.dart';
import '../providers/cart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String authToken;
  final String userId;
  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://shopping-flutter-7dd86-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      //print(response.body);

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      if (extractedData == null) {
        return;
      }

      print(extractedData);
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'].toInt(),
                    price: item['price'].toDouble()))
                .toList()));
      });

      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shopping-flutter-7dd86-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();

    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timestamp.toIso8601String(),
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price
                    })
                .toList()
          }));

      _orders.insert(
          0,
          OrderItem(
              id: json.decode(response.body)['name'],
              amount: total,
              products: cartProducts,
              dateTime: timestamp));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
