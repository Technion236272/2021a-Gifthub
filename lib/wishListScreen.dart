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

class WishListScreen extends StatefulWidget {
  WishListScreen({Key key}) : super(key: key);

  @override
  _WishListScreenState createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> with SingleTickerProviderStateMixin {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKeyWishList = new GlobalKey<ScaffoldState>();
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

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Consumer<UserRepository>(
        builder: (context, userRep, _) =>
          FutureBuilder(
            future: FirebaseFirestore.instance.collection("Wishlists").doc(userRep.user.uid).get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> wishListSnapshot) {
              if (wishListSnapshot.connectionState != ConnectionState.done) {
                return _circularProgressIndicator;
              } else if (!wishListSnapshot.hasData || 0 == wishListSnapshot.data.data()['Wishlist'].length) {
                return globals.emptyListErrorScreen(context, 'Wishlist');
              }
              int totalProducts = wishListSnapshot.data.data()['Wishlist'].length;
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
                        onPressed: () => Navigator.of(context).pop()
                    ),
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
                            //padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight * 2 + 7),
                            child: ListView.builder(
                              itemCount: totalProducts * 2,
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (BuildContext _context, int i) {
                                if (i >= 2 * totalProducts) {
                                  return null;
                                }
                                if (i.isOdd) {
                                  return Divider(
                                    color: Colors.green,
                                    thickness: 1.0,
                                  );
                                }
                                var wishlistIdData = wishListSnapshot.data.data()['Wishlist'];
                                String productID = wishlistIdData[i ~/ 2];
                                return FutureBuilder(
                                  future: FirebaseFirestore.instance.collection("Products").doc(productID).get(),
                                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> productSnapshot) {
                                    if (wishListSnapshot.connectionState != ConnectionState.done) {
                                      return _circularProgressIndicator;
                                    }
                                    if(!productSnapshot.hasData || _isCounter(productSnapshot)){
                                      return Container(width: 0.0, height: 0.0);
                                    }
                                    var productData = productSnapshot.data.data()['Product'];
                                    String prodName = productData['name'];
                                    String prodPrice = productData['price'];
                                    String prodDate = productData['date'];
                                    return FutureBuilder(
                                      future: _getImage(productID),
                                      builder: (BuildContext context, AsyncSnapshot<String> imageURL) {
                                        if (imageURL.connectionState != ConnectionState.done) {
                                          return _circularProgressIndicator;
                                        }
                                        ///if image url contains no data (meaning there is no product image)
                                        ///then defaulted asset image is displayed
                                        ///under 'Assets/no image product.png'
                                        return Slidable(
                                          actionPane: SlidableDrawerActionPane(),
                                          actionExtentRatio: 0.22,
                                          direction: Axis.horizontal,
                                          actions: <Widget>[
                                            //add to cart
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
                                                ///showing snackbar upon completion
                                                _scaffoldKeyWishList.currentState.showSnackBar(
                                                    SnackBar(
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
                                                            // var productList = [];
                                                            // groupBy(globals.userCart.
                                                            // map((e) => e.name)
                                                            //     .toList(), (p) => p)
                                                            //     .forEach((key, value) =>
                                                            //     productList.add(key.toString() + '  x' + value.length.toString()));
                                                            return CustomDialogBox();
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                );
                                              },
                                            ),
                                            // Share
                                            IconSlideAction(
                                              caption: 'Share',
                                              color: Colors.transparent,
                                              foregroundColor: Colors.blueAccent,
                                              icon: Icons.share_outlined,
                                              onTap: () async {
                                                if(imageURL.hasData && "" != imageURL.data) {
                                                  final RenderBox box = _scaffoldKeyWishList.currentContext.findRenderObject();
                                                  if (Platform.isAndroid) {
                                                    var response = await get(imageURL.data);
                                                    final documentDirectory = (await getExternalStorageDirectory()).path;
                                                    File imgFile = new File('$documentDirectory/flutter.png');
                                                    imgFile.writeAsBytesSync(response.bodyBytes);
                                                    List<String> sharingList = new List();
                                                    sharingList.add('$documentDirectory/flutter.png');
                                                    //TODO: add store's name next to product's name or add a direct url share option
                                                    await Share.shareFiles(
                                                        sharingList,
                                                        text: "check this cool product now!\n" + prodName,
                                                        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
                                                        subject: 'I found a lovely product on GiftHub!'
                                                    );
                                                  }
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
                                            // Delete
                                            IconSlideAction(
                                              caption: 'Delete',
                                              color: Colors.transparent,
                                              foregroundColor: Colors.red,
                                              icon: Icons.delete_outline_outlined,
                                              onTap: () async {
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
                                                              ///so that orders list will be updated
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
                                            leading: imageURL.hasData && imageURL.data != ""
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
                                            title: Text(prodName,
                                              style: GoogleFonts.lato(
                                                fontSize: 18.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                            subtitle: Text(prodPrice + "\$",
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
    );
  }

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

  bool _isCounter(AsyncSnapshot<DocumentSnapshot> snapshot){
    if(!snapshot.hasData){
      return false;
    }
    return snapshot.data.id == 'Counter';
  }
}