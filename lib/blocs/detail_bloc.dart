import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ndc/models/detail.dart';
import 'package:ndc/models/entity_state.dart';
import 'package:ndc/util/api.dart';
import 'package:ndc/util/bloc.dart';
import 'package:ndc/util/db.dart';

class DetailBloc extends BlocBase {
  EntityState<Detail> _detailState = EntityState<Detail>();

  StreamController<EntityState<Detail>> _detailStateController = StreamController<EntityState<Detail>>.broadcast();
  Stream<EntityState<Detail>> get outDetail => _detailStateController.stream;
  Sink<EntityState<Detail>> get _inDetail => _detailStateController.sink;

  void getDetails(String link) async {

    _detailState.isRefreshing = true;

    try {
      final db = await Db.db.database;
      String detailResponseString;
      bool fromCache = false;
      int detailResponseId = 0;
      int detailResponseFav = 0;

      var dbResponse = await db.rawQuery("select * from session_details where link = ?", [link]);
      if (dbResponse.isNotEmpty) {
        detailResponseString = dbResponse.first["detail"].toString();
        detailResponseId = int.parse(dbResponse.first['id'].toString());
        detailResponseFav = int.parse(dbResponse.first['is_fav'].toString());
        fromCache = true;
      } else {
        detailResponseString = await api.getRequest("http://sarbay.com/api/examples/ndc_detail.php?url=$link");
      }
      
      var json = jsonDecode(detailResponseString);

      _detailState.isRefreshing = false;

      _detailState.row = Detail();
      _detailState.row.title = json['title'];
      _detailState.row.spotContent = json["spotContent"]; 
      _detailState.row.content= json["content"]; 
      _detailState.row.day = json['day'];
      _detailState.row.time = json['time'];
      _detailState.row.room = json['room'];
      _detailState.row.tags = json['tags'];
      _detailState.row.speakers = json['speakers'];
      _detailState.row.link = link;
      _detailState.row.isFav = false;

      if (detailResponseId > 0) {
        _detailState.row.id = detailResponseId;
        _detailState.row.isFav = detailResponseFav == 1;
      }
      
      if (!fromCache) {
        await db.rawDelete("delete from session_details where link = ?", [link]);
        var insertResult = await db.rawInsert("insert into session_details (link, detail, is_fav) values (?, ?, ?)", [
          link, detailResponseString, 0
        ]);
        _detailState.row.id = insertResult;
      }

    } catch (error) {
      _detailState.isRefreshing = false;
      _detailState.hasError = true;
      _detailState.errorMessage = error.toString();
    }
    
    _inDetail.add(_detailState);

  }

  void addToFavourites(Detail detail, BuildContext context) async {
    final db = await Db.db.database;

    var favResponse = await db.rawQuery("select * from session_details where id = ?", [
      detail.id
    ]);

    int is_fav = 1;
    if (favResponse.isNotEmpty) {
      var item = favResponse.first;
      is_fav = item['is_fav'].toString() == "1" ? 0 : 1;
    }
     
    await db.rawUpdate("update session_details set is_fav=? where id = ?", [
      is_fav, detail.id
    ]);

    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(is_fav == 1 ? "Session Added to Favourites" : "Session Removed from favourites"),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));

    getDetails(detail.link);
  }

  @override
  void dispose() {
    _detailStateController.close();
  }
}