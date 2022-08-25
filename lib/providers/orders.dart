import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myapp/models/http_exception.dart';
import 'package:myapp/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  final String orderAuthToken;
  final String userId;
  Orders(this.orderAuthToken, this._orders, this.userId);

  Future<void> fetchAndSetOrders() async {
    final url =
        "https://shoppingapp-2e7aa-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$orderAuthToken";
    final response = await http.get(Uri.parse(url));
    final fetchedOrders = json.decode(response.body);
    if (fetchedOrders == null) {
      return;
    }
    final List<OrderItem> loadedOrders = [];

    fetchedOrders.forEach((orderId, orderData) {
      loadedOrders.insert(
        0,
        OrderItem(
          id: orderId,
          amount: orderData["amount"],
          products: (orderData["products"] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item["id"],
                  title: item["title"],
                  quantity: item["quantity"],
                  price: item["price"] as double,
                ),
              )
              .toList(),
          dateTime: DateTime.parse(
            orderData["dateTime"],
          ),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();

    print(response.body);
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        "https://shoppingapp-2e7aa-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId/.json?auth=$orderAuthToken";
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            "creatorId": userId,
            "amount": total,
            "dateTime": timeStamp.toIso8601String(),
            "products": cartProducts
                .map((e) => {
                      "id": e.id,
                      "title": e.title,
                      "quantity": e.quantity,
                      "price": e.price,
                    })
                .toList(),
          },
        ),
      );
      if (cartProducts.isEmpty) {
        return;
      } else {
        _orders.insert(
          0,
          OrderItem(
            id: json.decode(response.body)["name"],
            amount: total,
            products: cartProducts,
            dateTime: timeStamp,
          ),
        );
      }
      notifyListeners();
    } catch (error) {
      throw "Opps something went wrong!";
    }
  }

  Future<void> removeAllOrders() async {
    final url =
        "https://shoppingapp-2e7aa-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$orderAuthToken";
    final List<OrderItem> _deletedOrders = [];
    _deletedOrders.addAll(_orders);
    _orders.clear();
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _orders = _deletedOrders.toList();
      notifyListeners();
      throw HttpException("Orders could not be removed");
    }
  }

  Future<void> removeSingleOrder(String orderId) async {
    final url =
        "https://shoppingapp-2e7aa-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId/$orderId.json?auth=$orderAuthToken";
    final existingOrderIndex =
        _orders.indexWhere((order) => order.id == orderId);
    var exisitngOrder = _orders[existingOrderIndex];
    _orders.removeAt(existingOrderIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _orders.insert(existingOrderIndex, exisitngOrder);
      notifyListeners();
      throw HttpException("Something went wrong");
    }
  }

  double get totalAmount {
    double total = 0.0;

    for (var element in _orders) {
      total += element.amount;
    }

    return total;
  }
}
