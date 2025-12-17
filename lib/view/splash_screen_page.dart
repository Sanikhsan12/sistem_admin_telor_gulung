import 'package:flutter/material.dart';
import 'dart:async';
import 'login_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.egg_outlined, size: 150, color: Colors.white),
            SizedBox(height: 32),
            LoadingAnimationWidget.waveDots(color: Colors.white, size: 50),
          ],
        ),
      ),
    );
  }
}
