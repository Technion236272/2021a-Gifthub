import 'dart:ui';
import 'userMock.dart'; //TODO: remove as soon as user repository class is implemented
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'globals.dart' as globals;

class StoreScreen extends StatefulWidget {
  StoreScreen({Key key}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyUserScreenSet = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {

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
                  image: AssetImage("assets/images/birthday_cake.jpg")
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                  "Description of the store",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16.0,
                    color: Colors.white,
                  )
              ), //TODO: Pull from databse
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text("Store Address",
                        textAlign: TextAlign.start,
                        style: GoogleFonts.montserrat(
                          fontSize: 16.0,
                          color: Colors.white,
                        )),
                  ),
                  IconButton(icon: Icon(Icons.navigation, color: Colors.white), onPressed: null),
                  IconButton(icon: Icon(Icons.phone, color: Colors.white), onPressed: null),
                ],
              ),
            ),
            SizedBox(width: 10),
            RatingBar(
              initialRating: 3.5,
              //TODO: pull from store database
              direction: Axis.horizontal,
              allowHalfRating: true,
              ignoreGestures: true,
              itemCount: 5,
              ratingWidget: RatingWidget(
                full: Icon(Icons.star, color: Colors.red),
                half: Icon(Icons.star_half, color: Colors.red),
                empty: Icon(Icons.star_border, color: Colors.red),
              ),
              onRatingUpdate: (rating) {},
              itemPadding: EdgeInsets.symmetric(horizontal: 10.0),
            ),
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
              child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ListTile(
                      title: Text("Bad store!", style: globals.niceFont()),
                      subtitle: Text("Karen Smith", style: globals.niceFont(size: 12)),
                      leading: RatingBar(
                          itemSize: 20.0,
                          wrapAlignment: WrapAlignment.center,
                          initialRating: 1,
                          //TODO: pull from store database
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          ignoreGestures: true,
                          itemCount: 5,
                          ratingWidget: RatingWidget(
                            full: Icon(Icons.star, color: Colors.red),
                            half: Icon(Icons.star_half, color: Colors.red),
                            empty: null,
                          ),
                        onRatingUpdate: (rating) {},
                      ),
                    ),
                    ListTile(
                      title: Text("Great store!", style: globals.niceFont()),
                      subtitle: Text("John Wick", style: globals.niceFont(size: 12)),
                      leading: RatingBar(
                          itemSize: 20.0,
                          wrapAlignment: WrapAlignment.center,
                          initialRating: 4,
                          //TODO: pull from store database
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          ignoreGestures: true,
                          itemCount: 5,
                          ratingWidget: RatingWidget(
                            full: Icon(Icons.star, color: Colors.red),
                            half: Icon(Icons.star_half, color: Colors.red),
                            empty: null,
                          ),
                        onRatingUpdate: (rating) {},
                      ),
                    ),
                  ]
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
      crossAxisCount: 2,
      children: <Widget>[
        Center(
          child: Text("Hello", style: globals.niceFont()),
        ),
        Center(
            child: Text("Hello", style: globals.niceFont())
        ),
        Center(
            child: Text("Hello", style: globals.niceFont())
        ),
        Center(
            child: Text("Hello", style: globals.niceFont())
        ),
        Center(
            child: Text("Hello", style: globals.niceFont())
        ),
        Center(
            child: Text("Hello", style: globals.niceFont())
        ),
        Center(
            child: Text("Hello", style: globals.niceFont())
        ),

      ],
    );
    return Material(
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
                  title: Text("Generic Store"), //TODO: pull store name from database
                  bottom: TabBar(
                    tabs: [
                      Tab(text: "Items"),
                      Tab(text: "About"),
                    ],
                    indicatorColor: Colors.red,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                  )
                ),

                body: TabBarView(
                  children: [
                    itemsTab,
                    aboutTab,
                  ]
                )
              );
            }
        )
    );
  }
}
