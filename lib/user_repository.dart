import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

const String defaultAvatar = 'https://cdn.onlinewebfonts.com/svg/img_258083.png';

///This class is used to sign in and out and keep user's information
class UserRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User _user;
  Status _status = Status.Uninitialized;
  FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  String _avatarURL = defaultAvatar;
  String _firstName = "";
  String _lastName = "";
  String _address = "";
  String _apt = "";
  String _city = "";

  ///This function gets user's information from firebase and initializes the local class variables with it.
  void updateLocalUserFields() async {
    var snapshot = await FirebaseFirestore.instance.collection('Users').doc(_user.uid).get();
    var list = snapshot.data();
    _firstName = list['Info'][0];
    _lastName = list['Info'][1];
    _address = list['Info'][2];
    _apt = list['Info'][3];
    _city = list['Info'][4];
    try {
      _avatarURL = await FirebaseStorage.instance.ref("userImages")
          .child(_user.uid)
          .getDownloadURL() ?? defaultAvatar;
    } catch (_){
      _avatarURL = defaultAvatar;
    }
  }
  ///This function takes the current information stored in this class's variables and uploads it to the user's information list on firebase.
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
        _auth = FirebaseAuth.instance {//_auth.authStateChanges().listen(_authStateChanges);
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

  ///This function is used for Email sign in
  ///Returns "Success" string if succeeded
  Future<String> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _status = Status.Authenticated;
      _user = FirebaseAuth.instance.currentUser;
      try {
        _avatarURL = await _storage.ref('userImages').child(_user.uid).getDownloadURL();
      }
      on FirebaseException catch (_) { /// in case the user hasn't yet uploaded an avatar
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
  ///This function is used for Email sign up
  ///Returns "Success" string if succeeded
  Future<String> signUp(String email, String password,String firstName,String lastName,String address,String apt,String city) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _user = FirebaseAuth.instance.currentUser;
      _status = Status.Authenticated;
      _firstName=firstName;
      _lastName=lastName;
      _address=address;
      _apt=apt;
      _city=city;
      updateFirebaseUserList();
      var list=[];
      await _db.collection('Orders').doc(_user.uid).set({'Orders':list});
      await _db.collection('Wishlists').doc(_user.uid).set({'Wishlist':list});
      await _db.collection('Stores').doc(_user.uid).set({
        'Products':[],
        'Reviews':[],
        'Store':{
          'address':address,
          'description': 'This is default store description!',
          'name':firstName+'\'s store',
          'phone':'00000000'
        }
      });
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
    notifyListeners();
    return Future.delayed(Duration.zero);
  }
  ///This function signs in user with Google account.
  ///This is called after pressing "Continue with Google" on start screen.
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
    _status = Status.Authenticated;
    _user = FirebaseAuth.instance.currentUser;
  }
  ///After signing up with Google, we initialize class's parameters and initialize the needed lists on Firebase.
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
    await _db.collection('Stores').doc(_user.uid).set({
      'Products':[],
      'Reviews':[],
      'Store':{
        'address':address,
        'description': 'This is default store description!',
        'name':firstName+'\'s store',
        'phone':'00000000'
      }
    });
  }
  ///This function checks if a user signs in with a google account for the first time.
  ///if yes, returns true.
  ///if no, returns false and update local variables with his updated information on firebase.
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
    if (null == firebaseUser || firebaseUser.isAnonymous) {
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