import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gifthub_2021a/user_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'user_repository.dart';
import 'globals.dart' as globals;
import 'StartScreen.dart';
import 'package:flutter_launcher_icons/android.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/ios.dart';
import 'package:flutter_launcher_icons/main.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';

void main() {
  globals.userCart = <globals.Product>[];
  globals.userCartOptions = <Map>[];
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
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
                textSelectionHandleColor: Colors.transparent,
                cursorColor: Colors.lightGreen[800],
                primaryColor: Colors.green,
                accentColor: Colors.lightGreen[800],
                fontFamily: 'NewRomanTimes',
                textTheme: TextTheme(
                  headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
                  headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
                )
              ),
              home: MyHomePage()
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    init();
    return startScreenScaffold(context);
  }

  Future<void> init() async {
    await Firebase.initializeApp();
  }
}