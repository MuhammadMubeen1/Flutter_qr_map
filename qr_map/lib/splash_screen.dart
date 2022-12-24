import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth/loginScreen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  init() {
    Timer(const Duration(seconds: 5), () {
      if (_auth.currentUser != null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250.0,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 30.0,
                  fontFamily: 'Agne',
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                  
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText('Wellcome to QrMape'),
                  ],
                  onTap: () {},
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            CircularProgressIndicator(
              strokeWidth: 5.0,
              backgroundColor: Colors.grey,
            ),
          ],
        )),
      ),
    );
  }
}
