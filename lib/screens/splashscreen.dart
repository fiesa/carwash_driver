import 'dart:async';

import 'package:flutter3_firestore_driver/screens/tabs.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Splashscreen extends StatefulWidget {
  Splashscreen({Key? key}) : super(key: key);

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      Navigator.push(context, MaterialPageRoute(builder: (c) => TabsScreen()));
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
            // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topRight,
          //     end: Alignment.bottomLeft,
          //     colors: [
          //       Colors.black,
          //       Colors.blue,
          //     ],
          //   )
          // ),

        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/logo.png"),
              const SizedBox(
                height: 10,
              ),
              Lottie.asset('images/splash.json'),
              Text(
                "Arcade CarWash Driver",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue.shade500,
                    fontWeight: FontWeight.bold),
              ),

              // const Text(
              //   "Uber & inDriver Clone App",
              //   style: TextStyle(
              //       fontSize: 24,
              //       color: Colors.white,
              //       fontWeight: FontWeight.bold),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
