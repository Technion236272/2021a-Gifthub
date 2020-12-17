import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'user_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyMainScreen = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 0.35,
              color: Colors.lightGreen[800],
            ),
          ),
          Scaffold(
            resizeToAvoidBottomInset: true,
            resizeToAvoidBottomPadding: false,
            backgroundColor: Colors.transparent,
            key: _scaffoldKeyMainScreen,
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.lightGreen[800],
            ),
            body: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: Container(
                color: Colors.white,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("Products").snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if(!snapshot.hasData) {
                      print("notice me, snapshot doesn't have data");
                      return Container();
                    }
                    return GridView.count(
                      primary: false,
                      crossAxisCount: 2,
                      padding: const EdgeInsets.all(20),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: List.generate(
                        15,
                        (index) => InkWell(
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            color: Colors.redAccent,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[

                              ],
                            ),
                          ),
                        )
                      ),
                    );
                  }
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.lightGreen[800],
              items: [],
            ),
          ),
        ],
      ),
    );
  }

  // Future<List<Widget>> _buildGridTileList(int count) async {
  //   var counterCollection = await FirebaseFirestore.instance.collection("Products").doc("Counter").get();
  //   var counterData = counterCollection.data();
  //   return List.generate(
  //     count,
  //     (index) async {
  //       //FIXME: Doesn't work beacuse generator cannot be async!!
  //       var avatarUrl = await FirebaseStorage.instance.ref('${counterData[index]}').child('${counterData[index]}').getDownloadURL();
  //       return Container(
  //         child: Center(
  //           child: NetworkImage(avatarUrl),
  //         ),
  //       );
  //     }
  //   );
  // }
}
