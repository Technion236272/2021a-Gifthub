import 'package:flutter/material.dart';
import 'package:gifthub_2021a/userMock.dart';
import 'package:provider/provider.dart';
import 'wishListScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserRepository(),
      child: MaterialApp(
        home: WishListScreen(),
      ),
    );
  }
}
