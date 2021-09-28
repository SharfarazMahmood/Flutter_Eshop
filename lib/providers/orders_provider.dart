import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../providers/cart_provider.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class OrderProvider with ChangeNotifier {
  final _serverUrl = 'https://flutter-app-e9af7-default-rtdb.firebaseio.com';
  final _ordersUrl = '/orders';
  final _jsonUrl = '.json';
  final String _tockenSegment = '?auth=';
  final String authToken;

  final String userId;

  List<OrderItem> _orders = [];

  OrderProvider(this._orders, {this.userId, this.authToken});

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    // final ordersUrl = "https://flutter-app-e9af7-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken" ;
    final url = Uri.parse(_serverUrl +
        _ordersUrl +
        '/$userId' +
        _jsonUrl +
        _tockenSegment +
        authToken);

    final response = await http.get(url);
    // print(json.decode(response.body));
    final List<OrderItem> loadedOrders = [];

    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(
      {List<CartItem> cartProducts, double totalPrice}) async {
    final url = Uri.parse(_serverUrl +
        _ordersUrl +
        '/$userId' +
        _jsonUrl +
        _tockenSegment +
        authToken);
    final timeStamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': totalPrice,
        'dateTime': timeStamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: totalPrice,
        products: cartProducts,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }
}
