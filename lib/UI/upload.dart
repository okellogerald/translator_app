import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translator_app/REPOSITORY/translationProcess.dart';
import 'package:translator_app/UI/homepage.dart';
import 'package:translator_app/main.dart';

class Upload extends StatelessWidget {
  final String name, language;
  final int index;
  Upload(this.index, {this.name, this.language, Key key}) : super(key: key);

  Future uploadData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(name)
        .set({'pic': avatarsList[index], 'name': name, 'language': language});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: color.background,
        child: FutureBuilder(
            future: uploadData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return CircularProgressIndicator(
                    strokeWidth: 1.5,
                    backgroundColor: color.background,
                    valueColor: AlwaysStoppedAnimation(color.main));
              } else {
                Future.delayed(Duration(milliseconds: 400)).then((value) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                name,
                              )));
                });
              }
              return Container();
            }),
      ),
    );
  }
}
