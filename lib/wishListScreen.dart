import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:gifthub_2021a/globals.dart' as globals;
import 'checkoutScreen.dart';
import 'ProductScreen.dart';
import 'package:badges/badges.dart';

///-----------------------------------------------------------------------------
/// User Wish List Screen:
/// displays all products that the current user set on his wish list
/// user's products are fetched remotely from FireBase FireStore & Storage,
/// generated and displayed in a ListView
/// all list items are slidable and multiple options offered as will be described below
///-----------------------------------------------------------------------------

class WishListScreen extends StatefulWidget {
  WishListScreen({Key key}) : super(key: key);

  @override
  _WishListScreenState createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> with SingleTickerProviderStateMixin {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKeyWishList = new GlobalKey<ScaffoldState>();

  ///nasty workaround to display 'added to cart' snackbar
  final GlobalKey<ScaffoldState> _scaffoldKeyWorkAround = new GlobalKey<ScaffoldState>();

  ///flag to detect on widget tree build - whether or not an item was added
  ///to cart
  bool _addedToCart = false;

  ///showing 'added to cart' snackbar upon completion
  SnackBar _onAddToCartSnackBar;

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
  
  @override
  void initState() {
    _onAddToCartSnackBar = SnackBar(
      content: Text('Product Successfully Added to Cart!',
        style: GoogleFonts.lato(
          fontSize: 13.0,
          color: Colors.white
        ),
      ),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Checkout',
        textColor: Colors.lime,
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox();
          },
        ),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Consumer<UserRepository>(
        builder: (context, userRep, _) =>
          Scaffold(
            key: _scaffoldKeyWorkAround,
            body: StreamBuilder<QuerySnapshot>(
              /// fetching user's wish list from FB storage
              stream: userRep.firestore.collection('Wishlists').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> wishListCollectionSnapshot) {
                print(wishListCollectionSnapshot.connectionState);
                if (!wishListCollectionSnapshot.hasData || wishListCollectionSnapshot.connectionState != ConnectionState.active) {
                  return _circularProgressIndicator;
                }
                if(_addedToCart){ ///displaying 'added to cart' snackbar
                  _addedToCart = false;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scaffoldKeyWorkAround.currentState.showSnackBar(_onAddToCartSnackBar);
                  });
                }
                ///getting user's wishlist:
                var wishListSnapshot = wishListCollectionSnapshot
                    .data
                    .docs
                    .firstWhere((element) => element.id == userRep.user.uid);
                int totalProducts = wishListSnapshot.data()['Wishlist'].length;
                if (0 == totalProducts) {
                  /// if user's wish list is empty then a blank, informative and interactive
                  /// screen is displayed. defined under globals.dart
                  return globals.emptyListErrorScreen(context, 'Wishlist');
                }
                return RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: Scaffold(
                    key: _scaffoldKeyWishList,
                    resizeToAvoidBottomPadding: false,
                    resizeToAvoidBottomInset: false,
                    backgroundColor: Colors.lightGreen[800],
                    appBar: AppBar(
                      centerTitle: true,
                      automaticallyImplyLeading: false,
                      elevation: 0.0,
                      backgroundColor: Colors.lightGreen[800],
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                        iconSize: 27.0,
                      ),
                      actions: <Widget>[
                        /// Checkout - cart
                        /// displays a checkout dialog box defined in checkoutScreen.dart
                        Badge(
                          badgeContent: Text(
                            globals.userCart.length < 10 ? globals.userCart.length.toString() : '10+',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: globals.userCart.length < 10 ? 10.0 : 9.0,
                            ),
                          ),
                          position: BadgePosition(
                            top: 5.5,
                            start: globals.userCart.length < 10 ? 25 : 22,
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
                      ],
                      title: Text("Wish List",
                        style: GoogleFonts.calistoga(
                          fontSize: 33,
                          color: Colors.white
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    body: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.white,
                              child: ListView.builder(
                                /// generating the wishlist
                                itemCount: totalProducts * 2,
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(16),
                                itemBuilder: (BuildContext context, int i) {
                                  if (i >= 2 * totalProducts) {
                                    return null;
                                  }
                                  if (i.isOdd) {
                                    return Divider(
                                      color: Colors.green,
                                      thickness: 1.0,
                                    );
                                  }
                                  var wishlistIdData = wishListSnapshot.data()['Wishlist'];
                                  String productID = wishlistIdData[i ~/ 2];
                                  return FutureBuilder(
                                    future: FirebaseFirestore.instance.collection("Products").doc(productID).get(),
                                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> productSnapshot) {
                                      if (productSnapshot.connectionState != ConnectionState.done) {
                                        return _circularProgressIndicator;
                                      }
                                      if(!productSnapshot.hasData || _isCounter(productSnapshot)){
                                        return Container(width: 0.0, height: 0.0);
                                      }
                                      /// parsing product details from FB firestore
                                      var productData = productSnapshot.data.data()['Product'];
                                      String prodName = productData['name'];
                                      String prodPrice = productData['price'];
                                      String prodDate = productData['date'];
                                      return FutureBuilder(
                                        future: _getImage(productID),
                                        builder: (BuildContext context, AsyncSnapshot<String> imageURL) {
                                          if (imageURL.connectionState != ConnectionState.done || !imageURL.hasData) {
                                            return _circularProgressIndicator;
                                          }
                                          ///if image url has error (meaning there is no product image)
                                          ///then defaulted asset image is displayed
                                          ///under 'Assets/no image product.png'
                                          return Slidable(
                                            actionPane: SlidableDrawerActionPane(),
                                            actionExtentRatio: 0.22,
                                            direction: Axis.horizontal,
                                            actions: <Widget>[
                                              ///add to cart
                                              IconSlideAction(
                                                caption: 'Add to cart',
                                                color: Colors.transparent,
                                                foregroundColor: Colors.amberAccent,
                                                icon: Icons.add_shopping_cart,
                                                onTap: () async {
                                                  globals.userCart.add(globals.Product(
                                                      productID,
                                                      userRep.user.uid,
                                                      prodName,
                                                      double.parse(prodPrice),
                                                      prodDate, [], "", "")
                                                  );
                                                  _addedToCart = true;
                                                  ///removing product from wishlist
                                                  List toRemove = [];
                                                  toRemove.add(productID);
                                                  await userRep.firestore
                                                      .collection('Wishlists')
                                                      .doc(userRep.user.uid)
                                                      .get()
                                                      .then((value) async {
                                                        List<dynamic> list = List.from(value.data()['Wishlist']);
                                                        list..removeWhere((e) => toRemove.contains(e));
                                                        await userRep.firestore
                                                            .collection('Wishlists')
                                                            .doc(userRep.user.uid)
                                                            .update({'Wishlist': list});
                                                      });
                                                },
                                              ),
                                              /// Share
                                              IconSlideAction(
                                                caption: 'Share',
                                                color: Colors.transparent,
                                                foregroundColor: Colors.blueAccent,
                                                icon: Icons.share_outlined,
                                                onTap: () async {
                                                  /// split between 2 cases:
                                                  /// item has an image or not
                                                  if(!imageURL.hasError && imageURL.hasData && "" != imageURL.data) {
                                                    try {
                                                      final RenderBox box = _scaffoldKeyWishList.currentContext.findRenderObject();
                                                      if (Platform.isAndroid) {
                                                        var response = await get(imageURL.data);
                                                        final documentDirectory = (await getExternalStorageDirectory()).path;
                                                        File imgFile = new File('$documentDirectory/flutter.png');
                                                        imgFile.writeAsBytesSync(response.bodyBytes);
                                                        List<String> sharingList = new List();
                                                        sharingList.add('$documentDirectory/flutter.png');
                                                        await Share.shareFiles(
                                                            sharingList,
                                                            text: "check this cool product now!\n" + prodName,
                                                            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
                                                            subject: 'I found a lovely product on GiftHub!'
                                                        );
                                                      }
                                                    } catch (_) {}
                                                  } else {
                                                    try {
                                                      final RenderBox box = _scaffoldKeyWishList.currentContext.findRenderObject();
                                                      String image = 'no image product.png';
                                                      final List <String> list = [];
                                                      final tempDir = await getTemporaryDirectory();
                                                      list.add('${tempDir.path}/' + image);
                                                      await Share.shareFiles(
                                                          list,
                                                          text: "check this cool product now!\n" + prodName,
                                                          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
                                                          subject: 'I found a lovely product on GiftHub!'
                                                      );
                                                    } catch (_) {} //TODO: show error snackbar?
                                                  }
                                                },
                                              ),
                                            ],
                                            secondaryActions: <Widget>[
                                              /// Delete
                                              IconSlideAction(
                                                caption: 'Delete',
                                                color: Colors.transparent,
                                                foregroundColor: Colors.red,
                                                icon: Icons.delete_outline_outlined,
                                                onTap: () async {
                                                  /// upon deletion
                                                  /// showing alert dialog to reassure
                                                  /// user's intention
                                                  showDialog(
                                                    barrierDismissible: true,
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        backgroundColor: Colors.white,
                                                        elevation: 24.0,
                                                        title: Text('Delete?',
                                                          style: GoogleFonts.lato(
                                                            fontSize: 18.0,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        content: Text('Are you sure you want to delete ' +
                                                            prodName + '?',
                                                          style: GoogleFonts.lato(
                                                            fontSize: 16.0,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        actions: [
                                                          FlatButton(
                                                            child: Text("Yes",
                                                              style: GoogleFonts.lato(
                                                                fontSize: 14.0,
                                                                color: Colors.green,
                                                              ),
                                                            ),
                                                            onPressed: () async {
                                                              var toRemoveList = [];
                                                              toRemoveList.add(productID);
                                                              await userRep.firestore
                                                                  .collection('Wishlists')
                                                                  .doc(userRep.user.uid)
                                                                  .update({
                                                                'Wishlist':FieldValue.arrayRemove(toRemoveList)
                                                              });
                                                              setState(() {
                                                                ///so that wishlist list will be updated
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
                                                      );
                                                    }
                                                  );
                                                },
                                              )
                                            ],
                                            child: ListTile(
                                              onTap: () => Navigator.of(context).push(
                                                new MaterialPageRoute(
                                                  builder: (BuildContext context) {
                                                    return ProductScreen(productID);
                                                  }
                                                )
                                              ),
                                              leading: !imageURL.hasError && imageURL.hasData && imageURL.data != ""
                                              /// split to 2 cases where product has a
                                              /// picture or not
                                              ? CircularProfileAvatar(
                                                imageURL.data,
                                                radius: 26.0,
                                                onTap: () {
                                                  Navigator.of(context).push(new MaterialPageRoute<void>(
                                                    builder: (BuildContext context) => Dismissible(
                                                      key: const Key('keyH'),
                                                      direction: DismissDirection.horizontal,
                                                      onDismissed: (_) => Navigator.pop(_scaffoldKeyWishList.currentContext),
                                                      child: Dismissible(
                                                        direction: DismissDirection.vertical,
                                                        key: const Key('keyV'),
                                                        onDismissed: (_) => Navigator.pop(_scaffoldKeyWishList.currentContext),
                                                        child: DecoratedBox(
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              image: NetworkImage(imageURL.data),
                                                              fit: BoxFit.fitWidth,
                                                            )
                                                          )
                                                        )
                                                      ),
                                                    ),
                                                  )
                                                  );
                                                },
                                              )
                                              : InkWell(
                                                onTap: () => _scaffoldKeyWishList.currentState.showSnackBar(
                                                  SnackBar(
                                                    behavior: SnackBarBehavior.floating,
                                                    content: Text('This Product does not have an image',
                                                      style: GoogleFonts.lato(
                                                        fontSize: 13.0,
                                                        color: Colors.white
                                                      ),
                                                    )
                                                  )
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(26.0),
                                                  child: Image.asset('Assets/no image product.png'),
                                                ),
                                              ),
                                              title: Text(prodName, ///product name
                                                style: GoogleFonts.lato(
                                                  fontSize: 18.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              subtitle: Text(prodPrice + "\$", ///product's price
                                                style: GoogleFonts.lato(
                                                  fontSize: 13.5,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              visualDensity: VisualDensity.adaptivePlatformDensity,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                }
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ),
    );
  }

  /// gets product image from firebase storage with respect to the storage's
  /// structure under docs/ folder at our GitHub project
  /// if there is no image, then an empty string is returned
  Future<String> _getImage(String productId) async {
    String imageURL = "";
    try {
      imageURL = await FirebaseStorage.instance
          .ref('productImages')
          .child(productId)
          .getDownloadURL();
    } catch (_) {
      imageURL = "";
    }
    return imageURL;
  }

  ///checks whether current snapshot is the 'Counter' snapshot or not
  bool _isCounter(AsyncSnapshot<DocumentSnapshot> snapshot){
    return snapshot.hasData && snapshot.data.id == 'Counter';
  }
}