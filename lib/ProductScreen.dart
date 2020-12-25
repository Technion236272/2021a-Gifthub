import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:gifthub_2021a/user_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
  final _productId;

  ProductScreen(String productId, {Key key}) : _productId = productId, super(key: key);
  @override
  _ProductScreenState createState() => _ProductScreenState(_productId);
}

class _ProductScreenState extends State<ProductScreen> {
  String _productId;
  globals.Product _prod;
  String _productImageURL;
  NetworkImage _productImage;
  Size _productImageSize;
  bool editingMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKeyProductScreenSet = new GlobalKey<ScaffoldState>();
  final List controllers = <TextEditingController>[TextEditingController(), TextEditingController(), TextEditingController()];


  _ProductScreenState(String productId) : _productId = productId;

  Future<void> _initProductArgs(DocumentSnapshot doc) async {
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
    Completer<Size> completer = Completer<Size>();
    try {
      _productImageURL = await FirebaseStorage.instance.ref().child('productImages/' + _productId).getDownloadURL();
      _productImage = NetworkImage(_productImageURL);
      _productImage.resolve(ImageConfiguration()).addListener(ImageStreamListener(
              (i, b) {
            completer.complete(Size(i.image.width.toDouble(), i.image.height.toDouble()));
          }
      ));
    } catch (e) {
      _productImageURL = null;
      _productImage = null;
      Image
          .asset('Assets/Untitled.png')
          .image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener(
              (i, b) {
            completer.complete(Size(i.image.width.toDouble(), i.image.height.toDouble()));
          }
      ));
    } finally {
      _productImageSize = await completer.future;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
        builder: (context, userRep, _) {
          return FutureBuilder(
              future: (() async {
                var prodDoc = userRep.firestore.collection('Products').doc(_productId);
                await _initProductArgs(await prodDoc.get());
              })(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.done) {
                  return Material(
                      color: Colors.lightGreen,
                      child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        resizeToAvoidBottomPadding: false,
                        backgroundColor: Colors.lightGreen[600],
                        appBar: AppBar(
                          backgroundColor: Colors.lightGreen[800],
                          title: editingMode?
                              TextField(
                                controller: controllers[0],
                                style: globals.calistogaFont(),
                              )
                              : Text(_prod.name, style: globals.calistogaFont(),),
                          actions: userRep.status == Status.Authenticated && _prod.user == userRep.user.uid ?
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
                              editingMode?
                              InkWell(
                                onLongPress: () async {
                                  PickedFile photo = await ImagePicker().getImage(source: ImageSource.gallery);
                                  if (null == photo) {
                                    _scaffoldKeyProductScreenSet.currentState.showSnackBar(
                                        SnackBar(
                                          content: Text("No image selected",
                                            style: GoogleFonts.notoSans(fontSize: 14.0),
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(milliseconds: 2500),
                                        )
                                    );
                                  } else {
                                    await FirebaseStorage.instance.ref().child('productImages/' + _productId).putFile(File(photo.path));
                                    setState(() { });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 5),
                                  ),
                                  child: Image(
                                    image: _productImage != null ? _productImage : AssetImage('Assets/Untitled.png'),
                                    width: min(min(MediaQuery
                                        .of(context).size.width, _productImageSize.width), MediaQuery.of(context).size.height * 0.25),
                                  ),
                                ),)
                                  : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 5),
                                ),
                                child: Image(
                                  width: min(min(MediaQuery.of(context).size.width, _productImageSize.width), MediaQuery.of(context).size.height * 0.25),
                                  image: _productImage != null ? _productImage : AssetImage('Assets/Untitled.png'),
                                ),
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
