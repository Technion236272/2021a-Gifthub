import 'package:flutter/material.dart';
import 'package:gifthub_2021a/user_repository.dart';
import 'StartScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'userOrdersScreen.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'wishListScreen.dart';
import 'userSettingsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'mainScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserRepository.instance(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          textSelectionHandleColor: Colors.transparent,
          cursorColor: Colors.lightGreen[800],
          primaryColor: Colors.green,
          accentColor: Colors.red,
          fontFamily: 'NewRomanTimes',
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          )
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    init();
    // return startScreenScaffold(context);
    return MainScreen();
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    userRep = UserRepository.instance();
  }

}