// ignore_for_file: avoid_print

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'mainpage.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final bgColor = const Color.fromARGB(255, 255, 171, 64);
  bool isReady = false;
  bool isLoading = false;

  String username = "";
  String password = "";
  String email = "";
  final _auth = FirebaseAuth.instance;
  late StreamSubscription _authState;

  @override
  void initState() {
    _authState = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          isReady = true;
        });
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _authState.cancel();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Form(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(36),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.transparent,
                        backgroundImage: CachedNetworkImageProvider(
                            "https://cdn-icons-png.flaticon.com/512/5087/5087592.png"),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          email = value;
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          hintText: 'E-Mail Adresiniz',
                          prefixIcon: Icon(
                            Icons.email,
                            color: bgColor,
                          ),
                        ),
                        keyboardAppearance: Brightness.dark,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        obscureText: true,
                        onChanged: (value) {
                          password = value.trim();
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          hintText: 'Şifreniz',
                          prefixIcon: Icon(
                            Icons.password,
                            color: bgColor,
                          ),
                        ),
                        keyboardAppearance: Brightness.dark,
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await login();
                        },
                        child: const Text('Giriş'),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Register(email)),
                          );
                        },
                        onLongPress: () {},
                        child: const Text("Hesabınız yok mu? Kayıt olun"),
                      )
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      setState(() {
        isReady = false;
      });
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Kullanıcı Bulunamadı.';
      } else if (e.code == 'wrong-password') {
        message = 'Şifre Yanlış.';
      } else if (e.code == 'invalid-email') {
        message = 'E-posta adresi hatalı.';
      } else {
        message = 'Ops! Giriş Yapılamadı.';
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(message),
          content: Text('${e.message}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            )
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ops! Oturum açılamadı'),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            )
          ],
        ),
      );
    }
  }
}
