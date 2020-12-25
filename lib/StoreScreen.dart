import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:gifthub_2021a/ProductScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globals.dart' as globals;
import 'user_repository.dart';
import 'package:device_apps/device_apps.dart';
import 'package:intl/intl.dart';
import 'AllReviewsScreen.dart';
import 'package:tuple/tuple.dart';

class StoreScreen extends StatefulWidget {
  final _storeId;

  StoreScreen(String storeId, {Key key}) : _storeId = storeId, super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState(_storeId);
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  String _storeId;
  String _storeName;
  String _storeImageURL;
  NetworkImage _storeImage;
  Size _storeImageSize;
  String _storeDesc;
  String _storeAddr;
  String _storePhone;
  double _storeRating = 1.0;
  List _products = <globals.Product>[];
  List _reviews = <globals.Review>[];
  bool editingMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKeyUserScreenSet = new GlobalKey<ScaffoldState>();
  final List controllers = <TextEditingController>[TextEditingController(), TextEditingController(), TextEditingController()];
  final reviewCtrl = TextEditingController();

  _StoreScreenState(String storeId) : _storeId = storeId;


  void _initStoreArgs(DocumentSnapshot doc, CollectionReference ref) async {
    var storeArgs = doc.data()['Store'];
    _storeName = storeArgs['name'];
    _storeDesc = storeArgs['description'];
    _storeAddr = storeArgs['address'];
    _storePhone = storeArgs['phone'];
    Completer<Size> completer = Completer<Size>();
    try {
      _storeImageURL = await FirebaseStorage.instance.ref().child('storeImages/' + _storeId).getDownloadURL();
      _storeImage = NetworkImage(_storeImageURL);
      _storeImage.resolve(ImageConfiguration()).addListener(ImageStreamListener(
              (i, b) {
            completer.complete(Size(i.image.width.toDouble(), i.image.height.toDouble()));
          }
      ));
    } catch (e) {
      _storeImageURL = null;
      _storeImage = null;
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
      _storeImageSize = await completer.future;
    }
    _products = <globals.Product>[];
    for (var p in doc.data()['Products']) {
      var prodArgs = (await ref.doc(p).get()).data()['Product'];
      _products.add(globals.Product(
          p,
          prodArgs['user'],
          prodArgs['name'],
          double.parse(prodArgs['price']),
          prodArgs['date'],
          prodArgs['reviews'],
          prodArgs['category'],
          prodArgs['description']));
    }
    _reviews = doc.data()['Reviews'].map<globals.Review>((v) =>
        globals.Review(v['user'], double.parse(v['rating']), v['content'])
    ).toList();
  }

  double _getStoreRating() {
    double sum = 0.0;
    for (globals.Review r in _reviews) {
      sum += r.rating;
    }
    return sum / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
        builder: (context, userRep, _) {
          return FutureBuilder(
              future: (() async {
                var storeDoc = userRep.firestore.collection('Stores').doc(_storeId);
                var prodDoc = userRep.firestore.collection('Products');
                // var doc = await storeDoc.get();
                await _initStoreArgs(await storeDoc.get(), prodDoc);
                _storeRating = _getStoreRating();
              })(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final aboutTab = SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          editingMode ?
                          InkWell(
                            onLongPress: () async {
                              PickedFile photo = await ImagePicker().getImage(source: ImageSource.gallery);
                              // Navigator.pop(_scaffoldKeyUserScreenSet.currentContext);
                              if (null == photo) {
                                _scaffoldKeyUserScreenSet.currentState.showSnackBar(
                                    SnackBar(
                                      content: Text("No image selected",
                                        style: GoogleFonts.notoSans(fontSize: 14.0),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(milliseconds: 2500),
                                    )
                                );
                              } else {
                                await FirebaseStorage.instance.ref().child('storeImages/' + _storeId).putFile(File(photo.path));
                                String s = await FirebaseStorage.instance.ref().child('storeImages/' + _storeId).getDownloadURL();
                                setState(() {
                                  _storeImageURL = s;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 5),
                              ),
                              child: Image(
                                image: _storeImage != null ? _storeImage : AssetImage('Assets/Untitled.png'),
                                width: min(min(MediaQuery
                                    .of(context).size.width, _storeImageSize.width), MediaQuery.of(context).size.height * 0.25),
                              ),
                            ),)
                              : Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 5),
                            ),
                            child: Image(
                              width: min(min(MediaQuery.of(context).size.width, _storeImageSize.width), MediaQuery.of(context).size.height * 0.25),
                              image: _storeImage != null ? _storeImage : AssetImage('Assets/Untitled.png'),
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: editingMode ?
                            TextField(
                              controller: controllers[1],
                              style: globals.niceFont(),
                            )
                                : Text(
                              _storeDesc,
                              textAlign: TextAlign.center,
                              style: globals.niceFont(),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: editingMode ?
                                  TextField(
                                    controller: controllers[2],
                                    style: globals.niceFont(),
                                  )
                                      : Text(_storeAddr,
                                      textAlign: TextAlign.start,
                                      style: globals.niceFont()),
                                ),
                                IconButton(icon: Icon(Icons.navigation, color: Colors.white), onPressed: null),
                                IconButton(icon: Icon(Icons.phone, color: Colors.white), onPressed: () async {
                                  await DeviceApps.openApp('com.android.tel'); // FIXME not working, probably bad package name
                                }),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          globals.fixedStarBar(_storeRating),
                          SizedBox(height: 10),
                          Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.2,
                            child: Expanded(
                              child: ListView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: _reviews.map<ListTile>((r) =>
                                    ListTile(
                                      title: Text(r.content, style: globals.niceFont()),
                                      subtitle: Text(r.userName, style: globals.niceFont(size: 12)),
                                      leading: globals.fixedStarBar(r.rating, itemSize: 18.0,),
                                    ),
                                ).toList(),
                              ),
                            ),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RaisedButton(
                                    elevation: 15.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.transparent),
                                    ),
                                    visualDensity: VisualDensity.adaptivePlatformDensity,
                                    color: Colors.red[900],
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AllReviewsScreen(_reviews)));
                                    },
                                    child: Row(
                                        children: [
                                          Icon(Icons.list_alt),
                                          Text("All ${_reviews.length} Reviews"),
                                        ]
                                    )
                                ),
                                RaisedButton(
                                    elevation: 15.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.transparent),
                                    ),
                                    visualDensity: VisualDensity.adaptivePlatformDensity,
                                    color: Colors.red[900],
                                    textColor: Colors.white,
                                    onPressed: () {
                                      _getReviewBottomSheet();
                                    },
                                    child: Row(
                                        children: [
                                          Icon(Icons.add),
                                          Text("Add Review"),
                                        ]
                                    )
                                ),
                              ]
                          )
                        ]
                    ),
                  );
                  final itemsTab = GridView.count(
                    childAspectRatio: 3 / 2,
                    crossAxisCount: 2,
                    children: _products.map((p) {
                      return FutureBuilder<Tuple2>(
                        future: () async {
                          var prodImage;
                          try {
                            var prodImageURL = await FirebaseStorage.instance.ref().child('productImages/' + p.productId).getDownloadURL();
                            prodImage = Image.network(prodImageURL);
                          } catch (e) {
                            prodImage = null;
                          }
                          return Tuple2<globals.Product, Image>(p, prodImage);
                        } (),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return Card(
                              elevation: 5.0,
                              color: Colors.lightGreen[800],
                              child: InkWell(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: snapshot.data.item2 != null? snapshot.data.item2 : Image.asset('Assets/Untitled.png')),
                                    Text(p.name, style: globals.niceFont()),
                                    Text('\$' + p.price.toString(), style: globals.niceFont())
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductScreen(p.productId)));
                                },
                                onLongPress: () {}, // TODO show options to view product or add to cart
                              ),
                            );
                          }
                          return Center(child: CircularProgressIndicator());
                        },
                      );
                    }).toList(),
                  );
                  return DefaultTabController(
                    length: 2,
                    child: Material(
                        color: Colors.lightGreen,
                        child: Consumer<UserRepository>(
                            builder: (context, userRep, _) {
                              return Scaffold(
                                  resizeToAvoidBottomInset: false,
                                  resizeToAvoidBottomPadding: false,
                                  backgroundColor: Colors.lightGreen[600],
                                  key: _scaffoldKeyUserScreenSet,
                                  appBar: AppBar(
                                    backgroundColor: Colors.lightGreen[900],
                                    leading: IconButton(
                                        icon: Icon(Icons.keyboard_arrow_left_outlined),
                                        onPressed: () {Navigator.of(context).pop();}
                                    ),
                                    title: editingMode ?
                                    TextField(
                                      controller: controllers[0],
                                      style: globals.niceFont(),
                                    )
                                        : Text(_storeName),
                                    bottom: TabBar(
                                      tabs: [
                                        Tab(text: "About"),
                                        Tab(text: "Items"),
                                      ],
                                      indicatorColor: Colors.red,
                                      labelColor: Colors.white,
                                      unselectedLabelColor: Colors.grey,
                                    ),
                                    actions: userRep.status == Status.Authenticated && _storeId == userRep.user.uid ?
                                    editingMode ? [IconButton(icon: Icon(Icons.save_outlined), onPressed: () async {
                                      await userRep.firestore.collection('Stores').doc(_storeId).get().then((snapshot) async {
                                        var storeArgs = snapshot['Store'];
                                        storeArgs['name'] = controllers[0].text;
                                        storeArgs['description'] = controllers[1].text;
                                        storeArgs['address'] = controllers[2].text;
                                        await userRep.firestore.collection('Stores').doc(_storeId).update({'Store': storeArgs});
                                      });
                                      setState(() {
                                        editingMode = false;
                                      });
                                    },)
                                    ]
                                        : [
                                      IconButton(icon: Icon(Icons.edit_outlined), onPressed: () {
                                        setState(() {
                                          editingMode = true;
                                          controllers[0].text = _storeName;
                                          controllers[1].text = _storeDesc;
                                          controllers[2].text = _storeAddr;
                                        });
                                      }),
                                    ]
                                        : [],
                                  ),
                                  floatingActionButton: editingMode ? FloatingActionButton(
                                    child: Icon(Icons.add_outlined),
                                    onPressed: () {
                                      showDialog(context: context,
                                          builder: (BuildContext context) {
                                            return AddProductDialogBox(_storeId); //TODO: insert the correct total and product list
                                          }
                                      );
                                    },
                                    backgroundColor: Colors.red[900],
                                  ) : null,
                                  body: TabBarView(
                                      children: [
                                        aboutTab,
                                        itemsTab,
                                      ]
                                  )
                              );
                            }
                        )
                    ),
                  );
                }
                return globals.emptyLoadingScaffold();
              }
          );
        }
    );
  }

  void _getReviewBottomSheet() {
    double _currReviewRating;
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context1) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery
                    .of(_scaffoldKeyUserScreenSet.currentContext)
                    .viewInsets
                    .bottom
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 10,),
                globals.changingStarBar(0, onUpdate: (rating) {
                  _currReviewRating = rating;
                }, color: Colors.lightGreen[800]),
                SizedBox(height: 15.0,),
                Container(
                  width: MediaQuery
                      .of(context1)
                      .size
                      .width - 45,
                  height: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4.0))
                  ),
                  child: TextField(
                    controller: reviewCtrl,
                    decoration: InputDecoration(
                      hintText: "Write a review...",
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.lightGreen[800],
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.lightGreen[800],
                          width: 1.5,
                        ),
                      ),
                    ),
                    maxLines: null,
                    minLines: 5,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                SizedBox(height: 5.0,),
                Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                    width: 200,
                    child: RaisedButton(
                      color: Colors.white,
                      textColor: Colors.lightGreen[800],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(
                            color: Colors.lightGreen[800],
                            width: 2.0,
                          )
                      ),
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      onPressed: () async {
                        var db = FirebaseFirestore.instance;
                        await db.collection('Stores').doc(_storeId).update({
                          'Reviews': FieldValue.arrayUnion([{
                            'user': '',
                            'rating': _currReviewRating.toString(),
                            'content': reviewCtrl.text,
                          }
                          ])
                        }).catchError((e) {});
                        Navigator.of(context).pop();
                        setState(() {
                          reviewCtrl.text = '';
                        });
                      },
                      child: Text(
                        "Submit",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          // color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0,)
              ],
            ),
          );
        }
    );
  }
}

class AddProductDialogBox extends StatefulWidget {
  final String title="Add product",textConfirm="Add", textCancel="Cancel", storeId;
  final List controllersList = <TextEditingController>[];


  AddProductDialogBox(String storeId, {Key key}) : storeId = storeId, super(key: key) {
    for(int i=0;i<3;i++){
      controllersList.add(TextEditingController());
    }
  }
  //YOU CALL THIS DIALOG BOX LIKE THIS:
  /*
  showDialog(context: context,
                    builder: (BuildContext context){
                      return AddProductDialogBox(total: "45",productList: null,);//TODO: insert the correct total and product list
                    }
   */
  @override
  _AddProductDialogBoxState createState() => _AddProductDialogBoxState();
}

class _AddProductDialogBoxState extends State<AddProductDialogBox> {
  bool clickedButNoName = false, clickedButNoPrice = false, isImagePicked = false;
  PickedFile pickedImage;

  @override
  void initState() {
    clickedButNoName = clickedButNoPrice = false;
    pickedImage = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
      builder: (context, userRep, _) =>
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(globals.Constants.padding),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: contentBox(context),
          ),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 2.0),
          // margin: EdgeInsets.only(top: globals.Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(globals.Constants.padding),
              boxShadow: [
                BoxShadow(color: Colors.black, offset: Offset(0, 10),
                    blurRadius: 10
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(widget.title, style: GoogleFonts.openSans(fontSize: MediaQuery
                  .of(context)
                  .size
                  .width * 0.06, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              Container(
                padding: EdgeInsets.only(left: 2.0, right: 2.0),
                child: TextField(
                  controller: widget.controllersList[0],
                  style: globals.niceFont(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "name*",
                    errorText: clickedButNoName ? "Enter product name" : null,
                  ),
                    textAlign: TextAlign.center,
                    onChanged: (s) {setState(() {
                    clickedButNoName = s == '';
                  });}
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 2.0, right: 2.0),
                child: TextField(
                  controller: widget.controllersList[1],
                  style: globals.niceFont(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "description",
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 2.0, right: 2.0),
                child: TextField(
                  controller: widget.controllersList[2],
                  style: globals.niceFont(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "price*",
                    errorText: clickedButNoPrice ? "Enter product price" : null,
                  ),
                  textAlign: TextAlign.center,
                  onChanged: (s) {setState(() {
                    clickedButNoPrice = s == '';
                  });},
                ),
              ),
              Center(child: Text(!isImagePicked ? "No image picked!" : "Image picked!", style: globals.niceFont(color: Colors.black),)),
              RaisedButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () async {
                    var image = await ImagePicker().getImage(source: ImageSource.gallery);
                    isImagePicked = true;
                    setState(() {pickedImage = image;});
                  },
                  child: Text("pick image", style: globals.niceFont()),
              ),
              InkWell(
                onTap: () async {
                  if(widget.controllersList[0].text == '' || widget.controllersList[2].text == ''){
                    return;
                  }
                  var _db = FirebaseFirestore.instance;
                  var prodId = (await _db.collection('Products').doc('Counter').get()).data()['Counter'];
                  var today = DateFormat('dd/MM/yyyy').format(DateTime.now()).toString();
                  await _db.collection('Products').doc(prodId.toString()).set({
                    'Product': {
                      'user': widget.storeId,
                      'name': widget.controllersList[0].text,
                      'description': widget.controllersList[1].text,
                      'price': widget.controllersList[2].text,
                      'reviews': [],
                      'date': today,
                      'category': '',
                    }
                  }).catchError((e) {
                    return;
                  });
                  await _db.collection('Stores').doc(widget.storeId).update({
                    'Products': FieldValue.arrayUnion([prodId.toString()]),
                  }).catchError((e) {
                    return;
                  });
                  await _db.collection('Products').doc('Counter').update({
                    'Counter': FieldValue.increment(1),
                  }).catchError((e) {
                    return;
                  });
                  await FirebaseStorage.instance.ref().child('productImages/' + prodId.toString()).putFile(File(pickedImage.path));
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.only(top: MediaQuery
                      .of(context)
                      .size
                      .height * 0.02, bottom: MediaQuery
                      .of(context)
                      .size
                      .height * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(globals.Constants.padding),
                        bottomRight: Radius.circular(globals.Constants.padding)),
                  ),
                  child: Text
                    (widget.textConfirm,
                    style: GoogleFonts.openSans(color: Colors.white, fontSize: MediaQuery
                        .of(context)
                        .size
                        .width * 0.05, fontWeight: FontWeight.w600,),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}