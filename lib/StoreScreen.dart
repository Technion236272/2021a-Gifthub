import 'dart:ui';
import 'userMock.dart'; //TODO: remove as soon as user repository class is implemented
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class StoreScreen extends StatefulWidget {
  StoreScreen({Key key}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyUserScreenSet = new GlobalKey<ScaffoldState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _creditCardController = TextEditingController();
  bool _firstNameChanged = false;
  bool _lastNameChanged = false;
  String _newFirstName = "";
  String _newLastName = "";

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.lightGreen,
        child: Consumer<UserRepository>(
            builder:(context, userRep, _) {
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
                ),
                body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 20,),
                      // Stack(
                      //   alignment: Alignment.center,
                      //   children: <Widget> [
                      //     CircularProfileAvatar(
                      //       userRep.avatarURL ??
                      //           'https://www.flaticon.com/svg/static/icons/svg/848/848043.svg',
                      //       borderColor: Colors.red,
                      //       borderWidth: 1.3,
                      //       radius: MediaQuery.of(context).size.height * 0.1,
                      //       onTap: () {
                      //         //TODO: add option of avatar removal if exists
                      //         showModalBottomSheet(
                      //             isScrollControlled: true,
                      //             context: context,
                      //             builder: (BuildContext context) {
                      //               return Container(
                      //                 height: 117,
                      //                 child: Column(
                      //                   textDirection: TextDirection.ltr,
                      //                   mainAxisAlignment: MainAxisAlignment.start,
                      //                   crossAxisAlignment: CrossAxisAlignment.center,
                      //                   children: <Widget>[
                      //                     //TODO: initialize firebase so that pictures can be added
                      //                     ListTile(
                      //                       tileColor: Colors.white,
                      //                       leading: Icon(
                      //                         Icons.photo_camera,
                      //                         color: Colors.red,
                      //                       ),
                      //                       title: Text("Take a new photo",
                      //                         style: GoogleFonts.lato(),
                      //                       ),
                      //                       onTap: () async {
                      //                         PickedFile photo = await ImagePicker()
                      //                             .getImage(source: ImageSource.camera);
                      //                         Navigator.pop(context);
                      //                         if (null == photo) {
                      //                           Scaffold.of(context).showSnackBar(
                      //                               SnackBar(content:
                      //                               Text("No image selected",
                      //                                 style: GoogleFonts.notoSans(fontSize: 18.0),
                      //                               ),
                      //                                 behavior: SnackBarBehavior.floating,
                      //                               )
                      //                           );
                      //                         } else {
                      //                           setState(() {
                      //                             userRep.avatarURL = photo.path;
                      //                           });
                      //                         }
                      //                       },
                      //                     ),
                      //                     ListTile(
                      //                       tileColor: Colors.white,
                      //                       leading: Icon(
                      //                         Icons.photo_size_select_actual_rounded,
                      //                         color: Colors.red,
                      //                       ),
                      //                       title: Text("Select from gallery",
                      //                         style: GoogleFonts.lato(),
                      //                       ),
                      //                       onTap: () async {
                      //                         PickedFile photo = await ImagePicker()
                      //                             .getImage(source: ImageSource.gallery);
                      //                         Navigator.pop(context);
                      //                         if (null == photo) {
                      //                           Scaffold.of(context).showSnackBar(
                      //                               SnackBar(content:
                      //                               Text("No image selected",
                      //                                 style: GoogleFonts.notoSans(fontSize: 18.0),
                      //                               ),
                      //                                 behavior: SnackBarBehavior.floating,
                      //                               )
                      //                           );
                      //                         } else {
                      //                           setState(() {
                      //                             userRep.avatarURL = photo.path;
                      //                           });
                      //                         }
                      //                       },
                      //                     ),
                      //                   ],
                      //                 ),
                      //               );
                      //             }
                      //         );  //showModalBottomSheet
                      //       },
                      //     ),
                      //     Column(
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: <Widget>[
                      //           SizedBox(height: 50,),
                      //           InkWell(
                      //             onTap: () {
                      //               //TODO: add option of avatar removal if exists
                      //               showModalBottomSheet(
                      //                   isScrollControlled: true,
                      //                   context: context,
                      //                   builder: (BuildContext context) {
                      //                     return Container(
                      //                       height: 117,
                      //                       child: Column(
                      //                         textDirection: TextDirection.ltr,
                      //                         mainAxisAlignment: MainAxisAlignment.start,
                      //                         crossAxisAlignment: CrossAxisAlignment.center,
                      //                         children: <Widget>[
                      //                           //TODO: initialize firebase so that pictures can be added
                      //                           ListTile(
                      //                             tileColor: Colors.white,
                      //                             leading: Icon(
                      //                               Icons.photo_camera,
                      //                               color: Colors.red,
                      //                             ),
                      //                             title: Text("Take a new photo",
                      //                               style: GoogleFonts.lato(),
                      //                             ),
                      //                             onTap: () async {
                      //                               PickedFile photo = await ImagePicker()
                      //                                   .getImage(source: ImageSource.camera);
                      //                               Navigator.pop(context);
                      //                               if (null == photo) {
                      //                                 Scaffold.of(context).showSnackBar(
                      //                                     SnackBar(content:
                      //                                     Text("No image selected",
                      //                                       style: GoogleFonts.notoSans(fontSize: 18.0),
                      //                                     ),
                      //                                       behavior: SnackBarBehavior.floating,
                      //                                     )
                      //                                 );
                      //                               } else {
                      //                                 setState(() {
                      //                                   userRep.avatarURL = photo.path;
                      //                                 });
                      //                               }
                      //                             },
                      //                           ),
                      //                           ListTile(
                      //                             tileColor: Colors.white,
                      //                             leading: Icon(
                      //                               Icons.photo_size_select_actual_rounded,
                      //                               color: Colors.red,
                      //                             ),
                      //                             title: Text("Select from gallery",
                      //                               style: GoogleFonts.lato(),
                      //                             ),
                      //                             onTap: () async {
                      //                               PickedFile photo = await ImagePicker()
                      //                                   .getImage(source: ImageSource.gallery);
                      //                               Navigator.pop(context);
                      //                               if (null == photo) {
                      //                                 Scaffold.of(context).showSnackBar(
                      //                                     SnackBar(content:
                      //                                     Text("No image selected",
                      //                                       style: GoogleFonts.notoSans(fontSize: 18.0),
                      //                                     ),
                      //                                       behavior: SnackBarBehavior.floating,
                      //                                     )
                      //                                 );
                      //                               } else {
                      //                                 setState(() {
                      //                                   userRep.avatarURL = photo.path;
                      //                                 });
                      //                               }
                      //                             },
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     );
                      //                   }
                      //               );  //showModalBottomSheet
                      //             },
                      //             child: Container(
                      //               width: MediaQuery.of(context).size.height * 0.18,
                      //               decoration: BoxDecoration(
                      //                 borderRadius: BorderRadius.all(Radius.circular(20)),
                      //                 color: Colors.black45,
                      //               ),
                      //               child: Text(
                      //                 "Press to change",
                      //                 textAlign: TextAlign.center,
                      //                 style: GoogleFonts.lato(),
                      //               ),
                      //             ),
                      //           ),
                      //         ]
                      //     )
                      //   ],
                      // ),
                      Container(
                          child: Image(
                              height: 40,
                              width: 40,
                              image: AssetImage("assets/birthday_cake.jpg")
                          ),
                      ),
                      SizedBox(height: 30,),
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
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Expanded(
                            child: Text("Store Address",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                )),
                          ),
                          IconButton(icon: Icon(Icons.navigation, color: Colors.white), onPressed: null),
                          IconButton(icon: Icon(Icons.phone, color: Colors.white), onPressed: null),
                        ],
                      ),
                      SizedBox(width: 20),
                      RatingBar(
                        initialRating: 3, //TODO: pull from store database
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        ignoreGestures: true,
                        itemCount: 5,
                        ratingWidget: RatingWidget(
                          full: Icon(Icons.star, color: Colors.red),
                          half: Icon(Icons.star_half, color: Colors.red),
                          empty: Icon(Icons.star_border, color: Colors.red),
                        ),
                        itemPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                      SizedBox(height: 40,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('Credit card number',
                              style: GoogleFonts.montserrat(
                                fontSize: 16.0,
                                color: Colors.white,
                              )
                          ),
                          TextField(
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            textAlign: TextAlign.center,
                            controller: _creditCardController..text = "**** **** **** " + userRep.creditCard.substring(15),
                            style: GoogleFonts.lato(
                                fontSize: 16.0,
                                color: Colors.white
                            ),
                            readOnly: true,
                          ),
                        ],
                      ),
                      SizedBox(height: 45,),
                      Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          width: 200,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.red)
                            ),
                            visualDensity: VisualDensity.adaptivePlatformDensity,
                            color: Colors.red,
                            textColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                if(_firstNameChanged){
                                  userRep.firstName = _newFirstName;
                                }
                                if(_lastNameChanged){
                                  userRep.lastName = _newLastName;
                                }
                                userRep.address = _addressController.text;
                              });
                            },
                            child: Text(
                              "Update",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.openSans(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                    ]
                ),
              );
            }
        )
    );
  }
}
