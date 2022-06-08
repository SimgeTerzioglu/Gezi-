// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/comment.dart';
import '../models/place.dart';

class DetailPage extends StatefulWidget {
  final Place place;
  final String route;
  final String category;

  const DetailPage({
    Key? key,
    required this.place,
    required this.route,
    required this.category,
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool commentsVisible = false;
  static const offWhite = Color.fromARGB(255, 216, 214, 218);
  final bgColor = const Color.fromARGB(255, 255, 171, 64);

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  late String guid;
  String loggedUserID = '';

  double? rating = 3;
  double? previousRating = 0;
  bool shouldUpdateRatingCount = true;

  @override
  void initState() {
    _getComments(widget.route);
    _getUser();
    _getRating();
    super.initState();
  }

  @override
  void dispose() {
    _commentsSubscription.cancel();
    _userSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  final _userDb = FirebaseDatabase.instance.ref();
  late StreamSubscription _userSubscription;
  final _auth = FirebaseAuth.instance;
  String username = '';
  String email = '';

  void _getUser() {
    final User? user = _auth.currentUser;
    final uid = user?.uid;
    loggedUserID = uid!;

    _userSubscription =
        _userDb.child("Users/$uid/username").onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        String loggedUser = snapshot.value.toString();
        username = loggedUser;
      }
    });
  }

  String commentString = '';
  bool isReady = false;
  List<Comment> comments = [];
  final _commentsdb = FirebaseDatabase.instance.ref();
  late StreamSubscription _commentsSubscription;

  Future<void> _addRating() async {
    await _updatePlaceRating();
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("Users/$loggedUserID/ratings/${widget.place.name}");
    await ref.update({"rating": rating});
  }

  Future<void> _updatePlaceRating() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("Locations/${widget.category}/${widget.place.name}");

    double? currentRating = double.tryParse(
      widget.place.rating.toString(),
    );
    double? currentRatingCount = double.tryParse(
      widget.place.ratingcount.toString(),
    );

    if (currentRating == 0 || currentRatingCount == 0) {
      await ref.update(
        {
          "rating": rating!.toString(),
          "ratingcount": "1",
        },
      );
    } else {
      if (shouldUpdateRatingCount) {
        // new rating being added
        //newRating =  ((currentRating * currentRatingCount) + new rating) / (currentRating +1)

        double? buffer = ((currentRating! * currentRatingCount!) + rating!) /
            (currentRatingCount + 1);
        await ref.update({
          "rating": buffer.toString(),
          "ratingcount": (currentRatingCount + 1).toInt().toString(),
        });
      } else {
        //an existing rate being changed
        //newrating = ((((currentRating * currentRatingCount)) - previousRating) + rating)  / (currentratingcount)
        print(rating);
        print(previousRating);
        double? buffer =
            ((((currentRatingCount! * currentRating!) - previousRating!) +
                     rating!) /
               (currentRatingCount));
        //((((currentRating! * currentRatingCount!)) - previousRating!) + rating!)  / (currentRatingCount);
        await ref.update(
          {
            "rating": buffer.toString(),
            "ratingcount": (currentRatingCount).toInt().toString(),
          },
        );
      }
    }
  }

  final _ratingsDb = FirebaseDatabase.instance.ref();

  void _getRating() {
    _ratingsDb
        .child("Users/$loggedUserID/ratings/${widget.place.name}")
        .onValue
        .listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        shouldUpdateRatingCount = false;
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        double? temp = double.tryParse(data["rating"].toString());
        rating = temp;
        previousRating = temp;
      } else {
        shouldUpdateRatingCount = true;
      }
    });
  }

  void _getComments(String route) {
    _commentsSubscription = _commentsdb.child('Comments/$route').onValue.listen(
      (event) {
        final DataSnapshot snapshot = event.snapshot;
        if (snapshot.exists) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          comments.clear();
          data.forEach(
            (key, value) {
              comments.add(
                Comment(
                  message: value["message"],
                  username: value["username"],
                  id: key,
                ),
              );
            },
          );
        } else {}
        if (mounted) {
          setState(() {
            isReady = true;
          });
        }
      },
    );
  }

  Future<void> _showRatingMenu() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uyarı'),
          content: SingleChildScrollView(
              child: RatingBar.builder(
            initialRating: rating!,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rate) {
              rating = rate;
            },
          )),
          actions: <Widget>[
            TextButton(
              child: const Text('Vazgeç'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Puan ver'),
              onPressed: () {
                _addRating();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _postComment(String text) async {
    guid = getRandomString(15);
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("Comments/${widget.route}/$guid");
    await ref.set({
      "username": username,
      "message": commentString,
      "id": guid,
    });
    commentString = '';
  }

  String _getRatingString(String rating) {
    if (rating == "0") {
      return "- / 5";
    }
    if (rating.length > 1) {
      if (rating[2] == '0') {
        return "${rating[0]} / 5";
      } else {
        if (rating.length > 4) {
          String substring = rating.substring(0, 4);
          return "$substring / 5";
        } else {
          return "$rating / 5";
        }
      }
    } else {
      return "$rating / 5";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        backgroundColor: bgColor,
        automaticallyImplyLeading: true,
        title: Text(
          widget.place.name,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          GestureDetector(
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.star,
              ),
            ),
            onTap: () {
              _showRatingMenu();
            },
          ),
        ],
      ),
      body: isReady
          ? SizedBox(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CachedNetworkImage(
                          width: 250,
                          height: 250,
                          imageUrl: widget.place.image,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24)),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                widget.place.name,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              widget.place.info,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Çalışma Saatleri : ${widget.place.workinghours}",
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Puan : ${_getRatingString(widget.place.rating)}",
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Ücret : ${widget.place.pricing == 'Ücretsiz' ? 'Ücretsiz' : '${widget.place.pricing} ₺'}",
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Yorumlar",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                commentsVisible = !commentsVisible;
                              });
                            },
                            child: Text(
                              commentsVisible == false
                                  ? 'Yorumları Göster'
                                  : 'Yorumları Gizle',
                              style: TextStyle(color: bgColor),
                            ),
                          )
                        ],
                      ),
                      Visibility(
                        visible: commentsVisible,
                        child: SizedBox(
                          height: 125,
                          child: ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(comments[index].username),
                                subtitle: Text(comments[index].message),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        child: Column(
                          children: [
                            TextFormField(
                              //controller tanımla yukarıda
                              keyboardType: TextInputType.multiline,
                              onChanged: (value) {
                                commentString = value;
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                                hintText: 'Yorumunuz',
                                prefixIcon: Icon(
                                  Icons.add_comment,
                                  color: bgColor,
                                ),
                              ),
                              keyboardAppearance: Brightness.dark,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                if (commentString.isNotEmpty) {
                                  _postComment(commentString);
                                }
                              },
                              child: Text("Gönder",
                                  style: TextStyle(color: bgColor))),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          : const CircularProgressIndicator(),
    );
  }
}
