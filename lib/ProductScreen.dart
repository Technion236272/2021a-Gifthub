import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'globals.dart' as globals;

class ProductScreen extends StatefulWidget {
  ProductScreen({Key key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.lightGreen,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            resizeToAvoidBottomPadding: false,
            backgroundColor: Colors.lightGreen[600],
            appBar: AppBar(
                backgroundColor: Colors.lightGreen[900],
                leading: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: null //TODO: implement navigation drawer
                ),
                title: Text("Generic Product"), //TODO: pull product name from database
            ),

            body: SingleChildScrollView(
              child: Column(
                children: [
                  Image(
                    width: MediaQuery.of(context).size.width,
                    image: AssetImage('assets/images/birthday_cake.jpg'),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "Description of the product",
                    style: globals.niceFont(size: 14.0),
                  ),
                  SizedBox(height: 10.0),
                  InkWell(
                    child: Text("Seller Name", style: globals.niceFont(size: 14.0, color: Colors.red[900]),), // TODO should be the seller's name from firestore
                    onTap: () => {}, //TODO should be a push of the seller's store screen
                  ),
                  SizedBox(height: 20.0),
                  globals.fixedStarBar(4.0),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      globals.regButton("Contact Seller", icon: Icon(Icons.mail_outline), buttonColor: Colors.white, textColor: Colors.red),
                      globals.regButton("Add to Cart", icon: Icon(Icons.add_shopping_cart_outlined)),
                    ]
                  )
                ],
              ),
            ),
        )
    );
  }
}
