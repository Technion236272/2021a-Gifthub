import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'globals.dart' as globals;

class AllReviewsScreen extends StatefulWidget {
  final _reviews;

  AllReviewsScreen(List reviews, {Key key}) : _reviews = reviews, super(key: key);
  @override
  _AllReviewsScreenState createState() => _AllReviewsScreenState(_reviews);
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  final _reviews;

  _AllReviewsScreenState(List reviews) : _reviews = reviews;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[600],
      appBar: AppBar(
        backgroundColor: Colors.lightGreen[900],
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left_outlined),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text("All reviews"),
      ),

      body: ListView(
        children: _reviews.map<ListTile>((r) =>
            ListTile(
              title: Text(r.content, style: globals.niceFont()),
              subtitle: Text(r.userName, style: globals.niceFont(size: 12)),
              leading: globals.fixedStarBar(r.rating, itemSize: 18.0,),
            ),
        ).toList(),
      ),
    );
  }
}
