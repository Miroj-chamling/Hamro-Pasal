import 'package:flutter/material.dart';
import 'package:myapp/providers/cart.dart' show Cart;
import 'package:myapp/providers/orders.dart';

import 'package:myapp/providers/products.dart';

//we need the information only from the Cart from the providers and dont need information from the cartItem of the providers
import '../Components/cart_item.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  const Spacer(),
                  Chip(
                    label: Text(
                      'Rs ${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: cart.itemCount == 0
                ? const Text("Cart is Empty!")
                : Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          cart.removeAllItems();
                          // for (int i = 0; i < cart.itemCount; i++) {
                          //   print(cart.items);
                          //   cart.removeItem(cart.items.keys.toList()[i]);
                          //   print(i);
                          // }
                        },
                        child: const Chip(
                          label: Text("Clear all"),
                        ),
                      ),
                      Expanded(
                          child: Consumer<Products>(builder: (ctx, pData, _) {
                        return ListView.builder(
                          itemCount: cart.items.length,
                          itemBuilder: (context, index) => CartItem(
                            cart.items.values.toList()[index].id,
                            cart.items.keys.toList()[index],
                            cart.items.values.toList()[index].price,
                            cart.items.values.toList()[index].quantity,
                            cart.items.values.toList()[index].title,
                            pData.items[index].imageUrl,
                          ),
                        );
                      })),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: widget.cart.totalAmount <= 0
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await Provider.of<Orders>(context, listen: false).addOrder(
                    widget.cart.items.values.toList(), widget.cart.totalAmount);
                widget.cart.removeAllItems();
              } catch (err) {
                print(err);
              }
              Scaffold.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Order has been placed"),
                  duration: Duration(seconds: 2),
                ),
              );
              setState(() {
                _isLoading = false;
              });
            },
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text("Order Now"),
    );
  }
}
