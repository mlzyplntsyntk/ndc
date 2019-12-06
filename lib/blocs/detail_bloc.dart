import 'dart:async';
import 'dart:convert';

import 'package:ndc/models/detail.dart';
import 'package:ndc/models/entity_state.dart';
import 'package:ndc/util/api.dart';
import 'package:ndc/util/bloc.dart';

class DetailBloc extends BlocBase {
  EntityState<Detail> _detailState = EntityState<Detail>();

  StreamController<EntityState<Detail>> _detailStateController = StreamController<EntityState<Detail>>.broadcast();
  Stream<EntityState<Detail>> get outDetail => _detailStateController.stream;
  Sink<EntityState<Detail>> get _inDetail => _detailStateController.sink;

  void getDetails(String link) async {

    _detailState.isRefreshing = true;

    try {
      var detailResponse = await api.getRequest("http://sarbay.com/api/examples/ndc_detail.php?url=$link");
      var json = jsonDecode(detailResponse);

      _detailState.isRefreshing = false;

      _detailState.row = Detail();
      _detailState.row.spotContent = json["spotContent"]; 
      _detailState.row.content= json["content"]; 

    } catch (error) {
      _detailState.isRefreshing = false;
      _detailState.hasError = true;
      _detailState.errorMessage = error.toString();
    }
    
    _inDetail.add(_detailState);

  }

  @override
  void dispose() {
      _detailStateController.close();
  }
}