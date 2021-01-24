import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gifthub_2021a/ProductScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'globals.dart' as globals;
import 'user_repository.dart';
import 'package:intl/intl.dart';
import 'AllReviewsScreen.dart';
import 'package:tuple/tuple.dart';

/// ----------------------------------------------------
/// The Store Screen:
/// This is a generic widget that will show a store based
/// on the store Id it gets upon creation.
/// Contains a tab with info about the store ('abot tab')
/// and a tab with a grid of the store's product ('items tab').
/// Also allows a store owner to edit their store information
/// and add new products.
/// ----------------------------------------------------
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
  final GlobalKey<ScaffoldState> _scaffoldKeyStoreScreenSet = new GlobalKey<ScaffoldState>();
  final List controllers = <TextEditingController>[TextEditingController(), TextEditingController(), TextEditingController()];
  final reviewCtrl = TextEditingController();

  _StoreScreenState(String storeId) : _storeId = storeId;

  @override
  void dispose() {
    for(TextEditingController tec in controllers){
      tec.dispose();
    }
    reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _initStoreArgs(DocumentSnapshot doc, CollectionReference ref) async {
    var storeArgs = doc.data()['Store'];
    _storeName = storeArgs['name'];
    _storeDesc = storeArgs['description'];
    _storeAddr = storeArgs['address'];
    _storePhone = storeArgs['phone'];
    Completer<Size> completer = Completer<Size>();
    /// Get the store's image from the storage if it exists or show a default image.
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
    ///Get all the store's products.
    _products = <globals.Product>[];
    for (var p in doc.data()['Products']) {
      var docRef = await ref.doc(p).get();
      var prodArgs = docRef.data()['Product'];
      _products.add(globals.Product(
          p,
          prodArgs['user'],
          prodArgs['name'],
          double.parse(prodArgs['price']),
          prodArgs['date'],
          prodArgs['reviews'],
          prodArgs['category'],
          prodArgs['description'],
          docRef.data()['Options'] ?? globals.falseOptions,)
      );
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
    return _reviews.length != 0 ? sum / _reviews.length : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    Map ordered = {};
    List<Widget> orderTiles = [];
    return Consumer<UserRepository>(
        builder: (context, userRep, _) {
          return FutureBuilder(
              future: (() async {
                var storeDoc = userRep.firestore.collection('Stores').doc(_storeId);
                var prodDoc = userRep.firestore.collection('Products');
                // var doc = await storeDoc.get();
                await _initStoreArgs(await storeDoc.get(), prodDoc);
                _storeRating = _getStoreRating();
                if (userRep.status == Status.Authenticated && _storeId == userRep.user.uid) {
                  for (var user in (await storeDoc.get()).data()['Ordered']) {
                    ordered[user] = [];
                    var userDoc = await FirebaseFirestore.instance.collection('Users').doc(user).get();
                    var orderDoc = (await userRep.firestore.collection('Orders').doc(user).get());
                    var ordersMap = orderDoc.data()['NewOrders'];
                    ordersMap[_storeId]?.asMap()?.forEach((index, prod) async {
                      ordered[user].add(prod);
                      orderTiles.add(Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          child: ListTile(
                            tileColor: Colors.grey[200],
                            isThreeLine: true,
                            title: Text(prod['name'], style: globals.niceFont(color: Colors.green)),
                            subtitle: Text('Ordered at: ' + prod['Date'] + '\n ship to: ' + userDoc?.data()['Info'][2], style: globals.niceFont(color: Colors.green, size: 12.0)),

                            trailing: StatefulBuilder(
                                builder: (context, setState) {
                                  return DropdownButton(
                                      value: prod['orderStatus'],
                                      items: ['Ordered', 'Confirmed', 'Shipped'].map<DropdownMenuItem>(
                                              (s) => DropdownMenuItem(value: s, child: Text(s, style: globals.niceFont(color: Colors.green)))
                                      ).toList(),
                                      dropdownColor: Colors.white,
                                      onChanged: (value) async {
                                        ordersMap[_storeId][index]['orderStatus'] = prod['orderStatus'] = value;
                                        await userRep.firestore.collection('Orders').doc(user).update({
                                          'NewOrders': ordersMap,
                                        });
                                        setState(() {});
                                      });
                                }
                            ),
                          ),
                        ),
                      ));
                    });
                  }
                }
              })(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return globals.emptyErrorScaffold(snapshot.error.toString());
                  }

                  /// Shows the store's information.
                  /// Supports editing mode that allows the owner to change
                  /// some of the store's info.
                  final aboutTab = SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          editingMode ?
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 5),
                              ),
                              child: Image(
                                image: _storeImage != null ? _storeImage : AssetImage('Assets/Untitled.png'),
                                width: min(min(MediaQuery
                                    .of(context)
                                    .size
                                    .width, _storeImageSize.width), MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.25),
                              ),
                            ),
                            onLongPress: () async {
                              PickedFile photo = await ImagePicker().getImage(source: ImageSource.gallery);
                              if (null == photo) {
                                _scaffoldKeyStoreScreenSet.currentState.showSnackBar(
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
                          )
                              : Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 5),
                            ),
                            child: Image(
                              width: min(min(MediaQuery
                                  .of(context)
                                  .size
                                  .width, _storeImageSize.width), MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.25),
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
                                IconButton(icon: Icon(Icons.navigation, color: Colors.white), onPressed: () async {
                                  String addrForUrl = Uri.encodeFull(_storeAddr);
                                  String navUrl = 'https://www.google.com/maps/dir/?api=1&destination=$addrForUrl';
                                  if (await canLaunch(navUrl)) {
                                    await launch(navUrl);
                                  } else {
                                    _scaffoldKeyStoreScreenSet.currentState.showSnackBar(SnackBar(content: Text("Could not launch navigation app")));
                                  }
                                }),
                                IconButton(icon: Icon(Icons.phone, color: Colors.white), onPressed: () async {
                                  String phoneUrl = 'tel: $_storePhone';
                                  if (await canLaunch(phoneUrl)) {
                                    await launch(phoneUrl);
                                  } else {
                                    _scaffoldKeyStoreScreenSet.currentState.showSnackBar(SnackBar(content: Text("Could not launch phone")));
                                  }
                                }),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          globals.fixedStarBar(_storeRating),
                          SizedBox(height: 10),
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
                                          Text("All Reviews (${_reviews.length})"),
                                        ]
                                    )
                                ),
                                RaisedButton(
                                  child: Row(
                                      children: [
                                        Icon(Icons.add),
                                        Text("Add Review"),
                                      ]
                                  ),
                                  elevation: 15.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.transparent),
                                  ),
                                  visualDensity: VisualDensity.adaptivePlatformDensity,
                                  color: Colors.red[900],
                                  textColor: Colors.white,
                                  onPressed: () {
                                    if (userRep.status != Status.Authenticated) {
                                      _scaffoldKeyStoreScreenSet.currentState.showSnackBar(SnackBar(content: Text("Sign in to use this feature")));
                                      return;
                                    }
                                    if (userRep.user.uid == _storeId) {
                                      _scaffoldKeyStoreScreenSet.currentState.showSnackBar(SnackBar(content: Text("You can't add a review to your own store")));
                                      return;
                                    }
                                    _getReviewBottomSheet();
                                  },
                                ),
                              ]
                          )
                        ]
                    ),
                  );

                  /// Shows the store's product in a pretty grid.
                  /// Users can access any product by clicking it.
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
                        }(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return Card(
                              elevation: 5.0,
                              color: Colors.lightGreen[800],
                              child: InkWell(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: snapshot.data.item2 != null ? snapshot.data.item2 : Image.asset('Assets/Untitled.png')),
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
                  List tiles = <ListTile>[];
                  // ordered?.forEach((key, value) {});
                  final ordersTab = ListView(
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: orderTiles ?? [],
                      ).toList(),
                  );
                  bool isMyStore = userRep.status == Status.Authenticated && userRep.user.uid == _storeId;
                  return DefaultTabController(
                    length: isMyStore? 3 : 2,
                    child: Material(
                        color: Colors.lightGreen,
                        child: Consumer<UserRepository>(
                            builder: (context, userRep, _) {
                              return Scaffold(
                                  resizeToAvoidBottomInset: false,
                                  resizeToAvoidBottomPadding: false,
                                  backgroundColor: Colors.lightGreen[600],
                                  key: _scaffoldKeyStoreScreenSet,
                                  appBar: AppBar(
                                    backgroundColor: Colors.lightGreen[800],
                                    title: editingMode ?
                                    TextField(
                                      controller: controllers[0],
                                      style: globals.calistogaFont(),
                                    )
                                        : Text(_storeName, style: globals.calistogaFont(),),
                                    bottom: TabBar(
                                      tabs: isMyStore ?
                                      [
                                        Tab(text: "About"),
                                        Tab(text: "Items"),
                                        Tab(text: "Orders"),
                                      ]
                                          : [
                                        Tab(text: "About"),
                                        Tab(text: "Items"),
                                      ],
                                      indicatorColor: Colors.red,
                                      labelColor: Colors.white,
                                      unselectedLabelColor: Colors.grey,
                                    ),

                                    ///Let the user edit and save store changes only if it's the owner
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
                                      children: isMyStore ?
                                      [
                                        aboutTab,
                                        itemsTab,
                                        ordersTab,
                                      ]:
                                      [
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
                    .of(_scaffoldKeyStoreScreenSet.currentContext)
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
  final String title="Add product",textConfirm="Add", storeId;
  final List controllersList = <TextEditingController>[];


  AddProductDialogBox(String storeId, {Key key}) : storeId = storeId, super(key: key) {
    for(int i=0;i<3;i++){
      controllersList.add(TextEditingController());
    }
  }

  @override
  _AddProductDialogBoxState createState() => _AddProductDialogBoxState();

  void dispose() {
    for(TextEditingController tec in controllersList){
      tec.dispose();
    }
  }
}

class _AddProductDialogBoxState extends State<AddProductDialogBox> {
  bool clickedButNoName, clickedButNoPrice, isCategorySelected, isImagePicked;
  Color colorForCategory, colorForImage;
  PickedFile pickedImage;
  String category;
  bool _isAddedPressed = false;
  final Map optionsDict = {'wrapping': false, 'greeting': false, 'fast': false};


  @override
  void initState() {
    clickedButNoName = clickedButNoPrice = isCategorySelected = isImagePicked = false;
    pickedImage = null;
    colorForCategory = colorForImage = Colors.black;
    String category = globals.categories[0];
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
          child: SingleChildScrollView(
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
                      onChanged: (s) {
                        setState(() {
                          clickedButNoName = s == '';
                        });
                      }
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
                    onChanged: (s) {
                      try {
                        double checkPrice = double.parse(widget.controllersList[2].text);
                      } catch (e) {
                        setState(() {
                          clickedButNoPrice = true;
                        });
                        return;
                      }
                      setState(() {
                        clickedButNoPrice = s == '';
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Category:", style: globals.niceFont(color: colorForCategory),),
                    Container(
                        color: Colors.transparent,
                        child: DropdownButton<String>(
                            elevation: 0,
                            value: category,
                            onChanged: (String newValue) {
                              setState(() {
                                category = newValue;
                                isCategorySelected = newValue.compareTo(globals.categories[0]) != 0;
                                colorForCategory = isCategorySelected ? Colors.black : Colors.red;
                              });
                            },
                            items: globals.categories
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList())
                    ),
                  ],
                ),
                Text("Enable gift features?", style: globals.niceFont(color: colorForImage)),
                Container(
                  child: CheckboxListTile(
                      title: Text("Gift wrapping", style: globals.niceFont(color: colorForImage)),
                      value: optionsDict['wrapping'],
                      activeColor: Colors.green,
                      onChanged: (b) {
                        setState(() {
                          optionsDict['wrapping'] = b;
                        });
                      }),
                ),
                Container(
                  child: CheckboxListTile(
                      title: Text("Personal greeting", style: globals.niceFont(color: colorForImage)),
                      value: optionsDict['greeting'],
                      activeColor: Colors.green,
                      onChanged: (b) {
                        setState(() {
                          optionsDict['greeting'] = b;
                        });
                      }),
                ),
                Container(
                  child: CheckboxListTile(
                      title: Text("Fast delivery", style: globals.niceFont(color: colorForImage)),
                      value: optionsDict['fast'],
                      activeColor: Colors.green,
                      onChanged: (b) {
                        setState(() {
                          optionsDict['fast'] = b;
                        });
                      }),
                ),
                Center(child: Text(!isImagePicked ? "No image picked!" : "Image picked!", style: globals.niceFont(color: colorForImage),)),
                RaisedButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () async {
                    var image = await ImagePicker().getImage(source: ImageSource.gallery);
                    setState(() {
                      pickedImage = image;
                      isImagePicked = true;
                      colorForImage = isImagePicked ? Colors.black : Colors.red;
                    });
                  },
                  child: Text("pick image", style: globals.niceFont()),
                ),
                InkWell(
                  onTap: _isAddedPressed? null : () async {
                    bool isAllGood = true;
                    if (widget.controllersList[0].text == '' || widget.controllersList[2].text == '') {
                      setState(() {
                        clickedButNoName = widget.controllersList[0].text == '';
                        clickedButNoPrice = widget.controllersList[2].text == '';
                      });
                      isAllGood = false;
                    }
                    try {
                      double checkPrice = double.parse(widget.controllersList[2].text);
                    } catch (e) {
                      setState(() {
                        clickedButNoPrice = true;
                      });
                      isAllGood = false;
                    }
                    if (!isCategorySelected) {
                      setState(() {
                        colorForCategory = Colors.red;
                      });
                      isAllGood = false;
                    } else if (!isImagePicked) {
                      setState(() {
                        colorForCategory = Colors.black;
                        colorForImage = Colors.red;
                      });
                      isAllGood = false;
                    }
                    if (!isAllGood) {
                      return;
                    }
                    setState(() {
                      _isAddedPressed = true;
                    });
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
                        'category': category,
                      },
                      'Options': optionsDict,
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
                    setState(() {
                      _isAddedPressed = false;
                    });
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
                      color: _isAddedPressed ? Colors.grey : Colors.red,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(globals.Constants.padding),
                          bottomRight: Radius.circular(globals.Constants.padding)),
                    ),
                    child: _isAddedPressed ? Center(child: CircularProgressIndicator())
                        : Text
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
        ),
      ],
    );
  }
}