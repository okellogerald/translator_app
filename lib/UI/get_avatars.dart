import 'package:flutter/material.dart';
import 'package:translator_app/REPOSITORY/translationProcess.dart';
import 'package:translator_app/UI/upload.dart';
import 'package:translator_app/main.dart';

class Avatars extends StatelessWidget {
  final String name, language;
  Avatars({this.name, this.language, Key key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: color.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 16),
            child: Text('2/2',
                style: styles.medium(size: 20.0, color: color.black)),
          )
        ],
      ),
      body: Container(
          color: color.background,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20),
              RichText(
                  text: TextSpan(
                      style: styles.medium(size: 20.0, color: color.black),
                      text: 'Choose an avatar',
                      children: [])),
              SizedBox(height: 20),
              Expanded(
                  child: GridView.builder(
                      itemCount: avatarsList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          crossAxisCount: 2),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Future.delayed(Duration(milliseconds: 500))
                                    .then((value) => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Upload(
                                                index,
                                                name: name,
                                                language: language))));
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          avatarsList[index],
                                        ),
                                      ))),
                            ),
                          ],
                        );
                      })),
            ],
          )),
    );
  }
}
