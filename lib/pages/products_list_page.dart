import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:woo_flutter/model/woo_commerce_image.dart';
import 'package:woo_flutter/model/category.dart';
import 'package:woo_flutter/model/product.dart';
import 'package:woo_flutter/util/remoteconfig.dart';
import 'package:woo_flutter/widgets/products_list_item.dart';

class ProductsListPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "PRODUCT LIST",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: _buildProductsListPage(),
    );
  }

  _buildProductsListPage() {
    return Container(
      color: Colors.grey[100],
      child: FutureBuilder<List<Product>>(
        future: _parseProductsFromResponse(0),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:

            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());

            case ConnectionState.none:
              return Center(child: Text("No Connection"));

            case ConnectionState.done:
              return GridView.builder(
                scrollDirection: Axis.vertical,
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: .8,
                    crossAxisCount: 2),
                itemCount: snapshot.data == null ? 0 : snapshot.data.length,
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                itemBuilder: (context, index) {
                  return ProductsListItem(
                    product1: snapshot.data[index],
                  );
                },
              );
          }
        },
      ),
    );
  }

  Future<dynamic> _getProductsByCategory(categoryId, pageIndex) async {
    var response = await http
        .get(
      RemoteConfig.config["BASE_URL"] +
          RemoteConfig.config["BASE_PRODUCTS_URL"] +
          "?" +
          RemoteConfig.getAuthorizationParameterString() +
          "&categoryId=$categoryId&per_page=6&page=$pageIndex",
    )
        .catchError(
          (error) {
        return false;
      },
    );

    return json.decode(response.body);
  }

  Future<List<Product>> _parseProductsFromResponse(int categoryId) async {
    List<Product> productsList = <Product>[];

    var dataFromResponse = await _getProductsByCategory(categoryId, 1);

    dataFromResponse.forEach(
          (newProduct) {

        List<WooCommerceImage> imagesOfProductList = [];

        newProduct["images"].forEach(
              (newImage) {
            imagesOfProductList.add(
              new WooCommerceImage(
                imageURL: newImage["src"],
                id: newImage["id"],
                title: newImage["name"],
                alt: newImage["alt"],
              ),
            );
          },
        );

        List<Category> categoriesOfProductList = [];

        newProduct["categories"].forEach(
              (newCategory) {
            categoriesOfProductList.add(
              new Category(
                id: newCategory["id"],
                name: newCategory["name"],
              ),
            );
          },
        );

        Product product = new Product(
          productId: newProduct["id"],
          productName: newProduct["name"],
          description: newProduct["description"],
          regularPrice: newProduct["regular_price"],
          salePrice: newProduct["sale_price"],
          stockQuantity: newProduct["stock_quantity"] != null
              ? newProduct["stock_quantity"]
              : 0,
          ifItemAvailable: newProduct["purchasable"] &&
              newProduct["in_stock"],
          discount: _getDiscountForProduct(newProduct),
          images: imagesOfProductList,
          categories: categoriesOfProductList,
        );

        productsList.add(product);
      },
    );

    return productsList;
  }

  int _getDiscountForProduct(dynamic newProduct) {

    int salePrice = 0;
    String salePriceString = newProduct["sale_price"];
    if (salePriceString.isEmpty) {
      salePrice = 0;
    } else {
      salePrice = int.parse(salePriceString);
    }

    int regularPrice = int.parse(newProduct["regular_price"]);
    int discount = regularPrice - salePrice;
    int discountPercent = (discount / regularPrice * 100).round();
    return discountPercent;
  }
}
