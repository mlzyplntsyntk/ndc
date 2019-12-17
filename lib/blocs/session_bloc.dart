import 'dart:async';
import 'dart:convert';

import 'package:ndc/models/list_state.dart';
import 'package:ndc/models/session.dart';
import 'package:ndc/util/api.dart';
import 'package:ndc/util/bloc.dart';
import 'package:ndc/util/db.dart';

class SessionBloc extends BlocBase {

  ListState<Session> _sessions = ListState<Session>();
  StreamController<ListState<Session>> _sessionStateController = StreamController<ListState<Session>>.broadcast();
  Stream<ListState<Session>> get outSessions => _sessionStateController.stream;
  Sink<ListState<Session>> get _inSessions => _sessionStateController.sink;

  SessionBloc();

  void removeSessions() async {
    final db = await Db.db.database;

    await db.rawDelete("delete from session_details");
  }

  Future<List<Session>> getSessions() async {

    List<Session> allSessions = List<Session>();

    
    _sessions.isRefreshing = true;
    _sessions.hasError = false;
    _sessions.rows = [];
    _inSessions.add(_sessions);
    
    try {
      final db = await Db.db.database;

      await db.rawDelete("delete from json_data where content_type = ?", [
        'sessions'
      ]);

      String sessionResponseString;
      bool fromCache = false;

      var dbResponse = await db.rawQuery("select * from json_data where content_type='sessions'");
      if (dbResponse.isNotEmpty) {
        sessionResponseString = dbResponse.first["content"].toString();
        fromCache = true;
      } else {
        sessionResponseString = await api.getRequest("http://sarbay.com/api/examples/ndc.php");
      }
      
      List<dynamic> json = jsonDecode(sessionResponseString);

      String lastRenderedDay = "";
      String lastRenderedHour = "";

      for (Map<String, dynamic> item in json) {
        if (lastRenderedDay != item['day'] + ' ' + item['time']) {
          allSessions.add(new Session(day: item['day'], time: item['time'], sessionType: 'daytime'));
          lastRenderedDay = item['day'] + ' ' + item['time'];
        }
        if (lastRenderedHour != item['time']) {
          lastRenderedHour = item['time'];
        }
        allSessions.add(Session.fromJson(item, "even"));
      }

      _sessions.isRefreshing = false;
      _sessions.rows = allSessions;

      _inSessions.add(_sessions);

      if (!fromCache) {
        await db.rawDelete("delete from json_data where content_type = ?", [
          'sessions'
        ]);
        await db.rawInsert("insert into json_data (content_type, content) values (?, ?)", [
          'sessions',
          sessionResponseString
        ]);
      }

    } catch(err) {
      _sessions.hasError = true;
      _sessions.errorMessage = err.toString();
      _sessions.isRefreshing = false;
      _inSessions.add(_sessions);
    }

    return allSessions;
  }
  
  void getFavoruitesTable() async {
    var allSessions = await getSessions();

    for (var item in allSessions) {
      
    }
  }

  @override
  void dispose() {
    _sessionStateController.close();
  }
}