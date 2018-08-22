import 'package:woo_flutter/model/woo_commerce_image.dart';

class Category {
  int id;
  String name;
  int parent;
  String description;
  WooCommerceImage image;
  int count;

  Category(
      {this.id,
      this.name,
      this.parent,
      this.description,
      this.image,
      this.count});
}
