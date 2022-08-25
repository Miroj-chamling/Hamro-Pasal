import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/product.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.order.id),
      confirmDismiss: (direction) {
        return showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text("Are you sure?"),
            content: const Text("Do you want to remove the order?"),
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
        Provider.of<ord.Orders>(context, listen: false)
            .removeSingleOrder(widget.order.id);
      },
      child: Card(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Rs ${widget.order.amount}'),
              subtitle:
                  Text(DateFormat("dd-MM-yyyyy").format(widget.order.dateTime)),
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                ),
              ),
            ),
            if (_expanded)
              Container(
                padding: const EdgeInsets.all(8.0),
                height: min(widget.order.products.length * 20.0 + 10, 100),
                child: ListView(
                  children: widget.order.products
                      .map((product) => Row(
                            children: [
                              Text(product.title),
                              Text('${product.quantity}X  \$${product.price} ')
                            ],
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
