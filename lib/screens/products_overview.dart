import 'package:flutter/material.dart';
import 'package:myapp/Components/app_drawer.dart';
import 'package:myapp/Components/badge.dart';
import 'package:myapp/Components/product_grid.dart';
import 'package:myapp/providers/cart.dart';
import 'package:myapp/providers/product.dart';
import 'package:myapp/providers/products.dart';
import 'package:myapp/screens/cart_screen.dart';
import 'package:provider/provider.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavorites = false;
  bool _isInit = true;
  bool _isLoading = false;
  String _title = "Hamro Pasal";
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchPorducts().catchError((onError) {
        print("error");
      }).then(
        (_) {
          setState(() {
            _isLoading = false;
          });
        },
      );
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_title),
        actions: [
          PopupMenuButton(
              onSelected: (FilterOptions value) {
                setState(() {
                  if (value == FilterOptions.favorites) {
                    _showFavorites = true;
                    _title = "Favourites";
                    print(_showFavorites);
                  } else {
                    _showFavorites = false;
                    _title = "Hamro Pasal";
                    print("all");
                  }
                });
              },
              icon: const Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    const PopupMenuItem(
                        child: Text("Favourites"),
                        value: FilterOptions.favorites),
                    const PopupMenuItem(
                        child: Text("Show All"), value: FilterOptions.all),
                  ]),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: Icon(Icons.shopping_cart),
              ),
              value: cart.itemCount.toString(),
              color: Colors.red,
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body:
          // FutureBuilder(
          //   future: Provider.of<Products>(context).fetchPorducts(),
          //   builder: (ctx, snapShot) {
          //     if (snapShot.connectionState == ConnectionState.waiting) {
          //       return Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     }
          //     if (snapShot.hasError) {
          //       return Center(
          //         child: Text(
          //             "Opps! Something went wrong, Check your internet connection and try again"),
          //       );
          //     } else {
          //       return Consumer<Products>(builder: (context, productData, child) {
          //         return ProductsGrid(_showFavorites);
          //       });
          //     }
          //   },
          // )
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ProductsGrid(_showFavorites),
    );
  }
}
