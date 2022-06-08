// ignore_for_file: avoid_print

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebasetest/models/place.dart';
import 'package:firebasetest/pages/detailpage.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';
import 'login.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final bgColor = const Color.fromARGB(255, 255, 171, 64);

  List<Category> categoryList = [
    Category(title: 'Parklar', dbName: 'Parks'),
    Category(title: 'Kütüphaneler', dbName: 'Libraries'),
    Category(title: 'Tarihi Yerler', dbName: 'HistoricalPlaces'),
    Category(title: 'Oteller', dbName: 'Hotels'),
    Category(title: 'Marketler', dbName: 'Markets'),
    Category(title: 'İbadet Yerleri', dbName: 'PrayingLocations'),
    Category(title: 'Otoparklar', dbName: 'Autopark'),
    Category(title: 'Favoriler', dbName: 'Favorites'),
  ];

  int? selectedIndex;

  List<Place> places = [];
  final _database = FirebaseDatabase.instance.ref();
  final _databaseFavorites = FirebaseDatabase.instance.ref();
//  late StreamSubscription _subscription;
//  late StreamSubscription _favoritesSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //  _subscription.cancel();
    //  _favoritesSubscription.cancel();
    super.dispose();
  }

  void _resetRatings() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Locations");
    DatabaseEvent event = await ref.once();
    final DataSnapshot snapshot = event.snapshot;

    Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    data.forEach((key, value) {
      print(key + "--");
      Map<dynamic, dynamic> temp = value as Map<dynamic, dynamic>;
      temp.forEach((key, value) {
        print("$key $value");
      });
      print("----");
    });
    // puanları sıfırlama yaz.
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

  void _getPlaces(String place) async {
    if (selectedIndex == 7) {
      //_favoritesSubscription =
      final snapshot = await _databaseFavorites.child('Locations').get();
      if (snapshot.exists) {
        places.clear();
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach(
          (key, value) {
            Map<dynamic, dynamic> temp = value as Map<dynamic, dynamic>;
            temp.forEach(
              (key, value) {
                if (double.tryParse(value["rating"].toString())! >= 4.0) {
                  setState(
                    () {
                      places.add(
                        Place(
                          image: value["image"],
                          workinghours: value["workinghours"],
                          rating: value["rating"],
                          info: value["info"],
                          name: value["name"],
                          pricing: value["pricing"],
                          ratingcount: value["ratingcount"],
                          category: value["category"],
                        ),
                      );
                    },
                  );
                }
              },
            );
          },
        );
      }
    } else {
      //  _subscription =
      _database.child('Locations/$place').onValue.listen(
        (event) {
          final DataSnapshot snapshot = event.snapshot;
          if (snapshot.exists) {
            places.clear();
            Map<dynamic, dynamic> data =
                snapshot.value as Map<dynamic, dynamic>;

            data.forEach(
              (key, value) {
                setState(
                  () {
                    places.add(
                      Place(
                        image: value["image"],
                        workinghours: value["workinghours"],
                        rating: value["rating"],
                        info: value["info"],
                        name: value["name"],
                        pricing: value["pricing"],
                        ratingcount: value["ratingcount"],
                        category: value["category"],
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      );
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uyarı'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Çıkış yapmak istediğinize emin misiniz ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hayır'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Evet'),
              onPressed: () {
                logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: const Text("Kategoriler"),
              onTap: () {
                _resetRatings();
              },
            ),
            InkWell(
              child: const Icon(
                Icons.power_settings_new,
              ),
              onTap: () {
                _showMyDialog();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryList.length,
                  itemBuilder: ((context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        _getPlaces(categoryList[index].dbName);
                      },
                      child: Chip(
                        backgroundColor: bgColor,
                        avatar: CircleAvatar(
                          backgroundColor: selectedIndex != index
                              ? Colors.white
                              : Colors.green,
                          child: const Text(''),
                        ),
                        label: Text(
                          categoryList[index].title,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(
                height: 550,
                child: ListView.builder(
                  itemCount: places.length,
                  itemBuilder: ((context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              place: places[index],
                              route: places[index].name,
                              category: places[index].category
                              //Favoriler seçili olduğunda categorisimi favoriler olarak gönderiyor, kendi kategorisini göndermesi gerekiyor bu yüzden her yer kategorsini içinde tutmalı
                              ,
                            ),
                          ),
                        );
                      },
                      trailing: Column(
                        children: [
                          const Icon(Icons.star),
                          Text(
                            _getRatingString(
                              places[index].rating.toString(),
                            ).toString(),
                          ),
                        ],
                      ),
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        places[index].name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
