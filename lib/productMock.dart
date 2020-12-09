import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

enum OrderStatus { Ordered, Pending, Confirmed, Arrived }

class Product with ChangeNotifier {
  String _name;
  double _price;
  String _dateOfOrder;
  OrderStatus _orderStatus;
  String _productPictureURL;

  Product(this._name, this._price, this._orderStatus, this._productPictureURL){
    _dateOfOrder = new DateFormat("dd-MM-yyyy").format(DateTime.now());
  }

  String get dateOfOrder => _dateOfOrder;

  set dateOfOrder(String value) {
    _dateOfOrder = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  double get price => _price;

  set price(double value) {
    _price = value;
  }


  OrderStatus get orderStatus => _orderStatus;

  set orderStatus(OrderStatus value) {
    _orderStatus = value;
  }

  String get productPictureURL => _productPictureURL;

  set productPictureURL(String value) {
    _productPictureURL = value;
  }
}