import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/models/http_exception.dart';
import 'package:myapp/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
  ];

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavourtie).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchPorducts([bool userFilter = false]) async {
    final filterByUser =
        userFilter ? 'orderBy="creatorId"&equalTo="$userId"' : "";
    var url =
        "https://shoppingapp-2e7aa-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken&$filterByUser";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }
      url =
          "https://shoppingapp-2e7aa-default-rtdb.asia-southeast1.firebasedatabase.app/userFavourites/$userId.json?auth=$authToken";
      final favResponse = await http.get(Uri.parse(url));
      final favData = json.decode(favResponse.body);
      final List<Product> fetchedProducts = [];
      extractedData.forEach((productId, productData) {
        //print("favv" + favouriteData);
        fetchedProducts.insert(
          0,
          Product(
            id: productId,
            title: productData["title"],
            description: productData["description"],
            price: productData["price"],
            imageUrl: productData["imageUrl"],
            isFavourtie: favData == null ? false : favData[productId] ?? false,
          ),
        );
      });
      _items = fetchedProducts;
      notifyListeners();
    } catch (error) {
      throw "error has occured";
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        "https://shoppingapp-2e7aa-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "creatorId": userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      //_items.add(newProduct);
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      throw HttpException("");
    }

    // print("this error is from products " + error.toString());
    // throw error;
  }

  Future<void> updateProducts(String id, Product editedProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final url =
          "https://shoppingapp-2e7aa-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken";
      await http.patch(Uri.parse(url),
          body: json.encode({
            "title": editedProduct.title,
            "description": editedProduct.description,
            "price": editedProduct.price,
            "imageUrl": editedProduct.imageUrl,
          }));
      _items[productIndex] = editedProduct;
      notifyListeners();
    } else {
      return;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://shoppingapp-2e7aa-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken";
    final existingPorductIndex =
        _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingPorductIndex];
    _items.removeAt(existingPorductIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _items.insert(existingPorductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Item Deletion Failed");
    }
  }
}
