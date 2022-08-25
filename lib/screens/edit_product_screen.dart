import 'package:flutter/material.dart';
import 'package:myapp/providers/product.dart';
import 'package:myapp/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);

  static const routeName = "/edit-product";

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  final TextEditingController _imageUrlController = TextEditingController();
  bool _isFav = false;
  bool _isLoading = false;
  var _editedProduct = Product(
    id: "",
    title: "",
    description: "",
    price: 0,
    imageUrl: "",
  );
  var _intiValues = {
    "id": "",
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };

  var _isInit = true;

  @override
  void initState() {
    _imageUrlController.addListener(updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final id = ModalRoute.of(context)!.settings.arguments as String;
      final _editedProduct =
          Provider.of<Products>(context).findById(id.toString());
      _intiValues = {
        "id": _editedProduct.id,
        "title": _editedProduct.title,
        "description": _editedProduct.description,
        "price": _editedProduct.price.toString(),
        "imageUrl": "",
      };
      _isFav = _editedProduct.isFavourtie;
      _imageUrlController.text = _editedProduct.imageUrl;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlController.removeListener(updateImageUrl);
    _priceFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    if (_form.currentState!.validate()) {
      _form.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Products>(context, listen: false)
          .updateProducts(_editedProduct.id, _editedProduct);

      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            onPressed: () {
              _saveForm();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter a title";
                        }
                        return null;
                      },
                      initialValue: _intiValues["title"],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Title",
                      ),
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocusNode),
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _intiValues["id"].toString(),
                          title: value.toString(),
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavourtie: _isFav,
                        );
                      },
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter a price";
                        }
                        return null;
                      },
                      initialValue: _intiValues["price"],
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Price",
                      ),
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _intiValues["id"].toString(),
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(value.toString()),
                          imageUrl: _editedProduct.imageUrl,
                          isFavourtie: _isFav,
                        );
                      },
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Description about the product";
                        }
                        return null;
                      },
                      initialValue: _intiValues["description"],
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _intiValues["id"].toString(),
                          title: _editedProduct.title,
                          description: value.toString(),
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavourtie: _isFav,
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
                                ? Text("")
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
                            //initialValue: _imageUrlController.text,
                            decoration: InputDecoration(labelText: "Image Url"),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _intiValues["id"].toString(),
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: value.toString(),
                                isFavourtie: _isFav,
                              );
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
