import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import 'dart:convert';
import './product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> _items = [
    //   Product(
    //     id: 'p1',
    //     title: 'Red Shirt',
    //     description: 'A red shirt - it is pretty red!',
    //     price: 29.99,
    //     imageUrl:
    //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //   ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

/**shouldn't do it here as it would affect all the screens. do it in specific screen/widget */
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }

    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  // var type = "default";
  // String get getType {
  //   return type;
  // }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://shopping-flutter-7dd86-default-rtdb.firebaseio.com/products.json?auth=$authToken$filterString');
    try {
      final response = await http.get(url);
      //print(response.body);
      //type = "${response.body.runtimeType.toString()}:${json.encode(response.body)}";

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }

      //Fetching favorite status
      final favoriteUrl = Uri.parse(
          'https://shopping-flutter-7dd86-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(favoriteUrl);
      final favoriteData = json.decode(favoriteResponse.body);

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: json.encode(prodData['title']).replaceAll('"', ''),
            description:
                json.encode(prodData['description']).replaceAll('"', ''),
            imageUrl: json.encode(prodData['imageUrl']).replaceAll('"', ''),
            price: prodData['price'] as double,
            isFavorite: favoriteData == null
                ? false
                //if favoriteData[prodId] is null (??), assign default value
                : (favoriteData[prodId] as bool) ?? false));
      });

      _items = loadedProducts;

      /**For testing. need to add more products in Firebase */
      // final tempList = _items;
      // _items = loadedProducts;
      // _items.addAll(tempList);
      /**END */
      notifyListeners();
    } catch (error) {
      print("fetchAndSetProducts error :: $error");
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    // final url = Uri.https(
    //     'https://shopping-flutter-7dd86-default-rtdb.firebaseio.com',
    //     '/products.json');
    final url = Uri.parse(
        'https://shopping-flutter-7dd86-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    //TEST error handling by removing ".json" from the url
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId
          }));

      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)['name']);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Future<void> addProduct(Product product) {
  //   // final url = Uri.https(
  //   //     'https://shopping-flutter-7dd86-default-rtdb.firebaseio.com',
  //   //     '/products.json');
  //   final url = Uri.parse(
  //       'https://shopping-flutter-7dd86-default-rtdb.firebaseio.com/products.json');
  //       //TEST error handling by removing ".json" from the url
  //   return http
  //       .post(url,
  //           body: json.encode({
  //             'title': product.title,
  //             'description': product.description,
  //             'imageUrl': product.imageUrl,
  //             'price': product.price,
  //             'isFavorite': product.isFavorite
  //           }))
  //       .then((response) {
  //     final newProduct = Product(
  //         title: product.title,
  //         description: product.description,
  //         price: product.price,
  //         imageUrl: product.imageUrl,
  //         id: json.decode(response.body)['name']);
  //     _items.add(newProduct);
  //     notifyListeners();
  //   }).catchError((error) {
  //     print(error);
  //     throw error;
  //   });
  // }

  Future<void> updateProduct(Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == newProduct.id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://shopping-flutter-7dd86-default-rtdb.firebaseio.com/products/${newProduct.id}.json?auth=$authToken');
      try {
        await http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price
            }));

        _items[prodIndex] = newProduct;
      } catch (error) {
        throw error;
      } finally {
        notifyListeners();
      }
    } else {
      //handle the case
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shopping-flutter-7dd86-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

    /**optimistic updating*/
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      /**Can't use catchError() by default as ONLY HTTP GET & POST throw error.
       * Hence throwing from then block.
       * So, need to use HTTP status code */
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product.");
    }

    //else...
    existingProduct = null;
  }
}
