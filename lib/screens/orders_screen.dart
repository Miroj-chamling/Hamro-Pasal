import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:myapp/Components/app_drawer.dart';
import 'package:myapp/Components/order_item.dart';
import 'package:myapp/providers/orders.dart' show Orders;
import 'package:myapp/screens/esewa_payment_screen.dart';

import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = "/orders";
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<Orders>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text("Your Orders"),
      ),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (dataSnapShot.hasError) {
            return const Center(
              child: Text("Opps! Something went wrong"),
            );
          } else {
            return Column(
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
                            'Rs ${ordersData.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 10),
                        //esewa options
                        FlatButton(
                          onPressed: ordersData.totalAmount <= 0
                              ? null
                              : () {
                                  Get.to(EsewaPaymentScreen());
                                },
                          child: const Text("Check Out"),
                        ),
                      ],
                    ),
                  ),
                ),
                FlatButton(
                    onPressed: ordersData.totalAmount <= 0
                        ? null
                        : () async {
                            try {
                              await Provider.of<Orders>(context, listen: false)
                                  .removeAllOrders();
                            } catch (err) {
                              print(err.toString());
                            }
                          },
                    child: const Text("Remove Orders")),
                Consumer<Orders>(
                  builder: (ctx, ordersData, child) {
                    return ordersData.orders.isEmpty
                        ? const Center(
                            child: Text("No order has been placed"),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: ordersData.orders.length,
                              itemBuilder: (ctx, index) => OrderItem(
                                ordersData.orders[index],
                              ),
                            ),
                          );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
