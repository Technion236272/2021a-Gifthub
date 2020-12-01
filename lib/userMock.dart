import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

/// This is a user mocking for testing purposes only
/// as soon as a user class is implemented, this must be removed
class UserRepository with ChangeNotifier {
  String _avatarURL = "http://www.nretnil.com/avatar/LawrenceEzekielAmos.png";
  String _firstName = "Daddy";
  String _lastName = "Cool";
  String _address = "Crazy like a fool st. 23, Boney M. city";
  String _creditCard = "1234 1234 5678 8901";
  Status _status = Status.Authenticated;

  Status get status => _status;

  String get avatarURL => _avatarURL;

  set avatarURL(String value) {
    _avatarURL = value;
  }

  String get firstName => _firstName;

  set firstName(String value) {
    _firstName = value;
  }

  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
  }

  String get address => _address;

  set address(String value) {
    _address = value;
  }

  String get creditCard => _creditCard;

  set creditCard(String value) {
    _creditCard = value;
  }

}