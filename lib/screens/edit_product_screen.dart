import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: null, title: "", description: "", price: 0.0, imageUrl: "");
  var _isLoading = false;
  var _isInit = true;
  var _initValues = {
    'title': '',
    'price': '',
    'desc': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context).findById(productId);
        _initValues['title'] = _editedProduct.title;
        _initValues['desc'] = _editedProduct.description;
        _initValues['price'] = _editedProduct.price.toString();
        // _initValues['imageUrl'] = '';

        _imageUrlController.text = _editedProduct.imageUrl;

        // _initValues = {
        //   'title': _editedProduct.title,
        //   'price': _editedProduct.price.toString(),
        //   'desc': _editedProduct.description,
        //   'imageUrl': '',
        // };
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!(_imageUrlController.text.startsWith("http") ||
              _imageUrlController.text.startsWith("https")) ||
          !(_imageUrlController.text.endsWith("png") ||
              _imageUrlController.text.endsWith("jpg") ||
              _imageUrlController.text.endsWith("jpeg"))) {
        return;
      }
      setState(() {});
    }
  }

  void _submitForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) return;

    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("An error occurred!"),
                  content: Text("Something went wrong"),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text("OK"))
                  ],
                ));
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

//test URL:
//https://sites.google.com/a/doversherborn.org/dshs-tanaka-new-zealand/_/rsrc/1467887056914/home/New-Zealand.jpg
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submitForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(
                          labelText: "Title",
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter a title.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: value,
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl,
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite);
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: InputDecoration(
                          labelText: "Price",
                        ),
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter a price.";
                          }
                          if (double.tryParse(value) == null) {
                            return "Please enter a valid number.";
                          }
                          if (double.parse(value) <= 0.0) {
                            return "Please enter a number greater than zero.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: double.parse(value),
                              imageUrl: _editedProduct.imageUrl,
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite);
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      TextFormField(
                        initialValue: _initValues['desc'],
                        decoration: InputDecoration(
                          labelText: "Description",
                        ),
                        maxLines: 3,
                        focusNode: _descriptionFocusNode,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter a description.";
                          }
                          if (value.length < 10) {
                            return "Description should be at least 10 characters.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              description: value,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl,
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite);
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              height: 100,
                              width: 100,
                              margin: const EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.grey)),
                              child: _imageUrlController.text.isEmpty
                                  ? Text("Enter a URL")
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "Image URL",
                              ),
                              keyboardType: TextInputType.url,
                              focusNode: _imageUrlFocusNode,
                              onEditingComplete: () {
                                setState(() {});
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter an image URL.";
                                }
                                if (!(value.startsWith("http") ||
                                    value.startsWith("https"))) {
                                  return "Please enter a valid URL.";
                                }

                                if (!(value.endsWith("png") ||
                                    value.endsWith("jpg") ||
                                    value.endsWith("jpeg"))) {
                                  return "Please enter a valid image URL.";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _editedProduct = Product(
                                    title: _editedProduct.title,
                                    description: _editedProduct.description,
                                    price: _editedProduct.price,
                                    imageUrl: value,
                                    id: _editedProduct.id,
                                    isFavorite: _editedProduct.isFavorite);
                              },
                              onFieldSubmitted: (_) => _submitForm(),
                              controller: _imageUrlController,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
    );
  }

  @override
  void dispose() {
    try {
      _priceFocusNode.dispose();
      _descriptionFocusNode.dispose();
      _imageUrlFocusNode.dispose();

      _imageUrlFocusNode.removeListener(_updateImageUrl);
      _imageUrlController.dispose();
      super.dispose();
    } on Exception catch (_) {}
  }
}
