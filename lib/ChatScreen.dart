import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
  String userID;
  ChatScreen({Key key, this.userID}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState( userID);
}
class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyUserScreenSet =
      new GlobalKey<ScaffoldState>();
  String userID;
  var peerid;
  var imageUrl;
  bool inChat = false;

  @override
  _ChatScreenState( String userID)
      :
        userID = userID,
        inChat = false {}

  @override
  Widget build(BuildContext context) {

    return Material(
        child: Consumer<UserRepository>(builder: (context, userRep, _) {


      return Stack(alignment: Alignment.center, children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: s50(context) * 2.2,
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
                onPressed: () {
                  if (inChat) {
                    setState(() {
                      inChat = false;
                    });
                  } else {
                    //TODO: return to previous screen
                  }
                }),
            title: Text(
              "Chat",
              style: GoogleFonts.lato(
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
                  child:
                      inChat
                      ? Chat(
                          userId: userID,
                          peerId: peerid,
                          peerAvatar: imageUrl)
                      : StreamBuilder(
                          stream: Firestore.instance
                              .collection('messageAlert').doc(userID).snapshots(),
                          builder: (context, snapshot) {
                            if(snapshot.data['users'].length==0){
                              return Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Center(
                                  child: Column(children: [
                                    gifthub_logo,
                                    Spacer(),
                                    Container(alignment:Alignment.bottomCenter,child: Center(
                                      child: Text("You have no chats available!"
                                          "\n\nTo start chatting, go to a seller store page and hit Contact Seller!",style: GoogleFonts.lato(fontSize: 20,),textAlign: TextAlign.center,),
                                    )),
                                    Spacer(),
                                    Spacer()
                                  ],),
                                ),
                              );
                            }
                            if (snapshot.hasData) {
                              return ListView.builder(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.023),
                                itemBuilder: (context, index) {
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 1200),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation
                                        (
                                        child: FutureBuilder(
                                          future: FirebaseStorage.instance
                                              .ref("userImages/")
                                              .child(snapshot.data['users'][index]['id'])
                                              .getDownloadURL(),
                                          builder: (BuildContext context,
                                                  AsyncSnapshot<String>
                                                      imageLink) {

                                              return buildListTile(
                                                  context,
                                                  snapshot.data['users'][index],
                                                  imageLink,index);}
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: snapshot.data['users'].length,
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

  Widget buildListTile(BuildContext context, Map listitem,
      AsyncSnapshot<String> imageUrlAsync,int index) {
    //This is the dream fade function. This took me 2 hours, idk why... :(
    int i=index%14+1;
    if(i>8){
      i=i%8;
      currGreen=800-i*100;
    }
    else{
      currGreen=i*100;
    }
    //----------
    String name=listitem['name'];


    String imageUrl = imageUrlAsync.data;
    if (imageUrl == null) {
      imageUrl =
          "https://ui-avatars.com/api/?bold=true&background=random&name=" +
               name;
    }

    return Container(
      padding: EdgeInsets.only(
          bottom: s10(context), left: s5(context), right: s5(context)),
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
                        width: s50(context) * 1.2,
                        height: s50(context) * 1.2,
                        padding: EdgeInsets.all(s5(context) * 3),
                      ),
                      imageUrl: imageUrl,
                      width: s50(context) * 1.2,
                      height: s50(context) * 1.2,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.account_circle,
                      size: s50(context),
                      color: Colors.grey,
                    ),
              borderRadius: BorderRadius.all(Radius.circular(25)),
              clipBehavior: Clip.hardEdge,
            ),
            Flexible(
              child: Container(

                child: Column(
                  children: <Widget>[
                    Container(

                      child: Padding(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.01),
                        child: Text(
                          name,
                          maxLines: 1,
                          style: GoogleFonts.lato(
                              fontSize: 22,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    // bottomLeft
                                    offset: Offset(-1, -1),
                                    color: darkG),
                                Shadow(
                                    // bottomRight
                                    offset: Offset(1, -1),
                                    color: darkG),
                                Shadow(
                                    // topRight
                                    offset: Offset(1, 1),
                                    color: darkG),
                                Shadow(
                                    // topLeft
                                    offset: Offset(-1, 1),
                                    color: darkG),
                              ],
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(
                          s10(context), 0.0, 0.0, s5(context)),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(left: s10(context)),
              ),
            ),
          ],
        ),
        onPressed: () {
          setState(() {
            this.userID = userID;
            this.peerid=listitem['id'];
            this.imageUrl = imageUrl;
            this.inChat = true;
          });
        },
        color: Colors.green[currGreen],
        padding: EdgeInsets.fromLTRB(
            s25(context), s10(context), s25(context), s10(context)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(s10(context))),
      ),
    );
  }
}
bool down=true;
int currGreen=800;