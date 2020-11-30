import 'all_confetti_widget.dart';
import 'my_flutter_app_icons.dart';
import 'package:flutter/material.dart';


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
            fontSize: 24, fontFamily: 'TimesNewRoman',
            fontWeight: FontWeight.bold
        ),
      )
    ]);

var star_gifthub = Container(
  child: Icon(
    Icons.star,
    color: Colors.lightGreenAccent,
    size: 380,
  ),
);







final firstNameController = TextEditingController();
final lastNameController = TextEditingController();
final emailController = TextEditingController();
final phoneController = TextEditingController();
final passwordController = TextEditingController();

void firstSignUpSheet(var context) {
  int screen = 1;
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
                            color: Colors.red,
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
                            color: Colors.red,
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
                                screen = 2;
                              });
                            },
                            color: Colors.red,
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
                      height:450,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(40),
                              topRight: const Radius.circular(40))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Container(),
                          Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                            Container(width: 150,height:50,decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(5.0)),
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                controller: firstNameController,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text.isEmpty) {
                                    return 'Cannot be empty!';
                                  }
                                  else {
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
                                      color: Colors.grey, fontWeight: FontWeight.bold),

                                  labelText: 'First Name',

                                ),

                              ),
                            ),Container(width: 150,height:50,decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(5.0)),
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                controller: lastNameController,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text.isEmpty) {
                                    return 'Cannot be empty!';
                                  }
                                  else {
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
                                      color: Colors.grey, fontWeight: FontWeight.bold),

                                  labelText: 'Last Name',

                                ),

                              ),
                            ),


                          ],),

                          Container(width: 330,height:50,decoration: BoxDecoration(
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
                                }
                                else {
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
                                    color: Colors.grey, fontWeight: FontWeight.bold),

                                labelText: 'Email',

                              ),

                            ),
                          ),

                          Container(width: 330,height:50,decoration: BoxDecoration(
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
                                }
                                else {
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
                                    color: Colors.grey, fontWeight: FontWeight.bold),

                                labelText: 'Phone number',

                              ),

                            ),
                          ),
                          Container(width: 330,height:50,decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(5.0)),
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              controller: passwordController,
                              obscureText: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text.isEmpty) {
                                  return 'Cannot be empty!';
                                }
                                else {
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
                                    color: Colors.grey, fontWeight: FontWeight.bold),

                                labelText: 'Password',

                              ),

                            ),
                          ),
                          FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0)),
                            onPressed: () {
                              //TODO: sign up
                              //TODO: verify email: https://stackoverflow.com/questions/61023827/firebase-email-verification-flutter
                              setState(() {
                                screen = 4;
                              });
                            },
                            color: Colors.red,
                            textColor: Colors.white,
                            child: Text(
                                'Continue',
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
                      height:300,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(40),
                              topRight: const Radius.circular(40))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Container(),
                          Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                            Container(width: 150,height:50,decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(5.0)),
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                controller: firstNameController,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text.isEmpty) {
                                    return 'Cannot be empty!';
                                  }
                                  else {
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
                                      color: Colors.grey, fontWeight: FontWeight.bold),

                                  labelText: 'First Name',

                                ),

                              ),
                            ),Container(width: 150,height:50,decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(5.0)),
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                controller: lastNameController,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text.isEmpty) {
                                    return 'Cannot be empty!';
                                  }
                                  else {
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
                                      color: Colors.grey, fontWeight: FontWeight.bold),

                                  labelText: 'Last Name',

                                ),

                              ),
                            ),


                          ],),



                          Container(width: 330,height:50,decoration: BoxDecoration(
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
                                }
                                else {
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
                                    color: Colors.grey, fontWeight: FontWeight.bold),

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
                            child: Text(
                                'Continue',
                                style: TextStyle(fontSize: 23)),
                          )


                        ],
                      )),
                );
              }
              if (screen == 4) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                      height:250,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(40),
                              topRight: const Radius.circular(40))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Container(),
                          Text(
                            'Lets go gifting!',
                            style: TextStyle(
                                fontSize: 28, fontFamily: 'TimesNewRoman', color: Colors.white70,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic
                            ),
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
                            child: Text(
                                'Start Gifting!',
                                style: TextStyle(fontSize: 23,fontFamily: 'TimesNewRoman',)),
                          )


                        ],
                      )),
                );
              }

              return null;
            });
      });
}



Widget startScreenScaffold(context)=>Scaffold(
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
            AllConfettiWidget(child:Center(child: gifthub_logo)),
          ],
        ),
        Text(
          'Enjoy the highest quality gifts. One click away',
          style: TextStyle(
            fontSize: 28, fontFamily: 'TimesNewRoman',
          ),
          textAlign: TextAlign.center,
        ),
        Container(
          height: 100,
        ),
        OutlineButton(
          child: Text(
            'Get Started',
            style: TextStyle(fontSize: 30,fontFamily: 'TimesNewRoman'),
            textAlign: TextAlign.center,
          ),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          onPressed: () {
            firstSignUpSheet(context);
          },
        )
      ],
    ),
  ),
);