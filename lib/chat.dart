import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'globals.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gifthub_2021a/user_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'globals.dart';
import 'package:cached_network_image/cached_network_image.dart';






class Chat extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String userId;
  Chat({Key key, @required this.userId,@required this.peerId, @required this.peerAvatar})
      : super(key: key);

  @override
  State createState() =>
      ChatState(userId: userId,peerId: peerId, peerAvatar: peerAvatar);
}

class ChatState extends State<Chat> {
  ChatState({Key key, @required this.userId,@required this.peerId, @required this.peerAvatar});

  String peerId;
  String peerAvatar;
  String id;
  String userId;
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  //final int _limitIncrement = 20;
  String groupChatId='';


  File imageFile;
  bool isLoading;
  String imageUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
/*
  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }*/

  @override
  void initState() {
    super.initState();
    //listScrollController.addListener(_scrollListener);
    focusNode.addListener(onFocusChange);
    imageUrl = '';
    isLoading = false;
    id = userId ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = id+"-"+peerId;
    } else {
      groupChatId = peerId+"-"+id;
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
      });
    }
  }



  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    imageFile = File(pickedFile.path);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });

      uploadFile();
    }
  }



  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference = FirebaseStorage.instance.ref().child("chatImages/"+fileName);
    var storageTaskSnapshot = await reference.putFile(imageFile); //TODO: there is a bug on the old phone, cant send an image, stuck on this line.
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image

    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Please enter a message before sending.',
          backgroundColor: mainColor,
          textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG);
    }
  }

  imageClicked(var context,var document){
    Navigator.of(context).push(new MaterialPageRoute<void>(
      builder: (BuildContext context) => Dismissible(
        key: const Key('keyH'),
        direction: DismissDirection.horizontal,
        onDismissed: (_) => Navigator.pop(context),
        child: Dismissible(
            direction: DismissDirection.vertical,
            key: const Key('keyV'),
            onDismissed: (_) => Navigator.pop(context),
            child: Center(
              child: InteractiveViewer(
                  boundaryMargin: EdgeInsets.all(0),
                  minScale: 1.0,
                  maxScale: 2.2,
                  child: Image.network(document.data()['content'],
                    fit: BoxFit.fitWidth,
                  )
              ),
            )
        ),
      ),
    ));
  }
  Widget buildItem(int index, DocumentSnapshot document) {
    if (document.data()['idFrom'] == id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document.data()['type'] == 0
              // Text
              ? Container(
                  child: Text(
                    document.data()['content'],
                    style: GoogleFonts.lato(fontSize: 15, color: secondaryTextColor),
                  ),
                  padding: EdgeInsets.fromLTRB(s5(context)*3, s10(context), s5(context)*3, s10(context)),
                  width: s50(context)*4,
                  decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? s10(context)*2 : s10(context),
                      right: s10(context)),
                )
              : //document.data()['type'] == 1
                  // Image
                   Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(appColor),
                              ),
                              width: s50(context)*4,
                              height: s50(context)*4,
                              padding: EdgeInsets.all(s50(context)*1.5),
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Icon(Icons.error,size: s50(context)*4,),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document.data()['content'],
                            width: s50(context)*4,
                            height: s50(context)*4,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {

                          imageClicked(context,document);
                        },
                        padding: EdgeInsets.all(0),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? s10(context)*2 : s10(context),
                          right: s10(context)),
                    )


        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(appColor),
                            ),
                            width: s10(context)*3.5,
                            height: s10(context)*3.5,
                            padding: EdgeInsets.all(s10(context)),
                          ),
                          imageUrl: peerAvatar,
                          width: s10(context)*3.5,
                          height: s10(context)*3.5,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: s10(context)*3.5),
                document.data()['type'] == 0
                    ? Container(
                        child: Text(
                          document.data()['content'],
                          style: GoogleFonts.lato(fontSize: 15, color: secondaryTextColor),
                        ),
                        padding: EdgeInsets.fromLTRB(s5(context)*3, s10(context), s5(context)*3, s10(context)),
                        width: s50(context)*4,
                        decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: s10(context)),
                      )
                    :
                        Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          appColor),
                                    ),
                                    width: s50(context)*4,
                                    height: s50(context)*4,
                                    padding: EdgeInsets.all(s10(context)*7),
                                    decoration: BoxDecoration(
                                      color: secondaryColor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Icon(Icons.error),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document.data()['content'],
                                  width: s50(context)*4,
                                  height: s50(context)*4,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                imageClicked(context,document);
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(left: s10(context)),
                          )
                        ,
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document.data()['timestamp']))),
                      style: niceFont(size: 12,color: darkG),
                    ),
                    margin: EdgeInsets.only(left: s50(context), top: s5(context), bottom: s5(context)),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: s10(context)),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            // List of messages
            buildListMessage(),



            // Input content
            buildInput(),
          ],
        ),

        // Loading
        isLoading ? Center(child:CircularProgressIndicator()) : Container()
      ],
    );



  }



  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: darkG,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0);
                },
                style: TextStyle(color: darkG, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Enter your message...',
                  hintStyle: TextStyle(color: darkG),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: darkG,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: s50(context),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: darkG, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(appColor)))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(appColor)));
                } else {
                  listMessage.addAll(snapshot.data.documents);
                  return ListView.builder(
                    padding: EdgeInsets.all(s10(context)),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}