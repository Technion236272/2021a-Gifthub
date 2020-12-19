import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';



class ChatScreen extends StatefulWidget {
  ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyUserScreenSet = new GlobalKey<ScaffoldState>();




  @override
  Widget build(BuildContext context) {
    return Material(
        child: Consumer<UserRepository>(
            builder:(context, userRep, _) {
              return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 110,
                        color: Colors.lightGreen[800],
                      ),
                    ),
                    Scaffold(
                      resizeToAvoidBottomInset: true,
                      resizeToAvoidBottomPadding: false,
                      backgroundColor: Colors.transparent,
                      key: _scaffoldKeyUserScreenSet,
                      appBar: AppBar(
                        elevation: 0.0,
                        backgroundColor: Colors.lightGreen[800],
                        leading: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: null //TODO: implement return
                        ),
                        title: Text("Chat with "+ "[sellerName]",
                          style: GoogleFonts.calistoga(
                              fontSize: 28,
                              color: Colors.white
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      body: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: Container(height: MediaQuery.of(context).size.height,
                            color: Colors.white),
                      ),
                    ),
                  ]
              );
            }
        )
    );
  }



}
