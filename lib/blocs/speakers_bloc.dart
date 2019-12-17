import 'dart:async';
import 'dart:convert';

import 'package:ndc/models/entity_state.dart';
import 'package:ndc/models/list_state.dart';
import 'package:ndc/models/speaker.dart';
import 'package:ndc/util/api.dart';
import 'package:ndc/util/bloc.dart';
import 'package:ndc/util/db.dart';

class SpeakersBloc extends BlocBase {

  StreamController<ListState<Speaker>> _speakerStateController = StreamController<ListState<Speaker>>.broadcast();
  Stream<ListState<Speaker>> get outSpeakers => _speakerStateController.stream;

  StreamController<ListState<Speaker>> _singleSessionController = StreamController<ListState<Speaker>>.broadcast();
  Stream<ListState<Speaker>> get outSingleSession => _singleSessionController.stream;

  Future<List<Speaker>> _getSpeakers() async {
      final db = await Db.db.database;

      var dbResponse = await db.rawQuery("select * from json_data where content_type='speakers'");

      String speakerResponseString;
      bool fromCache = false;

      if (dbResponse.isNotEmpty) {
        speakerResponseString = dbResponse.first["content"].toString();
        fromCache = true;
      } else {
        speakerResponseString = await api.getRequest("http://sarbay.com/api/examples/ndc_speakers.php");
      }
      
      List<dynamic> json = jsonDecode(speakerResponseString);

      List<Speaker> _list = List<Speaker>();

      for (Map<String, dynamic> item in json) {
        _list.add(Speaker.fromJson(item));
      }       

      if (!fromCache) {
        await db.rawDelete("delete from json_data where content_type = ?", [
          'speakers'
        ]);
        await db.rawInsert("insert into json_data (content_type, content) values (?, ?)", [
          'speakers',
          speakerResponseString
        ]);
      }

      return _list;
  }

  void getSpeakers() async {
    ListState<Speaker> _state = ListState<Speaker>();

    _state.isRefreshing = true;
    _state.hasError = false;
    _state.rows = [];
    
    _speakerStateController.sink.add(_state);

    try {
      
      var speakers = await this._getSpeakers();
      _state.rows.addAll(speakers);
      _state.isRefreshing = false;
      
      _speakerStateController.sink.add(_state);
       
    } catch (err) {
      _state.hasError = true;
      _state.errorMessage = err.toString();
      _state.isRefreshing = false;

      _speakerStateController.sink.add(_state);
    }
  }

  void getSpecificSpeakers(List<dynamic> speakers) async {
    ListState<Speaker> _state = ListState<Speaker>();

    _state.isRefreshing = true;
    _state.hasError = false;
    _state.rows = [];
    
    _singleSessionController.sink.add(_state);

    try {
      
      var allSpeakers = await this._getSpeakers();

      for (var search in speakers) {
        for (var speaker in allSpeakers) {
          if (speaker.name == search) {
            _state.rows.add(speaker);
          }
        }
      }

      _state.isRefreshing = false;
      
      _singleSessionController.sink.add(_state);
       
    } catch (err) {
      _state.hasError = true;
      _state.errorMessage = err.toString();
      _state.isRefreshing = false;

      _singleSessionController.sink.add(_state);
    }
  }

  @override
  void dispose() {
    _speakerStateController.close();
    _singleSessionController.close();
  }
}