library gifthub.globals;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

TextStyle niceFont({double size= 16.0, Color color=Colors.white}) {
  return GoogleFonts.montserrat(
    fontSize: size,
    color: color,
  );
}

RatingBar fixedStarBar(double rate, {Color color= Colors.red}) {
  return RatingBar(
    initialRating: rate,
    direction: Axis.horizontal,
    allowHalfRating: true,
    ignoreGestures: true,
    itemCount: 5,
    ratingWidget: RatingWidget(
      full: Icon(Icons.star, color: Colors.red),
      half: Icon(Icons.star_half, color: Colors.red),
      empty: Icon(Icons.star_border, color: Colors.red),
    ),
    onRatingUpdate: (rating) {},
    itemPadding: EdgeInsets.symmetric(horizontal: 10.0),
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