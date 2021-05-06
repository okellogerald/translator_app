import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translator_app/UI/homepage.dart';
import 'package:translator_app/main.dart';

class LoginPage extends StatelessWidget {
  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: color.white,
        iconTheme: IconThemeData(color: color.black),
        actions: [
          /*   Padding(
            padding: const EdgeInsets.only(right: 20, top: 16),
            child: Text('1/2',
                style: styles.medium(size: 20.0, color: color.black)),
          ) */
        ],
      ),
      body: Container(
        color: color.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 50,
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: TextField(
                          controller: _controller1,
                          style: styles.medium(size: 20.0),
                          textCapitalization: TextCapitalization.words,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              fillColor: Colors.grey.withOpacity(.15),
                              filled: true,
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(8),
                              hintText: 'First Name',
                              hintStyle: styles.regular(
                                  size: 18.0, color: Colors.grey)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        child: TextField(
                          controller: _controller2,
                          style: styles.medium(size: 20.0),
                          textCapitalization: TextCapitalization.words,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              fillColor: Colors.grey.withOpacity(.15),
                              filled: true,
                              isDense: true,
                              contentPadding: EdgeInsets.all(8),
                              hintText: 'Last Name',
                              border: InputBorder.none,
                              hintStyle: styles.regular(
                                  size: 18.0, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ],
                )),
            Padding(
              padding:
                  EdgeInsets.only(right: 20, left: 20, bottom: 40, top: 20),
              child: Text(
                  'Here, use the usernames you provided in the other testing phone.',
                  style: styles.regular(size: 18.0, color: color.black)),
            ),
            Center(
              child: TextButton(
                  onPressed: () async {
                    if (_controller1.text.isEmpty ||
                        _controller2.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: color.main,
                          content: Text(
                            'Please fill both username fields.',
                            style:
                                styles.regular(color: color.white, size: 18.0),
                          )));
                    } else {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_controller1.text + '  ' + _controller2.text)
                          .get()
                          .then((value) {
                        if (value.exists) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage(
                                        _controller1.text +
                                            '  ' +
                                            _controller2.text,
                                      )));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: color.main,
                              content: Text(
                                'Hello and Welcome again ${_controller1.text}',
                                style: styles.regular(
                                    color: color.white, size: 18.0),
                              )));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: color.main,
                              content: Text(
                                'Can\'t find this name, Please try again. However, you can always use new names',
                                style: styles.regular(
                                    color: color.white, size: 18.0),
                              )));
                        }
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: color.main,
                      padding: EdgeInsets.symmetric(horizontal: 20)),
                  child: Text('Done',
                      style: styles.medium(size: 20.0, color: color.white))),
            )
          ],
        ),
      ),
    );
  }
}
