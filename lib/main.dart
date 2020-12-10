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
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: UserSettingsScreen()
      ),
    );
  }
}
