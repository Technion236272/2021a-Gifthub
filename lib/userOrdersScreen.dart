import 'dart:ui';
import 'package:gifthub_2021a/productMock.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'userMock.dart'; //TODO: remove as soon as user repository class is implemented
import 'userOrdersScreen.dart'; //TODO: remove as soon as user repository class is implemented
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class UserOrdersScreen extends StatefulWidget {
  UserOrdersScreen({Key key}) : super(key: key);

  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen>{
  final GlobalKey<ScaffoldState> _scaffoldKeyOrders = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Consumer<UserRepository>(
        builder: (context, userRep, _) {
          //TODO: remove these 3 lines as soon as user firebase initializes:
            userRep.orders.add(new Product("cake", 15.0, OrderStatus.Arrived,
                "https://storcpdkenticomedia.blob.core.windows.net/media/recipemanagementsystem/media/recipe-media-files/recipes/retail/desktopimages/rainbow-cake600x600_2.jpg?ext=.jpg"));
            userRep.orders.add(new Product(
                "18 muffins", 5.0, OrderStatus.Pending,
                "https://pngimg.com/uploads/muffin/muffin_PNG123.png"));
            userRep.orders.add(new Product(
                "rose bouquet", 50.0, OrderStatus.Ordered,
                "https://images-na.ssl-images-amazon.com/images/I/71t3JW2-jzL._SL1500_.jpg"));
          return Scaffold(
            key: _scaffoldKeyOrders,
            resizeToAvoidBottomInset: false,
            resizeToAvoidBottomPadding: false,
            backgroundColor: Colors.lightGreen[900],
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.lightGreen[900],
              leading: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: null //TODO: implement navigation drawer
              ),
              title: Text("Orders",
                /*style: GoogleFonts.robotoSlab(
                  fontSize: 18.0
                ),*/
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 15,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      padding: EdgeInsets.all(12),
                      color: Colors.green[600],
                      child: ListView.builder(
                          itemCount: userRep.orders.length * 2,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (BuildContext _context, int i) {
                            if (i >= userRep.orders.length) {
                              return null;
                            }
                            if (i.isOdd) {
                              return Divider(
                                color: Colors.red,
                                thickness: 2.0,
                              );
                            }
                            return ListTile(
                              trailing: IconButton(
                                icon: Icon(Icons.more_vert),
                                onPressed: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: _scaffoldKeyOrders.currentContext,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 202,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                tileColor: Colors.white,
                                                leading: Icon(
                                                  Icons.attach_money,
                                                  color: Colors.red,
                                                ),
                                                title: Text("Re-order",
                                                  style: GoogleFonts.lato(),
                                                ),
                                                onTap: null, //TODO: navigate to product screen for order
                                              ),
                                              Divider(
                                                color: Colors.red,
                                                indent: 20,
                                                thickness: 2.0,
                                                endIndent: 20,
                                              ),
                                              ListTile(
                                                tileColor: Colors.white,
                                                leading: Icon(
                                                  Icons.send,
                                                  color: Colors.red,
                                                ),
                                                title: Text("Send to...",
                                                  style: GoogleFonts.lato(),
                                                ),
                                                onTap: null //TODO: implement sharing options,
                                              ),
                                              Divider(
                                                indent: 20,
                                                endIndent: 20,
                                                color: Colors.red,
                                                thickness: 2.0,
                                              ),
                                              ListTile(
                                                  tileColor: Colors.white,
                                                  leading: Icon(
                                                    Icons.star,
                                                    color: Colors.red,
                                                  ),
                                                  title: Text("Write review...",
                                                    style: GoogleFonts.lato(),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    showModalBottomSheet<dynamic>(
                                                        context: context,
                                                        isScrollControlled: true,
                                                        builder: (BuildContext context1) {
                                                          return Padding(
                                                            padding: EdgeInsets.only(
                                                                bottom: MediaQuery.of(_scaffoldKeyOrders.currentContext).viewInsets.bottom
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: <Widget>[
                                                                RatingBar.builder(
                                                                    initialRating: 0,
                                                                    itemCount: 5,
                                                                    minRating: 1,
                                                                    direction: Axis.horizontal,
                                                                    allowHalfRating: true,
                                                                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                                    itemBuilder: (context, __) {
                                                                      return Icon(
                                                                        Icons.star,
                                                                        color: Colors.red,
                                                                      );
                                                                    },
                                                                    onRatingUpdate: (rating) {
                                                                      setState(() {

                                                                      });
                                                                    }
                                                                ),
                                                                SizedBox(height: 15.0,),
                                                                Container(
                                                                  width: MediaQuery.of(context1).size.width - 45,
                                                                  height: 150,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                                                                  ),
                                                                  child: TextField(
                                                                    decoration: InputDecoration(
                                                                      hintText: "Write a review...",
                                                                      focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                          color: Colors.red,
                                                                          width: 1.5,
                                                                        ),
                                                                      ),
                                                                      enabledBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                          color: Colors.red,
                                                                          width: 1.5,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    maxLines: null,
                                                                    minLines: 5,
                                                                    keyboardType: TextInputType.multiline,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 10.0,),
                                                                Align(
                                                                  alignment: FractionalOffset.bottomCenter,
                                                                  child: Container(
                                                                    width: 200,
                                                                    child: RaisedButton(
                                                                      color: Colors.white,
                                                                      textColor: Colors.red,
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(18.0),
                                                                          side: BorderSide(
                                                                              color: Colors.red,
                                                                              width: 2.0,
                                                                          )
                                                                      ),
                                                                      visualDensity: VisualDensity.adaptivePlatformDensity,
                                                                      onPressed: () {
                                                                        setState(() {

                                                                        });
                                                                      },
                                                                      child: Text(
                                                                        "Submit",
                                                                        textAlign: TextAlign.center,
                                                                        style: GoogleFonts.openSans(
                                                                            fontSize: 16.0,
                                                                            fontWeight: FontWeight.bold,
                                                                            // color: Colors.red,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                    );
                                                  }
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                  );  //showModalBottomSheet
                                }, //TODO: show modal bottom sheet of options
                              ),
                              leading: CircularProfileAvatar(
                                userRep.orders[i~/2].productPictureURL,
                                radius: 20.0,
                                onTap: null, //TODO: add navigation to product screen when set
                              ),
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(userRep.orders[i~/2].name,
                                    style: GoogleFonts.lato(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  SizedBox(height: 6,),
                                  Text(userRep.orders[i~/2].price.toString() + "\$  |  " +
                                    userRep.orders[i~/2].dateOfOrder + "  |  " +
                                    userRep.orders[i~/2].orderStatus.toString().substring(12),
                                    style: GoogleFonts.lato(
                                      fontSize: 11.0,
                                    ),
                                  )
                                ],
                              ),
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
      ),
    );
  }

}