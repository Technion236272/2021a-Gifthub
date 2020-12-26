library gifthub.globals;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'my_flutter_app_icons.dart';

class Product {
  String _productId;
  String _userId;
  String _name;
  double _price;
  String _date;
  List _reviews = <Review>[];
  String _category;
  String _description;

  String get productId => _productId;
  String get user => _userId;
  String get name => _name;
  double get price => _price;
  String get date => _date;
  List get reviews => _reviews;
  String get category => _category;
  String get description => _description;

  Product(String prodId, String userId, String name, double price, String date, List reviews, String category, String description)
      : _productId = prodId, _userId = userId, _name = name, _price = price, _date = date, _category = category, _description = description {
    _reviews = reviews.map<Review>((v) =>
        Review(v['user'], double.parse(v['rating']), v['content'])
    ).toList();
  }

  Product.fromDoc(DocumentSnapshot doc) {
    _productId = doc.id;
    var prodArgs = doc.data();
    _userId = prodArgs['user'];
    _name = prodArgs['name'];
    _price = double.parse(prodArgs['price']);
    _date = prodArgs['date'];
    _reviews = prodArgs['reviews'].map<Review>((r) => Review(r['user'], double.parse(r['rating']), r['content'])).toList();
    _category = prodArgs['user'];
    _description = prodArgs['user'];
  }

}

class Review {
  String _userName;
  double _rating;
  String _content;

  Review(String userName, double rating, String content) : _userName = userName, _rating = rating, _content = content ;

  Review.fromDoc(DocumentSnapshot doc) {
    var reviewArgs = doc.data();
    _userName = reviewArgs['user'];
    _rating = double.parse(reviewArgs['rating']);
    _content = reviewArgs['content'];
  }

  String get userName => _userName;
  double get rating => _rating;
  String get content => _content;

}

List userCart;

final List<String> categories = ['', 'Cakes', 'Chocolate', 'Balloons', 'Flowers', 'Greeting Cards','Gift Cards', 'Other'];

var gifthub_logo = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Icon(
        GiftHubIcons.gift,
        color: Colors.red,
        size: 100,
      ),
      Text(
        'GiftHub',
        style: TextStyle(
            fontSize: 24,
            fontFamily: 'TimesNewRoman',
            fontWeight: FontWeight.bold),
      )
    ]);

TextStyle niceFont({double size= 16.0, Color color=Colors.white}) {
  return GoogleFonts.montserrat(
    fontSize: size,
    color: color,
  );
}

TextStyle calistogaFont({double size = 24.0, Color color=Colors.white}) {
  return GoogleFonts.calistoga(
    fontSize: size,
    color: color,
  );
}
RatingBar fixedStarBar(double rate, {Color color= Colors.red, double itemSize = 40.0}) {
  return RatingBar(
    initialRating: rate,
    direction: Axis.horizontal,
    allowHalfRating: true,
    ignoreGestures: true,
    itemSize: itemSize,
    ratingWidget: RatingWidget(
      full: Icon(Icons.star, color: color),
      half: Icon(Icons.star_half, color: color),
      empty: Icon(Icons.star_border, color: color),
    ),
    onRatingUpdate: (rating) {},
    itemPadding: EdgeInsets.zero,
  );
}

RatingBar changingStarBar(double rate, {Color color= Colors.red, double itemSize = 40.0, Function onUpdate = null}) {
  return RatingBar.builder(
      initialRating: rate,
      itemCount: 5,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemSize: itemSize,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, __) {
        return Icon(
          Icons.star,
          color: color,
        );
      },
      onRatingUpdate: onUpdate,
  );
}

RaisedButton regTextButton(String text, {Icon icon=null, Function press=null, Color buttonColor=Colors.red, Color textColor=Colors.white}) {
  return RaisedButton(
      elevation: 15.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: Colors.transparent),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      color: buttonColor,
      textColor: textColor,
      onPressed: press == null ? () {} : press,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: icon == null ? [Text(text)] : [icon, Text(text)],
      )
  );
}

class Constants{
  Constants._();
  static const double padding =20;
  static const double avatarRadius =45;
}

Scaffold emptyLoadingScaffold() {
  return Scaffold(
    backgroundColor: Colors.lightGreen[600],
    appBar: AppBar(
      backgroundColor: Colors.lightGreen[800],
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {},
      ),
      title: Text("Loading...", style: calistogaFont(),),
    ),

    body: Center(child: CircularProgressIndicator()),
  );
}

Scaffold emptyErrorScaffold(String error) {
  return Scaffold(
    backgroundColor: Colors.lightGreen[600],
    appBar: AppBar(
      backgroundColor: Colors.lightGreen[800],
      title: Text("Error", style: calistogaFont(),),
    ),

    body: Center(child: Text("The app ran into an error:\n" + error, style: niceFont(), textAlign: TextAlign.center,)),
  );
}