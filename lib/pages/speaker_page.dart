import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ndc/blocs/detail_bloc.dart';
import 'package:ndc/blocs/session_bloc.dart';
import 'package:ndc/blocs/speaker_detail_bloc.dart';
import 'package:ndc/blocs/speakers_bloc.dart';
import 'package:ndc/models/entity_state.dart';
import 'package:ndc/models/list_state.dart';
import 'package:ndc/models/session.dart';
import 'package:ndc/models/speaker.dart';
import 'package:ndc/util/bloc.dart';

import 'detail_page.dart';

class SpeakerPage extends StatelessWidget {
  const SpeakerPage(this.name, this.link, this.job, this.photo, {Key key}) : super(key:key);

  final String name;
  final String link;
  final String job;
  final String photo;

  @override
  Widget build(BuildContext context) {
    SpeakerDetailBloc speakersBloc = BlocProvider.of<SpeakerDetailBloc>(context);

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    
    speakersBloc.getSpeakerDetail(link);

    return Scaffold(
      appBar: AppBar(
        title: Text("Speaker Information"),
      ),
      body: StreamBuilder<EntityState<Speaker>>(
        stream: speakersBloc.outSpeakerDetail,
        builder: (BuildContext context, AsyncSnapshot<EntityState<Speaker>> snapshot) {
          if (snapshot != null && snapshot.data != null && snapshot.data.row != null) {
            speakersBloc.getSpeakerSessions(snapshot.data.row.sessions);
          }
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
                          CircleAvatar(
                            radius:_width<_height? _width/4:_height/4,
                            backgroundImage: NetworkImage(this.photo),
                          ),
                          SizedBox(height: _height/25.0,),
                          Text(
                            this.name, 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: _width/15
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: _height/30, left: _width/8, right: _width/8),
                            child: Text(
                              this.job,
                              style: TextStyle(
                                fontWeight: FontWeight.normal, 
                                fontSize: _width/25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Divider(height: _height/30,),
                          Html(
                            data: snapshot.data.row.content,
                            defaultTextStyle: TextStyle(
                              fontSize: 16,
                              fontFamily: "FiraSansRegular",
                            ),
                          ),
                          Divider(height: _height/30,),
                          SizedBox(height: 20,),
                          Html(
                            data: "Sessions",
                            defaultTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "FiraSansRegular",
                              fontSize: 25,
                              color: Color(0xffe7005c), 
                            ),
                          ),
                          SizedBox(height: 30,),
                          StreamBuilder<ListState<Session>>(
                            stream: speakersBloc.outSpeakerSession,
                            builder: (BuildContext context, AsyncSnapshot<ListState<Session>> snapshot) {
                              return snapshot == null || snapshot.data == null ? CircularProgressIndicator() : Padding(
                                padding: const EdgeInsets.only(top: 0, bottom: 0.0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data.rows.length,
                                  itemBuilder: (context ,index) {
                                    final item = snapshot.data.rows[index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                          settings: RouteSettings(isInitialRoute: true),
                                          builder: (context) => BlocProvider<DetailBloc>(
                                            bloc: DetailBloc(), 
                                            child: BlocProvider<SpeakersBloc>(
                                              bloc: SpeakersBloc(),
                                              child: DetailPage(item.link, item.title, item.speakers)
                                            )
                                          )
                                        ));
                                      },
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Color(0xff2600c3),
                                          child: Text(
                                            item.room.replaceAll("Room ", ""),
                                            style: TextStyle(
                                              fontFamily: "FiraSansRegular"
                                            ),
                                          ),
                                        ),
                                        title: Html(
                                          data: item.title,
                                          defaultTextStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "FiraSansRegular",
                                            fontSize: 16
                                          ),
                                        ),
                                        subtitle: Text(
                                          "${item.day} ${item.time}"
                                        )
                                      )
                                    );
                                  }
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 30,),
                        ],
                      ),
                    ),
                    
                  ],
                )
                
            );
        },
      ),
    );
  }
}