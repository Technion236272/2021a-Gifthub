library gifthub.globals;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'my_flutter_app_icons.dart';

var gifthub_logo = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Icon(
        GiftHubIcons.gift,
        color: Colors.red,
        size: 100,
      ),
      Text(
        'GiftHub',
        style: TextStyle(
            fontSize: 24,
            fontFamily: 'TimesNewRoman',
            fontWeight: FontWeight.bold),
      )
    ]);

TextStyle niceFont({double size= 16.0, Color color=Colors.white}) {
  return GoogleFonts.montserrat(
    fontSize: size,
    color: color,
  );
}

RatingBar fixedStarBar(double rate, {Color color= Colors.red, double itemSize = 40.0}) {
  return RatingBar(
    initialRating: rate,
    direction: Axis.horizontal,
    allowHalfRating: true,
    ignoreGestures: true,
    itemSize: itemSize,
    ratingWidget: RatingWidget(
      full: Icon(Icons.star, color: color),
      half: Icon(Icons.star_half, color: color),
      empty: Icon(Icons.star_border, color: color),
    ),
    onRatingUpdate: (rating) {},
    itemPadding: EdgeInsets.zero,
  );
}

RatingBar changingStarBar(double rate, {Color color= Colors.red, double itemSize = 40.0, Function onUpdate = null}) {
  return RatingBar.builder(
      initialRating: rate,
      itemCount: 5,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemSize: itemSize,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, __) {
        return Icon(
          Icons.star,
          color: color,
        );
      },
      onRatingUpdate: onUpdate,
  );
}

RaisedButton regTextButton(String text, {Icon icon=null, Function press=null, Color buttonColor=Colors.red, Color textColor=Colors.white}) {
  return RaisedButton(
      elevation: 15.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: Colors.transparent),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      color: buttonColor,
      textColor: textColor,
      onPressed: press == null ? () {} : press,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: icon == null ? [Text(text)] : [icon, Text(text)],
      )
  );
}

class Constants{
  Constants._();
  static const double padding =20;
  static const double avatarRadius =45;
}

Scaffold emptyLoadingScaffold() {
  return Scaffold(
    backgroundColor: Colors.lightGreen[600],
    appBar: AppBar(
      backgroundColor: Colors.lightGreen[900],
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {},
      ),
      title: Text("Loading..."),
    ),

    body: Center(child: CircularProgressIndicator()),
  );
}