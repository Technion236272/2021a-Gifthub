import 'package:flutter/material.dart';
import 'package:gifthub_2021a/ProductScreen.dart';
import 'package:gifthub_2021a/user_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'StoreScreen.dart';
import 'user_repository.dart';
import 'globals.dart' as globals;

void main() {
  globals.userCart = <globals.Product>[];
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return ChangeNotifierProvider<UserRepository>(
              create: (_) => UserRepository.instance(),
              child: MaterialApp(
                  title: 'Flutter Demo',
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                  ),
                  home: ProductScreen(null)),
            );
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    // userRep = UserRepository.instance();
  }
}