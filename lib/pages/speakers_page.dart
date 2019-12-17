import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ndc/blocs/session_bloc.dart';
import 'package:ndc/blocs/speaker_detail_bloc.dart';
import 'package:ndc/blocs/speakers_bloc.dart';
import 'package:ndc/models/speaker.dart';
import 'package:ndc/pages/speaker_page.dart';

import '../models/list_state.dart';
import '../util/bloc.dart';

class SpeakersPage extends StatelessWidget {
  SpeakersPage({Key key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    final SpeakersBloc speakersBloc = BlocProvider.of<SpeakersBloc>(context);

    return Scaffold(
      body: Center(
        child: StreamBuilder<ListState<Speaker>>(
          stream: speakersBloc.outSpeakers,
          builder: (BuildContext context, AsyncSnapshot<ListState<Speaker>> snapshot) {
            return snapshot == null || snapshot.data == null || snapshot.data.isRefreshing ? 
              Center(
                child: CircularProgressIndicator(
                  backgroundColor: Color(0xffe7005c),
                )
              ) 
              : 
              Center(
                child: snapshot.data.hasError ? 
                  Column(
                    children: <Widget>[
                      Text(
                        "${snapshot.data.errorMessage}"
                      ),
                      RaisedButton(
                        onPressed: () async {
                          speakersBloc.getSpeakers();
                        },
                        child: Text(
                          "Try Again"
                        ),
                      )
                    ],
                  )
                  :
                  snapshot.data.rows.length > 0 ?
                    ListView.builder(
                      itemCount: snapshot.data.rows.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data.rows[index];
                        
                        return Container(
                            child: Card(
                            elevation: 0,
                            color: Colors.white,
                            child:InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  settings: RouteSettings(isInitialRoute: true),
                                  builder: (context) => BlocProvider<SpeakerDetailBloc>(
                                    bloc: SpeakerDetailBloc(), 
                                    child: SpeakerPage(item.name, item.link, item.job, item.photo)
                                  )
                                ));
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(item.photo),
                                  backgroundColor: Colors.grey,
                                ),
                                title: Text(
                                  item.name.toString(),
                                  style: TextStyle(
                                    fontFamily: "FiraSansRegular"
                                  ),
                                ),
                                subtitle: Html(
                                  data: item.job
                                )
                              )
                            )
                          )
                        ); 
                      },
                    )
                    :
                    Center(
                      child: Text(
                        "Speakers could not be loaded"
                      )
                    )
              );
          },
        ),
      ),
    );
  }
}