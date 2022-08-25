import 'package:flutter/material.dart';
import 'package:myapp/Components/app_drawer.dart';
import 'package:myapp/Components/user_product_item.dart';
import 'package:myapp/providers/products.dart';
import 'package:myapp/screens/add_products_screen.dart';
import 'package:provider/provider.dart';

class UserProductScreen extends StatefulWidget {
  const UserProductScreen({Key? key}) : super(key: key);
  static const routeName = "/user-product-screen";

  @override
  State<UserProductScreen> createState() => _UserProductScreenState();
}

class _UserProductScreenState extends State<UserProductScreen> {
  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchPorducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final product = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Produts"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AddProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (ctx, product, _) => ListView.builder(
                        itemCount: product.items.length,
                        itemBuilder: (context, index) => Column(
                          children: [
                            UserProductItem(
                              product.items[index].id,
                              product.items[index].title,
                              product.items[index].imageUrl,
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
      drawer: AppDrawer(),
    );
  }
}
