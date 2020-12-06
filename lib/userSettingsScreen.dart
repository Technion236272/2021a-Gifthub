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


class UserSettingsScreen extends StatefulWidget {
  UserSettingsScreen({Key key}) : super(key: key);

  @override
  _UserSettingsScreenState createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKeyUserScreenSet = new GlobalKey<ScaffoldState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _creditCardController = TextEditingController();
  final FocusNode _firstNameInputFocusNode = FocusNode();
  final FocusNode _lastNameInputFocusNode = FocusNode();
  final FocusNode _addressInputFocusNode = FocusNode();
  bool _firstNameChanged = false;
  bool _lastNameChanged = false;
  String _newFirstName = "";
  String _newLastName = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.lightGreen,
      child: Consumer<UserRepository>(
        builder:(context, userRep, _) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            resizeToAvoidBottomPadding: false,
            backgroundColor: Colors.lightGreen[900],
            key: _scaffoldKeyUserScreenSet,
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.lightGreen[900],
              leading: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: null //TODO: implement navigation drawer
              ),
              title: Text("Settings"),
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.green[600],
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 20),
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
                                                Navigator.pop(_scaffoldKeyUserScreenSet.currentContext);
                                                if (null == photo) {
                                                  _scaffoldKeyUserScreenSet.currentState.showSnackBar(
                                                      SnackBar(content:
                                                      Text("No image selected",
                                                        style: GoogleFonts.notoSans(fontSize: 14.0),
                                                      ),
                                                        behavior: SnackBarBehavior.floating,
                                                        duration: Duration(milliseconds: 2500),
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
                                                  _scaffoldKeyUserScreenSet.currentState.showSnackBar(
                                                      SnackBar(content:
                                                      Text("No image selected",
                                                        style: GoogleFonts.notoSans(fontSize: 14.0),
                                                      ),
                                                        behavior: SnackBarBehavior.floating,
                                                        duration: Duration(milliseconds: 2500),
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
                                                      _scaffoldKeyUserScreenSet.currentState.showSnackBar(
                                                          SnackBar(content:
                                                          Text("No image selected",
                                                            style: GoogleFonts.notoSans(fontSize: 14.0),
                                                          ),
                                                            behavior: SnackBarBehavior.floating,
                                                            duration: Duration(milliseconds: 2500),
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
                                                      _scaffoldKeyUserScreenSet.currentState.showSnackBar(
                                                          SnackBar(content:
                                                          Text("No image selected",
                                                            style: GoogleFonts.notoSans(fontSize: 14.0),
                                                          ),
                                                            behavior: SnackBarBehavior.floating,
                                                            duration: Duration(milliseconds: 2500),
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
                        SizedBox(height: 15,),
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
                                          autofocus: false,
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
                                          controller: _firstNameChanged
                                            ? (_firstNameController..text = _newFirstName)
                                            : (_firstNameController..text = userRep.firstName),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))
                                          ],
                                          focusNode: _firstNameInputFocusNode,
                                          onSubmitted: (text) {
                                            if(text.isNotEmpty) {
                                              setState(() {
                                                _newFirstName = text;
                                                _firstNameChanged = true;
                                                // _firstNameController.text = text;
                                              });
                                            }
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
                                          autofocus: false,
                                          focusNode: _lastNameInputFocusNode,
                                          keyboardType: TextInputType.name,
                                          decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))
                                          ],
                                          textAlign: TextAlign.center,
                                          controller: _lastNameChanged
                                            ? (_lastNameController..text = _newLastName)
                                            : (_lastNameController..text = userRep.lastName),
                                          onSubmitted: (text) {
                                            if (text.isNotEmpty){
                                              setState(() {
                                                _newLastName = text;
                                                _lastNameChanged = true;
                                              });
                                            }
                                          },
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
                              //TODO: think about how validate correct input for address
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              focusNode: _addressInputFocusNode,
                              controller: _addressController..text = userRep.address,
                              autofocus: false,
                              keyboardType: TextInputType.streetAddress,
                              onChanged: (text) => {},
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 16.0,
                                color: Colors.white
                              )
                            ),
                          ],
                        ),
                        SizedBox(height: 30,),
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
                        SizedBox(height: 55,),
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
                ),
              ),
            ),
          );
        }
      )
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lastNameInputFocusNode.dispose();
    _firstNameInputFocusNode.dispose();
    _addressInputFocusNode.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _addressController.dispose();
    _creditCardController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final value = WidgetsBinding.instance.window.viewInsets.bottom;
    if(0 == value) {
      _addressInputFocusNode.unfocus();
      _firstNameInputFocusNode.unfocus();
      _lastNameInputFocusNode.unfocus();
    }
  }
}
