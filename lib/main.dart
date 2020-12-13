import 'package:flutter/material.dart';
import 'userMock.dart';
// import 'package:flutter/cupertino.dart';
import 'userOrdersScreen.dart';
// import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

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
            primarySwatch: Colors.lightGreen,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: UserOrdersScreen()
      ),
    );
  }
}