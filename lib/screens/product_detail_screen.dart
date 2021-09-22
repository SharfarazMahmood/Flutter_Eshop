import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product_detail';
  final Product product;
  // final String id;
  // final String title;
  // final String imageUrl;

  const ProductDetailScreen({this.product});

  @override
  Widget build(BuildContext context) {
    ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
    );
  }
}
