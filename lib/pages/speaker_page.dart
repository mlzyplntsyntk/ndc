import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ndc/blocs/speaker_detail_bloc.dart';
import 'package:ndc/blocs/speakers_bloc.dart';
import 'package:ndc/models/entity_state.dart';
import 'package:ndc/models/speaker.dart';
import 'package:ndc/util/bloc.dart';

class SpeakerPage extends StatelessWidget {
  const SpeakerPage(this.name, this.link, {Key key}) : super(key:key);

  final String name;
  final String link;

  @override
  Widget build(BuildContext context) {
    SpeakerDetailBloc speakersBloc = BlocProvider.of<SpeakerDetailBloc>(context);
    
    speakersBloc.getSpeakerDetail(link);

    return Scaffold(
      appBar: AppBar(
        title: Text(this.name),
      ),
      body: StreamBuilder<EntityState<Speaker>>(
        stream: speakersBloc.outSpeakerDetail,
        builder: (BuildContext context, AsyncSnapshot<EntityState<Speaker>> snapshot) {
          
          return snapshot == null || snapshot.data == null || snapshot.data.isRefreshing ? 
            Center(child: CircularProgressIndicator(),) : 
            SingleChildScrollView(
              child: snapshot.data.hasError ? 
                Center(
                  child:Text(snapshot.data.errorMessage)
                )
                : 
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: <Widget>[
                          Html(
                            data: snapshot.data.row.content,
                            defaultTextStyle: TextStyle(
                              fontSize: 16,
                              fontFamily: "FiraSansRegular",
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Text(
                      snapshot.data.row.sessions.toString()
                    )
                  ],
                )
                
            );
        },
      ),
    );
  }
}