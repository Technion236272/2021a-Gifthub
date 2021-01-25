library gifthub.globals;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'my_flutter_app_icons.dart';
import 'package:badges/badges.dart';
import 'checkoutScreen.dart';

/// ------------------------------------------------
/// globals
/// This file contains implementations to some classes,
/// variables and functions that are used widely throughout
/// the app, and it allows us to create app-wide conventions
/// easily.
/// ------------------------------------------------

final appColor = Colors.red;
final mainColor = Colors.green;
final secondaryTextColor = Colors.white;
final secondaryColor=Colors.blue[400];
final darkG=Colors.grey[700];
s50(context) => MediaQuery.of(context).size.width * 0.023 * 6;
s25(context) => s50(context) / 2;
s10(context) => s50(context) / 5;
s5(context) => s10(context) / 2;
///NOTE: font size of 18.0 is usually approx. "MediaQuery.of(context).size.height * 0.0256"

const Map falseOptions = {'wrapping': false, 'greeting': false, 'fast': false};

class Product {
  String _productId;
  String _userId;
  String _name;
  double _price;
  String _date;
  List _reviews = <Review>[];
  String _category;
  String _description;
  Map _options = falseOptions;

  String get productId => _productId;
  String get user => _userId;
  String get name => _name;
  double get price => _price;
  String get date => _date;
  List get reviews => _reviews;
  String get category => _category;
  String get description => _description;
  Map get options => _options;
  set options(dict) { _options = dict;}

  Product(String prodId, String userId, String name, double price, String date, List reviews, String category, String description, Map options)
      : _productId = prodId, _userId = userId, _name = name, _price = price, _date = date, _category = category, _description = description, _options = options {
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

  @override
  bool operator==(Object o) {
    if(o is! Product){
      return false;
    }
    Product prod = o;
    return this.productId == prod.productId;
  }

  @override
  int get hashCode => super.hashCode;

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

List<Product> userCart;
List<Map> userCartOptions;

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
  return GoogleFonts.lato(
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

///returns a green Circular Progress Indicator
Center greenCircularProgressIndicator(double height, double width) {
  return Center(
    child: SizedBox(
      width: width,
      height: height,
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightGreen[800]),
      )
    ),
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

/// decorated screen upon empty WishList or Orders list
/// displays GiftHub's logo with a star and an informative text to the user
Widget emptyListErrorScreen(BuildContext context, String list) {
  return Scaffold(
    appBar: 'Orders ' == list ? null
    : AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0.0,
      backgroundColor: Colors.lightGreen[800],
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        iconSize: 27.0,
      ),
      title: Text("Wish List",
        style: GoogleFonts.calistoga(
          fontSize: 33,
          color: Colors.white
        ),
        textAlign: TextAlign.center,
      ),
    ),
    body: Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 0.35,
            color: Colors.lightGreen[800],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FittedBox(
                  child: Center(
                    child: Icon(
                      Icons.star,
                      color: Colors.lightGreenAccent,
                      size: MediaQuery.of(context).size.height *
                          0.065 *
                          3.3 *
                          2.1 * 3,
                    )
                  ),
                ),
                Center(
                  child: Icon(
                    GiftHubIcons.gift,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.height * 0.065 * 2,
                  ),
                ),
                Align(
                  alignment: FractionalOffset.center,
                  child: Text(
                    "Oops!\n\n It looks like your " + list + (list == 'Orders ' ? "list is empty!\n" : " is empty!\n") +
                        "\nGo gifting now to fill your " + list + "!",
                    style: niceFont(
                      color: Colors.black,
                      size: 18.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ]
            ),
          ),
        ),
      ]
    ),
  );
}
/// decorated screen upon empty search result of categories
/// displays GiftHub's logo with a star and an informative text to the user
Stack emptyListOfCategories (BuildContext context, String category) {
  return Stack(
    alignment: Alignment.center,
    children: [
      FittedBox(
        child: Center(
            child: Icon(
              Icons.star,
              color: Colors.lightGreenAccent,
              size: MediaQuery.of(context).size.height *
                  0.065 *
                  3.3 *
                  2.1 * 5,
            )
        ),
      ),
      Center(
        child: Icon(
          GiftHubIcons.gift,
          color: Colors.white,
          size: MediaQuery.of(context).size.height * 0.065 * 2,
        ),
      ),
      Align(
        alignment: FractionalOffset.center,
        child: Text(
          "Oops!\n\n "
          "It looks like there are no products\n"
              "under " + category + " category!\n",
          style: niceFont(
              color: Colors.black,
              size: 18.0
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ]
  );
}