import 'dart:ui';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.lightGreen,
      child: Consumer<UserRepository>(
        builder:(context, userRep, _) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            resizeToAvoidBottomPadding: false,
            backgroundColor: Colors.lightGreen[800],
            key: _scaffoldKeyUserScreenSet,
            appBar: AppBar(
              backgroundColor: Colors.green,
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
                  SizedBox(height: 10,),
                  CircularProfileAvatar(
                    userRep.avatarURL ??
                        'https://www.flaticon.com/svg/static/icons/svg/848/848043.svg',
                    borderColor: Colors.red,
                    radius: MediaQuery.of(context).size.height * 0.1,
                    initialsText: Text(
                      "Press to change",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato()
                    ),
                    onTap: () {
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
                  SizedBox(height: 20,),
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
                                      fontSize: 16.0
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: 200.0,
                                  width: MediaQuery.of(context).size.width * 0.5 - 10,
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: _firstNameController..text = userRep.firstName,
                                    onChanged: (text) => {},
                                    style: GoogleFonts.lato(
                                      fontSize: 16.0
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
                                        fontSize: 16.0
                                      )
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: 200.0,
                                  width: MediaQuery.of(context).size.width * 0.5 - 10,
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: _lastNameController..text = userRep.lastName,
                                    onChanged: (text) => {},
                                    style: GoogleFonts.lato(
                                      fontSize: 16.0
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
                  Expanded(
                    flex: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Address',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 16.0
                            )
                        ),
                        TextField(
                            controller: _addressController..text = userRep.address,
                            onChanged: (text) => {},
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: 16.0
                            )
                        ),
                      ],
                    ),
                  ),
                  Expanded(flex: 0, child: SizedBox(height: 40,)),
                  Expanded(
                    flex: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Credit card number',
                            style: GoogleFonts.montserrat(
                              fontSize: 16.0
                            )
                        ),
                        Text("**** **** **** " + userRep.creditCard.substring(16),
                            style: GoogleFonts.lato(
                              fontSize: 16.0
                            )
                        ),
                        Divider(
                          color: Colors.black,
                          thickness: 0.75,
                        )
                      ],
                    ),
                  ),
                  Expanded(flex: 0, child: SizedBox(height: 45,)),
                  Expanded(
                    flex: 0,
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: FlatButton(
                        minWidth: 185,
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
                  Expanded(flex: 0, child: SizedBox(height: 20,)),
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
  String _avatarURL = "https://www.google.com/imgres?imgurl=https%3A%2F%2Fwww.fcbarcelona.com%2Fphoto-resources%2F2020%2F02%2F19%2Fd8f54b57-05d8-46bc-854e-014d7a9a9e46%2F2635_01_24.jpg%3Fwidth%3D1200%26height%3D750&imgrefurl=https%3A%2F%2Fwww.fcbarcelona.fr%2Ffr%2Ffootball%2Fequipe-premiere%2Fnews%2F1615168%2Fthe-big-read-maradona-the-fc-barcelona-years&tbnid=dS5D2TWl_UH_EM&vet=12ahUKEwidhtLVsqjtAhVFZxoKHRf2BC4QMygEegUIARCrAQ..i&docid=LkJfkaAEThuezM&w=1200&h=750&q=maradona&ved=2ahUKEwidhtLVsqjtAhVFZxoKHRf2BC4QMygEegUIARCrAQ";
  String _firstName = "Josef";
  String _lastName = "Gil";
  String _address = "Lisp st. 23, Prolog City";
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