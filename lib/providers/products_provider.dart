import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import './product.dart';

class ProductsProvider with ChangeNotifier {
  final String _serverUrl =
      'https://flutter-app-e9af7-default-rtdb.firebaseio.com';
  final String _productsUrl = '/products';
  final String _userFavoriteUrl = '/userFavorites';
  final String _jsonUrl = '.json';
  final String _tockenSegment = '?auth=';

  final String authToken;
  final String userId;

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
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
    //   title: 'Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  ProductsProvider(this._items, {this.authToken, this.userId});

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';

    // productUrl = 'https://flutter-app-e9af7-default-rtdb.firebaseio.com/products.json?auth=$authToken&orderBy="creatorId"&equalTo="$userId"' ;
    final productUrl = Uri.parse(_serverUrl +
        _productsUrl +
        _jsonUrl +
        _tockenSegment +
        authToken +
        filterString);

    final favoritesUrl = Uri.parse(_serverUrl +
        _userFavoriteUrl +
        '/$userId' +
        _jsonUrl +
        _tockenSegment +
        authToken);

    try {
      final productsResponse = await http.get(productUrl);
      // print(json.decode(response.body));

      final extractedData =
          json.decode(productsResponse.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      final favoriteResponse = await http.get(favoritesUrl);
      final favoriteData = json.decode(favoriteResponse.body);
      // print(favoriteData);

      final List<Product> loadedProduct = [];
      extractedData.forEach((productId, productData) {
        loadedProduct.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[productId] ?? false,
        ));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    // final url = Uri.parse('https://flutter-update.firebaseio.com/products.json');

    final url = Uri.parse(
        _serverUrl + _productsUrl + _jsonUrl + _tockenSegment + authToken);

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': userId,
        }),
      );
      // print(json.decode(response.body));
      final newProduct = Product(
        // id: DateTime.now().toString(),
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      // print(newProduct.id);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      // print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
      final url = Uri.parse(_serverUrl +
          _productsUrl +
          '/${id}' +
          _jsonUrl +
          _tockenSegment +
          authToken);
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('....');
    }
  }

  // optimistic updating
  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(_serverUrl +
        _productsUrl +
        '/${id}' +
        _jsonUrl +
        _tockenSegment +
        authToken);
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
