import 'dart:async';
import 'dart:convert';

import 'package:ndc/models/list_state.dart';
import 'package:ndc/models/session.dart';
import 'package:ndc/util/api.dart';
import 'package:ndc/util/bloc.dart';
import 'package:ndc/util/db.dart';

import '../models/detail.dart';

class FavBloc extends BlocBase {

  StreamController<ListState<Detail>> _favStateController = StreamController<ListState<Detail>>.broadcast();
  Stream<ListState<Detail>> get outFavourites => _favStateController.stream;

  StreamController<ListState<Session>> _favCalController = StreamController<ListState<Session>>.broadcast();
  Stream<ListState<Session>> get outFavCalendar => _favCalController.stream;

  void getFavourites() async {
    final db = await Db.db.database;

    var allFavs = await db.rawQuery("select * from session_details where is_fav = 1");

    ListState<Detail> favourites = ListState<Detail>();

    for (var item in allFavs) {

      int detailResponseId = int.parse(item['id'].toString());
      String detailResponseLink = item['link'].toString();
      
      var json = jsonDecode(item["detail"].toString());

      favourites.rows.add(Detail(
        id: detailResponseId,
        link: detailResponseLink,
        isFav: true,
        day: json['day'],
        time: json['time'],
        room: json['room'],
        title: json['title']
      ));
    }

    _favStateController.sink.add(favourites);
  }

  Future<List<Detail>> _getFavs() async {
    final db = await Db.db.database;

    var allFavs = await db.rawQuery("select * from session_details where is_fav = 1");

    List<Detail> favourites = List<Detail>();

    for (var item in allFavs) {

      int detailResponseId = int.parse(item['id'].toString());
      String detailResponseLink = item['link'].toString();
      
      var json = jsonDecode(item["detail"].toString());

      favourites.add(Detail(
        id: detailResponseId,
        link: detailResponseLink,
        isFav: true,
        day: json['day'],
        time: json['time'],
        room: json['room'],
        title: json['title']
      ));
    }

    return favourites;
  }

  void getFavouritesBoard() async {

    ListState<Session> _sessions = ListState<Session>();
    _sessions.isRefreshing = true;
    _sessions.hasError = false;
    _sessions.rows = [];
    _favCalController.sink.add(_sessions);

    try {

      final db = await Db.db.database;

      var dbResponse = await db.rawQuery("select * from json_data where content_type='sessions'");

      if (dbResponse.isNotEmpty) {
        List<Session> allSessions = List<Session>();

        var sessionResponseString = dbResponse.first["content"].toString();

        String lastRenderedDay = "";
        String lastRenderedHour = "";

        List<dynamic> json = jsonDecode(sessionResponseString);

        Session lastSession;

        var allFavs = await _getFavs();

        for (Map<String, dynamic> item in json) {
          if (lastRenderedDay != item['day']) {
            if (lastSession != null) {
              allSessions.add(lastSession);
              lastSession = null;
            }
            allSessions.add(new Session(day: item['day'], time: item['time'], sessionType: 'day'));
            lastRenderedDay = item['day'] ;
          }

          if (lastRenderedHour != item['time']) {
            if (lastSession != null) {
              allSessions.add(lastSession);
              lastSession = null;
            }
            lastRenderedHour = item['time'];
            lastSession = new Session(day: item['day'], time: item['time']);
          }

          var hasFav = allFavs.where((x)=>x.link == item['link']);
          if (hasFav.length > 0) {
            lastSession.title = hasFav.first.title;
            lastSession.link = hasFav.first.link;
            lastSession.speakers = item['speakers'];
            lastSession.room = item['room'];
          }

          //allSessions.add(Session.fromJson(item, "odd"));
        }

        if (lastSession != null) {
          allSessions.add(lastSession);
          lastSession = null;
        }

        _sessions.isRefreshing = false;
        _sessions.rows = allSessions;

        _favCalController.sink.add(_sessions);

      } else {

        _sessions.hasError = true;
        _sessions.errorMessage = "Calendar couldn't be prepared";
        _sessions.isRefreshing = false;
        _favCalController.sink.add(_sessions);
      }

    } catch (error) {
      _sessions.hasError = true;
      _sessions.errorMessage = error.toString();
      _sessions.isRefreshing = false;
      _favCalController.sink.add(_sessions);
    }

  }

  @override
  void dispose() {
    _favStateController.close();
    _favCalController.close();
  }

}