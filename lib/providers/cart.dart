import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // int itemQuantity = 1;

  // void increment() {
  //   itemQuantity++;
  //   notifyListeners();
  // }

  // void decrement() {
  //   if (itemQuantity <= 1) {
  //     return;
  //   }
  //   itemQuantity--;
  //   notifyListeners();
  // }

  void addItem(
    String productId,
    double price,
    String title,
    int quantity,
  ) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (exisitingItem) => CartItem(
          id: exisitingItem.id,
          title: exisitingItem.title,
          quantity: exisitingItem.quantity + quantity,
          price: exisitingItem.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          title: title,
          quantity: quantity,
          price: price,
        ),
      );
    }

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
            id: existingItem.id,
            title: existingItem.title,
            quantity: existingItem.quantity - 1,
            price: existingItem.price),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeAllItems() {
    _items.clear();
    notifyListeners();
  }
}
