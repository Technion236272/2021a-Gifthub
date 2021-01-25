import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'all_confetti_widget.dart';
import 'mainScreen.dart';
import 'my_flutter_app_icons.dart';
import 'user_repository.dart';


//Text Controllers for sign up/in fields
final firstNameController = TextEditingController();
final lastNameController = TextEditingController();
final emailController = TextEditingController();
final aptController = TextEditingController();
final cityController = TextEditingController();
final addressController = TextEditingController();
final passwordController = TextEditingController();


bool checkEmailSignupFields() {
  /*
  This function checks that the fields for sign up, it checks that they are not empty and have the right kind of text (for example, email should have '@' after the first section).
  Returns a bool, if everything has passed or not.
   */
  return (emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          cityController.text.isNotEmpty &&
          addressController.text.isNotEmpty &&
          aptController.text.isNotEmpty) &&
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(emailController.text) &&
      passwordController.text.length >= 6;
}

bool checkEmailSigninFields() {
  /*
  This function checks that the fields for sign up, it checks that they are not empty
  Returns a bool, if everything has passed or not.
   */
  return (emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty);
}

bool emailInUse = false;

Future<void> firstSignUpSheet(var context, int screen) async {
  bool clicked=true;
  /**This function shows the bottom sheet when pressing on one of the "Continue with ...".
    Receives the ID of the screen it should show.
    IDs:
    2- Email sign up (shows after trying to sign in with an email that doesnt exist)
    3- Google sign up (shows after trying to sign in with an Google account that doesnt exist in GiftHub's system)
    5- Email sign in screen
    Returns nothing.
   **/
  showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40.0),
        topRight: Radius.circular(40.0),
      )),
      enableDrag: false,
      builder: (context) {
        return Consumer<UserRepository>(
          builder: (context, userRep, _) => StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                ///Email sign up bottom sheet state.
            if (screen == 2) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                    height: 450,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(40),
                            topRight: const Radius.circular(40))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.37,
                              height:
                                  MediaQuery.of(context).size.height * 0.075,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      labelText: 'First Name',
                                      isDense: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                    ),
                                    controller: firstNameController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (text) {
                                      if (text.isEmpty) {
                                        return 'Cannot be empty!';
                                      } else {
                                        return null;
                                      }
                                    },
                                    autofocus: false,
                                    keyboardType: TextInputType.name,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        color: Colors.white)),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.37,
                              height:
                                  MediaQuery.of(context).size.height * 0.075,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      labelText: 'Last Name',
                                      isDense: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                    ),
                                    controller: lastNameController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (text) {
                                      if (text.isEmpty) {
                                        return 'Cannot be empty!';
                                      } else {
                                        return null;
                                      }
                                    },
                                    autofocus: false,
                                    keyboardType: TextInputType.name,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width:
                              MediaQuery.of(context).size.width * 0.37 * 2.25,
                          height: MediaQuery.of(context).size.height * 0.075,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextFormField(
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  labelText: 'Email',
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                ),
                                controller: emailController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text.isEmpty) {
                                    return 'Cannot be empty!';
                                  } else {
                                    if (!RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(text)) {
                                      return 'Email must be valid!';
                                    }
                                    return null;
                                  }
                                },
                                autofocus: false,
                                keyboardType: TextInputType.emailAddress,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    color: Colors.white)),
                          ),
                        ),
                        Container(
                          width:
                              MediaQuery.of(context).size.width * 0.37 * 2.25,
                          height: MediaQuery.of(context).size.height * 0.075,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextFormField(
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  labelText: 'Address',
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                ),
                                controller: addressController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text.isEmpty) {
                                    return 'Cannot be empty!';
                                  } else {
                                    return null;
                                  }
                                },
                                autofocus: false,
                                keyboardType: TextInputType.streetAddress,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    color: Colors.white)),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.37,
                              height:
                                  MediaQuery.of(context).size.height * 0.075,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      labelText: 'City',
                                      isDense: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                    ),
                                    controller: cityController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (text) {
                                      if (text.isEmpty) {
                                        return 'Cannot be empty!';
                                      } else {
                                        return null;
                                      }
                                    },
                                    autofocus: false,
                                    keyboardType: TextInputType.streetAddress,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        color: Colors.white)),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.37,
                              height:
                                  MediaQuery.of(context).size.height * 0.075,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      labelText: 'Apartment',
                                      isDense: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                    ),
                                    controller: aptController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (text) {
                                      if (text.isEmpty) {
                                        return 'Cannot be empty!';
                                      } else {
                                        return null;
                                      }
                                    },
                                    autofocus: false,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        color: Colors.white)),
                              ),
                            )
                          ],
                        ),
                        Container(
                          width:
                              MediaQuery.of(context).size.width * 0.37 * 2.25,
                          height: MediaQuery.of(context).size.height * 0.075,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextFormField(
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  labelText: 'Password',
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                ),
                                controller: passwordController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text.length < 6) {
                                    return 'Password length should be 6 or more!';
                                  }
                                  if (text.isEmpty) {
                                    return 'Cannot be empty!';
                                  } else {
                                    return null;
                                  }
                                },
                                autofocus: false,
                                obscureText: true,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    color: Colors.white)),
                          ),
                        ),
                        FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0)),
                          onPressed: checkEmailSignupFields()
                              ? () async {
                                  if (!checkEmailSignupFields()) return;
                                  String code = await userRep.signUp(
                                    emailController.text,
                                    passwordController.text,
                                    firstNameController.text,
                                    lastNameController.text,
                                    addressController.text,
                                    aptController.text,
                                    cityController.text,
                                  );
                                  if (code == 'Success') {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        new MaterialPageRoute<void>(
                                            builder: (context) => MainScreen()),
                                        (r) => false);
                                  }
                                  if (code == 'email-already-in-use') {}
                                  emailInUse = true;

                                  setState(() {});
                                }
                              : null,
                          color: Colors.red,
                          textColor: Colors.white,
                          child: Text('Sign up',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.03)),
                        )
                      ],
                    )),
              );
            }
            ///After signing in with Google for the first time, this bottom sheet state shows.
            if (screen == 3) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                    height: MediaQuery.of(context).size.width * 0.37 * 2,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(40),
                            topRight: const Radius.circular(40))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.37,
                              height:
                                  MediaQuery.of(context).size.height * 0.075,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      labelText: 'First Name',
                                      isDense: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                    ),
                                    controller: firstNameController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (text) {
                                      if (text.isEmpty) {
                                        return 'Cannot be empty!';
                                      } else {
                                        return null;
                                      }
                                    },
                                    autofocus: false,
                                    keyboardType: TextInputType.name,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        color: Colors.white)),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.37,
                              height:
                                  MediaQuery.of(context).size.height * 0.075,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      labelText: 'Last Name',
                                      isDense: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                    ),
                                    controller: lastNameController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (text) {
                                      if (text.isEmpty) {
                                        return 'Cannot be empty!';
                                      } else {
                                        return null;
                                      }
                                    },
                                    autofocus: false,
                                    keyboardType: TextInputType.name,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width:
                              MediaQuery.of(context).size.width * 0.37 * 2.25,
                          height: MediaQuery.of(context).size.height * 0.075,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextFormField(
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  labelText: 'Address',
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                ),
                                controller: addressController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text.isEmpty) {
                                    return 'Cannot be empty!';
                                  } else {
                                    return null;
                                  }
                                },
                                autofocus: false,
                                keyboardType: TextInputType.streetAddress,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    color: Colors.white)),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.37,
                              height:
                                  MediaQuery.of(context).size.height * 0.075,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      labelText: 'City',
                                      isDense: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                    ),
                                    controller: cityController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (text) {
                                      if (text.isEmpty) {
                                        return 'Cannot be empty!';
                                      } else {
                                        return null;
                                      }
                                    },
                                    autofocus: false,
                                    keyboardType: TextInputType.streetAddress,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        color: Colors.white)),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.37,
                              height:
                                  MediaQuery.of(context).size.height * 0.075,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      labelText: 'Apartment',
                                      isDense: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                    ),
                                    controller: aptController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (text) {
                                      if (text.isEmpty) {
                                        return 'Cannot be empty!';
                                      } else {
                                        return null;
                                      }
                                    },
                                    autofocus: false,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        color: Colors.white)),
                              ),
                            )
                          ],
                        ),
                        FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0)),
                          onPressed: () {
                            userRep.signInWithGoogleAddAccountInfo(
                              firstNameController.text,
                              lastNameController.text,
                              addressController.text,
                              aptController.text,
                              cityController.text,
                            );
                            setState(() {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  new MaterialPageRoute<void>(
                                      builder: (context) => MainScreen()),
                                  (r) => false);
                            });
                          },
                          color: Colors.red,
                          textColor: Colors.white,
                          child: Text('Continue',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.03)),
                        )
                      ],
                    )),
              );
            }
            ///Email sign in bottom sheet state
            if (screen == 5) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.075 * 5,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(40),
                            topRight: const Radius.circular(40))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(),
                        Container(
                          width:
                              MediaQuery.of(context).size.width * 0.37 * 2.25,
                          height: MediaQuery.of(context).size.height * 0.075,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextFormField(
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  labelText: 'Email',
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                ),
                                controller: emailController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text.isEmpty) {
                                    return 'Cannot be empty!';
                                  } else {
                                    if (!RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(text)) {
                                      return 'Email must be valid!';
                                    }
                                    return null;
                                  }
                                },
                                autofocus: false,
                                keyboardType: TextInputType.emailAddress,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    color: Colors.white)),
                          ),
                        ),
                        Container(
                          width:
                              MediaQuery.of(context).size.width * 0.37 * 2.25,
                          height: MediaQuery.of(context).size.height * 0.075,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextFormField(
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  labelText: 'Password',
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                ),
                                controller: passwordController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text.length < 6) {
                                    return 'Password length should be 6 or more!';
                                  }
                                  if (text.isEmpty) {
                                    return 'Cannot be empty!';
                                  } else {
                                    return null;
                                  }
                                },
                                autofocus: false,
                                obscureText: true,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    color: Colors.white)),
                          ),
                        ),
                        FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0)),
                          onPressed: checkEmailSigninFields() && clicked
                              ? () async {
                            clicked=false;
                            if (!checkEmailSigninFields()) return;
                                  String message = await userRep.signIn(
                                      emailController.text,
                                      passwordController.text);
                                  if (message == 'Success') {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        new MaterialPageRoute<void>(
                                            builder: (context) => MainScreen()),
                                        (r) => false);
                                  }
                                  if (message ==
                                      'The password is invalid or the user does not have a password.') {
                                    Fluttertoast.showToast(msg: 'The password is invalid or the user does not have a password.');
                                  }
                                  if (message ==
                                      'A network error (such as timeout, interrupted connection or unreachable host) has occurred.') {
                                    Fluttertoast.showToast(msg: 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.');
                                  }
                                  if (message ==
                                      'There is no user record corresponding to this identifier. The user may have been deleted.') {
                                    screen = 2;
                                  }
                                  setState(() {});
                                  clicked=true;
                                }
                              : null,
                          color: Colors.red,
                          textColor: Colors.white,
                          child: Text('Login / Sign up',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.03)),
                        )
                      ],
                    )),
              );
            }

            return null;
          }),
        );
      });
}
///Start screen.
Widget startScreenScaffold(context) => Material(
      child: Consumer<UserRepository>(
        builder: (context, userRep, _) => Scaffold(
          //resizeToAvoidBottomInset: true,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                          child: Container(
                        child: Icon(
                          Icons.star,
                          color: Colors.lightGreenAccent,
                          size: MediaQuery.of(context).size.height *
                              0.065 *
                              3.3 *
                              2.1,
                        ),
                      )),
                      AllConfettiWidget(
                          child: Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                            Icon(
                              GiftHubIcons.gift,
                              color: Colors.red,
                              size:
                                  MediaQuery.of(context).size.height * 0.075 * 2,
                            ),
                            Text(
                              'GiftHub',
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.height * 0.03,
                                  fontFamily: 'TimesNewRoman',
                                  fontWeight: FontWeight.bold),
                            )
                          ]))),
                    ],
                  ),
                  Text(
                    'Enjoy the highest quality gifts.\nOne click away',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.04,
                      fontFamily: 'TimesNewRoman',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: OutlineButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            width: MediaQuery.of(context).size.width * 0.075,
                            height: MediaQuery.of(context).size.height * 0.04,
                            image: AssetImage("Assets/google.png"),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.025,
                          ),
                          Text(
                            'Continue with Google',
                            textAlign: TextAlign.center,
                            style: TextStyle(

                                fontSize:
                                    MediaQuery.of(context).size.width * 0.05,
                                fontFamily: 'TimesNewRoman'),
                          )
                        ],
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      onPressed: () async {
                        try {
                          final result = await InternetAddress.lookup('google.com');
                          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                            //Everything is good in the hood.
                          }
                        } on SocketException catch (_) {
                          Fluttertoast.showToast(msg: 'No internet connection!');
                          return;
                        }
                        await userRep.signInWithGoogle();
                        if (await userRep.signInWithGoogleCheckIfFirstTime()) {
                          firstSignUpSheet(context, 3);
                        } else {

                          Navigator.pushAndRemoveUntil(
                              context,
                              new MaterialPageRoute<void>(
                                  builder: (context) => MainScreen()),
                              (r) => false);
                        }
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: OutlineButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.email,
                            size: MediaQuery.of(context).size.height *
                                0.065 *
                                3.1 /
                                5,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.025,
                          ),
                          Text(
                            'Continue with Email',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize:
                                MediaQuery.of(context).size.width * 0.05,
                                fontFamily: 'TimesNewRoman'),
                          )
                        ],
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      onPressed: () async {
                        try {
                          final result = await InternetAddress.lookup('google.com');
                          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                            //Everything is good in the hood.
                          }
                        } on SocketException catch (_) {
                          Fluttertoast.showToast(msg: 'No internet connection!');
                          return;
                        }
                        firstSignUpSheet(context, 5);
                      },
                    ),
                  ),
                  Text(
                    'or',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.025,
                        fontFamily: 'TimesNewRoman'),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    child: Text(
                      'Continue as a guest',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.03,
                          fontFamily: 'TimesNewRoman',
                          color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () async {
                      try {
                        final result = await InternetAddress.lookup('google.com');
                        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                          //Everything is good in the hood.
                        }
                      } on SocketException catch (_) {
                        Fluttertoast.showToast(msg: 'No internet connection!');
                        return;
                      }
                      userRep.status = Status.Unauthenticated;
                      await FirebaseAuth.instance.signInAnonymously();
                      Navigator.pushAndRemoveUntil(
                          context,
                          new MaterialPageRoute<void>(
                              builder: (context) => MainScreen()),
                          (r) => false);
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
