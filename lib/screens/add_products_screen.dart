import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/providers/product.dart';
import 'package:myapp/providers/products.dart';
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);
  static const routeName = "/add-products";

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formkey = GlobalKey<FormState>();
  final _priceFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  var _newProduct = Product(
    id: "",
    title: "",
    description: "",
    price: 0,
    imageUrl: "",
  );

  bool _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formkey.currentState!.validate();
    if (isValid) {
      _formkey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_newProduct);
      } catch (error) {
        print("this error is from add_products" + error.toString());
        await showDialog<void>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text("An error occured!"),
            content: const Text("Something went wrong!"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Okay"),
              )
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Products"),
        actions: [
          IconButton(
            iconSize: 30,
            onPressed: () {
              _saveForm();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter a title";
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: "Title",
                        ),
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_priceFocusNode),
                        onSaved: (value) {
                          _newProduct = Product(
                            id: _newProduct.id,
                            title: value.toString(),
                            description: _newProduct.description,
                            price: _newProduct.price,
                            imageUrl: _newProduct.imageUrl,
                            isFavourtie: _newProduct.isFavourtie,
                          );
                        },
                      ),
                      TextFormField(
                        validator: ((value) {
                          if (value == null || value == "") {
                            return "Enter Price";
                          }
                          return null;
                        }),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: "Price",
                        ),
                        onSaved: (value) {
                          _newProduct = Product(
                            id: _newProduct.id,
                            title: _newProduct.title,
                            description: _newProduct.description,
                            price: double.parse(value.toString()),
                            imageUrl: _newProduct.imageUrl,
                            isFavourtie: _newProduct.isFavourtie,
                          );
                        },
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter a description";
                          }
                          return null;
                        },
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: "Description",
                        ),
                        onSaved: (value) {
                          _newProduct = Product(
                            id: _newProduct.id,
                            title: _newProduct.title,
                            description: value.toString(),
                            price: _newProduct.price,
                            imageUrl: _newProduct.imageUrl,
                            isFavourtie: _newProduct.isFavourtie,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: Container(
                              child: _imageUrlController.text.isEmpty
                                  ? const Text("")
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter a Url";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _newProduct = Product(
                                  id: _newProduct.id,
                                  title: _newProduct.title,
                                  description: _newProduct.description,
                                  price: _newProduct.price,
                                  imageUrl: value.toString(),
                                );
                              },
                              //initialValue: _imageUrlController.text,
                              decoration:
                                  InputDecoration(labelText: "Image Url"),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) => {
                                _saveForm(),
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
    );
  }
}
