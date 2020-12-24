import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'StoreScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
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
                  home: DefaultTabController(
                    length: 2,
                    child: StoreScreen(null), //TODO: should be a storeId
                  )),
            );
          }
          return Center(child: CircularProgressIndicator());
        });

  }
}