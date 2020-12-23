import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gifthub_2021a/StartScreen.dart';
import 'user_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'userSettingsScreen.dart';
import 'userOrdersScreen.dart';
import 'wishListScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_flutter_app_icons.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';

/// ----------------------------------------------------------------------------
/// The Main Screen:
/// The screen which controls the nav. bar and the navigation between the 3
/// different screens - Home, Orders and Account.
/// it also sets an appropriate AppBar for each screen accordingly.
/// ----------------------------------------------------------------------------

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyMainScreen = new GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomeScreen(),
    UserOrdersScreen(),
    UserSettingsScreen()
  ];

  void _signInDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.23,
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.058),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,offset: Offset(0,10),
                        blurRadius: 10
                    ),
                  ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ListTile(
                    tileColor: Colors.white,
                    leading: Image(
                      width: MediaQuery.of(context).size.width * 0.06,
                      height: MediaQuery.of(context).size.height * 0.06,
                      image: AssetImage("Assets/google.png"),
                    ),
                    title: Text('Continue with Google',
                      style: GoogleFonts.lato(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () async {
                      userRep.signInWithGoogle();
                      if (await userRep.signInWithGoogleCheckIfFirstTime()){
                        firstSignUpSheet(context, 3);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.004,
                    child: Divider(
                      color: Colors.red[400],
                      indent: 10,
                      thickness: 1.0,
                      endIndent: 10,
                    ),
                  ),
                  ListTile(
                    title: Text('Continue with Email',
                      style: GoogleFonts.lato(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    leading: Icon(Icons.email_outlined,
                      color: Colors.black87,
                    ),
                    onTap: () => firstSignUpSheet(context,5),
                  ),
                ],
              ),
            ),
            Positioned(
                left: 20,
                right: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 45,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(45)),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.12,
                      color: Colors.lightGreenAccent,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              GiftHubIcons.gift,
                              color: Colors.red,
                              size: MediaQuery.of(context).size.height * 0.06,
                            ),
                            Text('GiftHub',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.03,
                                  fontFamily: 'TimesNewRoman',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

  String _currentAppBarTitle(int index){
    return 0 == index ? '' : 1 == index ? "Orders" : "Account";
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_){
      setState(() {});
    });
    return Material(
      child: Consumer<UserRepository>(
        builder: (context, userRep, _) =>
        Scaffold(
          resizeToAvoidBottomInset: true,
          resizeToAvoidBottomPadding: false,
          backgroundColor: Colors.transparent,
          key: _scaffoldKeyMainScreen,
          appBar: AppBar(
            centerTitle: _currentIndex != 0,
            elevation: 0.0,
            backgroundColor: Colors.lightGreen[800],
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined),
                onPressed: () => {} //TODO: navigate to shopping cart screen
              ),
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => WishListScreen()
                  )
                )
              ),
            ],
            leading: IconButton(
              icon: userRep.status == Status.Authenticated ?
                Icon(Icons.logout) : Icon(Icons.login_outlined),
              onPressed: userRep.status == Status.Authenticated
                ? () async {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => AlertDialog(
                      title: Text('Logout?',
                        style: GoogleFonts.lato(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                      content: Text('Are you sure you want to logout?',
                        style: GoogleFonts.lato(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      elevation: 24.0,
                      actions: [
                        FlatButton(
                          child: Text("Yes",
                            style: GoogleFonts.lato(
                              fontSize: 14.0,
                              color: Colors.green,
                            ),
                          ),
                          onPressed: () async {
                            await userRep.signOut();
                            setState(() {});
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: Text("No",
                            style: GoogleFonts.lato(
                              fontSize: 14.0,
                              color: Colors.red,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )
                  );
                }
                : _signInDialog
            ),
            title: Text(_currentAppBarTitle(_currentIndex),
              style: GoogleFonts.calistoga(
                  fontSize: 2 == _currentIndex ? 28 : 30,
                  color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
          ),
          body: _children[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            currentIndex: _currentIndex,
            onTap: (i) {
              if(i > 0 && userRep.status != Status.Authenticated){
                _scaffoldKeyMainScreen.currentState.showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('only verified users can access this screen',
                      style: GoogleFonts.lato(
                        fontSize: 13.0
                      ),
                    ),
                    action: SnackBarAction(
                      textColor: Colors.deepPurpleAccent,
                      label: 'Log in',
                      onPressed: _signInDialog,
                    ),
                  )
                );
                return;
              }
              setState(() {
                _currentIndex = i;
              });
            },
            backgroundColor: Colors.lightGreen[800],
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.attach_money_outlined),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ----------------------------------------------------------------------------
/// The Home Screen:
/// The screen which shows the home page of the app.
/// It displays a limited GridView of the different products available in
/// the app.
/// ----------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final Center _circularProgressIndicator = Center(
    child: SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightGreen[800]),
        )
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  Future<int> _getTotalProducts() async {
    var x = await FirebaseFirestore.instance.collection("Products").doc("Counter").get();
    var y = x.data();
    return y['Counter'];
  }

  Future<String> _getImage(int i) async {
    String imageURL;
    await FirebaseFirestore.instance.collection("Products").doc(
        "$i").get().then((value) async {
      var productData = value.data();
      print(productData['Product']['user'] + '_' + i.toString());
      imageURL = await FirebaseStorage.instance.ref().child(
          productData['Product']['user'] + '_' + i.toString()).getDownloadURL();
    });
    return imageURL;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: Alignment.center,
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
              color: Colors.white,
              child: FutureBuilder(
                future: _getTotalProducts(),
                builder:(BuildContext context, AsyncSnapshot<int> totalProducts) =>
                (!totalProducts.hasData || totalProducts.connectionState != ConnectionState.done)
                ? _circularProgressIndicator
                : FutureBuilder(
                  future: FirebaseFirestore.instance.collection("Products").get(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData || snapshot.connectionState != ConnectionState.done) {
                      return _circularProgressIndicator;
                    }
                    return GridView.count(
                      primary: false,
                      crossAxisCount: 2,
                      padding: const EdgeInsets.all(20),
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      children: List.generate(
                        min(16, totalProducts.data - 1),
                        (index) {
                          var productData = snapshot.data.docs[index].data();
                          String prodName = productData['Product']['name'];
                          String prodDescription = productData['Product']['description'];
                          String prodPrice = productData['Product']['price'];
                          return FutureBuilder(
                            future: _getImage(index),
                            builder: (BuildContext context, AsyncSnapshot<String> imageURL) =>
                            //TODO: check why imageURL never has data!
                            ///found the answer - pictures in DB storage end with .jpg, .png...
                            (imageURL.connectionState != ConnectionState.done)
                            ? _circularProgressIndicator
                            : Card(
                              elevation: 10.0,
                              child: InkWell(
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () => {}, //TODO: navigate to product screen
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  color: Colors.redAccent,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height * 1/6,
                                        color: Colors.cyan,
                                        child: Image.network(imageURL.data ?? defaultAvatar,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Text('  ' +
                                                  ((prodName.length <= 17)
                                                  ? prodName
                                                  : (prodName.substring(0,16) + '...')), //product title goes here
                                                  textAlign: TextAlign.left,
                                                  style: GoogleFonts.lato(
                                                    fontSize: 14.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Text('  ' +
                                                  ((prodDescription.length > 19)
                                                  ? (prodDescription.substring(0,20) + '...')
                                                  : prodDescription), //product description goes here
                                                  textAlign: TextAlign.left,
                                                  style: GoogleFonts.lato(
                                                    fontSize: 11.0,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Flexible(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                prodPrice + '\$', //product price goes here
                                                textAlign: TextAlign.right,
                                                style: GoogleFonts.lato(
                                                  fontSize: 11.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}