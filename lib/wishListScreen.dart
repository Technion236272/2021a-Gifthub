import 'package:gifthub_2021a/productMock.dart';
import 'userMock.dart'; //TODO: remove as soon as user repository class is implemented
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

class WishListScreen extends StatefulWidget {
  WishListScreen({Key key}) : super(key: key);

  @override
  _WishListScreenState createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> with SingleTickerProviderStateMixin {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKeyWishList = new GlobalKey<ScaffoldState>();

  // TODO: remove these as soon as user repository is initialized with firebase:
  @override
  void initState() {
    super.initState();
    var userRep = Provider.of<UserRepository>(context, listen: false);
    userRep.orders.add(new Product("cake", 15.0, OrderStatus.Arrived,
        "https://storcpdkenticomedia.blob.core.windows.net/media/recipemanagementsystem/media/recipe-media-files/recipes/retail/desktopimages/rainbow-cake600x600_2.jpg?ext=.jpg"));
    userRep.orders.add(new Product(
        "18 muffins", 5.0, OrderStatus.Pending,
        "https://pngimg.com/uploads/muffin/muffin_PNG123.png"));
    userRep.orders.add(new Product(
        "rose bouquet", 50.0, OrderStatus.Ordered,
        "https://images-na.ssl-images-amazon.com/images/I/71t3JW2-jzL._SL1500_.jpg"));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Consumer<UserRepository>(
        builder: (context, userRep, _) =>
          RepaintBoundary(
            key: _repaintBoundaryKey,
            child: Scaffold(
              key: _scaffoldKeyWishList,
              resizeToAvoidBottomPadding: false,
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.lightGreen[900],
              appBar: AppBar(
                automaticallyImplyLeading: false,
                elevation: 0.0,
                backgroundColor: Colors.lightGreen[900],
                leading: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: null //TODO: implement navigation drawer
                ),
                title: Text("Wish List",
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 10,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        // padding: EdgeInsets.all(12),
                        color: Colors.green[600],
                        child: ListView.builder(
                          itemCount: userRep.orders.length * 2,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (BuildContext _context, int i) {
                            if (i >= 2 * userRep.orders.length) {
                              return null;
                            }
                            if (i.isOdd) {
                              return Divider(
                                color: Colors.red,
                                thickness: 2.0,
                              );
                            }
                            var wishListProduct = userRep.orders[i~/2];
                            return Slidable(
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: 0.22,
                              direction: Axis.horizontal,
                              actions: <Widget>[
                                //add to cart
                                IconSlideAction(
                                  caption: 'Add to cart',
                                  color: Colors.transparent,
                                  foregroundColor: Colors.amberAccent,
                                  icon: Icons.add_shopping_cart,
                                  onTap: () {
                                    //TODO: implement adding to cart option
                                  },
                                ),
                                // Share
                                IconSlideAction(
                                  caption: 'Share',
                                  color: Colors.transparent,
                                  foregroundColor: Colors.black,
                                  icon: Icons.share,
                                  onTap: () async {
                                    final RenderBox box = _scaffoldKeyWishList
                                        .currentContext
                                        .findRenderObject();
                                    Product product = userRep.orders[i ~/ 2];
                                    if (Platform.isAndroid) {
                                      var response = await get(
                                          product.productPictureURL);
                                      final documentDirectory = (await getExternalStorageDirectory())
                                          .path;
                                      File imgFile = new File(
                                          '$documentDirectory/flutter.png');
                                      imgFile.writeAsBytesSync(
                                          response.bodyBytes);
                                      List<String> sharingList = new List();
                                      sharingList.add(
                                          '$documentDirectory/flutter.png');
                                      //TODO: add store's name next to product's name or add a direct url share option
                                      await Share.shareFiles(
                                          sharingList,
                                          text: "check this cool product now!\n" +
                                              product.name,
                                          sharePositionOrigin: box
                                              .localToGlobal(
                                              Offset.zero) & box
                                              .size,
                                          subject: 'I found a lovely product on Gifthub!'
                                      );
                                    }
                                  },
                                ),
                              ],
                              secondaryActions: <Widget>[
                                // Delete
                                IconSlideAction(
                                  caption: 'Delete',
                                  color: Colors.transparent,
                                  foregroundColor: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () {
                                    var product;
                                    setState(() {
                                      product = userRep.orders.removeAt(i~/2);
                                    });
                                    _scaffoldKeyWishList.currentState.showSnackBar(
                                        SnackBar(
                                          content: Text('Product deleted'),
                                          behavior: SnackBarBehavior.floating,
                                          action: SnackBarAction(
                                            textColor: Colors.deepPurpleAccent,
                                            label:'Undo',
                                            onPressed: () {
                                              setState(() {
                                                userRep.orders.add(product);
                                              });
                                            },
                                          ),
                                        )
                                    );
                                  },
                                )
                              ],
                              child: ListTile(
                                onTap: null, //TODO: implement navigation to product page
                                leading: CircularProfileAvatar(
                                  wishListProduct.productPictureURL,
                                  radius: 26.0,
                                  onTap: () {
                                    Navigator.of(context).push(new MaterialPageRoute<void>(
                                      builder: (BuildContext context) => Dismissible(
                                        direction: DismissDirection.down,
                                        key: const Key('key'),
                                        onDismissed: (_) => Navigator.pop(_scaffoldKeyWishList.currentContext),
                                        child: Center(
                                          child: InteractiveViewer(
                                            boundaryMargin: EdgeInsets.all(0),
                                            minScale: 1.0,
                                            maxScale: 2.2,
                                            child: Image.network(wishListProduct.productPictureURL,
                                              fit: BoxFit.fitWidth,
                                            )
                                          ),
                                        )
                                      ),
                                    )
                                    );
                                  },
                                ),
                                title: Text(wishListProduct.name,
                                  style: GoogleFonts.lato(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(wishListProduct.price.toString() + "\$",
                                  style: GoogleFonts.lato(
                                    fontSize: 13.5,
                                    color: Colors.white,
                                  ),
                                ),
                                visualDensity: VisualDensity.adaptivePlatformDensity,
                              ),
                            );
                          }
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}