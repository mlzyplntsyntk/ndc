import 'dart:async';

import 'package:ndc/models/session.dart';
import 'package:ndc/util/bloc.dart';

class SessionBloc extends BlocBase {

  StreamController<List<Session>> _sessionStateController = StreamController<List<Session>>.broadcast();

  SessionBloc() {

  }

  @override
  void dispose() {
    _sessionStateController.close();
  }
}