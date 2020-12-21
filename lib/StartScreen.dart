import 'all_confetti_widget.dart';
import 'my_flutter_app_icons.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'user_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mainScreen.dart';
//For many uses:
var gifthub_logo = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Icon(
        GiftHubIcons.gift,
        color: Colors.red,
        size: 100,
      ),
      Text(
        'GiftHub',
        style: TextStyle(
            fontSize: 24,
            fontFamily: 'TimesNewRoman',
            fontWeight: FontWeight.bold),
      )
    ]);

var star_gifthub = Container(
  child: Icon(
    Icons.star,
    color: Colors.lightGreenAccent,
    size: 380,
  ),
);

UserRepository userRep;

final firstNameController = TextEditingController();
final lastNameController = TextEditingController();
final emailController = TextEditingController();
final aptController = TextEditingController();
final cityController = TextEditingController();
final addressController = TextEditingController();
final passwordController = TextEditingController();
bool checkEmailSignupFields() {
  return (emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
      cityController.text.isNotEmpty&&addressController.text.isNotEmpty&&
          aptController.text.isNotEmpty) &&
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(emailController.text) &&
      passwordController.text.length >= 6;
}

bool checkEmailSigninFields() {
  return (emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty);
}

bool emailInUse = false;
void firstSignUpSheet(var context,int screen) {
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
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {


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
                            width: 150,
                            height: 50,
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
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                  ),

                                  controller: firstNameController,

                                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                      fontSize: 16.0,
                                      color: Colors.white
                                  )
                              ),
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 50,
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
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                  ),

                                  controller: lastNameController,

                                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                      fontSize: 16.0,
                                      color: Colors.white
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 330,
                        height: 50,
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
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                              ),

                              controller: emailController,

                              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                  fontSize: 16.0,
                                  color: Colors.white
                              )
                          ),
                        ),
                      ),

                      Container(
                        width: 330,
                        height: 50,
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
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                              ),

                              controller: addressController,

                              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                  fontSize: 16.0,
                                  color: Colors.white
                              )
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 150,
                            height: 50,
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
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                  ),

                                  controller: cityController,

                                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                      fontSize: 16.0,
                                      color: Colors.white
                                  )
                              ),
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 50,
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
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                  ),

                                  controller: aptController,

                                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                      fontSize: 16.0,
                                      color: Colors.white
                                  )
                              ),
                            ),
                          )
                        ],
                      ),



                      Container(
                        width: 330,
                        height: 50,
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
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                              ),

                              controller: passwordController,

                              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                  fontSize: 16.0,
                                  color: Colors.white
                              )
                          ),
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
                                  setState(() {});
                                  Navigator.pushAndRemoveUntil(context,
                                      new MaterialPageRoute<void>(builder: (context) => MainScreen()),
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
                            style: TextStyle(fontSize: 23)),
                      )
                    ],
                  )),
            );
          }
          if (screen == 3) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  height: 300,
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
                            width: 150,
                            height: 50,
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
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                  ),

                                  controller: firstNameController,

                                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                      fontSize: 16.0,
                                      color: Colors.white
                                  )
                              ),
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 50,
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
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                  ),

                                  controller: lastNameController,

                                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                      fontSize: 16.0,
                                      color: Colors.white
                                  )
                              ),
                            ),
                          ),],
                      ),
                      Container(
                        width: 330,
                        height: 50,
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
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                              ),

                              controller: addressController,

                              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                  fontSize: 16.0,
                                  color: Colors.white
                              )
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 150,
                            height: 50,
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
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                  ),

                                  controller: cityController,

                                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                      fontSize: 16.0,
                                      color: Colors.white
                                  )
                              ),
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 50,
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
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                    ),
                                  ),

                                  controller: aptController,

                                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                      fontSize: 16.0,
                                      color: Colors.white
                                  )
                              ),
                            ),
                          )
                        ],
                      ),





                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)),
                        onPressed: () {
                          userRep.signInWithGoogleAddAccountInfo(firstNameController.text,lastNameController.text,addressController.text,
                            aptController.text,
                            cityController.text,);
                          setState(() {
                            Navigator.pushAndRemoveUntil(context,
                                new MaterialPageRoute<void>(builder: (context) => MainScreen()),
                                    (r) => false);
                          });
                        },
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text('Continue', style: TextStyle(fontSize: 23)),
                      )
                    ],
                  )),
            );
          }


          if (screen == 5) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  height: 250,
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
                        width: 330,
                        height: 50,
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
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                              ),

                              controller: emailController,

                              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                  fontSize: 16.0,
                                  color: Colors.white
                              )
                          ),
                        ),
                      ),
                      Container(
                        width: 330,
                        height: 50,
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
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                ),
                              ),

                              controller: passwordController,

                              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                  fontSize: 16.0,
                                  color: Colors.white
                              )
                          ),
                        ),
                      ),




                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)),
                        onPressed: checkEmailSigninFields()
                            ? () async {
                                if (!checkEmailSigninFields()) return;
                                String message = await userRep.signIn(
                                    emailController.text,
                                    passwordController.text);
                                if (message == 'Success') {
                                  setState(() {});
                                  Navigator.pushAndRemoveUntil(context,
                                      new MaterialPageRoute<void>(builder: (context) => MainScreen()),
                                          (r) => false);
                                }
                                if (message ==
                                    'The password is invalid or the user does not have a password.') {
                                  //TODO: show snackbar wrong password
                                }
                                if (message ==
                                    'A network error (such as timeout, interrupted connection or unreachable host) has occurred.') {
                                  //TODO: show snackbar netwrok error
                                }
                                if (message ==
                                    'There is no user record corresponding to this identifier. The user may have been deleted.') {
                                  screen = 2;
                                }
                                setState(() {});
                              }
                            : null,
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text('Login / Sign up', style: TextStyle(fontSize: 23)),
                      )
                    ],
                  )),
            );
          }

          return null;
        });
      });
}


Widget startScreenScaffold(context) => Scaffold(
      //resizeToAvoidBottomInset: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Center(child: star_gifthub),
                AllConfettiWidget(child: Center(child: gifthub_logo)),
              ],
            ),
            Text(
              'Enjoy the highest quality gifts. One click away',
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'TimesNewRoman',
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              height: 100,
            ),
            Container(
              width: 300,
              child: OutlineButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      width: 30,
                      height: 30,
                      image: AssetImage("Assets/google.png"),
                    ),
                    Container(
                      width: 10,
                    ),
                    Text(
                      'Continue with Google',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontFamily: 'TimesNewRoman'),
                    )
                  ],
                ),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                onPressed: () async {
                  userRep.signInWithGoogle();
                  if(await userRep.signInWithGoogleCheckIfFirstTime()){
                    firstSignUpSheet(context, 3);
                  }
                  else{
                    Navigator.pushAndRemoveUntil(context,
                        new MaterialPageRoute<void>(builder: (context) => MainScreen()),
                            (r) => false);
                  }




                },
              ),
            ),
            Container(
              width: 300,
              child: OutlineButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email,
                      size: 30,
                    ),
                    Container(
                      width: 10,
                    ),
                    Text(
                      'Continue with Email',
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontSize: 24, fontFamily: 'TimesNewRoman'),
                    )
                  ],
                ),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  firstSignUpSheet(context,5);
                },
              ),
            ),
            Text(
              'or',
              style: TextStyle(fontSize: 20, fontFamily: 'TimesNewRoman'),
              textAlign: TextAlign.center,
            )
            ,
            TextButton(

              child: Text(
                'Continue as a guest',
                style: TextStyle(fontSize: 20, fontFamily: 'TimesNewRoman',color: Colors.black),
                textAlign: TextAlign.center,
              ),


              onPressed: () {},
            )


          ],
        ),
      ),
    );
