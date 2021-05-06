import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:translator_app/UI/get_username.dart';
import 'package:translator_app/UI/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

MyColors color = MyColors();
MyTextstyles styles = MyTextstyles();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: color.main),
      home: Username(),
    );
  }
}
