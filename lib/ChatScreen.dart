import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat.dart';
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
  String sellerID;
  String userID;
  ChatScreen({Key key, this.sellerID,this.userID}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState(sellerID, userID);
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyUserScreenSet = new GlobalKey<ScaffoldState>();
  String sellerID;
  String userID;




  @override
   _ChatScreenState(String sellerID,String userID):sellerID= sellerID,userID=userID{

  }

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
                        title: Text("Message Box",
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                          child: Container(height: MediaQuery.of(context).size.height,
                              color: Colors.white,
                            child:Container(
                              child: StreamBuilder(
                                stream: Firestore.instance.collection('Users').snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                      ),
                                    );
                                  } else {
                                    return ListView.builder(
                                      padding: EdgeInsets.all(10.0),
                                      itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
                                      itemCount: snapshot.data.documents.length,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
              );
            }
        )
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    String imageUrl="https://ui-avatars.com/api/?bold=true&background=random&name="+document.data()['Info'][0]+"+"+document.data()['Info'][1];

    if (document.id == userID) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: imageUrl != null
                    ? CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                    width: 50.0,
                    height: 50.0,
                    padding: EdgeInsets.all(15.0),
                  ),
                  imageUrl: imageUrl,
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.account_circle,
                  size: 50.0,
                  color: greyColor,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),

              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Name: ${document.data()['Info'][0]?? 'Not available'}',
                          style: TextStyle(color: Colors.white),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'UID: ${document.id ?? 'Not available'}',
                          style: TextStyle(color: Colors.white),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                      userId: userID,
                      peerId: document.id,
                      peerAvatar: imageUrl,
                    )));
          },
          color: Colors.grey,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }
}



