import 'dart:ui';
import 'globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'my_flutter_app_icons.dart';

class Constants {
  Constants._();

  static const double padding = 20;
  static const double avatarRadius = 45;
}

class CustomDialogBox extends StatefulWidget {
  final String title = "Shopping Cart", text = "Checkout";
  final double total;
  final productList;

  const CustomDialogBox({Key key, this.total, this.productList})
      : super(key: key);

  //YOU CALL THIS DIALOG BOX LIKE THIS:
  /*
  showDialog(context: context,
                    builder: (BuildContext context){
                      return CustomDialogBox(total: "45",productList: null,);//TODO: insert the correct total and product list
                    }
   */
  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(top: Constants.avatarRadius + Constants.padding),
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
                Text('\$' + widget.total.toString(),
                    style: GoogleFonts.openSans(
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontWeight: FontWeight.w600)),
                Spacer(),
              ]),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Text(
                // "TODO: PRODUCTS LIST HERE, REMOVE THIS TEXT AND REPLACE WITH A LIST!",
                globals.userCart
                    .map<String>((e) => e.name + '\n')
                    .toList()
                    .fold("", (previousValue, element) => previousValue + element)
                    .toString(),
                style: GoogleFonts.openSans(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              InkWell(
                onTap: () {
                  //TODO: What happens after checkout?
                  Navigator.of(context).pop();
                  //TODO: make cool animation
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
}
