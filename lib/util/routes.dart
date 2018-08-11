import 'package:flutter/material.dart';
import 'package:woo_flutter/pages/product_detail_page.dart';
import 'package:woo_flutter/util/constants.dart';


class Routes {
  static final routes = <String, WidgetBuilder>{
    Constants.ROUTE_PRODUCT_DETAIL: (BuildContext context) =>
        ProductDetailPage(),
  };
}
