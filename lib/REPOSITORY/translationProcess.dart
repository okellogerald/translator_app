import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';
import 'package:translator_app/UI/homepage.dart';

//all translation-processes
class TranslationProcess {
  final _translator = GoogleTranslator();
  final _imagePicker = ImagePicker();

  String _from =
          fromToList.value[0].substring(0, fromToList.value[0].indexOf(' - ')),
      _to =
          fromToList.value[1].substring(0, fromToList.value[1].indexOf(' - '));



  Future<String> translateText(String textInput) async {
    var _translation;
    if (inputs.filepath == null) {
      _translation =
          await _translator.translate(textInput, from: _from, to: _to);
    } else {
      _translation = await _translator.translate(textInput, to: _to);
    }
    return _translation.text;
  }

  Future<String> translateChat(String textInput, String language) async {
    
    var _translation;
    var to =
          language.substring(0, language.indexOf(' - '));

    _translation = await _translator.translate(textInput, to: to);

    return _translation.text;
  }

  uploadTranslatedChat(String translation) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(('${friend.value}'))
        .collection('chats-with-${inputs.username}')
        .add({
      'chat': translation,
      'time': DateTime.now(),
      'name': '${inputs.username}'
    });
  }

  void speak(String text) async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.setLanguage(_to);
    await flutterTts.speak(text);
  }

  Future<String> getImage(ImageSource source) async {
    String _imagePath;
    await _imagePicker.getImage(source: source).then((value) {
      _imagePath = value.path;
    });
    return _imagePath;
  }

  Future<String> translateImage(String path) async {
    final visionImage = FirebaseVisionImage.fromFile(File(path));
    final textRecognizer = FirebaseVision.instance.textRecognizer();
    final recognizedText = await textRecognizer.processImage(visionImage);
    return recognizedText.text.replaceAll('\n', ' ');
  }
}

//avatars-list
List<String> avatarsList = [
  'https://firebasestorage.googleapis.com/v0/b/languagetranslator-app.appspot.com/o/1.png?alt=media&token=9852aa1f-1f5b-4ef9-9851-ab2f586b7e9f',
  'https://firebasestorage.googleapis.com/v0/b/languagetranslator-app.appspot.com/o/2.png?alt=media&token=e3af651e-ea42-48c4-8456-f5f5ce8a55f5',
  'https://firebasestorage.googleapis.com/v0/b/languagetranslator-app.appspot.com/o/3.png?alt=media&token=dacc5ac7-733f-4a27-805c-ec793d980a1b',
  'https://firebasestorage.googleapis.com/v0/b/languagetranslator-app.appspot.com/o/4.png?alt=media&token=1bb9d471-27fd-4344-a8fd-7255b49e35ef',
  'https://firebasestorage.googleapis.com/v0/b/languagetranslator-app.appspot.com/o/author1.png?alt=media&token=3fc68a8c-e3d9-4073-a1d8-5179bafd5653',
  'https://firebasestorage.googleapis.com/v0/b/languagetranslator-app.appspot.com/o/author2.png?alt=media&token=a8bc3907-493c-4bf7-8b04-33dae1888105',
  'https://firebasestorage.googleapis.com/v0/b/languagetranslator-app.appspot.com/o/author3.png?alt=media&token=f2db357f-52ba-4dda-9e4d-32eba0eefb0f',
  'https://firebasestorage.googleapis.com/v0/b/languagetranslator-app.appspot.com/o/author4.png?alt=media&token=061a9da0-1358-4ab2-8548-c0b3857650f0'
];
