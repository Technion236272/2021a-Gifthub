import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gifthub_2021a/user_repository.dart';
import 'package:provider/provider.dart';
import 'ChatScreen.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(MyApp());
}
initFirebase() async {
  await Firebase.initializeApp();
}
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    initFirebase();
    Random r = new Random();
    var b=r.nextBool();
    return ChangeNotifierProvider(
      create: (_) => UserRepository.instance(),
      child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.lightGreen,
            cursorColor: Colors.lightGreen,
            textSelectionTheme: TextSelectionThemeData(
                cursorColor: Colors.lightGreen,
                selectionHandleColor: Colors.transparent
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: ChatScreen(sellerID:"TEST SID",userID: "3I8TXyFiBVMIEmwbjxQKNCGK8oE3",)
      ),
    );
  }
}