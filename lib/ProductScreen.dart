import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:gifthub_2021a/user_repository.dart';
import 'package:provider/provider.dart';
import 'globals.dart' as globals;
import 'package:gifthub_2021a/StoreScreen.dart';

class ProductMock {
  String _userId;
  String _name;
  double _price;
  String _date;
  List _reviews = <ReviewMock>[];
  String _category;
  String _description;

  String get user => _userId;
  String get name => _name;
  double get price => _price;
  String get date => _date;
  List get reviews => _reviews;
  String get category => _category;
  String get description => _description;

  ProductMock(String userId, String name, double price, String date, List reviews, String category, String description)
      : _userId = userId, _name = name, _price = price, _date = date, _reviews = reviews, _category = category, _description = description;

}

class ReviewMock {
  String _userName;
  double _rating;
  String _content;

  ReviewMock(String userName, double rating, String content) : _userName = userName, _rating = rating, _content = content ;

  ReviewMock.fromDoc(DocumentSnapshot doc) {
    var reviewArgs = doc.data();
    _userName = reviewArgs['user'];
    _rating = double.parse(reviewArgs['rating']);
    _content = reviewArgs['content'];
  }

  String get userName => _userName;
  double get rating => _rating;
  String get content => _content;

}

class ProductScreen extends StatefulWidget {
  String _productId;

  ProductScreen(String productId, {Key key}) : /*_productId = productId,*/ super(key: key){
    _productId = "0";
  }

  @override
  _ProductScreenState createState() => _ProductScreenState(_productId);
}

class _ProductScreenState extends State<ProductScreen> {
  String _productId;
  globals.Product _prod;
  bool editingMode = false;
  final List controllers = <TextEditingController>[TextEditingController(), TextEditingController(), TextEditingController()];


  _ProductScreenState(String productId) : _productId = productId;

  void _initProductArgs(DocumentSnapshot doc) {
    var _prodArgs = doc.data()['Product'];
    _prod = globals.Product(
        _productId,
        _prodArgs['user'],
        _prodArgs['name'],
        double.parse(_prodArgs['price']),
        _prodArgs['date'],
        _prodArgs['reviews'],
        _prodArgs['category'],
        _prodArgs['description']);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
        builder: (context, userRep, _) {
          return FutureBuilder(
              future: (() async {
                var prodDoc = userRep.firestore.collection('Products').doc(_productId);
                int i = 12;
                _initProductArgs(await prodDoc.get());
              })(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.done) {
                  int j = 0;
                  return Material(
                      color: Colors.lightGreen,
                      child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        resizeToAvoidBottomPadding: false,
                        backgroundColor: Colors.lightGreen[600],
                        appBar: AppBar(
                          backgroundColor: Colors.lightGreen[900],
                          leading: IconButton(
                              icon: Icon(Icons.menu),
                              onPressed: () {} //TODO: implement navigation drawer
                          ),
                          title: editingMode?
                              TextField(
                                controller: controllers[0],
                                style: globals.niceFont(),
                              )
                              : Text(_prod.name),
                          actions: /*userRep.status == Status.Authenticated && _storeId == userRep.user.uid*/ true ?
                          editingMode ? [IconButton(icon: Icon(Icons.save_outlined), onPressed: () async {
                            await userRep.firestore.collection('Products').doc(_productId).get().then((snapshot) async {
                              var prodArgs = snapshot['Product'];
                              prodArgs['name'] = controllers[0].text;
                              prodArgs['description'] = controllers[1].text;
                              prodArgs['price'] = controllers[2].text;
                              await userRep.firestore.collection('Products').doc(_productId).update({'Product': prodArgs});
                            });
                            setState(() {
                              editingMode = false;
                            });
                          },)
                          ]
                              : [
                            IconButton(icon: Icon(Icons.edit_outlined), onPressed: () async {
                              await userRep.firestore.collection('Products').doc(_productId).get().then((snapshot) {
                                var prodArgs = snapshot['Product'];
                                setState(() {
                                  controllers[0].text = prodArgs['name'];
                                  controllers[1].text = prodArgs['description'];
                                  controllers[2].text = prodArgs['price'];
                                  editingMode = true;
                                });
                              });
                            }),
                          ] : [],
                        ),

                        body: SingleChildScrollView(
                          child: Column(
                            children: [
                              Image(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                image: AssetImage('assets/images/birthday_cake.jpg'),
                              ),
                              SizedBox(height: 20.0),
                              editingMode?
                              TextField(
                                controller: controllers[2],
                                style: globals.niceFont(),
                              )
                                  : Text(
                                '\$' + _prod.price.toString(),
                                style: globals.niceFont(size: 20.0),
                              ),
                              SizedBox(height: 10.0),
                              editingMode?
                              TextField(
                                controller: controllers[1],
                                style: globals.niceFont(),
                              )
                                  : Text(
                                _prod.description,
                                style: globals.niceFont(size: 14.0),
                              ),
                              SizedBox(height: 10.0),
                              InkWell(
                                child: Text("Visit seller", style: globals.niceFont(size: 14.0, color: Colors.red[900]),),
                                onTap: () => {Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoreScreen(_prod.user)))},
                              ),
                              SizedBox(height: 20.0),
                              globals.fixedStarBar(4.0),
                              SizedBox(height: 20.0),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    globals.regTextButton("Contact Seller", icon: Icon(Icons.mail_outline), buttonColor: Colors.white, textColor: Colors.red, press: () {}), // TODO add "contact seller" function
                                    globals.regTextButton("Add to Cart", icon: Icon(Icons.add_shopping_cart_outlined), press: () {
                                      globals.userCart.add(_prod);
                                    }),
                                  ]
                              )
                            ],
                          ),
                        ),
                      )
                  );
                }
                return globals.emptyLoadingScaffold();
              });
        }
    );
  }
}
