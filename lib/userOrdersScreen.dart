import 'dart:ui';
import 'package:gifthub_2021a/productMock.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:io';
import 'user_repository.dart';

class UserOrdersScreen extends StatefulWidget {
  UserOrdersScreen({Key key}) : super(key: key);

  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen>{
  final GlobalKey<ScaffoldState> _scaffoldKeyOrders = new GlobalKey<ScaffoldState>();

  // TODO: remove these as soon as user repository is initialized with firebase:
  @override
  void initState() {
    super.initState();
    var userRep = Provider.of<UserRepository>(context, listen: false);
    userRep.orders.clear();
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
        builder: (context, userRep, _) {
          return Scaffold(
            key: _scaffoldKeyOrders,
            resizeToAvoidBottomInset: false,
            resizeToAvoidBottomPadding: false,
            backgroundColor: Colors.lightGreen[800],
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
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
                              color: Colors.green,
                              thickness: 1.0,
                            );
                          }
                          var ordersProduct = userRep.orders[i~/2];
                          return Slidable(
                            showAllActionsThreshold: 0.5,
                            actionPane: SlidableDrawerActionPane(),
                            fastThreshold: 2.0,
                            actionExtentRatio: 0.22,
                            direction: Axis.horizontal,
                            actions: <Widget>[
                              //Reorder
                              IconSlideAction(
                                caption: 'Reorder',
                                color: Colors.transparent,
                                foregroundColor: Colors.amberAccent,
                                icon: Icons.attach_money_outlined,
                                onTap: () {
                                  //TODO: implement reorder option screen
                                },
                              ),
                              //Write review
                              IconSlideAction(
                                caption: 'Write review',
                                color: Colors.transparent,
                                foregroundColor: Colors.lime,
                                icon: Icons.star_half_outlined,
                                onTap: () {
                                  showModalBottomSheet<dynamic>(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (BuildContext context1) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(_scaffoldKeyOrders.currentContext).viewInsets.bottom
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              SizedBox(height: 10,),
                                              RatingBar.builder(
                                                  initialRating: 0,
                                                  itemCount: 5,
                                                  minRating: 1,
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: true,
                                                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                  itemBuilder: (context, __) {
                                                    return Icon(
                                                      Icons.star,
                                                      color: Colors.lightGreen[800],
                                                    );
                                                  },
                                                  onRatingUpdate: (rating) {
                                                    setState(() {

                                                    });
                                                  }
                                              ),
                                              SizedBox(height: 15.0,),
                                              Container(
                                                width: MediaQuery.of(context1).size.width - 45,
                                                height: 150,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                                                ),
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    hintText: "Write a review...",
                                                    focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.lightGreen[800],
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.lightGreen[800],
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                                  maxLines: null,
                                                  minLines: 5,
                                                  keyboardType: TextInputType.multiline,
                                                ),
                                              ),
                                              SizedBox(height: 5.0,),
                                              Align(
                                                alignment: FractionalOffset.bottomCenter,
                                                child: Container(
                                                  width: 200,
                                                  child: RaisedButton(
                                                    color: Colors.white,
                                                    textColor: Colors.lightGreen[800],
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(18.0),
                                                        side: BorderSide(
                                                          color: Colors.lightGreen[800],
                                                          width: 2.0,
                                                        )
                                                    ),
                                                    visualDensity: VisualDensity.adaptivePlatformDensity,
                                                    onPressed: () {
                                                      setState(() {

                                                      });
                                                    },
                                                    child: Text(
                                                      "Submit",
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.openSans(
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.bold,
                                                        // color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10.0,)
                                            ],
                                          ),
                                        );
                                      }
                                  );
                                },
                              ),
                              //share
                              IconSlideAction(
                                caption: 'Share to...',
                                color: Colors.transparent,
                                foregroundColor: Colors.blueAccent,
                                icon: Icons.share_outlined,
                                onTap: () async {
                                  final RenderBox box = _scaffoldKeyOrders.currentContext.findRenderObject();
                                  if (Platform.isAndroid) {
                                    var response = await get(ordersProduct.productPictureURL);
                                    final documentDirectory = (await getExternalStorageDirectory()).path;
                                    File imgFile = new File('$documentDirectory/flutter.png');
                                    imgFile.writeAsBytesSync(response.bodyBytes);
                                    List<String> sharingList = new List();
                                    sharingList.add('$documentDirectory/flutter.png');
                                    //TODO: add store's name next to product's name or add a direct url share option
                                    await Share.shareFiles(sharingList,
                                        text: "check this cool product now!\n" + ordersProduct.name,
                                        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
                                        subject: 'I found a lovely product on Gifthub!'
                                    );
                                  }
                                },
                              )
                            ],
                            secondaryActions: <Widget>[
                              //delete
                              IconSlideAction(
                                caption: 'Delete',
                                color: Colors.transparent,
                                foregroundColor: Colors.red,
                                icon: Icons.delete_outline_outlined,
                                onTap: () {
                                  var product;
                                  setState(() {
                                    product = userRep.orders.removeAt(i~/2);
                                  });
                                  _scaffoldKeyOrders.currentState.showSnackBar(
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
                                }
                              ),
                            ],
                            child: ListTile(
                              leading: CircularProfileAvatar(
                                ordersProduct.productPictureURL,
                                radius: 26.0,
                                onTap: () {
                                  Navigator.of(context).push(new MaterialPageRoute<void>(
                                    builder: (BuildContext context) => Dismissible(
                                      key: const Key('keyV'),
                                      direction: DismissDirection.vertical,
                                      onDismissed: (_) => Navigator.pop(context),
                                      child: Dismissible(
                                        key: const Key('keyH'),
                                        direction: DismissDirection.horizontal,
                                        onDismissed: (_) => Navigator.pop(context),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(ordersProduct.productPictureURL),
                                              fit: BoxFit.fitWidth,
                                            )
                                          )
                                        ),
                                      ),
                                    ),
                                  )
                                  );
                                },
                              ),
                              title: Text(ordersProduct.name,
                                style: GoogleFonts.lato(
                                  fontSize: 18.0,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text(ordersProduct.price.toString() + "\$  |  " +
                                  ordersProduct.dateOfOrder + "  |  " +
                                  ordersProduct.orderStatus.toString().substring(12),
                                style: GoogleFonts.lato(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }
                      ),
                    ),
                  ),
                ]
              ),
            )
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}