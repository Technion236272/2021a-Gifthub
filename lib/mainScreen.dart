import 'dart:ffi';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:ui';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gifthub_2021a/ProductScreen.dart';
import 'package:gifthub_2021a/StartScreen.dart';
import 'package:gifthub_2021a/StoreScreen.dart';
import 'package:gifthub_2021a/SpinnerDropdown.dart';
import 'user_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'userSettingsScreen.dart';
import 'userOrdersScreen.dart';
import 'wishListScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_flutter_app_icons.dart';
import 'checkoutScreen.dart';
import 'StartScreen.dart';
import 'package:gifthub_2021a/globals.dart' show emptyListOfCategories, niceFont, userCart;
import 'package:cached_network_image/cached_network_image.dart';
import 'ChatScreen.dart';
import 'package:badges/badges.dart';

/// ----------------------------------------------------------------------------
/// The Main Screen:
/// The screen which controls the nav. bar and the navigation between the 3
/// different screens - Home, Orders and Account.
/// It also sets an appropriate AppBar for each screen accordingly.
/// As of release-1.0 - there are only 4 different screens to navigate to:
/// HomeScreen - marked as 'Home'
/// UserOrdersScreen - marked as 'Orders'
/// StoreScreen - marked as 'My Store'
/// UserSettingsScreen - marked as 'Account'
///   An authenticated user can access all screens
///   A guest can only access HomeScreen, view products on HomeScreen and
///     checkout from app bar's trailing cart icon
/// ----------------------------------------------------------------------------

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyMainScreen = new GlobalKey<ScaffoldState>();

  ///current index of the current screen that is displayed
  ///e.g. currentIndex = 2 -> we're on StoreScreen
  int _currentIndex = 0;

  ///userID of the current authenticated user. empty if user on guest mode.
  static String _userID = "";

  ///final list of all screen we can navigate to as described above
  final List<Widget> _children = [
    HomeScreen(),
    UserOrdersScreen(),
    ChatScreen(userID: _userID,),
    StoreScreen(_userID),
    UserSettingsScreen()
  ];

  ///displayed whenever the current user is unauthenticated tries to navigate to
  ///Account, My Store, Orders or Wishlist
  ///initialized in initState() below
  SnackBar _snackBarUserUnauthenticated;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _snackBarUserUnauthenticated = SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('only verified users can access this screen',
          style: GoogleFonts.lato(
            fontSize: MediaQuery.of(context).size.width * 0.156 * (14/18) * (15/49),
          ),
        ),
        action: SnackBarAction(
          textColor: Colors.deepPurpleAccent,
          label: 'Log in',
          onPressed: this._signInDialog,
        ),
      );
    });
  }

  /// Sign In dialog.
  /// Decorated with our GiftHub logo.
  /// Displayed whenever unauthenticated user presses
  /// the leading icon 'Sign In' on app bar. Shows 2 sign in options:
  /// - With Google
  /// - With Email
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
              width: 300,
              height: 150,
              margin: EdgeInsets.only(top: 40),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  /// setting shadow of the popped dialog
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0,10),
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
                      width: 25,
                      height: 25,
                      image: AssetImage("Assets/google.png"),
                    ),
                    title: Text('Continue with Google',
                      style: GoogleFonts.lato(
                        fontSize: 15.9,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () async { ///sign in with Google:
                      var userRep = Provider.of<UserRepository>(context, listen: false);
                      await userRep.signInWithGoogle();
                      if (await userRep.signInWithGoogleCheckIfFirstTime()) {
                        firstSignUpSheet(context, 3);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  Container(
                    height: 1,
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
                        fontSize: 15.9,
                        color: Colors.black,
                      ),
                    ),
                    leading: Icon(Icons.email_outlined,
                      color: Colors.black87,
                    ),
                    /// sign in with Email:
                    onTap: () => firstSignUpSheet(context,5),
                  ),
                ],
              ),
            ),
            ///displaying GiftHub logo as decoration:
            Positioned(
              left: 20,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 45,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(45)),
                  child: Container(
                    width: 120,
                    height: 80,
                    color: Colors.lightGreenAccent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            GiftHubIcons.gift,
                            color: Colors.red,
                            size: 45,
                          ),
                          Text('GiftHub',
                            style: TextStyle(
                              fontSize: 19,
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

  /// Returns current app bar title in reliance of current Screen, which is
  /// determined bu current index of screen on _children's list
  /// in user under AppBar's title property
  String _currentAppBarTitle(int index) {
    return 0 == index
        ? ''
        : 1 == index ? "Orders"
        : 2 == index ? "Chat"
        : 3 == index ? "My Store" : "Account"; /// index = 4
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
          appBar: 3 == _currentIndex || 2 == _currentIndex ? null : AppBar(
            centerTitle: _currentIndex != 0,
            elevation: 0.0,
            backgroundColor: Colors.lightGreen[800],
            actions: <Widget>[
              /// Checkout - cart
              /// displays a checkout dialog box defined in checkoutScreen.dart
              Badge(
                badgeContent: Text(
                  userCart.length < 10 ? userCart.length.toString() : '10+',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: userCart.length < 10 ? 10.0 : 9.0,
                  ),
                ),
                position: BadgePosition(
                  top: 5.5,
                  start: userCart.length < 10 ? 25 : 22,
                ),
                toAnimate: true,
                animationType: BadgeAnimationType.scale,
                badgeColor: Colors.red.shade600,
                elevation: 8,
                shape: BadgeShape.circle,
                child: IconButton(
                  iconSize: 27.0, ///<-- default is 24.0
                  icon: Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialogBox();
                      }
                    );
                  }
                ),
              ),
              /// WishList
              /// on pressed - displays the user's wishlist
              IconButton(
                iconSize: 27.0, ///<-- default is 24.0
                icon: Icon(Icons.favorite),
                onPressed: () =>
                userRep.status == Status.Authenticated
                ? Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => WishListScreen()
                  )
                )
                : _scaffoldKeyMainScreen.currentState.showSnackBar(_snackBarUserUnauthenticated)
              ),
            ],
            /// IF current user is in guest mode then the icon is set to 'sign in' icon
            /// and on pressed a sign in dialog pops as described above
            /// IF current user is authenticated then the icon is set to 'sign out' icon
            /// and an alert dialog pops up to ensure user's will to logout
            leading: IconButton(
              iconSize: 27.0, ///<-- default is 24.0
              icon: userRep.status == Status.Authenticated
                  ? Icon(Icons.logout)
                  : Icon(Icons.login_outlined),
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
                            setState(() {
                              _currentIndex = 0;
                            });
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
                  fontSize: 30,
                  color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
          ),
          /// current displayed screen as of the current index's value
          body: _children[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            currentIndex: _currentIndex,
            onTap: (i) {
              ///Chat:
              if(2 == i && userRep.status == Status.Authenticated) {
                ///set store id to current user id:
                _MainScreenState._userID = userRep.user.uid;
                ///set StoreScreen with respect to current authenticated user
                this._children[2] = ChatScreen(userID: _userID);
                ///navigate to pressed screen
                setState(() {
                  _currentIndex = i;
                });
                return;
              }
              ///Store:
              if(3 == i && userRep.status == Status.Authenticated) {
                ///set chat id to current user id:
                _MainScreenState._userID = userRep.user.uid;
                ///set ChatScreen with respect to current authenticated user
                this._children[3] = StoreScreen(_userID);
                ///navigate to pressed screen
                setState(() {
                  _currentIndex = i;
                });
                return;
              }
              /// if user isn't authenticated and tries to navigate to a
              /// restricted-to-guests screen then an error SnackBar is displayed
              /// as described above
              if(i > 0 && userRep.status != Status.Authenticated) {
                _scaffoldKeyMainScreen.currentState.showSnackBar(
                  _snackBarUserUnauthenticated
                );
                return;
              }
              /// sets state to new screen
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
                icon: Icon(Icons.chat_outlined),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.storefront_outlined),
                label: 'My Store',
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
/// the app. Also, there is an option of filter products by categories.
/// ----------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// List of all available categories
  final List<String> _categories = ['All', 'Cakes', 'Chocolate', 'Balloons', 'Flowers', 'Greeting Cards','Gift Cards', 'Other'];

  ///holds current user-pressed category
  String _currCategory = 'All';

  bool _showProducts = true;

  ///big circular progress indicator
  final Center _circularProgressIndicator = Center(
    child: SizedBox(
      width: 60,
      height: 60,
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightGreen[800]),
      )
    ),
  );

  bool _showAll = true;

  RangeValues _rangeValues = RangeValues(0.0, 500.0);

  @override
  void initState() {
    super.initState();
  }

  /// gets product image from firebase storage with respect to the storage's
  /// structure under docs/ folder at our GitHub project
  /// if there is no image, then an empty string is returned
  Future<String> _getImage(String i) async {
    String imageURL = "";
    try {
      imageURL = await FirebaseStorage.instance
          .ref()
          .child('productImages/' + i)
          .getDownloadURL();
    } catch (_) {
      imageURL = "";
    }
    return imageURL;
  }

  OutlineInputBorder _getOutlineInputBorder({Color color = Colors.grey}) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: 1.3,
      ),
      borderRadius: BorderRadius.all(Radius.circular(30)),
    );
  }

  // ///extracts [_currCategory] String value from its Text child
  // String _getCenterText(Center center) {
  //   return center.toString().split('(\"')[1].split('\")')[0];
  // }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          /// making sure that the top os the screen remains green
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 0.35,
              color: Colors.lightGreen[800],
            ),
          ),
          ///setting top rounded corners on screen
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            /// bottom side of screen (below app bar) is set to be white
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(width: 7.0,),
                          IconButton(
                            icon: Icon(
                              Icons.card_giftcard_rounded,
                              color: _showProducts ? Colors.black26 : Colors.black,
                            ),
                            onPressed: () {
                              if(_showProducts){
                                return;
                              }
                              setState(() {
                                _showProducts = true;
                              });
                            }
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.store_outlined,
                              color: _showProducts ? Colors.black : Colors.black26,
                            ),
                            onPressed: () {
                              if(!_showProducts){
                                return;
                              }
                              setState(() {
                                _showProducts = false;
                              });
                            }
                          ),
                          Spacer(flex: 1,),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 6.0,
                                bottom: 4.0
                              ),
                              child: IconButton(
                                icon: Icon(Icons.filter_list_alt),
                                onPressed: () {
                                  if(_showProducts){
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (BuildContext context, void Function(void Function()) setState){
                                            return Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(20.0),
                                                child: GestureDetector(
                                                  onTap: (){
                                                    FocusScope.of(context).unfocus();
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                                    child: Material(
                                                      child: Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        height: MediaQuery.of(context).size.height * 0.4,
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: <Widget>[
                                                            Flexible(
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: <Widget>[
                                                                  Flexible(
                                                                    flex: 1,
                                                                    child: Padding(
                                                                      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.0256 * (11/18)),
                                                                      child: Align(
                                                                        alignment: Alignment.center,
                                                                        child: Text('Category:',
                                                                          style: GoogleFonts.lato(
                                                                            color: Colors.black,
                                                                            fontSize: MediaQuery.of(context).size.height * 0.0256,
                                                                            fontWeight: FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Flexible(
                                                                    flex: 2,
                                                                    child: Align(
                                                                      alignment: Alignment.center,
                                                                      child: CustomDropdownButton<String>(
                                                                        value: _currCategory,
                                                                        items: _categories
                                                                            .map<CustomDropdownMenuItem<String>>((e) => CustomDropdownMenuItem(
                                                                          child: Text(e,
                                                                            textAlign: TextAlign.center,
                                                                            style: niceFont(color: Colors.lightGreen[300]),
                                                                          ),
                                                                          value: e,
                                                                        )
                                                                        ).toList(),
                                                                        ///setting state for new chosen category
                                                                        onChanged: (String value) {
                                                                          setState(() {
                                                                            _currCategory = value;
                                                                          });
                                                                        },
                                                                        style: GoogleFonts.lato(
                                                                          color: Colors.lightGreen[300],
                                                                          fontWeight: FontWeight.w600,
                                                                        ),
                                                                        icon: Icon(Icons.keyboard_arrow_down_outlined,
                                                                          color: Colors.lightGreen[200],
                                                                        ),
                                                                        dropdownColor: Colors.white,
                                                                        underline: Container(
                                                                          height: 2,
                                                                          color: Colors.lightGreen[300],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ),
                                                            Flexible(
                                                              child: Align(
                                                                alignment: Alignment.centerLeft,
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.0256 * (11/18)),
                                                                  child: Text(
                                                                    'Price Range:',
                                                                    style: GoogleFonts.lato(
                                                                      color: Colors.black,
                                                                      fontSize: MediaQuery.of(context).size.height * 0.0256,
                                                                      fontWeight: FontWeight.w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ),
                                                            Flexible(
                                                              flex: 2,
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: <Widget>[
                                                                  Flexible(
                                                                    child: ListTileTheme(
                                                                      contentPadding: const EdgeInsets.all(0.0),
                                                                      child: CheckboxListTile(
                                                                        title: Text(
                                                                          'Show all',
                                                                          style: GoogleFonts.lato(
                                                                            fontWeight: FontWeight.normal,
                                                                            color: Colors.black,
                                                                          ),
                                                                        ),
                                                                        autofocus: false,
                                                                        controlAffinity: ListTileControlAffinity.leading,
                                                                        value: _showAll,
                                                                        onChanged: (value) {
                                                                          if(!_showAll) {
                                                                            setState(() {
                                                                              _showAll = true;
                                                                            });
                                                                          }
                                                                        }
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Flexible(
                                                                    child: ListTileTheme(
                                                                      contentPadding: const EdgeInsets.all(0.0),
                                                                      child: CheckboxListTile(
                                                                        autofocus: false,
                                                                        title: RangeSlider(
                                                                          min: 0.0,
                                                                          max: 500.0,
                                                                          values: _rangeValues,
                                                                          onChanged: _showAll
                                                                            ? null
                                                                            : (RangeValues value) {
                                                                            setState(() => _rangeValues = value);
                                                                          },
                                                                          labels: RangeLabels(
                                                                            _rangeValues.start.toStringAsFixed(0),
                                                                            _rangeValues.end.toStringAsFixed(0)
                                                                          ),
                                                                          divisions: 50,
                                                                          inactiveColor: Colors.grey,
                                                                          activeColor: Colors.green,
                                                                        ),
                                                                        controlAffinity: ListTileControlAffinity.leading,
                                                                        value: !_showAll,
                                                                        onChanged: (value) {
                                                                          if (_showAll) {
                                                                            setState(() {
                                                                              _showAll = false;
                                                                            });
                                                                          }
                                                                        }
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ),
                                                            Flexible(
                                                              child: Center(
                                                                child: OutlineButton.icon(
                                                                  onPressed: (){
                                                                    super.setState(() {});
                                                                    Navigator.pop(context);
                                                                  },
                                                                  icon: Icon(Icons.saved_search),
                                                                  label: Text(
                                                                    'Search',
                                                                    textAlign: TextAlign.center,
                                                                    style: GoogleFonts.lato(
                                                                      fontSize: MediaQuery.of(context).size.height * 0.0256 * 16/18,
                                                                      fontWeight: FontWeight.w600,
                                                                    ),
                                                                  ),
                                                                  borderSide: BorderSide(
                                                                    color: Colors.black,
                                                                    width: 1.5,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(30.0),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        );
                                      }
                                    );
                                  } else {

                                  }
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 11,
                    child: _showProducts
                    ? FutureBuilder(
                    /// fetching all product snapshots from firebase:
                    future: FirebaseFirestore.instance.collection("Products").get(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData || snapshot.connectionState != ConnectionState.done) {
                        return _circularProgressIndicator;
                      }
                      List<QueryDocumentSnapshot> productsList = List.from(snapshot.data.docs);
                      ///removing the 'Counter' document (see Firebase structure under docs/)
                      productsList.removeWhere((element) => element.id == 'Counter');
                      /// if the current category is not 'All', then we remove all products
                      /// that don't match current category
                      if(_categories[0] != _currCategory) {
                        productsList.removeWhere((e) => e.data()['Product']['category'].toString() != _currCategory);
                      }
                      /// price filtering:
                      if(!_showAll){
                        productsList.removeWhere((e) => double.parse(e.data()['Product']['price']) < _rangeValues.start
                          || double.parse(e.data()['Product']['price']) > _rangeValues.end
                        );
                      }
                      /// if there are no products under current category then
                      /// a decorated error screen is displayed
                      /// the screen is defined under globals.dart
                      if(productsList.isEmpty) {
                        return emptyListOfCategories(context, _currCategory);
                      }
                      /// setting displayed grid view:
                      return GridView.count(
                        primary: false,
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(20),
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        children: List.generate(
                          productsList.length,
                          (index) {
                            /// fetching product's attributes:
                            var productData = productsList[index].data();
                            String prodName = productData['Product']['name'];
                            String prodDescription = productData['Product']['description'];
                            String prodPrice = productData['Product']['price'];
                            return FutureBuilder(
                              future: _getImage(productsList[index].id),
                              builder: (BuildContext context, AsyncSnapshot<String> imageURL) =>
                              ///if imageURL has error then defaulted asset image is displayed
                              ///under 'Assets/no image product.png'
                              (imageURL.connectionState != ConnectionState.done || !imageURL.hasData)
                              ? _circularProgressIndicator
                              : Card(
                                elevation: 10.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                  child: InkWell(
                                    onTap: () { ///navigating to the user tapped product:
                                      Navigator.of(context).push(
                                        new MaterialPageRoute<void>(
                                          builder: (context) => ProductScreen(productsList[index].id)
                                        )
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height,
                                      color: Colors.transparent,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container( ///setting product's image:
                                            width: MediaQuery.of(context).size.width,
                                            height: MediaQuery.of(context).size.height * 1/6,
                                            color: Colors.transparent,
                                            child: !imageURL.hasError && "" != imageURL.data
                                            ? CachedNetworkImage(
                                                imageUrl: imageURL.data,
                                                placeholder: (context, url) => _circularProgressIndicator,
                                                fit: BoxFit.fitWidth,
                                            )
                                            : Image.asset('Assets/no image product.png',
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
                                                    ///product title goes here
                                                    ///if it's too long to fit then we take a substring of it
                                                    child: Text('  ' +
                                                      ((prodName.length < 20 - (prodPrice.length + 1))
                                                      ? prodName
                                                      : (prodName.substring(0, 17 - (prodPrice.length + 1)).trimRight() + '...')),
                                                      textAlign: TextAlign.left,
                                                      style: GoogleFonts.lato(
                                                        fontSize: 14.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    ///product description goes here
                                                    ///if it's too long to fit then we take a substring of it
                                                    child: Text('  ' +
                                                      ((prodDescription.length <= 23 - (prodPrice.length + 1))
                                                      ? prodDescription
                                                      : (prodDescription.substring(0, 20 - (prodPrice.length + 1)).trimRight() + '...')),
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
                                                ///product price goes here:
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                                                    child: Text(
                                                      prodPrice + '\$',
                                                      textAlign: TextAlign.right,
                                                      style: GoogleFonts.lato(
                                                        fontSize: 12.0,
                                                        color: Colors.black,
                                                      ),
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
                              ),
                            );
                          }
                        ),
                      );
                    }
                  )
                    : FutureBuilder(
                    /// fetching all stores snapshots from firebase:
                      future: FirebaseFirestore.instance.collection("Stores").get(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData || snapshot.connectionState != ConnectionState.done) {
                          return _circularProgressIndicator;
                        }
                        List<QueryDocumentSnapshot> storesList = List.from(snapshot.data.docs);
                        /// setting displayed grid view:
                        return GridView.count(
                          primary: false,
                          crossAxisCount: 2,
                          padding: const EdgeInsets.all(20),
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          children: List.generate(
                            storesList.length,
                              (index) {
                              /// fetching stores's attributes:
                              var storeData = storesList[index].data();
                              String storeName = storeData['Store']['name'];
                              String storeDescription = storeData['Store']['description'];
                              return FutureBuilder(
                                future: _getStoreImage(storesList[index].id),
                                builder: (BuildContext context, AsyncSnapshot<String> imageURL) =>
                                ///if imageURL has error then defaulted asset image is displayed
                                ///under 'Assets/no image product.png'
                                (imageURL.connectionState != ConnectionState.done || !imageURL.hasData)
                                ? _circularProgressIndicator
                                : Card(
                                  elevation: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                    child: InkWell(
                                      onTap: () { ///navigating to the user tapped store:
                                        Navigator.of(context).push(
                                          new MaterialPageRoute<void>(
                                            builder: (context) => ProductScreen(storeData[index].id)
                                          )
                                        );
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height,
                                        color: Colors.transparent,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container( ///setting product's image:
                                              width: MediaQuery.of(context).size.width,
                                              height: MediaQuery.of(context).size.height * 1/6,
                                              color: Colors.transparent,
                                              child: !imageURL.hasError && "" != imageURL.data
                                              ? CachedNetworkImage(
                                                imageUrl: imageURL.data,
                                                placeholder: (context, url) => _circularProgressIndicator,
                                                fit: BoxFit.fitWidth,
                                              )
                                              : Image.asset('Assets/Untitled.png',
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
                                                      ///store title goes here
                                                      ///if it's too long to fit then we take a substring of it
                                                      child: Text('  ' +
                                                          ((storeName.length <= 21)
                                                            ? storeName
                                                            : (storeName.substring(0, 18).trimRight() + '...')),
                                                        textAlign: TextAlign.left,
                                                        style: GoogleFonts.lato(
                                                          fontSize: 14.0,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      ///store description goes here
                                                      ///if it's too long to fit then we take a substring of it
                                                      child: Text('  ' +
                                                          ((storeDescription.length <= 28)
                                                            ? storeDescription
                                                            : (storeDescription.substring(0, 25).trimRight() + '...')),
                                                        textAlign: TextAlign.left,
                                                        style: GoogleFonts.lato(
                                                          fontSize: 11.0,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
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
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }

  Future<String> _getStoreImage(String id) async {
    String imageURL = "";
    try {
      imageURL = await FirebaseStorage.instance
        .ref()
        .child('storeImages/' + id)
        .getDownloadURL();
    } catch (_) {
      imageURL = "";
    }
    return imageURL;
  }
}

// Flexible(
//   flex: 8,
//   child: Padding(
//     padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.0256 * (11/18)),
//     child: Align(
//       alignment: Alignment.centerRight,
//       child: Text('   Category:',
//         style: GoogleFonts.lato(
//           color: Colors.black,
//           fontSize: MediaQuery.of(context).size.height * 0.0256,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     ),
//   ),
// ),
// Flexible(
//   flex: 10,
//   child: Align(
//     alignment: Alignment.centerLeft,
//     child: CustomDropdownButton<String>(
//       value: _currCategory,
//       items: _categories
//           .map<CustomDropdownMenuItem<String>>((e) => CustomDropdownMenuItem(
//             child: Text(e,
//               textAlign: TextAlign.center,
//               style: niceFont(color: Colors.lightGreen[300]),
//             ),
//             value: e,
//         )
//       ).toList(),
//       ///setting state for new chosen category
//       onChanged: (String value) {
//         setState(() {
//           _currCategory = value;
//         });
//       },
//       style: GoogleFonts.lato(
//         color: Colors.lightGreen[300],
//         fontWeight: FontWeight.w600,
//       ),
//       icon: Icon(Icons.keyboard_arrow_down_outlined,
//         color: Colors.lightGreen[200],
//       ),
//       dropdownColor: Colors.white,
//       underline: Container(
//         height: 2,
//         color: Colors.lightGreen[300],
//       ),
//     ),
//   ),
// ),

// title: Row(
// mainAxisSize: MainAxisSize.min,
// mainAxisAlignment: MainAxisAlignment.start,
// crossAxisAlignment: CrossAxisAlignment.center,
// children: <Widget>[
// Flexible(child: Text('From: ')),
// Flexible(
// child: Container(
// height: MediaQuery.of(context).size.height * 0.4 / 8,
// child: TextField(
// enabled: !_showAll,
// decoration: InputDecoration(
// enabledBorder: _getOutlineInputBorder(),
// focusedBorder: _getOutlineInputBorder(color: Colors.lightGreen.shade800),
// contentPadding: EdgeInsets.fromLTRB(5.0 , 5.0 , 5.0 , 5.0),
// ),
// ),
// ),
// ),
// Flexible(child: Text(' To: ')),
// Flexible(
// child: TextField(
// enabled: !_showAll,
// decoration: InputDecoration(
// enabledBorder: _getOutlineInputBorder(),
// focusedBorder: _getOutlineInputBorder(color: Colors.lightGreen.shade800),
// contentPadding: EdgeInsets.fromLTRB(5.0 , 5.0 , 5.0 , 5.0),
// ),
// ),
// ),
// ],
// ),