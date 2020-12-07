import 'all_confetti_widget.dart';
import 'my_flutter_app_icons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'user_repository.dart';

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
final phoneController = TextEditingController();
final passwordController = TextEditingController();
bool checkEmailSignupFields() {
  return (emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          phoneController.text.isNotEmpty) &&
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(emailController.text) &&
      passwordController.text.length >= 6;
}

bool checkEmailSigninFields() {
  return (emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty);
}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
          if (screen == 1) {
            return Container(
                height: 300,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(40),
                        topRight: const Radius.circular(40))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(),
                    Container(
                      height: 65,
                      width: 300,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)),
                        onPressed: () {
                          setState(() {
                            screen = 3;
                          });
                        },
                        color: Colors.red[800],
                        textColor: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image(
                              width: 40,
                              height: 40,
                              image: AssetImage("Assets/google.png"),
                            ),
                            Container(
                              width: 10,
                            ),
                            Text(
                              'Continue with Google',
                              style: TextStyle(fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 65,
                      width: 300,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)),
                        onPressed: () {
                          setState(() {
                            screen = 4;
                          });
                        },
                        color: Colors.red[800],
                        textColor: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 40,
                            ),
                            Container(
                              width: 10,
                            ),
                            Text(
                              'Continue with Facebook',
                              style: TextStyle(fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 65,
                      width: 300,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)),
                        onPressed: () {
                          setState(() {
                            screen = 5;
                          });
                        },
                        color: Colors.red[800],
                        textColor: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email,
                              size: 40,
                            ),
                            Container(
                              width: 10,
                            ),
                            Text(
                              'Continue with Email',
                              style: TextStyle(fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(),
                    Container(),
                  ],
                ));
          }

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
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(5.0)),
                            child: TextFormField(
                              textAlign: TextAlign.center,
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
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                labelStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                                labelText: 'First Name',
                              ),
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(5.0)),
                            child: TextFormField(
                              textAlign: TextAlign.center,
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
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                labelStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                                labelText: 'Last Name',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 330,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(5.0)),
                        child: TextFormField(
                          key: _formKey,
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.center,
                          controller: emailController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (emailInUse) {
                              emailInUse = false;
                              return 'email in use';
                            }

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
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            labelStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                            labelText: 'Email',
                          ),
                        ),
                      ),
                      Container(
                        width: 330,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(5.0)),
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.center,
                          controller: phoneController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (text.isEmpty) {
                              return 'Cannot be empty!';
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            labelStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                            labelText: 'Phone number',
                          ),
                        ),
                      ),
                      Container(
                        width: 330,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(5.0)),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: passwordController,
                          obscureText: true,
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
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            labelStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                            labelText: 'Password',
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
                                    phoneController.text);
                                if (code == 'Success') {
                                  screen = 4;
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
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(5.0)),
                            child: TextFormField(
                              textAlign: TextAlign.center,
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
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                labelStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                                labelText: 'First Name',
                              ),
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(5.0)),
                            child: TextFormField(
                              textAlign: TextAlign.center,
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
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                labelStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                                labelText: 'Last Name',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 330,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(5.0)),
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.center,
                          controller: phoneController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (text.isEmpty) {
                              return 'Cannot be empty!';
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            labelStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                            labelText: 'Phone number',
                          ),
                        ),
                      ),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)),
                        onPressed: () {
                          //TODO: sign up
                          setState(() {
                            screen = 4;
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
          if (screen == 4) {
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
                      Text(
                        'Lets go gifting!',
                        style: TextStyle(
                            fontSize: 28,
                            fontFamily: 'TimesNewRoman',
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)),
                        onPressed: () {
                          //TODO: sign up
                          setState(() {
                            screen = 4;
                          });
                        },
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text('Start Gifting!',
                            style: TextStyle(
                              fontSize: 23,
                              fontFamily: 'TimesNewRoman',
                            )),
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
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(5.0)),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.center,
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
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            labelStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                            labelText: 'Email',
                          ),
                        ),
                      ),
                      Container(
                        width: 330,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(5.0)),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            labelStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                            labelText: 'Password',
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
                                  screen = 4;
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

GlobalKey<ScaffoldState> _scaffoldkey =
    GlobalKey<ScaffoldState>(debugLabel: '_scaffoldkeySaved');
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
                onPressed: () {
                  firstSignUpSheet(context,3);
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
