import 'dart:async';

import 'package:ndc/models/entity_state.dart';
import 'package:ndc/models/speaker.dart';
import 'package:ndc/util/api.dart';
import 'package:ndc/util/bloc.dart';

class SpeakerDetailBloc extends BlocBase {

  StreamController<EntityState<Speaker>> _speakerDetailController = StreamController<EntityState<Speaker>>.broadcast();
  Stream<EntityState<Speaker>> get outSpeakerDetail => _speakerDetailController.stream;

  void getSpeakerDetail(String link) async {
    EntityState<Speaker> _state = EntityState<Speaker>();

    _state.isRefreshing = true;
    _state.hasError = false;

    try {
      String speakerResponseString = await api.getRequest("http://sarbay.com/api/examples/ndc_speaker.php?url=$link");

      _state.row = Speaker(content: "test");
    } catch (err) {
      _state.hasError = true;
      _state.errorMessage = err.toString();
    }

    _state.isRefreshing = false;
    
    _speakerDetailController.sink.add(_state);
  }

  @override
  void dispose() {
    _speakerDetailController.close();
  }
  
}