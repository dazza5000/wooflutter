import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:woo_flutter/model/any_image.dart';
import 'package:woo_flutter/model/category.dart';
import 'package:woo_flutter/model/product.dart';
import 'package:woo_flutter/util/remoteconfig.dart';
import 'package:woo_flutter/widgets/products_list_item.dart';

class ProductsListPage extends StatelessWidget {
  BuildContext context;

  @override
  Widget build(BuildContext context) {
    this.context = context;

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
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      color: Colors.grey[100],
      child: FutureBuilder<List<Product>>(
        future: _parseProductsFromResponse(95),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:

            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());

            case ConnectionState.none:
              return Center(child: Text("Unable to connect right now"));

            case ConnectionState.done:
              return ListView.builder(
                itemCount: 0,
                itemBuilder: (context, index) {
                  if (index % 2 == 0) {
                    //2nd, 4th, 6th.. index would contain nothing since this would
                    //be handled by the odd indexes where the row contains 2 items
                    return Container();
                  } else {
                    //1st, 3rd, 5th.. index would contain a row containing 2 products
                    return ProductsListItem(
                      product1: snapshot.data[index - 1],
                      product2: snapshot.data[index],
                    );
                  }
                },
              );
          }
        },
      ),
    );
  }

  Future<dynamic> _getProductsByCategory(categoryId, pageIndex) async {
    var response = await http.get(
      RemoteConfig.config["BASE_URL"] +
          RemoteConfig.config["BASE_PRODUCTS_URL"] +
          "&category=$categoryId&per_page=6&page=$pageIndex",
      headers: {
        "Authorization": RemoteConfig.config["AuthorizationToken"],
      },
    ).catchError(
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
        //parse the product's images
        List<AnyImage> imagesOfProductList = [];

        newProduct["images"].forEach(
              (newImage) {
            imagesOfProductList.add(
              new AnyImage(
                imageURL: newImage["src"],
                id: newImage["id"],
                title: newImage["name"],
                alt: newImage["alt"],
              ),
            );
          },
        );

        //parse the product's categories
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

        //parse new product's details
        Product product = new Product(
          productId: newProduct["id"],
          productName: newProduct["name"],
          description: newProduct["description"],
          regularPrice: newProduct["regular_price"],
          salePrice: newProduct["sale_price"],
          stockQuantity: newProduct["stock_quantity"] != null
              ? newProduct["stock_quantity"]
              : 0,
          ifItemAvailable: newProduct["on_sale"] &&
              newProduct["purchasable"] &&
              newProduct["in_stock"],
          discount: ((((int.parse(newProduct["regular_price"]) -
              int.parse(newProduct["sale_price"])) /
              (int.parse(newProduct["regular_price"]))) *
              100))
              .round(),
          images: imagesOfProductList,
          categories: categoriesOfProductList,
        );

        productsList.add(product);
      },
    );

    return productsList;
  }
}


