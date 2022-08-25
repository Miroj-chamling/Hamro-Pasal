import 'package:flutter/material.dart';
import 'package:myapp/providers/cart.dart';
import 'package:myapp/providers/products.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  static const routeName = '/product-detail';

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  increaseCount() {
    setState(() {
      quantity++;
    });
  }

  decreaseCount() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments
        as String; //this has been taken as an arguement from the named route of the product item.
    final loadedProduct = Provider.of<Products>(context).findById(
        productId); //we use the productId to find the product and save it into the loadedProduct
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              height: 300,
              width: double.infinity,
              child: Image.network(
                loadedProduct.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text('Rs ${loadedProduct.price.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            Text(loadedProduct.description),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () => decreaseCount(), child: Text("-")),
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(quantity.toString()),
                  ),
                ),
                ElevatedButton(
                    onPressed: () => increaseCount(), child: Text("+")),
                SizedBox(width: 50),
                FlatButton(
                  color: Colors.green,
                  onPressed: () {
                    cart.addItem(loadedProduct.id, loadedProduct.price,
                        loadedProduct.title, quantity);
                  },
                  child: const Text("Add to cart"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
