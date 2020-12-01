import 'dart:ui';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserSettingsScreen extends StatefulWidget {
  UserSettingsScreen({Key key}) : super(key: key);

  @override
  _UserSettingsScreenState createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyUserScreenSet = new GlobalKey<ScaffoldState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _creditCardController = TextEditingController();

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
              title: Text("Settings"),
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20,),
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget> [
                      CircularProfileAvatar(
                        userRep.avatarURL ??
                            'https://www.flaticon.com/svg/static/icons/svg/848/848043.svg',
                        borderColor: Colors.red,
                        borderWidth: 1.3,
                        radius: MediaQuery.of(context).size.height * 0.1,
                        onTap: () {
                          //TODO: add option of avatar removal if exists
                          showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 117,
                                  child: Column(
                                    textDirection: TextDirection.ltr,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      //TODO: initialize firebase so that pictures can be added
                                      ListTile(
                                        tileColor: Colors.white,
                                        leading: Icon(
                                          Icons.photo_camera,
                                          color: Colors.red,
                                        ),
                                        title: Text("Take a new photo",
                                          style: GoogleFonts.lato(),
                                        ),
                                        onTap: () async {
                                          PickedFile photo = await ImagePicker()
                                              .getImage(source: ImageSource.camera);
                                          Navigator.pop(context);
                                          if (null == photo) {
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(content:
                                                Text("No image selected",
                                                  style: GoogleFonts.notoSans(fontSize: 18.0),
                                                ),
                                                  behavior: SnackBarBehavior.floating,
                                                )
                                            );
                                          } else {
                                            setState(() {
                                              userRep.avatarURL = photo.path;
                                            });
                                          }
                                        },
                                      ),
                                      ListTile(
                                        tileColor: Colors.white,
                                        leading: Icon(
                                          Icons.photo_size_select_actual_rounded,
                                          color: Colors.red,
                                        ),
                                        title: Text("Select from gallery",
                                          style: GoogleFonts.lato(),
                                        ),
                                        onTap: () async {
                                          PickedFile photo = await ImagePicker()
                                              .getImage(source: ImageSource.gallery);
                                          Navigator.pop(context);
                                          if (null == photo) {
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(content:
                                                Text("No image selected",
                                                  style: GoogleFonts.notoSans(fontSize: 18.0),
                                                ),
                                                  behavior: SnackBarBehavior.floating,
                                                )
                                            );
                                          } else {
                                            setState(() {
                                              userRep.avatarURL = photo.path;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                          );  //showModalBottomSheet
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 50,),
                          InkWell(
                            onTap: () {
                              //TODO: add option of avatar removal if exists
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 117,
                                      child: Column(
                                        textDirection: TextDirection.ltr,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          //TODO: initialize firebase so that pictures can be added
                                          ListTile(
                                            tileColor: Colors.white,
                                            leading: Icon(
                                              Icons.photo_camera,
                                              color: Colors.red,
                                            ),
                                            title: Text("Take a new photo",
                                              style: GoogleFonts.lato(),
                                            ),
                                            onTap: () async {
                                              PickedFile photo = await ImagePicker()
                                                  .getImage(source: ImageSource.camera);
                                              Navigator.pop(context);
                                              if (null == photo) {
                                                Scaffold.of(context).showSnackBar(
                                                    SnackBar(content:
                                                    Text("No image selected",
                                                      style: GoogleFonts.notoSans(fontSize: 18.0),
                                                    ),
                                                      behavior: SnackBarBehavior.floating,
                                                    )
                                                );
                                              } else {
                                                setState(() {
                                                  userRep.avatarURL = photo.path;
                                                });
                                              }
                                            },
                                          ),
                                          ListTile(
                                            tileColor: Colors.white,
                                            leading: Icon(
                                              Icons.photo_size_select_actual_rounded,
                                              color: Colors.red,
                                            ),
                                            title: Text("Select from gallery",
                                              style: GoogleFonts.lato(),
                                            ),
                                            onTap: () async {
                                              PickedFile photo = await ImagePicker()
                                                  .getImage(source: ImageSource.gallery);
                                              Navigator.pop(context);
                                              if (null == photo) {
                                                Scaffold.of(context).showSnackBar(
                                                    SnackBar(content:
                                                    Text("No image selected",
                                                      style: GoogleFonts.notoSans(fontSize: 18.0),
                                                    ),
                                                      behavior: SnackBarBehavior.floating,
                                                    )
                                                );
                                              } else {
                                                setState(() {
                                                  userRep.avatarURL = photo.path;
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                              );  //showModalBottomSheet
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.height * 0.18,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  color: Colors.black45,
                                ),
                                child: Text(
                                  "Press to change",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(),
                                ),
                            ),
                          ),
                        ]
                      )
                    ],
                  ),
                  SizedBox(height: 30,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: SizedBox(
                                  height: 200.0,
                                  width: 100,
                                  child: Text('First name',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16.0,
                                      color: Colors.white
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 200.0,
                                  width: MediaQuery.of(context).size.width * 0.5 - 10,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    onChanged: (text) => {},
                                    textAlign: TextAlign.center,
                                    controller: _firstNameController..text = userRep.firstName,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))
                                    ],
                                    onSubmitted: (text) {
                                      setState(() {
                                        _firstNameController.text = text;
                                      });
                                    },
                                    style: GoogleFonts.lato(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    )
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: SizedBox(
                                  height: 200.0,
                                  width: 100.0,
                                  child: Text('Last name',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16.0,
                                        color: Colors.white,
                                      )
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 200.0,
                                  width: MediaQuery.of(context).size.width * 0.5 - 10,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                    controller: _lastNameController..text = userRep.lastName,
                                    onChanged: (text) => {},
                                    style: GoogleFonts.lato(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    )
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('Address',
                          textAlign: TextAlign.center,
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
                          controller: _addressController..text = userRep.address,
                          onChanged: (text) => {},
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 16.0,
                            color: Colors.white
                          )
                      ),
                    ],
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
                            userRep.firstName = _firstNameController.text;
                            userRep.lastName = _lastNameController.text;
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

/// This is a user mocking for testing purposes only
/// as soon as a user class is implemented, this must be removed
class UserRepository with ChangeNotifier {
  String _avatarURL = "http://www.nretnil.com/avatar/LawrenceEzekielAmos.png";
  String _firstName = "Daddy";
  String _lastName = "Cool";
  String _address = "Crazy like s fool st. 23, Some cool city";
  String _creditCard = "1234 1234 5678 8901";
  Status _status = Status.Authenticated;

  Status get status => _status;

  String get avatarURL => _avatarURL;

  set avatarURL(String value) {
    _avatarURL = value;
  }

  String get firstName => _firstName;

  set firstName(String value) {
    _firstName = value;
  }

  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
  }

  String get address => _address;

  set address(String value) {
    _address = value;
  }

  String get creditCard => _creditCard;

  set creditCard(String value) {
    _creditCard = value;
  }

}