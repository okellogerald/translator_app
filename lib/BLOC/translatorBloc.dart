import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator_app/DATA/translatedText.dart';
import 'package:translator_app/REPOSITORY/translationProcess.dart';
import 'package:translator_app/UI/homepage.dart';

enum BlocEvents { text, chat, image }

class Inputs {
  String textInput = '', filepath, source, language, username;
}

abstract class BlocState {
  void dispose();
}

class TranslatorBloc extends BlocState {
  //for events
  StreamController<BlocEvents> _eventsStreamController =
      StreamController<BlocEvents>.broadcast();
  Stream<BlocEvents> get _eventStream => _eventsStreamController.stream;
  StreamSink<BlocEvents> get eventSink => _eventsStreamController.sink;

  StreamController<TranslatedText> _translatationStreamController =
      StreamController<TranslatedText>.broadcast();
  Stream<TranslatedText> get translationStream =>
      _translatationStreamController.stream;
  StreamSink<TranslatedText> get _translationSink =>
      _translatationStreamController.sink;

  TranslatorBloc() {
    _eventStream.listen((event) async {
      final _translator = TranslationProcess();
      if (event == BlocEvents.text) {
        final _translation = await _translator.translateText(inputs.textInput);
        _translationSink.add(TranslatedText(_translation));
      }
      if (event == BlocEvents.image) {
        final _imageText = await _translator.translateImage(inputs.filepath);
        final _translation = await _translator.translateText(_imageText);
        _translationSink.add(TranslatedText(_translation));
      }
      if (event == BlocEvents.chat) {
        final _translation =
            await _translator.translateChat(inputs.textInput, inputs.language);
        _translator.uploadTranslatedChat(_translation);
        //     _translationSink.add(TranslatedText(_translation));
      }
    });
  }

  @override
  void dispose() {
    _eventsStreamController.close();
    _translatationStreamController.close();
  }
}
