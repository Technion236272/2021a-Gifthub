import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gifthub_2021a/user_repository.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'my_flutter_app_icons.dart';

class Constants {
  Constants._();

  static const double padding = 20;
  static const double avatarRadius = 45;
}

class CustomDialogBox extends StatefulWidget {
  final String title = "Shopping Cart", text = "Checkout";

  const CustomDialogBox({Key key,})
      : super(key: key);

  ///YOU CALL THIS DIALOG BOX LIKE THIS:
  ///
  /// showDialog(context: context,
  ///   builder: (BuildContext context){
  ///     return CustomDialogBox();
  ///   }
  /// )

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
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
    List<String> productList = [];
    groupBy(globals.userCart.
    map((e) => e.name)
        .toList(), (p) => p)
        .forEach((key, value) => productList.add(key.toString() + '  x' + value.length.toString()));
    double price = globals.userCart
        .map<double>((e) => e.price)
        .toList()
        .fold<double>(0.0, (previousValue, element) => previousValue + element);
    return Stack(
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
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
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
                      title: Text(productList[index]),
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
              Flexible(
                child: InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    var ordersToAdd = [];
                    globals.userCart.forEach((element) {
                      ordersToAdd.add({
                        'Date': DateFormat("dd-MM-yyyy").format(DateTime.now()),
                        'name': element.name,
                        'price': element.price.toString(),
                        'productID': element.productId,
                        'quantity': _getQuantity(element.name, productList)
                      });
                    });
                    await FirebaseFirestore.instance.collection('Orders')
                        .doc(Provider.of<UserRepository>(context, listen: false).user.uid)
                        .update({'Orders': FieldValue.arrayUnion(ordersToAdd)});
                    globals.userCart.clear();
                    Navigator.of(context).pop();
                    //TODO: make cool animation - prob. Sprint 2
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        bottom: MediaQuery.of(context).size.height * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.red,
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
    );
  }
  
  String _getQuantity(String name, List<String> list){
    for(String p in list) {
      if (name == p.split('  x')[0]) {
        return p.split('  x')[1];
      }
    }
    return "1"; ///shouldn't get here
  }
}