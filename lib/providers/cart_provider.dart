import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  int get quantityCount {
    int count = 0;
    if (_items.length > 0) {
      _items.forEach((key, cartItem) {
        count = count + cartItem.quantity;
      });
    }
    return count;
  }

  double get totalPrice {
    var total = 0.0;
    if (_items.length > 0) {
      _items.forEach((key, cartItem) {
        total = total + (cartItem.price * cartItem.quantity);
      });
    }
    return total;
  }

  void addItem({
    String productId,
    double price,
    String title,
  }) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            quantity: existingCartItem.quantity + 1,
            price: existingCartItem.price),
      );
    }
    {
      _items.putIfAbsent(
        productId,
        () => CartItem(
            id: DateTime.now().toString(),
            title: title,
            quantity: 1,
            price: price),
      );
    }

    notifyListeners();
  }

  void removeItem({String productId}) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleQuantity({String productId}) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId].quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity - 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  ////////////////////// class ended /////////////
}
