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
import 'globals.dart';
class ChatScreen extends StatefulWidget {
  String sellerID;
  String userID;
  ChatScreen({Key key, this.sellerID, this.userID}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState(sellerID, userID);
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyUserScreenSet =
      new GlobalKey<ScaffoldState>();
  String sellerID;
  String userID;
  var document;
  var imageUrl;
  bool inChat=false;
  @override
  _ChatScreenState(String sellerID, String userID)
      : sellerID = sellerID,
        userID = userID,inChat=false {}

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Consumer<UserRepository>(builder: (context, userRep, _) {
      return Stack(alignment: Alignment.center, children: <Widget>[
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
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.lightGreen[800],
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: (){
                  if(inChat){

                    setState(() {
                      inChat=false;
                    });
                  }
                  else{
                    //TODO: return to previous screen
                  }

                }
                ),
            title: Text(
              "Chat",
              style: GoogleFonts.calistoga(
                fontSize: 28,
                color: Colors.white,
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
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Container(
                  child: inChat? Chat(
                      userId: userID,
                      peerId: document.id,
                      peerAvatar: imageUrl
                  ):StreamBuilder(
                    stream: Firestore.instance.collection('Users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.023),
                          itemBuilder: (context, index) => buildListTile(
                              context, snapshot.data.documents[index]),
                          itemCount: snapshot.data.documents.length,
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ]);
    }));
  }

  Widget buildListTile(BuildContext context, DocumentSnapshot document) {
    if (document.id == userID) {
      return Container();
    }
    String imageUrl =
        "https://ui-avatars.com/api/?bold=true&background=random&name=" +
            document.data()['Info'][0] +
            "+" +
            document.data()['Info'][1];
     

    return Container(
      padding: EdgeInsets.only(bottom: s10(context), left: s5(context), right: s5(context)),
      child: FlatButton(
        child: Row(
          children: <Widget>[
            Material(
              child: imageUrl != null
                  ? CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          valueColor: AlwaysStoppedAnimation<Color>(appColor),
                        ),
                        width: s50(context),
                        height: s50(context),
                        padding: EdgeInsets.all(s5(context) * 3),
                      ),
                      imageUrl: imageUrl,
                      width: s50(context),
                      height: s50(context),
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.account_circle,
                      size: s50(context),
                      color: Colors.grey,
                    ),
              borderRadius: BorderRadius.all(Radius.circular(s25(context))),
              clipBehavior: Clip.hardEdge,
            ),
            Flexible(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        'Name: ${document.data()['Info'][0] ?? 'Not available'}',
                        style: TextStyle(color: Colors.white),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(s10(context), 0.0, 0.0, s5(context)),
                    ),
                    Container(
                      child: Text(
                        'UID: ${document.id ?? 'Not available'}',
                        style: TextStyle(color: Colors.white),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(s10(context), 0.0, 0.0, 0.0),
                    )
                  ],
                ),
                margin: EdgeInsets.only(left: s10(context)),
              ),
            ),
          ],
        ),
        onPressed: () {

          setState(() {
            this.userID= userID;
            this.document= document;
            this.imageUrl= imageUrl;
            this.inChat=true;
          });
        },
        color: Colors.grey,
        padding: EdgeInsets.fromLTRB(s25(context), s10(context), s25(context), s10(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s10(context))),
      ),

    );
  }
}