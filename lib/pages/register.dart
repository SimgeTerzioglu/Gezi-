import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class Register extends StatefulWidget {
  final String email;

  const Register(this.email, {Key? key}) : super(key: key);

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<Register> {
  final bgColor = const Color.fromARGB(255, 255, 171, 64);
  String username = "";
  String password = "";
  String email = "";
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                      const Text(
                        "Kayıt Formu",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 36),
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
                        keyboardType: TextInputType.name,
                        onChanged: (value) {
                          username = value;
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          hintText: 'Kullanıcı Adınız',
                          prefixIcon: Icon(
                            Icons.person,
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
                          await register();
                        },
                        child: const Text('Kayıt Ol'),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _auth.currentUser!.updateDisplayName(username);
      String userId = _auth.currentUser!.uid;
      FirebaseDatabase.instance.ref().child("Users/$userId").set({
        'id': userId,
        'emailAddress': email,
        'username': username,
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'Şifre çok güçsüz';
      } else if (e.code == 'invalid-email') {
        message = 'E-Posta adresi Hatalı';
      } else if (e.code == 'email-already-in-use') {
        message = 'Bu e-posta adresi zaten kullanılıyor';
      } else {
        message = 'Ops! Kayıt başarısız';
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(message),
          content: Text('${e.message}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Tamam'),
            )
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ops! Kayıt Başarısız'),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Tamam'),
            )
          ],
        ),
      );
    }
  }
}
