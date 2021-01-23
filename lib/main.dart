import 'dart:io';

import 'package:flutter/material.dart';

import 'myHttpOverrides.dart';
import 'src/customDrinkPage.dart';
import 'src/loginPage.dart';
import 'src/mainPage.dart';

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOMAUAS',
      initialRoute: LoginPage.routeName,
      routes: {
        LoginPage.routeName: (context) => LoginPage(),
        MainPage.routeName: (context) => MainPage(),
        CustomDrinkPage.routeName: (context) => CustomDrinkPage(),
      },
    );
  }
}
