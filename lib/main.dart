import 'package:flutter/material.dart';
import 'package:woo_flutter/pages/products_list_page.dart';
import 'package:woo_flutter/util/routes.dart';

void main() {
  runApp(
    MaterialApp(
      home: ProductsListPage(),
      routes: Routes.routes,
    ),
  );
}