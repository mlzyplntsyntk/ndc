import 'dart:async';
import 'dart:convert';

import 'package:ndc/models/entity_state.dart';
import 'package:ndc/models/list_state.dart';
import 'package:ndc/models/session.dart';
import 'package:ndc/models/speaker.dart';
import 'package:ndc/util/api.dart';
import 'package:ndc/util/bloc.dart';
import 'package:ndc/util/db.dart';

class SpeakerDetailBloc extends BlocBase {

  StreamController<EntityState<Speaker>> _speakerDetailController = StreamController<EntityState<Speaker>>.broadcast();
  Stream<EntityState<Speaker>> get outSpeakerDetail => _speakerDetailController.stream;

  StreamController<ListState<Session>> _speakerSessionController = StreamController<ListState<Session>>.broadcast();
  Stream<ListState<Session>> get outSpeakerSession => _speakerSessionController.stream;

  void getSpeakerDetail(String link) async {
    EntityState<Speaker> _state = EntityState<Speaker>();

    _state.isRefreshing = true;
    _state.hasError = false;

    try {
      String speakerResponseString = await api.getRequest("http://sarbay.com/api/examples/ndc_speaker.php?url=$link");
      
      dynamic json = jsonDecode(speakerResponseString);

      _state.row = Speaker(
        content: json['content'],
        sessions: json['sessions']
      );

    } catch (err) {
      _state.hasError = true;
      _state.errorMessage = err.toString();
    }

    _state.isRefreshing = false;
    
    _speakerDetailController.sink.add(_state);
  }

  void getSpeakerSessions(List<dynamic> links) async {

    ListState<Session> _sessions = ListState<Session>();

    _sessions.isRefreshing = true;

    final db = await Db.db.database;
    var dbResponse = await db.rawQuery("select * from json_data where content_type='sessions'");
    if (!dbResponse.isNotEmpty) {
      _sessions.isRefreshing = false;
      _sessions.hasError = true;
      _sessions.errorMessage = "Speaker's sessions not found";

      _speakerSessionController.sink.add(_sessions);
      return null;
    }

    List<dynamic> json = jsonDecode(dbResponse.first["content"].toString());

    for (String link in links) {
      for (Map<String, dynamic> item in json) {
        if (item['link'] == link) {
          var _session = Session.fromJson(item, "odd");
          _sessions.rows.add(_session);
        }
      }
    }

    _sessions.isRefreshing = false;
    _speakerSessionController.sink.add(_sessions);

  }

  @override
  void dispose() {
    _speakerDetailController.close();
    _speakerSessionController.close();
  }
  
}