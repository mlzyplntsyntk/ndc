import 'dart:async';
import 'dart:convert';

import 'package:ndc/models/list_state.dart';
import 'package:ndc/models/session.dart';
import 'package:ndc/util/api.dart';
import 'package:ndc/util/bloc.dart';

class SessionBloc extends BlocBase {

  ListState<Session> _sessions = ListState<Session>();
  StreamController<ListState<Session>> _sessionStateController = StreamController<ListState<Session>>.broadcast();
  Stream<ListState<Session>> get outSessions => _sessionStateController.stream;
  Sink<ListState<Session>> get _inSessions => _sessionStateController.sink;

  SessionBloc() {

  }

  void getSessions() async {
    _sessions.isRefreshing = true;
    _sessions.hasError = false;
    _sessions.rows = [];
    _inSessions.add(_sessions);
    
    try {
      String albumResponseString = await api.getRequest("http://sarbay.com/api/examples/ndc.php");
      List<dynamic> json = jsonDecode(albumResponseString);

      String lastRenderedDay = "";
      String lastRenderedHour = "";

      List<Session> allSessions = List<Session>();
      String groupName = "odd";

      for (Map<String, dynamic> item in json) {
        if (lastRenderedDay != item['day'] + ' ' + item['time']) {
          allSessions.add(new Session(day: item['day'], time: item['time'], sessionType: 'day'));
          lastRenderedDay = item['day'] + ' ' + item['time'];
        }
        if (lastRenderedHour != item['time']) {
          groupName = groupName == "odd" ? "even" : "odd";
          lastRenderedHour = item['time'];
        }
        allSessions.add(Session.fromJson(item, groupName));
      }

      _sessions.isRefreshing = false;
      _sessions.rows = allSessions;

      _inSessions.add(_sessions);

    } catch(err) {
      _sessions.hasError = true;
      _sessions.errorMessage = err.toString();
      _sessions.isRefreshing = false;
      _inSessions.add(_sessions);
    }
  }

  @override
  void dispose() {
    _sessionStateController.close();
  }
}