import 'dart:async';
import 'dart:convert';

import 'package:ndc/models/list_state.dart';
import 'package:ndc/models/speaker.dart';
import 'package:ndc/util/api.dart';
import 'package:ndc/util/bloc.dart';

class SpeakersBloc extends BlocBase {

  StreamController<ListState<Speaker>> _speakerStateController = StreamController<ListState<Speaker>>.broadcast();
  Stream<ListState<Speaker>> get outSpeakers => _speakerStateController.stream;

  void getSpeakers() async {
    ListState<Speaker> _state = ListState<Speaker>();

    _state.isRefreshing = true;
    _state.hasError = false;
    _state.rows = [];
    
    _speakerStateController.sink.add(_state);

    try {
      
      var speakerResponseString = await api.getRequest("http://sarbay.com/api/examples/ndc_speakers.php");

      List<dynamic> json = jsonDecode(speakerResponseString);

      for (Map<String, dynamic> item in json) {
        _state.rows.add(Speaker.fromJson(item));
      }       

      _state.isRefreshing = false;
      
      _speakerStateController.sink.add(_state);
       
    } catch (err) {
      _state.hasError = true;
      _state.errorMessage = err.toString();
      _state.isRefreshing = false;

      _speakerStateController.sink.add(_state);
    }
  }

  @override
  void dispose() {
    _speakerStateController.close();
  }
}