import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator_app/BLOC/translatorBloc.dart';
import 'package:translator_app/DATA/translatedText.dart';
import 'package:translator_app/REPOSITORY/translationProcess.dart';
import 'package:translator_app/main.dart';

class HomePage extends StatefulWidget {
  final String username;
  HomePage(this.username, {Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

//Quick lesson learnt with ValueNotifiers, two things: reading and listening its value
//you can read its value anywhere at any point in time but to build a widget
//after the value has changed you need the ValueListenableBuilder.

//Global Variables
Inputs inputs = Inputs();
final fromToList = ValueNotifier<List>(['en - English', 'sw - Swahili']);
final friend = ValueNotifier('friend');
final languages = [
  'en - English',
  'es - Spanish',
  'fr - French',
  'it - Italian',
  'ja - Japanese',
  'sw - Swahili'
];

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getDefaultLanguage();
  }

  getDefaultLanguage() async {
    inputs.username = widget.username;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.username)
        .get()
        .then((value) {
      setState(() {
        fromToList.value[1] = value['language'];
      });
    });
  }

  //Local Variables
  var start = ValueNotifier(true);
  var checkUsers = ValueNotifier(true);
  var closeChatField = ValueNotifier(false);
  final _index = ValueNotifier<int>(0);
  final _texttranslatedMode = ValueNotifier<bool>(false);
  final _imagetranslatedMode = ValueNotifier<bool>(false);
  final _active = ValueNotifier<bool>(false);
  final _textcontroller = TextEditingController();
  final _chatcontroller = TextEditingController();
  final _bloc = TranslatorBloc();
  final _imagePath = ValueNotifier<String>('noPath');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        color: color.background,
        child: ValueListenableBuilder(
            valueListenable: _index,
            builder: (context, snapshot, child) {
              if (_index.value == 0) {
                return _buildTextBody();
              } else if (_index.value == 1) {
                return _buildImageBody();
              } else {
                return _buildChatBody(context);
              }
            }),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      toolbarHeight: 120,
      title: Text('Language Translator', style: styles.regular()),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: ValueListenableBuilder<Object>(
            valueListenable: fromToList,
            builder: (context, snapshot, child) {
              return Container(
                height: 50,
                child: ValueListenableBuilder<Object>(
                    valueListenable: _index,
                    builder: (context, child, snapshot) {
                      return Row(
                        mainAxisAlignment: _index.value == 2
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                              onTap: () {
                                if (_index.value == 0) {
                                  _buildPopUp(context, 0, fromToList.value[0]);
                                }
                              },
                              child: Text(
                                  _index.value != 0
                                      ? _index.value == 2
                                          ? 'Conversations translated to'
                                          : 'Any Language'
                                      : fromToList.value[0].substring(
                                          fromToList.value[0].indexOf('-') + 1),
                                  style: styles.medium(
                                      color: color.white, size: 18.0))),
                          _index.value == 2
                              ? Container()
                              : Icon(Icons.swap_horiz, color: color.white),
                          GestureDetector(
                            onTap: () {
                              _buildPopUp(context, 1, fromToList.value[1]);
                            },
                            child: Text(
                                fromToList.value[1].substring(
                                    fromToList.value[1].indexOf('-') + 1),
                                style: styles.medium(
                                    color: color.white, size: 18.0)),
                          ),
                        ],
                      );
                    }),
              );
            }),
      ),
    );
  }

  _buildPopUp(BuildContext context, int __index, String language) {
    return showDialog(
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
                      fromToList.value = __index == 0
                          ? [languages[index], fromToList.value[1]]
                          : [fromToList.value[0], languages[index]];
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 50,
                      color: Colors.grey[200],
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(languages[index],
                              style: language == languages[index]
                                  ? styles.medium(size: 20.0, color: color.main)
                                  : styles.regular(size: 20.0)),
                          language == languages[index]
                              ? Icon(Icons.check, color: color.main)
                              : Container()
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  _buildImageBody() {
    return Column(
      children: [
        Expanded(
            child: Container(
          alignment: Alignment.center,
          child: ValueListenableBuilder<bool>(
              valueListenable: _active,
              builder: (context, snapshot, child) {
                return _active.value
                    ? ValueListenableBuilder(
                        valueListenable: _imagePath,
                        builder: (context, _snapshot, child) {
                          return Column(
                            children: [
                              Expanded(
                                  child: _imagePath.value == null
                                      ? Image.network(
                                          'https://image.freepik.com/free-vector/wooden-boat-tree_1308-6877.jpg',
                                          fit: BoxFit.cover)
                                      : Image.file(File(_imagePath.value),
                                          fit: BoxFit.cover)),
                              Flexible(
                                  child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Text('Text from the image',
                                      style: styles.medium(size: 20.0)),
                                  SizedBox(height: 20),
                                  StreamBuilder<TranslatedText>(
                                      stream: _bloc.translationStream,
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData ||
                                            snapshot.connectionState !=
                                                ConnectionState.active) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                backgroundColor:
                                                    color.background,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        color.main),
                                              )
                                            ],
                                          );
                                        } else {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Text(snapshot.data.text,
                                                textAlign: TextAlign.center,
                                                style:
                                                    styles.regular(size: 20.0)),
                                          );
                                        }
                                      }),
                                ],
                              ))
                            ],
                          );
                        })
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              _active.value = !_active.value;
                              inputs.source = 'Gallery';
                              _imagetranslatedMode.value =
                                  !_imagetranslatedMode.value;
                              await TranslationProcess()
                                  .getImage(ImageSource.gallery)
                                  .then((value) {
                                _imagePath.value = value;
                                _bloc.eventSink.add(BlocEvents.image);
                                inputs.filepath = _imagePath.value;
                              });
                            },
                            child: Container(
                                color: color.black,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                margin: EdgeInsets.only(
                                    left: 45, right: 45, bottom: 20),
                                child: Row(
                                  children: [
                                    Icon(Icons.photo_album, color: color.white),
                                    SizedBox(width: 10),
                                    Text('Add image from Gallery',
                                        style: styles.medium(
                                            size: 20.0, color: color.white)),
                                  ],
                                )),
                          ),
                          GestureDetector(
                            onTap: () async {
                              _active.value = !_active.value;
                              inputs.source = 'Camera';
                              _imagetranslatedMode.value =
                                  !_imagetranslatedMode.value;
                              await TranslationProcess()
                                  .getImage(ImageSource.camera)
                                  .then((value) {
                                _imagePath.value = value;
                                _bloc.eventSink.add(BlocEvents.image);
                                inputs.filepath = _imagePath.value;
                              });
                            },
                            child: Container(
                                color: color.black,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                margin: EdgeInsets.symmetric(horizontal: 45),
                                child: Row(
                                  children: [
                                    Icon(Icons.camera, color: color.white),
                                    SizedBox(width: 10),
                                    Text('Add image from Camera',
                                        style: styles.medium(
                                            size: 20.0, color: color.white)),
                                  ],
                                )),
                          )
                        ],
                      );
              }),
        ))
      ],
    );
  }

  _buildTextBody() {
    return Column(
      children: [
        Expanded(
            child: ValueListenableBuilder(
                valueListenable: _texttranslatedMode,
                builder: (context, snapshot, child) {
                  return _texttranslatedMode.value
                      ? Container(
                          color: color.background,
                          padding: const EdgeInsets.only(
                              top: 30, left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                  child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.only(bottom: 20),
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 2, color: Colors.black26))),
                                child: Text(_textcontroller.text,
                                    maxLines: 6,
                                    style: styles.medium(
                                        size: 24.0, color: Colors.black54)),
                              )),
                              Flexible(
                                  child: StreamBuilder<TranslatedText>(
                                      stream: _bloc.translationStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.active) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(snapshot.data.text,
                                                  style: styles.medium(
                                                      size: 30.0,
                                                      color: Colors.black)),
                                              GestureDetector(
                                                onTap: () async {
                                                  TranslationProcess().speak(
                                                      snapshot.data.text);
                                                },
                                                child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 20),
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                        color: color.black,
                                                        shape: BoxShape.circle),
                                                    child: Icon(Icons.volume_up,
                                                        color: color.white)),
                                              )
                                            ],
                                          );
                                        } else {
                                          return CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            backgroundColor: color.background,
                                            valueColor: AlwaysStoppedAnimation(
                                                color.main),
                                          );
                                        }
                                      }))
                            ],
                          ),
                        )
                      : TextField(
                          controller: _textcontroller,
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          style: styles.medium(size: 30.0),
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 20, top: 50, right: 20),
                              filled: true,
                              fillColor: color.background,
                              border: InputBorder.none,
                              hintText: 'Enter Text',
                              hintStyle: styles.medium(
                                  size: 30.0,
                                  bgColor: color.black,
                                  color: color.white)),
                        );
                }))
      ],
    );
  }

  _buildChatBody(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: start,
              builder: (context, child, snapshot) {
                return Expanded(
                    child: start.value
                        ? Container(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: () {
                                start.value = false;
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                margin: EdgeInsets.only(right: 20, bottom: 20),
                                color: color.black,
                                child: Text('Start a chat',
                                    style: styles.medium(
                                        size: 22.0, color: color.white)),
                              ),
                            ))
                        : ValueListenableBuilder(
                            valueListenable: checkUsers,
                            builder: (context, snapshot, child) {
                              return checkUsers.value
                                  ? Column(
                                      children: [
                                        StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('users')
                                                .where('name',
                                                    isNotEqualTo:
                                                        widget.username)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.data.docs.length >
                                                  0) {
                                                return Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Text(
                                                        'Choose a friend to chat with:',
                                                        style: styles.medium(
                                                            size: 22.0,
                                                            color:
                                                                color.black)),
                                                    SizedBox(height: 20),
                                                    Container(
                                                        width: double.maxFinite,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 20),
                                                        child: ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount: snapshot
                                                                .data
                                                                .docs
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  friend
                                                                      .value = snapshot
                                                                          .data
                                                                          .docs[
                                                                      index]['name'];
                                                                  inputs
                                                                      .language = snapshot
                                                                          .data
                                                                          .docs[index]
                                                                      [
                                                                      'language'];
                                                                  checkUsers
                                                                          .value =
                                                                      !checkUsers
                                                                          .value;
                                                                },
                                                                child:
                                                                    Container(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          .0),
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          bottom:
                                                                              20),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        height:
                                                                            40,
                                                                        width:
                                                                            40,
                                                                        decoration: BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            image: DecorationImage(image: NetworkImage(snapshot.data.docs[index]['pic']))),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              30),
                                                                      Text(
                                                                          snapshot.data.docs[index]
                                                                              [
                                                                              'name'],
                                                                          style:
                                                                              styles.medium(size: 20.0))
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            })),
                                                  ],
                                                );
                                              } else if (snapshot
                                                          .connectionState !=
                                                      ConnectionState.active ||
                                                  !snapshot.hasData ||
                                                  snapshot.hasError) {
                                                return CircularProgressIndicator(
                                                    strokeWidth: 1.5,
                                                    backgroundColor:
                                                        color.background,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                            color.main));
                                              } else {
                                                return Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height -
                                                      230,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'Add a new friend to start chating',
                                                    style: styles.regular(
                                                        size: 20.0),
                                                  ),
                                                );
                                              }
                                            })
                                      ],
                                    )
                                  : Container(
                                      height:
                                          MediaQuery.of(context).size.height -
                                              220,
                                      width: MediaQuery.of(context).size.width,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 70,
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  290,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    ValueListenableBuilder(
                                                        valueListenable: friend,
                                                        builder: (context,
                                                            snapshot, child) {
                                                          return StreamBuilder(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc((widget
                                                                      .username))
                                                                  .collection(
                                                                      'chats-with-${friend.value}')
                                                                  .orderBy(
                                                                      'time')
                                                                  .snapshots(),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (snapshot
                                                                    .hasData) {
                                                                  return Container(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Flexible(
                                                                          child: ListView.builder(
                                                                              shrinkWrap: true,
                                                                              physics: NeverScrollableScrollPhysics(),
                                                                              itemCount: snapshot.data.docs.length,
                                                                              itemBuilder: (context, index) {
                                                                                bool isMe = snapshot.data.docs[index]['name'] == widget.username ? true : false;
                                                                                return Align(
                                                                                  alignment: isMe ? Alignment.bottomRight : Alignment.bottomLeft,
                                                                                  child: Container(
                                                                                    width: MediaQuery.of(context).size.width * .8,
                                                                                    child: Row(
                                                                                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                                                                      children: [
                                                                                        Flexible(
                                                                                          child: Container(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5), decoration: BoxDecoration(color: isMe ? Color(0xFF161E30) : Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15), bottomRight: Radius.circular(isMe ? 0 : 15), bottomLeft: Radius.circular(isMe ? 15 : 0))), child: Text(snapshot.data.docs[index]['chat'], style: styles.medium(size: 18.0, color: isMe ? color.white : color.black))),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                } else {
                                                                  return Container(
                                                                      child: Text(
                                                                          'start a chat with ${friend.value}',
                                                                          style:
                                                                              styles.medium(size: 20.0)));
                                                                }
                                                              });
                                                        }),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                              bottom: 0,
                                              child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 70,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  child: TextField(
                                                    controller: _chatcontroller,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .sentences,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    keyboardAppearance:
                                                        Brightness.dark,
                                                    maxLines: null,
                                                    minLines: null,
                                                    expands: true,
                                                    style:styles.medium(size:18.0,color:Colors.black),
                                                    decoration: InputDecoration(
                                                        hintText:
                                                            'Write a chat to ${friend.value}',
                                                        filled: true,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                left: 30,top:10,
                                                                right: 30),
                                                        fillColor:
                                                            Colors.black12,
                                                        hintStyle:
                                                            styles.medium(
                                                                size: 18.0,
                                                                color: color
                                                                    .black)),
                                                    onSubmitted: (value) async {
                                                      _bloc.eventSink
                                                          .add(BlocEvents.chat);
                                                      inputs.textInput =
                                                          _chatcontroller.text;
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(
                                                              (widget.username))
                                                          .collection(
                                                              'chats-with-${friend.value}')
                                                          .add({
                                                        'chat': _chatcontroller
                                                            .text,
                                                        'time': DateTime.now(),
                                                        'name': widget.username
                                                      });
                                                      _chatcontroller.clear();
                                                    },
                                                  )))
                                        ],
                                      ),
                                    );
                            }));
              })
        ],
      ),
    );
  }

  _buildBottomNavBar(BuildContext context) {
    return ValueListenableBuilder<Object>(
        valueListenable: checkUsers,
        builder: (context, child, snapshot) {
          return ValueListenableBuilder<int>(
              valueListenable: _index,
              builder: (context, child, snapshot) {
                return Container(
                  height: 60,
                  width: double.maxFinite,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 3,
                            blurRadius: 3,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      _index.value = index;
                                      _active.value = _active.value
                                          ? !_active.value
                                          : _active.value;
                                      if (index == 1 || index == 2) {
                                        _texttranslatedMode.value = false;
                                        _imagetranslatedMode.value = false;
                                      }
                                    },
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        alignment: Alignment.center,
                                        child: ValueListenableBuilder<Object>(
                                            valueListenable: _index,
                                            builder:
                                                (context, snapshot, child) {
                                              return Icon(
                                                  index == 0
                                                      ? Icons.text_fields
                                                      : index == 1
                                                          ? Icons.image
                                                          : Icons.forum,
                                                  color: index == _index.value
                                                      ? color.main
                                                      : color.inactive);
                                            })),
                                  );
                                }),
                          ),
                        ],
                      )),
                );
              });
        });
  }

  _buildFloatingButton() {
    return ValueListenableBuilder<Object>(
        valueListenable: _imagetranslatedMode,
        builder: (context, child, snapshot) {
          return ValueListenableBuilder(
              valueListenable: _texttranslatedMode,
              builder: (context, snapshot, child) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: _index,
                          builder: (context, child, snapshot) {
                            return Visibility(
                              visible: _index.value == 2
                                  ? false
                                  : _index.value == 0
                                      ? !_texttranslatedMode.value
                                      : _imagetranslatedMode.value,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 35),
                                child: FloatingActionButton(
                                    elevation: 3,
                                    onPressed: () async {
                                      if (_index.value == 1) {
                                        if (inputs.source == 'Camera') {
                                          await TranslationProcess()
                                              .getImage(ImageSource.camera)
                                              .then((value) {
                                            _imagePath.value = value;
                                            _bloc.eventSink
                                                .add(BlocEvents.image);
                                            inputs.filepath = _imagePath.value;
                                          });
                                        } else {
                                          await TranslationProcess()
                                              .getImage(ImageSource.gallery)
                                              .then((value) {
                                            _imagePath.value = value;
                                            _bloc.eventSink
                                                .add(BlocEvents.image);
                                            inputs.filepath = value;
                                          });
                                        }
                                      }
                                    },
                                    backgroundColor: color.main,
                                    child: Icon(Icons.refresh,
                                        color: color.white)),
                              ),
                            );
                          }),
                      ValueListenableBuilder<int>(
                          valueListenable: _index,
                          builder: (context, snapshot, child) {
                            return Visibility(
                              visible: _index.value == 1 || _index.value == 2
                                  ? false
                                  : true,
                              child: FloatingActionButton(
                                  elevation: 3,
                                  onPressed: () {
                                    if (_index.value == 0) {
                                      _bloc.eventSink.add(BlocEvents.text);
                                      inputs.textInput = _textcontroller.text;
                                      _texttranslatedMode.value =
                                          !_texttranslatedMode.value;
                                    } else {}
                                  },
                                  backgroundColor: color.main,
                                  child: Icon(
                                      _texttranslatedMode.value
                                          ? Icons.arrow_back
                                          : Icons.swap_horiz,
                                      color: color.white)),
                            );
                          }),
                    ],
                  ),
                );
              });
        });
  }
}
