import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:flutter/gestures.dart';
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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:auto_size_text/auto_size_text.dart';

///-----------------------------------------------------------------------------
/// User Settings Screen
/// displays user's personal information and enables modifying user's info.
/// including:
/// - Avatar
/// - First and Last name
/// - address
/// - city
/// - Apartment
///-----------------------------------------------------------------------------

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
  final TextEditingController _googleStreetController = TextEditingController();
  final TextEditingController _googleCityController = TextEditingController();
  final FocusNode _firstNameInputFocusNode = FocusNode();
  final FocusNode _lastNameInputFocusNode = FocusNode();
  final FocusNode _addressInputFocusNode = FocusNode();
  final FocusNode _aptInputFocusNode = FocusNode();
  final FocusNode _cityInputFocusNode = FocusNode();
  final FocusNode _googleStreetInputFocusNode = FocusNode();
  final FocusNode _googleCityInputFocusNode = FocusNode();

  /// Google Map controller
  Completer<GoogleMapController> _googleMapsController = Completer();

  /// initial camera position of the map - set to Sarina Market, TLV :)
  static const LatLng _center = const LatLng(32.07163382209752, 34.78555801330857);

  ///user's current location
  LocationData _locationData;

  /// set of map markers that user inserted
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  /// true if user modified their avatar on edit mode, else false
  bool _avatarChanged = false;

  /// true if screen's current state in edit mode, else false
  bool _editingMode = false;

  ///true if user was on edit mode and presses confirm changes, else false
  bool _confirmEditingPressed = false;

  ///holds new avatar uploaded url if user changed avatar
  String _newAvatarURL = "";

  ///holds new avatar uploaded path if user changed avatar
  String _picPath = "";

  ///true if phone is currently uploading avatar, else false
  bool _uploadingAvatar = false;

  ///true if user chose to delete their avatar, else false
  bool _deletedAvatar = false;

  final Divider _avatarTilesDivider = Divider(
    color: Colors.grey[400],
    indent: 10,
    thickness: 1.0,
    endIndent: 10,
  );

  /// all map types available on our app:
  final List<MapType> _mapTypes = <MapType>[
    MapType.normal,
    MapType.hybrid,
  ];

  /// this is the initial tilt of the map:
  static const double _magicTilt = 59.440717697143555;

  /// current map type displayed on screen (default is normal):
  MapType _currentMapType = MapType.normal;

  /// user's current address location
  Address _address;

  ///whether or not customers are allowed to call the user
  ///TODO: pull it from the DB!!
  bool _allowCall = false;

  ///whether or not customers are allowed to navigate to the user
  ///TODO: pull it from the DB!!
  bool _allowNavigate = false;

  ///space between Columned TextFields:
  SizedBox _space = SizedBox(height: 10,);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ///fetching current data of user
    var userRep = Provider.of<UserRepository>(context, listen: false);
    _newAvatarURL = userRep.avatarURL ?? defaultAvatar;
    _firstNameController.text = userRep.firstName;
    _lastNameController.text = userRep.lastName;
    _addressController.text = userRep.address;
    _cityController.text = userRep.city;
    _aptController.text = userRep.apt;
  }

  /// method that is called on map creation and takes a MapController as a parameter.
  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _googleMapsController.complete(controller);
    });
    if(_markers.isEmpty){
      return;
    }
    var marker = _markers.values.first;
    double lat = marker.position.latitude;
    double long = marker.position.longitude;
    var c = await _googleMapsController.future;
    await c.animateCamera(CameraUpdate.newLatLng(LatLng(lat, long)));
    // await c.showMarkerInfoWindow(marker.markerId);
    setState(() {});
  }

  /// Map's text fields' input decoration
  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      enabledBorder: _getOutlineInputBorder(),
      focusedBorder: _getOutlineInputBorder(color: Colors.lightGreen.shade800),
      hintText: hint,
      suffixIcon: hint == 'City'
        ? Icon(Icons.location_city_outlined)
        : Icon(Icons.home_outlined),
      contentPadding: EdgeInsets.fromLTRB(5.0 , 5.0 , 5.0 , 5.0),
    );
  }

  /// Map's text fields' outline input border
  OutlineInputBorder _getOutlineInputBorder({Color color = Colors.grey}) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: 1.3,
      ),
      borderRadius: BorderRadius.all(Radius.circular(30)),
    );
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
                  height: MediaQuery.of(context).size.width * 0.35,
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
                            _space,
                            ///user's Avatar
                            Stack(
                              alignment: Alignment.center,
                              children: <Widget> [
                                ///circular progress indicator if user's picture yet to be set
                                _uploadingAvatar ?
                                Container(
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
                                  ///showing currently uploaded avatar if we're on edit mode
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
                                  ///'Press to change' text if we're on edit mode and not uploading
                                  ///new avatar
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
                                            fontSize: MediaQuery.of(context).size.height * 0.0256 * (15/18),
                                            color: Colors.black
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                ) : Container(),
                              ],
                            ),
                            _space,
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ///user's first name
                                Padding(
                                  padding: EdgeInsets.only(left: 10, right: 5),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.5 - 15,
                                    height: MediaQuery.of(context).size.height * 0.11,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Flexible(
                                          child: Text('First name',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: Container(
                                            height: MediaQuery.of(context).size.height * 0.07 - 2,
                                            width: MediaQuery.of(context).size.width * 0.5 - 10,
                                            child: TextField(
                                              readOnly: !_editingMode,
                                              enableInteractiveSelection: true,
                                              autofocus: false,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.fromLTRB(5.0 , 13.0 , 5.0 , 13.0),
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
                                              textAlignVertical: TextAlignVertical.top,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ///user's last name
                                Padding(
                                  padding: EdgeInsets.only(right: 10, left: 5),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.5 - 15,
                                    height: MediaQuery.of(context).size.height * 0.11,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Flexible(
                                          child: Text('Last name',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 16.0,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              )
                                          ),
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: Container(
                                            height: MediaQuery.of(context).size.height * 0.07 - 2,
                                            width: MediaQuery.of(context).size.width * 0.5 - 10,
                                            child: TextField(
                                              readOnly: !_editingMode,
                                              autofocus: false,
                                              focusNode: _lastNameInputFocusNode,
                                              keyboardType: TextInputType.name,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.fromLTRB(5.0 , 13.0 , 5.0 , 13.0),
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
                                              textAlignVertical: TextAlignVertical.top,
                                              textAlign: TextAlign.center,
                                              controller: _lastNameController,
                                              onChanged: (text) => {},
                                              style: GoogleFonts.lato(
                                                fontSize: 16.0,
                                                color: Colors.black,
                                              )
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            _space,
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
                                ///user's address
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.075 - 2,
                                    child: TextField(
                                      onTap:  () {
                                        _unfocusAll();
                                        if(!_editingMode || _confirmEditingPressed) {
                                          return;
                                        }
                                        /// Displaying Google Map:
                                        showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (context) {
                                            return StatefulBuilder(
                                              builder: (BuildContext context, void Function(void Function()) setState) =>
                                                Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(20.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(context).unfocus();
                                                      },
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                                        child: Material(
                                                          child: Container(
                                                            color: Colors.transparent,
                                                            height: MediaQuery.of(context).size.height * 0.8,
                                                            width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: <Widget>[
                                                                Flexible(
                                                                  flex: 5,
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: <Widget>[
                                                                      /// Google Street text field:
                                                                      Flexible(
                                                                        flex: 4,
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.only(
                                                                            left: 8.0,
                                                                            right: 4.0,
                                                                            top: 12.0,
                                                                            bottom: 9.0,
                                                                          ),
                                                                          child: TextField(
                                                                            controller: _googleStreetController,
                                                                            decoration: _getInputDecoration('Street'),
                                                                            style: GoogleFonts.lato(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 16.0,
                                                                            ),
                                                                            focusNode: _googleStreetInputFocusNode,
                                                                            autofocus: false,
                                                                            textAlign: TextAlign.start,
                                                                            textAlignVertical: TextAlignVertical.center,
                                                                            keyboardType: TextInputType.streetAddress,
                                                                            inputFormatters: [
                                                                              FilteringTextInputFormatter.allow(RegExp('[a-z A-Z 0-9 . א-ת]'))
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      /// Google City text field:
                                                                      Flexible(
                                                                        flex: 3,
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.only(
                                                                            left: 4.0,
                                                                            right: 4.0,
                                                                            top: 12.0,
                                                                            bottom: 9.0,
                                                                          ),
                                                                          child: TextField(
                                                                            controller: _googleCityController,
                                                                            decoration: _getInputDecoration('City'),
                                                                            style: GoogleFonts.lato(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 16.0,
                                                                            ),
                                                                            keyboardType: TextInputType.streetAddress,
                                                                            inputFormatters: [
                                                                              FilteringTextInputFormatter.allow(RegExp('[a-z A-Z . א-ת]'))
                                                                            ],
                                                                            focusNode: _googleCityInputFocusNode,
                                                                            autofocus: false,
                                                                            textAlign: TextAlign.start,
                                                                            textAlignVertical: TextAlignVertical.center,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      /// Search icon:
                                                                      Flexible(
                                                                        flex: 1,
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.only(bottom: 9.0),
                                                                          child: InkWell(
                                                                            onTap: () async {
                                                                              _unfocusAll();
                                                                              if(_isAddressEmpty()){
                                                                                Fluttertoast.showToast(msg: 'Please choose address');
                                                                                return;
                                                                              }
                                                                              List<Address> locations = <Address>[];
                                                                              try{
                                                                                locations = await Geocoder.local.findAddressesFromQuery(
                                                                                    _googleStreetController.text.trim() + ' ' + _googleCityController.text.trim()
                                                                                );
                                                                              } on PlatformException catch (_){
                                                                                Fluttertoast.showToast(msg: '   Invalid address   ');
                                                                                return;
                                                                              }
                                                                              if(locations.isEmpty){
                                                                                Fluttertoast.showToast(msg: '   Invalid address   ');
                                                                                return;
                                                                              }
                                                                              var first = locations.first;
                                                                              await _goToAddress(first);
                                                                              //FIXME: throwing PlatformException:
                                                                              // await _googleMapsController.future..showMarkerInfoWindow(_markers.keys.first);
                                                                              setState(() {});
                                                                            },
                                                                            child: Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: <Widget>[
                                                                                Flexible(
                                                                                  flex: 2,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(
                                                                                      bottom: 1.0,
                                                                                      top: 9.0,
                                                                                    ),
                                                                                    child: Image.asset(
                                                                                      'Assets/search_location-512.png',
                                                                                      width: MediaQuery.of(context).size.width * 0.075,
                                                                                      height: MediaQuery.of(context).size.height * 0.04,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Flexible(
                                                                                  flex: 1,
                                                                                  child: Text('Search',
                                                                                    style: GoogleFonts.lato(
                                                                                      fontSize: MediaQuery.of(context).size.height * 0.0256 * (12/18) + 0.4,
                                                                                      fontWeight: FontWeight.w600
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                ///Google Map:
                                                                Flexible(
                                                                  flex: 33,
                                                                  child: Stack(
                                                                    children: <Widget>[
                                                                      GoogleMap(
                                                                        markers: Set<Marker>.of(_markers.values),
                                                                        onTap: (LatLng details) {
                                                                          _unfocusAll();
                                                                        },
                                                                        mapType: _currentMapType,
                                                                        compassEnabled: false,
                                                                        myLocationEnabled: false,
                                                                        myLocationButtonEnabled: false,
                                                                        onMapCreated: (c) async {
                                                                          await _onMapCreated(c);
                                                                        },
                                                                        initialCameraPosition: CameraPosition(
                                                                          //TODO: think about alternative target place:
                                                                          target: _center,
                                                                          zoom: 17.6,
                                                                          tilt: _magicTilt,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.all(16.0),
                                                                        child: Align(
                                                                          alignment: Alignment.topLeft,
                                                                          child: Column(
                                                                            children: <Widget>[
                                                                              /// Change Map Type:
                                                                              FloatingActionButton(
                                                                                onPressed: () async {
                                                                                  _unfocusAll();
                                                                                  setState(() {
                                                                                    _currentMapType =
                                                                                    _currentMapType == _mapTypes[0]
                                                                                      ? _mapTypes[1]
                                                                                      : _mapTypes[0];
                                                                                  });
                                                                                },
                                                                                materialTapTargetSize: MaterialTapTargetSize.padded,
                                                                                backgroundColor: Colors.green.shade800,
                                                                                child: const Icon(Icons.map, size: 36.0),
                                                                              ),
                                                                              SizedBox(height: 16.0),
                                                                              /// Use Current Location:
                                                                              FloatingActionButton(
                                                                                materialTapTargetSize: MaterialTapTargetSize.padded,
                                                                                backgroundColor: Colors.green.shade800,
                                                                                onPressed: () async {
                                                                                  _unfocusAll();
                                                                                  String msg = await _onCurrentLocationPressed();
                                                                                  if (msg != 'Success') {
                                                                                    Fluttertoast.showToast(msg: 'Error: ' + msg);
                                                                                    return;
                                                                                  }
                                                                                  await _goToAddress(_address);
                                                                                  setState(() {
                                                                                    _googleStreetController.text = _getAddressAsString(_address).trim();
                                                                                    _googleCityController.text = _address.locality.trim();
                                                                                  });
                                                                                },
                                                                                child: Image.asset('Assets/current-location-icon.png',
                                                                                  width: MediaQuery.of(context).size.width * 0.11,
                                                                                  height: MediaQuery.of(context).size.height * 0.11,
                                                                                  color: Colors.white,
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                /// Submit Button:
                                                                Flexible(
                                                                  flex: 4,
                                                                  child: Center(
                                                                    child: OutlineButton.icon(
                                                                      onPressed: () {
                                                                        if(_isAddressEmpty()){
                                                                          Fluttertoast.showToast(
                                                                              msg: 'Please choose address'
                                                                          );
                                                                          return;
                                                                        }
                                                                        if(_markers.isEmpty){
                                                                          Fluttertoast.showToast(
                                                                              msg: 'Please search map location first'
                                                                          );
                                                                          return;
                                                                        }
                                                                        /// updating user's address
                                                                        String city = _address.locality ?? '';
                                                                        super.setState(() {
                                                                          _addressController.text = _getAddressAsString(_address) +
                                                                              (city.isNotEmpty ? ', ' + city : '');
                                                                        });
                                                                        Navigator.pop(context);
                                                                      },
                                                                      icon: Icon(
                                                                        Icons.approval,
                                                                        color: Colors.black,
                                                                        size: MediaQuery.of(context).size.height * 0.0256 * 25/18,
                                                                      ),
                                                                      label: Text(
                                                                        'Submit chosen location',
                                                                        textAlign: TextAlign.center,
                                                                        style: GoogleFonts.lato(
                                                                          fontSize: MediaQuery.of(context).size.height * 0.0256 * 16/18,
                                                                          fontWeight: FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      borderSide: BorderSide(
                                                                        color: Colors.black,
                                                                        width: 1.5,
                                                                      ),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(30.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            );
                                          }
                                        );
                                      },
                                      readOnly: true, //!_editingMode,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.fromLTRB(5.0 , 20.0 , 5.0 , 18.0),
                                        prefix: Transform.translate(
                                          offset: Offset(0.0, 5.0),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Image.asset(
                                              _editingMode && !_confirmEditingPressed
                                                ? 'Assets/GoogleMaps.png'
                                                : 'Assets/GoogleMapsGrey.jpeg',
                                              width: MediaQuery.of(context).size.width * 0.075,
                                              height: MediaQuery.of(context).size.height * 0.04,
                                            ),
                                          ),
                                        ),
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
                                      textAlignVertical: TextAlignVertical.top,
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 16.0,
                                        color: Colors.black
                                      )
                                    ),
                                  ),
                                ),
                                _space,
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    ///user's apartment
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.3 - 15,
                                        height: MediaQuery.of(context).size.height * 0.11,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text('Apt.',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 16.0,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Flexible(
                                              flex: 2,
                                              child: Container(
                                                height: MediaQuery.of(context).size.height * 0.07 - 2,
                                                width: MediaQuery.of(context).size.width * 0.3,
                                                child: TextField(
                                                  autofocus: false,
                                                  readOnly: !_editingMode,
                                                  keyboardType: TextInputType.number,
                                                  decoration: InputDecoration(
                                                    counterText: "",
                                                    contentPadding: EdgeInsets.fromLTRB(5.0 , 13.0 , 5.0 , 13.0),
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
                                                  textAlignVertical: TextAlignVertical.center,
                                                  textAlign: TextAlign.center,
                                                  controller: _aptController,
                                                  maxLength: 6,
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
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ///user's city
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10.0, left: 5.0),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.7 - 15,
                                        height: MediaQuery.of(context).size.height * 0.11,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text('City',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 16.0,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Flexible(
                                              flex: 2,
                                              child: Container(
                                                height: MediaQuery.of(context).size.height * 0.07 - 2,
                                                width: MediaQuery.of(context).size.width * 0.7 - 10,
                                                child: TextField(
                                                  autofocus: false,
                                                  readOnly: !_editingMode,
                                                  decoration: InputDecoration(
                                                    contentPadding: EdgeInsets.fromLTRB(5.0 , 13.0 , 5.0 , 13.0),
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
                                                  textAlignVertical: TextAlignVertical.top,
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
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.4 - kBottomNavigationBarHeight ,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ///allow call
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: ListTileTheme(
                                              contentPadding: EdgeInsets.all(0),
                                              child: CheckboxListTile(
                                                value: _allowCall,
                                                isThreeLine: false,
                                                title: AutoSizeText('Allow others to call me',
                                                  minFontSize: 15.0,
                                                  maxLines: 1,
                                                  style: GoogleFonts.lato(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                controlAffinity: ListTileControlAffinity.leading,
                                                checkColor: Colors.white,
                                                secondary: Icon(
                                                  _allowCall
                                                    ? Icons.phone_enabled
                                                    : Icons.phone_disabled,
                                                ),
                                                autofocus: false,
                                                // contentPadding:  EdgeInsets.fromLTRB(5.0 , 20.0 , 5.0 , 20.0),
                                                onChanged: _editingMode && !_confirmEditingPressed
                                                  ? (value) {
                                                    setState(() {
                                                      _allowCall = value;
                                                    });
                                                  } : null
                                              ),
                                            ),
                                          ),
                                        ),
                                        ///allow navigation
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: ListTileTheme(
                                              contentPadding: EdgeInsets.all(0),
                                              child: CheckboxListTile(
                                                  value: _allowNavigate,
                                                  isThreeLine: false,
                                                  title: AutoSizeText('Allow others to navigate to my store',
                                                    minFontSize: 13.0,
                                                    maxLines: 1,
                                                    style: GoogleFonts.lato(
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  controlAffinity: ListTileControlAffinity.leading,
                                                  checkColor: Colors.white,
                                                  secondary: Icon(
                                                    _allowNavigate
                                                        ? Icons.near_me
                                                        : Icons.near_me_disabled,
                                                  ),
                                                  autofocus: false,
                                                  // contentPadding:  EdgeInsets.fromLTRB(5.0 , 20.0 , 5.0 , 20.0),
                                                  onChanged: _editingMode && !_confirmEditingPressed
                                                      ? (value) {
                                                    setState(() {
                                                      _allowNavigate = value;
                                                    });
                                                  } : null
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  /// edit/submit changes button
                                  Flexible(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment(0.0, -0.5),
                                      child: Container(
                                        height: 40,
                                        width: 200,
                                        child: InkWell(
                                          child: RaisedButton(
                                            elevation: 8.0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18.0),
                                              side: BorderSide(color: Colors.transparent),
                                            ),
                                            visualDensity: VisualDensity.adaptivePlatformDensity,
                                            color: _editingMode && !_confirmEditingPressed ? Colors.green[900] : Colors.grey[900],
                                            textColor: Colors.white,
                                            onPressed:
                                            ///disabling button if we're uploading new avatar
                                            _uploadingAvatar ? null
                                              : _editingMode
                                            ///if we're in edit mode then we submit our changes
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
                                              await userRep.updateFirebaseUserList();
                                              setState(() {
                                                _uploadingAvatar = false;
                                              });
                                            }
                                            ///setting edit mode:
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
                                  ),
                                ],
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
    _googleCityInputFocusNode.dispose();
    _googleStreetInputFocusNode.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _aptController.dispose();
    _googleCityController.dispose();
    _googleStreetController.dispose();
    super.dispose();
  }

  ///showing bottom sheet of avatar changing options, including
  ///choose from gallery, camera and if user's avatar isn;t the defaulted one
  ///then also deletion option
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

  ///removing focus from all text field's
  void _unfocusAll(){
    _addressInputFocusNode.unfocus();
    _firstNameInputFocusNode.unfocus();
    _lastNameInputFocusNode.unfocus();
    _aptInputFocusNode.unfocus();
    _cityInputFocusNode.unfocus();
    _googleCityInputFocusNode.unfocus();
    _googleStreetInputFocusNode.unfocus();
  }

  /// QoL function that validates user's address input isn't empty
  bool _isAddressEmpty(){
    return _googleStreetController.text.trim().isEmpty || _googleCityController.text.trim().isEmpty;
  }

  /// called when user wants to use current location:
  Future<String> _onCurrentLocationPressed() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return 'Service is disabled';
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return 'permission denied - please enable it from app settings';
      }
    }
    String error = '';
    try {
      _locationData = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission Denied';
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission Denied - please enable it from app settings';
      }
      _locationData = null;
      return error.isEmpty ? 'Something unexpected occurred' : error;
    } catch (_) {
      return 'Something unexpected occurred';
    }
    final coordinates = new Coordinates(_locationData.latitude, _locationData.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    _address = addresses.first;
    return 'Success';
  }

  ///hiding keyboard and un-focusing text field on user tap outside text field
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final value = WidgetsBinding.instance.window.viewInsets.bottom;
    if(0 == value) {
      _unfocusAll();
    }
  }

  /// called upon successful search query of user's input.
  /// animates camera to the location submitted by the user.
  Future<void> _goToAddress(Address first) async {
    final GoogleMapController controller = await _googleMapsController.future;
    double lat = first.coordinates.latitude, long = first.coordinates.longitude;
    var position = CameraPosition(
      target: LatLng(lat, long),
      zoom: 17.6,
      tilt: _magicTilt,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
    if(_markers.isNotEmpty && await controller.isMarkerInfoWindowShown(_markers.keys.first)){
      await controller.hideMarkerInfoWindow(_markers.keys.first);
    }
    _address = first;
    _addMarker(LatLng(lat, long), first);
  }

  /// adds new marker on the map, corresponding to user's input.
  void _addMarker(LatLng latLng, Address first) {
    final MarkerId markerId = MarkerId(latLng.toString());
    final Marker marker = Marker(
      markerId: markerId,
      draggable: false,
      visible: true,
      position: latLng,
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: _getAddressAsString(first),
        snippet: first.locality.trim() + ', ' + first.adminArea.trim() + ', ' + first.countryName.trim(),
      )
    );
    _markers.clear();
    setState(() {
      _markers[markerId] = marker;
    });
  }

  /// return a String formatted address from [Address]
  String _getAddressAsString(Address first){
    return null != first.thoroughfare || null != first.subThoroughfare
        ? ((first.thoroughfare ?? '').trim() + ' ' + (first.subThoroughfare ?? '')).trim()
        : _googleStreetController.text.trim() + ', ' + _googleCityController.text.trim();
  }
}
