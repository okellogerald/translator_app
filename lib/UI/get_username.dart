import 'package:flutter/material.dart';
import 'package:translator_app/UI/get_avatars.dart';
import 'package:translator_app/UI/homepage.dart';
import 'package:translator_app/UI/login.dart';
import 'package:translator_app/main.dart';

class Username extends StatelessWidget {
  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();
  final _defaultLanguage = ValueNotifier('Default Language');

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
            child: Text('1/2',
                style: styles.medium(size: 20.0, color: color.black)),
          )
        ],
      ),
      body: Container(
        color: color.background,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                autofocus: false,
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
                                 autofocus: false,
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
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: languages.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        _defaultLanguage.value =
                                            languages[index];
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        height: 50,
                                        color: Colors.grey[200],
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(languages[index],
                                            style: styles.regular(size: 20.0)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          });
                    },
                    child: ValueListenableBuilder(
                        valueListenable: _defaultLanguage,
                        builder: (context, snapshot, child) {
                          return Container(
                              height: 50,
                              width: double.maxFinite,
                              margin: EdgeInsets.all(20),
                              alignment: Alignment.center,
                              color: Colors.grey.withOpacity(.3),
                              child: Text(_defaultLanguage.value,
                                  style: styles.medium(size: 18.0)));
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20, left: 20, bottom: 40),
                    child: Text(
                        'This set-up is required for the chat functionality in this app. ',
                        style: styles.regular(size: 18.0, color: color.black)),
                  ),
                  Center(
                    child: TextButton(
                        onPressed: () {
                          if (_controller1.text.isEmpty ||
                              _controller2.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: color.main,
                                content: Text(
                                  'Please fill both username fields.',
                                  style: styles.regular(
                                      color: color.white, size: 18.0),
                                )));
                          } else if (_defaultLanguage.value ==
                              'Default Language') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: color.main,
                                content: Text(
                                  'Please choose your default language',
                                  style: styles.regular(
                                      color: color.white, size: 18.0),
                                )));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Avatars(
                                          name: _controller1.text +
                                              '  ' +
                                              _controller2.text,
                                          language: _defaultLanguage.value,
                                        )));
                          }
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: color.main,
                            padding: EdgeInsets.symmetric(horizontal: 20)),
                        child: Text('Next',
                            style:
                                styles.medium(size: 20.0, color: color.white))),
                  )
                ],
              ),
            ),
            Expanded(
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 15),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style:
                                styles.regular(size: 18.0, color: color.black),
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Log in',
                                  style: styles.medium(
                                      size: 18.0, color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    )))
          ],
        ),
      ),
    );
  }
}
