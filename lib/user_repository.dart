import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'productMock.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

const String defaultAvatar = 'https://cdn.onlinewebfonts.com/svg/img_258083.png';

class UserRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User _user;
  Status _status = Status.Uninitialized;
  FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  String _avatarURL = defaultAvatar;
  List<Product> _orders = new List();
  String _firstName = "";
  String _lastName = "";
  String _address = "";
  String _apt = "";
  String _city = "";


  void updateLocalUserFields() async {
    var snapshot = await FirebaseFirestore.instance.collection('Users').doc(_user.uid).get();
    var list = snapshot.data();
    _firstName = list['Info'][0];
    _lastName = list['Info'][1];
    _address = list['Info'][2];
    _apt = list['Info'][3];
    _city = list['Info'][4];
    try {
      _avatarURL = await FirebaseStorage.instance.ref()
          .child(_user.uid)
          .getDownloadURL() ?? defaultAvatar;
    } catch (_){
      _avatarURL = defaultAvatar;
    }
      //TODO: update _orders too
  }
  Future<void> updateFirebaseUserList() async {
    var list=[_firstName,_lastName,_address,_apt,_city];
    await _db.collection('Users').doc(_user.uid).set({'Info':list});
    notifyListeners();
  }

  String get apt => _apt;

  set apt(String value) {
    _apt = value;
  }

  set avatarURL(String value) {
    this._avatarURL = value;
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

  String get city => _city;

  set city(String value) {
    _city = value;
  }

  UserRepository.instance() : _db = FirebaseFirestore.instance,
                              _storage = FirebaseStorage.instance,
                              _auth = FirebaseAuth.instance {_auth.authStateChanges().listen(_authStateChanges);
  }

  Status get status => _status;

  set status(Status value) {
    _status = value;
  }

  User get user => _user;

  FirebaseAuth get auth => _auth;

  FirebaseFirestore get firestore => _db;

  FirebaseStorage get storage => _storage;

  String get avatarURL => _avatarURL;

  List<Product> get orders => _orders;

  Future<String> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _status = Status.Authenticated;

      try {
        _avatarURL = await _storage.ref('userImages').child(_user.uid).getDownloadURL();
      }
      on FirebaseException catch (_) { // in case the user hasn't yet uploaded an avatar
        _avatarURL = null;
      }
      updateLocalUserFields();
      notifyListeners();
      return 'Success';
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return e.message;
      //throw e;
    }
  }

  Future<String> signUp(String email, String password,String firstName,String lastName,String address,String apt,String city) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _status = Status.Authenticated;
      _db = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _firstName=firstName;
      _lastName=lastName;
      _address=address;
      _apt=apt;
      _city=city;
      updateFirebaseUserList();
      var list=[];
      await _db.collection('Orders').doc(_user.uid).set({'Orders':list});
      await _db.collection('Wishlists').doc(_user.uid).set({'Wishlist':list});
      await _db.collection('Stores').doc(_user.uid).set({'Store':list});
      notifyListeners();
      return 'Success';
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return e.message;
      //throw e;
    }
  }

  Future signOut() async {
    _status = Status.Unauthenticated;
    _auth.signOut();
    _db = null;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void signInWithGoogleAddAccountInfo(String firstName,String lastName,String address,String apt,String city) async {
    _db = FirebaseFirestore.instance;
    _firstName=firstName;
    _lastName=lastName;
    _address=address;
    _apt=apt;
    _city=city;
    updateFirebaseUserList();
    var list=[];
    await _db.collection('Orders').doc(_user.uid).set({'Orders':list});
    await _db.collection('Wishlists').doc(_user.uid).set({'Wishlist':list});
    await _db.collection('Stores').doc(_user.uid).set({'Store':list});
  }

  Future<bool> signInWithGoogleCheckIfFirstTime() async {
    _db = FirebaseFirestore.instance;
    try {
      final snapShot = await _db.collection('Users').doc(_user.uid).get();
      if (snapShot == null || !snapShot.exists) {
        return true;
      } else {
        updateLocalUserFields();
        return false;
      }
    } catch(e) {
      updateLocalUserFields();
      return false;
    }
  }

  Future<void> _authStateChanges(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
      _user = null;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
  }

  /// sets avatar for a user
  /// in use at: userSettingsScreen.dart
  /// written by Ariel
  Future<void> setAvatar(String avatar) async {
    try {
      await _storage.ref('userImages').child(_auth.currentUser.uid).putFile(File(avatar));
      _avatarURL = await _storage.ref('userImages').child(_auth.currentUser.uid).getDownloadURL();
    } catch(_) {
      //nothing
    } finally {
      notifyListeners();
    }
  }

  /// deletes avatar for a user
  /// in use at: userSettingsScreen.dart
  /// written by Ariel
  Future<void> deleteAvatar() async {
    try {
      await _storage.ref("userImages").child(_user.uid).delete();
      _avatarURL = defaultAvatar;
    } catch (_) {
      //nothing
    } finally {
      notifyListeners();
    }
  }
}