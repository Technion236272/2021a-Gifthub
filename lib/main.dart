import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'userSettingsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'userMock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserRepository(),
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
        home: UserSettingsScreen()
      ),
    );
  }
}
