import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'productMock.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User _user;
  Status _status = Status.Uninitialized;
  FirebaseFirestore _db;
  FirebaseStorage _storage;
  String _avatarURL;
  List<Product> _orders = new List();

  UserRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_authStateChanges);
  }

  Status get status => _status;

  User get user => _user;

  FirebaseAuth get auth => _auth;

  FirebaseFirestore get firestore => _db;

  FirebaseStorage get storage => _storage;

  String get avatarURL => _avatarURL;

  List<Product> get orders => _orders;

  Future<void> _addUser(DocumentReference userRef) async {
    userRef.get().then((snapshot) {
      if (!snapshot.exists) {
        userRef.set({'email': _user.email, 'favorites': []});
      }
    });
  }

  Future<String> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _status = Status.Authenticated;
      _db = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      try {
        _avatarURL = await _storage.ref().child("Users/${_user.uid}/images/avatar").getDownloadURL();
      }
      on FirebaseException catch (_) { // in case the user hasn't yet uploaded an avatar
        _avatarURL = null;
      }

      notifyListeners();
      return 'Success';
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return e.message;
      throw e;
    }
  }

  Future<String> signUp(String email, String password,String firstName,String lastName,String phoneNumber) async {

    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _status = Status.Authenticated;
      _db = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      try {
        _avatarURL = await _storage.ref().child("Users/${_user.uid}/avatar").getDownloadURL();
      }
      on FirebaseException catch (_) { // in case the user hasn't yet uploaded an avatar
        _avatarURL = null;
      }
      var list=[firstName,lastName,phoneNumber];
      await _db.collection('Users').doc(_user.uid).set({'Info':list});
      list=[];
      await _db.collection('Orders').doc(_user.uid).set({'Orders':list});
      await _db.collection('Wishlists').doc(_user.uid).set({'Wishlist':list});
      notifyListeners();
      return 'Success';
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return e.message;
      throw e;
    }
  }

  Future signOut() async {
    _status = Status.Unauthenticated;
    _auth.signOut();
    _db = null;
    _avatarURL = null;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }



  void signInWithGoogle() async {
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

  void signInWithGoogleAddAccountInfo(String firstName,String lastName,String phoneNumber) async {
    _db = FirebaseFirestore.instance;
    var list=[firstName,lastName,phoneNumber];
    await _db.collection('Users').doc(_user.uid).set({'Info':list});
    list=[];
    await _db.collection('Orders').doc(_user.uid).set({'Orders':list});
    await _db.collection('Wishlists').doc(_user.uid).set({'Wishlist':list});
  }
  Future<bool> signInWithGoogleCheckIfFirstTime() async {
    _db = FirebaseFirestore.instance;
    try {
      final snapShot = await _db.collection('Users')
          .doc(_user.uid)
          .get();
      if (snapShot == null || !snapShot.exists) {
        return true;
      }
      else{
        return false;
      }
    }
    catch(e){
      return false;
    }
  }



  Future<void> _authStateChanges(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
  }

  Future addAvatar() async {
    final _picker = ImagePicker();

    await _picker.getImage(source: ImageSource.gallery).then((image) async {
      await _storage.ref().child("users/${_user.email}/images/avatar").putFile(File(image.path));
      _avatarURL = await _storage.ref().child("users/${_user.email}/images/avatar").getDownloadURL();
    });
    notifyListeners();
  }
}