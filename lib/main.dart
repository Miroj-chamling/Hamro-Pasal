import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/providers/auth.dart';
import 'package:myapp/providers/cart.dart';
import 'package:myapp/providers/orders.dart';
import 'package:myapp/providers/products.dart';
import 'package:myapp/screens/add_products_screen.dart';
import 'package:myapp/screens/auth_screen.dart';
import 'package:myapp/screens/cart_screen.dart';
import 'package:myapp/screens/edit_product_screen.dart';
import 'package:myapp/screens/esewa_payment_screen.dart';
import 'package:myapp/screens/orders_screen.dart';
import 'package:myapp/screens/product_detail_screen.dart';
import 'package:myapp/screens/products_overview.dart';
import 'package:myapp/screens/user_product_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products("", "", []),
          update: (context, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders("", [], ""),
          update: (context, auth, previousOrders) => Orders(
            auth.token,
            previousOrders == null ? [] : previousOrders.orders,
            auth.userId,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Student List',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              //:
              // FutureBuilder(
              //     future: auth.autoLogin(),
              //     builder: (ctx, authResultSnapshot) =>
              //         authResultSnapshot.connectionState ==
              //                 ConnectionState.waiting
              //             ? Center(
              //                 child: Text(auth.autoLogin().toString()),
              //              )
              : AuthScreen(),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrderScreen.routeName: (context) => OrderScreen(),
            UserProductScreen.routeName: (context) => UserProductScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
            AddProductScreen.routeName: (context) => AddProductScreen(),
            EsewaPaymentScreen.routeName: (context) => EsewaPaymentScreen(),
          },
        ),
      ),
    );
  }
}
