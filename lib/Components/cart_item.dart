import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/providers/cart.dart';
import 'package:myapp/providers/products.dart';
import 'package:provider/provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;
  final String prodImg;
  CartItem(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.title,
    this.prodImg,
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text("Are you sure?"),
            content: const Text("Do you want to remove item from the cart?"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  "No",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  "Yes",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 4.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(prodImg),
            ),
            title: Text(title),
            subtitle:
                Text('Total : Rs ${(price * quantity).toStringAsFixed(2)}'),
            trailing: Text('$quantity X'),
          ),
        ),
      ),
    );
  }
}
