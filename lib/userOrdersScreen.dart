import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:ui';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gifthub_2021a/ProductScreen.dart';
import 'package:gifthub_2021a/productMock.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:io';
import 'user_repository.dart';
import 'package:gifthub_2021a/globals.dart' as globals;
import 'checkoutScreen.dart';
import 'package:collection/collection.dart';

class UserOrdersScreen extends StatefulWidget {
  UserOrdersScreen({Key key}) : super(key: key);

  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyOrders = new GlobalKey<ScaffoldState>();
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;
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
        builder: (context, userRep, _) {
          return FutureBuilder(
            future: FirebaseFirestore.instance.collection("Orders").doc(userRep.user.uid).get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return _circularProgressIndicator;
              } else if (!snapshot.hasData || 0 == snapshot.data.data()['Products'].length) {
                return globals.emptyListErrorScreen(context, 'Orders');
              }
              int totalProducts = snapshot.data.data()['Products'].length;
              return Scaffold(
                key: _scaffoldKeyOrders,
                resizeToAvoidBottomInset: false,
                resizeToAvoidBottomPadding: false,
                backgroundColor: Colors.lightGreen[800],
                body: SingleChildScrollView(
                  child:  Column(
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
                          padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight * 2 + 7),
                          color: Colors.white,
                          child: ListView.builder(
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
                              var ordersProduct = snapshot.data.data()['Products'];
                              String prodName = ordersProduct[i ~/ 2]['name'];
                              String prodPrice = ordersProduct[i ~/ 2]['price'];
                              String prodDate = ordersProduct[i ~/ 2]['Date'];
                              String prodID = ordersProduct[i ~/ 2]['productID'];
                              String prodQuantity = ordersProduct[i ~/ 2]['quantity'];
                              return FutureBuilder(
                                future: _getImage(prodID),
                                builder: (BuildContext context, AsyncSnapshot<String> imageURL) {
                                  if (snapshot.connectionState != ConnectionState.done) {
                                    return _circularProgressIndicator;
                                  }
                                  ///if image url contains no data (meaning there is no product image)
                                  ///then defaulted asset image is displayed
                                  ///under 'Assets/no image product.png'
                                  return Slidable(
                                    showAllActionsThreshold: 0.5,
                                    actionPane: SlidableDrawerActionPane(),
                                    fastThreshold: 2.0,
                                    actionExtentRatio: 0.22,
                                    direction: Axis.horizontal,
                                    actions: <Widget>[
                                      //Reorder
                                      IconSlideAction(
                                        caption: 'Reorder',
                                        color: Colors.transparent,
                                        foregroundColor: Colors.amberAccent,
                                        icon: Icons.attach_money_outlined,
                                        onTap: () {
                                          globals.userCart.add(globals.Product(
                                            prodID,
                                            userRep.user.uid,
                                            prodName,
                                            double.parse(prodPrice),
                                            prodDate, [], "", "")
                                          );
                                          _scaffoldKeyOrders.currentState.showSnackBar(
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
                                                    var productList = [];
                                                    groupBy(globals.userCart.
                                                      map((e) => e.name)
                                                      .toList(), (p) => p)
                                                      .forEach((key, value) =>
                                                        productList.add(key.toString() + '  x' + value.length.toString()));
                                                    return CustomDialogBox();
                                                  },
                                                ),
                                              ),
                                            )
                                          );
                                        },
                                      ),
                                      //Write review
                                      IconSlideAction(
                                        caption: 'Write review',
                                        color: Colors.transparent,
                                        foregroundColor: Colors.lime,
                                        icon: Icons.star_half_outlined,
                                        onTap: () {
                                          showModalBottomSheet<dynamic>(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: MediaQuery.of(context).viewInsets.bottom
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    SizedBox(height: 10,),
                                                    RatingBar.builder(
                                                      initialRating: 1,
                                                      itemCount: 5,
                                                      minRating: 1,
                                                      direction: Axis.horizontal,
                                                      allowHalfRating: true,
                                                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                      itemBuilder: (context, __) {
                                                        return Icon(
                                                          Icons.star,
                                                          color: Colors.lightGreen[800],
                                                        );
                                                      },
                                                      onRatingUpdate: (r) {
                                                        _rating = r;
                                                      }
                                                    ),
                                                    SizedBox(height: 15.0,),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width - 45,
                                                      height: 150,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(4.0))
                                                      ),
                                                      child: TextField(
                                                        controller: _reviewController,
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
                                                            //TODO: upload review to DB
                                                            var listToAdd = [];
                                                            listToAdd.add(
                                                              {
                                                                'content': _reviewController.text,
                                                                'rating': _rating.toString(),
                                                                'user': userRep?.user?.uid ?? ""
                                                              });
                                                            await userRep.firestore
                                                                .collection('Products')
                                                                .doc(prodID).update(
                                                              {'reviews': FieldValue.arrayUnion(listToAdd)}
                                                            );
                                                            Navigator.of(context).pop();
                                                            _scaffoldKeyOrders.currentState.showSnackBar(
                                                              SnackBar(
                                                                content: Text('Review Uploaded Successfully',
                                                                  style: GoogleFonts.lato(
                                                                    fontSize: 13.0
                                                                  ),
                                                                ),
                                                                behavior: SnackBarBehavior.floating,
                                                              )
                                                            );
                                                          },
                                                          child: Text(
                                                            "Submit",
                                                            textAlign: TextAlign.center,
                                                            style: GoogleFonts.openSans(
                                                              fontSize: 16.0,
                                                              fontWeight: FontWeight.bold,
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
                                        },
                                      ),
                                      //share
                                      IconSlideAction(
                                        caption: 'Share to...',
                                        color: Colors.transparent,
                                        foregroundColor: Colors.blueAccent,
                                        icon: Icons.share_outlined,
                                        onTap: () async {
                                          if(imageURL.hasData && imageURL.data != "") {
                                            final RenderBox box = _scaffoldKeyOrders
                                                .currentContext
                                                .findRenderObject();
                                            if (Platform.isAndroid) {
                                              var response = await get(
                                                  imageURL.data);
                                              final documentDirectory = (await getExternalStorageDirectory())
                                                  .path;
                                              File imgFile = new File(
                                                  '$documentDirectory/flutter.png');
                                              imgFile.writeAsBytesSync(
                                                  response.bodyBytes);
                                              List<String> sharingList = new List();
                                              sharingList.add(
                                                  '$documentDirectory/flutter.png');
                                              //TODO: add store's name next to product's name or add a direct url share option
                                              await Share.shareFiles(
                                                  sharingList,
                                                  text: "check this cool product now!\n" +
                                                      prodName,
                                                  sharePositionOrigin: box
                                                      .localToGlobal(
                                                      Offset.zero) & box.size,
                                                  subject: 'I found a lovely product on Gifthub!'
                                              );
                                            }
                                          } else {
                                            try {
                                              final RenderBox box = _scaffoldKeyOrders.currentContext.findRenderObject();
                                              String image = 'no image product.png';
                                              final List <String> list = [];
                                              final tempDir = await getTemporaryDirectory();
                                              list.add('${tempDir.path}/' + image);
                                              await Share.shareFiles(
                                                list,
                                                text: "check this cool product now!\n" + prodName,
                                                sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
                                                subject: 'I found a lovely product on Gifthub!'
                                              );
                                            } catch (_) {}
                                          }
                                        },
                                      )
                                    ],
                                    secondaryActions: <Widget>[
                                    //delete
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
                                                      var toRemoveItem = ordersProduct[i ~/ 2];
                                                      toRemoveList.add(toRemoveItem);
                                                      await userRep.firestore
                                                          .collection('Orders')
                                                          .doc(userRep.user.uid)
                                                          .update({
                                                        'Products':FieldValue.arrayRemove(toRemoveList)
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
                                        }
                                      ),
                                    ],
                                    child: ListTile(
                                      leading: imageURL.hasData && imageURL.data != ""
                                      ? CircularProfileAvatar(
                                        imageURL.data,
                                        radius: 26.0,
                                        onTap: () {
                                          Navigator.of(context).push(new MaterialPageRoute<void>(
                                            builder: (BuildContext context) => Dismissible(
                                              key: const Key('keyV'),
                                              direction: DismissDirection.vertical,
                                              onDismissed: (_) => Navigator.pop(context),
                                              child: Dismissible(
                                                key: const Key('keyH'),
                                                direction: DismissDirection.horizontal,
                                                onDismissed: (_) => Navigator.pop(context),
                                                child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(imageURL.data),
                                                        fit: BoxFit.fitWidth,
                                                      )
                                                    )
                                                ),
                                              ),
                                            ),
                                          )
                                          );
                                        },
                                      )
                                      : ClipRRect(
                                        borderRadius: BorderRadius.circular(26.0),
                                        child: Image.asset('Assets/no image product.png'),
                                      ),
                                      title: Text(prodName + '  x' + prodQuantity,
                                        style: GoogleFonts.lato(
                                          fontSize: 18.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      subtitle: Text(prodPrice + "\$  |  " +
                                          prodDate + "  |  " +
                                          OrderStatus.values[i % 4].toString().substring(12),
                                        style: GoogleFonts.lato(
                                          fontSize: 12.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      onTap: () => Navigator.of(context).push(
                                        new MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return ProductScreen(prodID);
                                          }
                                        )
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          ),
                        ),
                      ),
                    ]
                  ),
                )
              );
            }
          );
        }
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

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}