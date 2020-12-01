import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

enum OrderStatus { Ordered, Pending, Confirmed, Arrived }

class Product with ChangeNotifier {
  String _name;
  double _price;
  DateFormat _dateOfOrder;

  Product(this._name, this._price, this._orderStatus, this._productPictureURL){
    _dateOfOrder = new DateFormat("dd-MM-yyyy");
  }

  OrderStatus _orderStatus;
  String _productPictureURL;

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  double get price => _price;

  set price(double value) {
    _price = value;
  }

  DateFormat get dateOfOrder => _dateOfOrder;

  set dateOfOrder(DateFormat value) {
    _dateOfOrder = value;
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