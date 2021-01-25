import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gifthub_2021a/all_confetti_widget.dart';
import 'package:gifthub_2021a/user_repository.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'my_flutter_app_icons.dart';
import 'user_repository.dart';
import 'package:pimp_my_button/pimp_my_button.dart';

class Constants {
  Constants._();

  static const double padding = 20;
  static const double avatarRadius = 45;
}

class CustomDialogBox extends StatefulWidget {
  final String title = "Shopping Cart", text = "Checkout";

  const CustomDialogBox({Key key,})
      : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  bool enableCheckoutButton = true;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.padding),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: contentBox(context),
        ),
      ),
    );
  }

  contentBox(context) {
    ///generating user's shopping cart to be displayed as follows:
    ///Product some_product -> (some_product's name)  x(some_product's quantity in cart)
    List<String> productList = [];
    groupBy(globals.userCart.map((e) => e.name).toList(), (p) => p)
        .forEach((key, value) => productList.add(key.toString() + '  x' + value.length.toString()));
    ///calculating total price of order:
    double price = globals.userCart
        .map<double>((e) => e.price)
        .toList()
        .fold<double>(0.0, (previousValue, element) => previousValue + element);
    return Consumer<UserRepository>(
      builder: (context, userRep, _) => Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: Constants.avatarRadius + Constants.padding),
            margin: EdgeInsets.only(top: Constants.avatarRadius),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(Constants.padding),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 10),
                    blurRadius: 10
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Spacer(flex: 7),
                  Text(widget.title,
                      style: GoogleFonts.openSans(
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                  Spacer(flex: 3),
                  ///total price of order:
                  Text('\$' + price.toStringAsFixed(1),
                      style: GoogleFonts.openSans(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          fontWeight: FontWeight.w600)),
                  Spacer(),
                ]),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: productList.isEmpty ? 0 : productList.length * 2 - 1,
                    itemBuilder: (BuildContext context, int index) {
                      if(index.isOdd){
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.0004,
                          child: Divider(
                            color: Colors.lightGreen,
                            thickness: 1.0,
                            indent: 10,
                            endIndent: 10,
                          ),
                        );
                      }
                      index ~/= 2;
                      return ListTile(
                        ///product's name
                        title: Text(productList[index]),
                        ///product deletion option:
                        trailing: IconButton(
                          onPressed: () {
                            for(globals.Product p in globals.userCart){
                              if(p.name == productList[index].split('  x')[0]){
                                globals.userCart.remove(p);
                                break;
                              }
                            }
                            setState(() {
                              ///setting state so that the cart list will be updated
                            });
                          },
                          icon: Icon(Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04,
                ),
                PimpedButton(
                  particle: DemoParticle(),
                  pimpedWidgetBuilder: (BuildContext context, AnimationController controller) => InkWell(
                    onTap: enableCheckoutButton ? (userRep.status == Status.Authenticated
                  ? () async {
                      ///Fingerprint auth
                      final LocalAuthentication localAuth= LocalAuthentication();
                      if(await localAuth.canCheckBiometrics){
                        try {
                          if (!(await localAuth.authenticateWithBiometrics(
                              localizedReason: "GiftHub Checkout Authentication"))) {
                            return;
                          }
                        } catch(e) {
                          Fluttertoast.showToast(msg: "Too many bad fingerprint attempts!");
                          return;
                        }
                      }
                      controller.forward(from: 0.0);
                      setState(() {
                        enableCheckoutButton = false;
                      });
                      Future.delayed(const Duration(milliseconds: 600), () {
                        Navigator.of(context).pop();
                      });
                      if(null == userRep.user || userRep.status != Status.Authenticated){
                        return Future.delayed(Duration.zero);
                      }
                      ///updating user's order history:
                      var ordersToAdd = [];
                      globals.userCart.forEach((element) {
                        ordersToAdd.add({
                          'Date': DateFormat("dd-MM-yyyy").format(DateTime.now()),
                          'name': element.name,
                          'price': element.price.toString(),
                          'productID': element.productId,
                          'quantity': _getQuantity(element.name, productList),
                          'orderStatus': 'Ordered',
                        });
                      });
                      for(int i = 0; i < ordersToAdd.length; i++){
                        ordersToAdd[i]['wrapping'] = globals.userCartOptions[i]['wrapping'].toString();
                        ordersToAdd[i]['greeting'] = globals.userCartOptions[i]['greeting'];
                        ordersToAdd[i]['fast'] = globals.userCartOptions[i]['fast'].toString();
                        ordersToAdd[i]['special'] = globals.userCartOptions[i]['special'];
                      }
                      await FirebaseFirestore.instance.collection('Orders')
                        .doc(userRep.user.uid)
                        .update({'Orders': FieldValue.arrayUnion(ordersToAdd)});

                      var data = await FirebaseFirestore.instance.collection('Orders')
                          .doc(userRep.user.uid).get();
                      Map newOrders = data.data()['NewOrders'] ?? {};

                      ///updating user's new orders
                      if(newOrders.isEmpty){
                        Map<String, List> map = {};
                        for (int i = 0; i < productList.length; i++) {
                          if(null == map[globals.userCart[i].user]){
                            map[globals.userCart[i].user] = new List();
                          }
                          map[globals.userCart[i].user].add(ordersToAdd[i]);
                        }
                        await FirebaseFirestore.instance.collection('Orders')
                          .doc(userRep.user.uid)
                          .update({'NewOrders': map});
                      } else {
                        for(int i = 0; i < productList.length; i++){
                          if(null == newOrders[globals.userCart[i].user]) {
                            newOrders[globals.userCart[i].user] = new List();
                          }
                          newOrders[globals.userCart[i].user].add(ordersToAdd[i]);
                        }
                        await FirebaseFirestore.instance.collection('Orders')
                          .doc(userRep.user.uid)
                          .update({'NewOrders': newOrders});
                      }

                      ///updating store's order list
                      globals.userCart.forEach((element) async {
                        await FirebaseFirestore.instance
                          .collection('Stores')
                          .doc(element.user)
                          .update({'Ordered' : FieldValue.arrayUnion([userRep.user.uid])});
                      });

                      ///clearing user's cart
                      globals.userCart.clear();
                      globals.userCartOptions.clear();
                    } : () => Fluttertoast.showToast(msg: "Please log in to place an order 😊")) : null,
                    child: Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.02,
                          bottom: MediaQuery.of(context).size.height * 0.02),
                      decoration: BoxDecoration(
                       color: userRep.status == Status.Authenticated && enableCheckoutButton? Colors.red : Colors.grey[850],
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(Constants.padding),
                            bottomRight: Radius.circular(Constants.padding)),
                      ),
                      child: Text(
                        widget.text,
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ///GiftHub logo decoration
          Positioned(
            left: Constants.padding,
            right: Constants.padding,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: Constants.avatarRadius,
              child: ClipRRect(
                  borderRadius:
                  BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                  child: Container(
                    width: MediaQuery.of(context).size.height * 0.15,
                    color: Colors.lightGreenAccent,
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                GiftHubIcons.gift,
                                color: Colors.red,
                                size: MediaQuery.of(context).size.height * 0.06,
                              ),
                              Text(
                                'GiftHub',
                                style: TextStyle(
                                    fontSize:
                                    MediaQuery.of(context).size.height * 0.03,
                                    fontFamily: 'TimesNewRoman',
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )
                            ])),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  ///getting product's quantity on cart
  String _getQuantity(String name, List<String> list){
    for(String p in list) {
      if (name == p.split('  x')[0]) {
        return p.split('  x')[1];
      }
    }
    return "1"; ///shouldn't get here because product has to be on user's cart
  }
}