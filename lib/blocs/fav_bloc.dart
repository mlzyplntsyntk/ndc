import 'dart:async';
import 'dart:convert';

import 'package:ndc/models/list_state.dart';
import 'package:ndc/util/bloc.dart';
import 'package:ndc/util/db.dart';

import '../models/detail.dart';

class FavBloc extends BlocBase {

  StreamController<ListState<Detail>> _favStateController = StreamController<ListState<Detail>>.broadcast();
  Stream<ListState<Detail>> get outFavourites => _favStateController.stream;

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

  void getFavouritesBoard() async {
    final db = await Db.db.database;

    var allSessions = await db.rawQuery("select * from sessions");

    if (allSessions.isNotEmpty) {
      
    }
  }

  @override
  void dispose() {
    _favStateController.close();
  }

}