import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:gifthub_2021a/ProductScreen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'globals.dart' as globals;
import 'user_repository.dart';
import 'package:device_apps/device_apps.dart';
// import 'productMock.dart';

class ProductMock {
  String _productId;
  String _userId;
  String _name;
  double _price;
  String _date;
  List _reviews = <ReviewMock>[];

  String get productId => _productId;
  String get user => _userId;
  String get name => _name;
  double get price => _price;
  String get date => _date;
  List get reviews => _reviews;

  ProductMock(String productId, String userId, String name, double price, String date, List reviews) :
        _productId = productId, _userId = userId, _name = name, _price = price, _date = date, _reviews = reviews;

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

class StoreScreen extends StatefulWidget {
  String _storeId;

  StoreScreen(String storeId, {Key key}) : /*_storeId = storeId,*/ super(key: key)
  { _storeId = "9C6irKocUFMZCvlcfqneZrFL0UM2";}

  @override
  _StoreScreenState createState() => _StoreScreenState(_storeId);
}

class _StoreScreenState extends State<StoreScreen> {
  String _storeId;
  String _storeName = "Default";
  String _storeImageURL = "Default";
  String _storeDesc = "Default Desc";
  String _storeAddr = "Default";
  String _storePhone = "Default";
  double _storeRating = 1.0;
  List _products = <ProductMock>[];
  List _reviews = <ReviewMock>[];
  bool editingMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKeyUserScreenSet = new GlobalKey<ScaffoldState>();
  final List controllers = <TextEditingController>[TextEditingController(), TextEditingController(), TextEditingController()];

  _StoreScreenState(String storeId) : _storeId = storeId;

  void _initStoreArgs(DocumentSnapshot doc, CollectionReference ref) async {
    var storeArgs  = doc.data()['Store'];
    _storeName = storeArgs[0];
    _storeImageURL = storeArgs[1];
    _storeDesc = storeArgs[2];
    _storeAddr = storeArgs[3];
    _storePhone = storeArgs[4];
    _storeRating = double.parse(storeArgs[5]);
    _products = <ProductMock>[];
    for(var p in doc.data()['Products']){
      var prodArgs = (await ref.doc(p).get()).data()['Product'];
      _products.add(ProductMock(p, prodArgs['user'], prodArgs['name'], double.parse(prodArgs['price']), prodArgs['date'], prodArgs['reviews']));
    }
    _reviews = doc.data()['Reviews'].map<ReviewMock>((v) =>
        ReviewMock(v['user'], double.parse(v['rating']), v['content'])
    ).toList();
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
              })(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final aboutTab = SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Image(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              image: _storeImageURL != 'Default' ? NetworkImage(_storeImageURL) : AssetImage('assets/images/birthday_cake.jpg'),
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: editingMode?
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
                                  child: editingMode?
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
                                    onPressed: () {},
                                    // TODO add push of all reviews screen
                                    child: Row(
                                        children: [
                                          Icon(Icons.list_alt),
                                          Text("All Reviews"),
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
                                    onPressed: () {},
                                    //TODO add bottom drawer to add a review
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
                      return Card(
                        color: Colors.lightGreen[600],
                        child: InkWell(
                          child: Column(
                            children: [
                              Expanded(child: Image.asset('assets/images/birthday_cake.jpg')),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(p.name, style: globals.niceFont()),
                                  Text('\$' + p.price.toString(), style: globals.niceFont()),
                                ],
                              )
                            ],

                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductScreen(p.productId)));
                          },
                          onLongPress: () {}, // TODO show options to view product or add to cart
                        ),
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
                                        icon: Icon(Icons.menu),
                                        onPressed: null //TODO: implement navigation drawer
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
                                        storeArgs[0] = controllers[0].text;
                                        storeArgs[2] = controllers[1].text;
                                        storeArgs[3] = controllers[2].text;
                                        await userRep.firestore.collection('Stores').doc(_storeId).update({'Store': storeArgs});
                                      });
                                      setState(() {editingMode = false;});
                                    },)]
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
                return Center(child: CircularProgressIndicator());
              }
          );
        }
    );
  }
}