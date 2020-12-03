import 'dart:ui';
import 'package:gifthub_2021a/productMock.dart';

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
          userRep.orders.add(new Product("cake", 15.0, OrderStatus.Arrived, "https://storcpdkenticomedia.blob.core.windows.net/media/recipemanagementsystem/media/recipe-media-files/recipes/retail/desktopimages/rainbow-cake600x600_2.jpg?ext=.jpg"));
          userRep.orders.add(new Product("18 muffins", 5.0, OrderStatus.Pending, "https://pngimg.com/uploads/muffin/muffin_PNG123.png"));
          userRep.orders.add(new Product("rose bouquet", 50.0, OrderStatus.Ordered, "https://images-na.ssl-images-amazon.com/images/I/71t3JW2-jzL._SL1500_.jpg"));
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
                      height: MediaQuery.of(context).size.height - 20,
                      padding: EdgeInsets.all(12),
                      color: Colors.green[600],
                      child: ListView.builder(
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
                                onPressed: null, //TODO: show modal bottom sheet of options
                              ),
                              leading: CircularProfileAvatar(
                                userRep.orders[i~/2].productPictureURL,
                                radius: 20.0,
                                onTap: null, //TODO: add navigation to product screen when set
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