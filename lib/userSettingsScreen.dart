import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'user_repository.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';


class UserSettingsScreen extends StatefulWidget {
  UserSettingsScreen({Key key}) : super(key: key);

  @override
  _UserSettingsScreenState createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKeyUserScreenSet = new GlobalKey<ScaffoldState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aptController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _firstNameInputFocusNode = FocusNode();
  final FocusNode _lastNameInputFocusNode = FocusNode();
  final FocusNode _addressInputFocusNode = FocusNode();
  final FocusNode _aptInputFocusNode = FocusNode();
  final FocusNode _cityInputFocusNode = FocusNode();
  bool _avatarChanged = false;
  bool _editingMode = false;
  bool _confirmEditingPressed = false;
  String _newAvatarURL = "";
  String _picPath = "";
  bool _uploadingAvatar = false;
  bool _deletedAvatar = false;
  final Divider _avatarTilesDivider = Divider(
    color: Colors.grey[400],
    indent: 10,
    thickness: 1.0,
    endIndent: 10,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    var userRep = Provider.of<UserRepository>(context, listen: false);
    _newAvatarURL = userRep.avatarURL ?? defaultAvatar;
    _firstNameController.text = userRep.firstName;
    _lastNameController.text = userRep.lastName;
    _addressController.text = userRep.address;
    _cityController.text = userRep.city;
    _aptController.text = userRep.apt;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_){
      setState(() {});
    });
    return Material(
      child: Consumer<UserRepository>(
        builder:(context, userRep, _) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 110,
                  color: Colors.lightGreen[800],
                ),
              ),
              Scaffold(
                resizeToAvoidBottomInset: true,
                resizeToAvoidBottomPadding: false,
                backgroundColor: Colors.transparent,
                key: _scaffoldKeyUserScreenSet,
                body: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 15),
                            Stack(
                              alignment: Alignment.center,
                              children: <Widget> [
                                _uploadingAvatar ?
                                Container(
                                  // padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.1),
                                  width: MediaQuery.of(context).size.height * 0.1 * 2,
                                  height: MediaQuery.of(context).size.height * 0.1 * 2,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.lightGreen[800]),
                                    )
                                  )
                                )
                                : CircularProfileAvatar(
                                  _editingMode ? _newAvatarURL : userRep.avatarURL ?? defaultAvatar,
                                  borderColor: Colors.black,
                                  borderWidth: 1.3,
                                  radius: MediaQuery.of(context).size.height * 0.1,
                                  onTap: _editingMode
                                  ? _showAvatarChangeOptions
                                  : userRep?.avatarURL != defaultAvatar
                                    ? () => Navigator.of(context).push(
                                    new MaterialPageRoute<void>(
                                      builder: (_) => Dismissible(
                                        key: const Key('key2'),
                                        direction: DismissDirection.horizontal,
                                        onDismissed: (direction) => Navigator.pop(context),
                                        child: Dismissible(
                                          key: const Key('key'),
                                          direction: DismissDirection.vertical,
                                          onDismissed: (direction) => Navigator.pop(context),
                                          child: InteractiveViewer(
                                            minScale: 1.0,
                                            maxScale: 1.0,
                                            panEnabled: false,
                                            scaleEnabled: false,
                                            boundaryMargin: EdgeInsets.all(100.0),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(userRep.avatarURL ?? defaultAvatar),
                                                  fit: BoxFit.fitWidth,
                                                )
                                              ),
                                            )
                                          ),
                                        ),
                                      ),
                                    )
                                  ) : null
                                ),
                                _editingMode && !_uploadingAvatar
                                ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    SizedBox(height: 50,),
                                    InkWell(
                                      onTap: _showAvatarChangeOptions,
                                      child: Container(
                                        width: MediaQuery.of(context).size.height * 0.18,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                          color: Colors.white54,
                                        ),
                                        child: Text(
                                          "Press to change",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                            fontSize: 15.0,
                                            color: Colors.black
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                ) : Container(),
                              ],
                            ),
                            SizedBox(height: 15,),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 10, right: 5),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.5 - 15,
                                    height: MediaQuery.of(context).size.height * 0.1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.025 - 2,
                                          width: 100.0,
                                          child: Text('First name',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: 4,),
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.075 - 2,
                                          width: MediaQuery.of(context).size.width * 0.5 - 10,
                                          child: TextField(
                                            readOnly: !_editingMode,
                                            enableInteractiveSelection: true,
                                            autofocus: false,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey),
                                                borderRadius: BorderRadius.all(Radius.circular(30))
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey),
                                                borderRadius: BorderRadius.all(Radius.circular(30))
                                              ),
                                            ),
                                            onChanged: (text) => {},
                                            textAlign: TextAlign.center,
                                            controller: _firstNameController,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp('[a-z A-Z -]'))
                                            ],
                                            focusNode: _firstNameInputFocusNode,
                                            style: GoogleFonts.lato(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                            )
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 10, left: 5),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.5 - 15,
                                    height: MediaQuery.of(context).size.height * 0.1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.025 - 2,
                                          width: 100.0,
                                          child: Text('Last name',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 16.0,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              )
                                          ),
                                        ),
                                        SizedBox(height: 4,),
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.075 - 2,
                                          width: MediaQuery.of(context).size.width * 0.5 - 10,
                                          child: TextField(
                                            readOnly: !_editingMode,
                                            autofocus: false,
                                            focusNode: _lastNameInputFocusNode,
                                            keyboardType: TextInputType.name,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey),
                                                borderRadius: BorderRadius.all(Radius.circular(30))
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey),
                                                borderRadius: BorderRadius.all(Radius.circular(30))
                                              ),
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp('[a-z A-Z -]'))
                                            ],
                                            textAlign: TextAlign.center,
                                            controller: _lastNameController,
                                            onChanged: (text) => {},
                                            style: GoogleFonts.lato(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                            )
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 15,),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text('Street address',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    )
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                  child: TextField(
                                    readOnly: !_editingMode,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                          borderRadius: BorderRadius.all(Radius.circular(30))
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                          borderRadius: BorderRadius.all(Radius.circular(30))
                                      ),
                                    ),
                                    focusNode: _addressInputFocusNode,
                                    controller: _addressController,
                                    autofocus: false,
                                    keyboardType: TextInputType.streetAddress,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp('[a-z A-Z 0-9 .]'))
                                    ],
                                    onChanged: (text) => {},
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                      fontSize: 16.0,
                                      color: Colors.black
                                    )
                                  ),
                                ),
                                SizedBox(height: 15,),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.3 - 15,
                                        height: MediaQuery.of(context).size.height * 0.1,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.03,
                                              child: Text('Apt.',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 16.0,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Container(
                                              height: MediaQuery.of(context).size.height * 0.065,
                                              width: MediaQuery.of(context).size.width * 0.3,
                                              child: TextField(
                                                autofocus: false,
                                                readOnly: !_editingMode,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.grey),
                                                      borderRadius: BorderRadius.all(Radius.circular(30))
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.grey),
                                                      borderRadius: BorderRadius.all(Radius.circular(30))
                                                  ),
                                                ),
                                                onChanged: (text) => {},
                                                textAlign: TextAlign.center,
                                                controller: _aptController,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                                                ],
                                                focusNode: _aptInputFocusNode,
                                                style: GoogleFonts.lato(
                                                  fontSize: 16.0,
                                                  color: Colors.black,
                                                )
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10.0, left: 5.0),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.7 - 15,
                                        height: MediaQuery.of(context).size.height * 0.1,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.03,
                                              child: Text('City',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 16.0,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Container(
                                              height: MediaQuery.of(context).size.height * 0.065,
                                              width: MediaQuery.of(context).size.width * 0.7 - 10,
                                              child: TextField(
                                                autofocus: false,
                                                readOnly: !_editingMode,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.grey),
                                                      borderRadius: BorderRadius.all(Radius.circular(30))
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.grey),
                                                      borderRadius: BorderRadius.all(Radius.circular(30))
                                                  ),
                                                ),
                                                onChanged: (text) => {},
                                                textAlign: TextAlign.center,
                                                controller: _cityController,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z .]'))
                                                ],
                                                focusNode: _cityInputFocusNode,
                                                style: GoogleFonts.lato(
                                                  fontSize: 16.0,
                                                  color: Colors.black,
                                                )
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: 80,),
                            Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: Container(
                                height: 40,
                                width: 200,
                                child: InkWell(
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: RaisedButton(
                                    elevation: 20.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.transparent),
                                    ),
                                    visualDensity: VisualDensity.adaptivePlatformDensity,
                                    color: _editingMode && !_confirmEditingPressed ? Colors.green[900] : Colors.grey[900],
                                    textColor: Colors.white,
                                    onPressed: _uploadingAvatar ? null
                                      : _editingMode
                                      ? () async {
                                      setState(() {
                                        _confirmEditingPressed = true;
                                      });
                                      if(_avatarChanged) {
                                        setState(() {
                                          _uploadingAvatar = true;
                                        });
                                        if(_deletedAvatar){
                                          await userRep.deleteAvatar();
                                          userRep.avatarURL = defaultAvatar;
                                        } else {
                                          await userRep.setAvatar(_picPath);
                                        }
                                        _avatarChanged = false;
                                        _deletedAvatar = false;
                                      }
                                      setState(() {
                                        if(_firstNameController.text.isNotEmpty) {
                                          userRep.firstName = _firstNameController.text;
                                        }
                                        if(_lastNameController.text.isNotEmpty) {
                                          userRep.lastName = _lastNameController.text;
                                        }
                                        if(_addressController.text.isNotEmpty) {
                                          userRep.address = _addressController.text;
                                        }
                                        if(_aptController.text.isNotEmpty) {
                                          userRep.apt = _aptController.text;
                                        }
                                        if(_cityController.text.isNotEmpty){
                                          userRep.city = _cityController.text;
                                        }
                                        _editingMode = false;
                                      });
                                      userRep.updateFirebaseUserList();
                                      setState(() {
                                        _uploadingAvatar = false;
                                      });
                                      // return Future.delayed(Duration(seconds: 3));
                                    }
                                    : () {
                                      _unfocusAll();
                                      setState(() {
                                        _editingMode = true;
                                        _confirmEditingPressed = false;
                                      });
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          _editingMode && !_confirmEditingPressed ? "Update   " : "Edit   ",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.openSans(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Icon(_editingMode && !_confirmEditingPressed ? Icons.check_outlined : Icons.edit_outlined,
                                          color: Colors.white,
                                          size: 17.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]
          );
        }
      )
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lastNameInputFocusNode.dispose();
    _firstNameInputFocusNode.dispose();
    _addressInputFocusNode.dispose();
    _aptInputFocusNode.dispose();
    _cityInputFocusNode.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _aptController.dispose();
    super.dispose();
  }

  void _showAvatarChangeOptions() {
    _unfocusAll();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: _newAvatarURL == defaultAvatar ? 67.0 * 2.0 : 67.0 * 3.0,
          child: Column(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                tileColor: Colors.white,
                leading: Icon(
                  Icons.photo_camera_outlined,
                  color: Colors.lightGreen[800],
                ),
                title: Text("Take a new photo",
                  style: GoogleFonts.lato(),
                ),
                onTap: () async {
                  PickedFile photo = await ImagePicker().getImage(source: ImageSource.camera);
                  Navigator.pop(_scaffoldKeyUserScreenSet.currentContext);
                  if (null == photo) {
                    _scaffoldKeyUserScreenSet.currentState.showSnackBar(
                      SnackBar(
                        content: Text("No image selected",
                          style: GoogleFonts.notoSans(fontSize: 14.0),
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(milliseconds: 2500),
                      )
                    );
                  } else {
                    setState(() {
                      _uploadingAvatar = true;
                    });
                    _picPath = photo.path;
                    var userRep = Provider.of<UserRepository>(context, listen: false);
                    await userRep.storage.ref("tempAvatarImages").child(userRep.auth.currentUser.uid).putFile(File(photo.path));
                    var pic = await userRep.storage.ref("tempAvatarImages").child(userRep.auth.currentUser.uid).getDownloadURL();
                    setState(() {
                      _newAvatarURL = pic;
                      _avatarChanged = true;
                    });
                    setState(() {
                      _uploadingAvatar = false;
                    });
                  }
                },
              ),
              _avatarTilesDivider,
              ListTile(
                tileColor: Colors.white,
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: Colors.lightGreen[800],
                ),
                title: Text("Select from gallery",
                  style: GoogleFonts.lato(),
                ),
                onTap: () async {
                  PickedFile photo = await ImagePicker().getImage(source: ImageSource.gallery);
                  Navigator.pop(context);
                  if (null == photo) {
                    _scaffoldKeyUserScreenSet.currentState.showSnackBar(
                      SnackBar(
                        content: Text("No image selected",
                          style: GoogleFonts.notoSans(fontSize: 14.0),
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(milliseconds: 2500),
                      )
                    );
                  } else {
                    setState(() {
                      _uploadingAvatar = true;
                    });
                    _picPath = photo.path;
                    var userRep = Provider.of<UserRepository>(context, listen: false);
                    await userRep.storage.ref("tempAvatarImages").child(userRep.auth.currentUser.uid).putFile(File(photo.path));
                    var pic = await userRep.storage.ref("tempAvatarImages").child(userRep.auth.currentUser.uid).getDownloadURL();
                    setState(() {
                      _newAvatarURL = pic;
                      _avatarChanged = true;
                    });
                    setState(() {
                      _uploadingAvatar = false;
                    });
                  }
                },
              ),
              _newAvatarURL != defaultAvatar
                ? _avatarTilesDivider
                : Container(),
              _newAvatarURL != defaultAvatar
                  ? ListTile(
                tileColor: Colors.white,
                leading: Icon(
                  Icons.delete_outline_outlined,
                  color: Colors.red,
                ),
                title: Text("Delete avatar",
                  style: GoogleFonts.lato(
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => AlertDialog(
                      title: Text("Delete avatar?",
                        style: GoogleFonts.lato(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                      content: Text("Are you sure you want to delete your avatar?",
                        style: GoogleFonts.lato(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      elevation: 24.0,
                      actions: [
                        FlatButton(
                          child: Text("Yes",
                            style: GoogleFonts.lato(
                              fontSize: 14.0,
                              color: Colors.green,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _newAvatarURL = defaultAvatar;
                              _avatarChanged = true;
                              _deletedAvatar = true;
                            });
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: Text("No",
                            style: GoogleFonts.lato(
                              fontSize: 14.0,
                              color: Colors.red,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    )
                  );
                },
              )
                  : Container(),
            ],
          ),
        );
      }
    );
  }

  void _unfocusAll(){
    _addressInputFocusNode.unfocus();
    _firstNameInputFocusNode.unfocus();
    _lastNameInputFocusNode.unfocus();
    _aptInputFocusNode.unfocus();
    _cityInputFocusNode.unfocus();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final value = WidgetsBinding.instance.window.viewInsets.bottom;
    if(0 == value) {
      _unfocusAll();
    }
  }
}
