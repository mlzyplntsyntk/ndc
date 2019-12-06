import 'package:flutter/material.dart';
import 'package:ndc/blocs/detail_bloc.dart';
import 'package:ndc/models/list_state.dart';
import 'package:ndc/models/session.dart';
import 'package:ndc/pages/detail_page.dart';

import '../blocs/session_bloc.dart';
import '../util/bloc.dart';

class SchedulePage extends StatefulWidget {
  SchedulePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  
  @override
  Widget build(BuildContext context) {
    final SessionBloc sessionBloc = BlocProvider.of<SessionBloc>(context);

    sessionBloc.getSessions();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          sessionBloc.getSessions();
        },
        child: StreamBuilder<ListState<Session>>(
          stream: sessionBloc.outSessions,
          builder: (BuildContext context, AsyncSnapshot<ListState<Session>> snapshot) {
            return snapshot == null || snapshot.data == null || snapshot.data.isRefreshing ? 
              Center(
                child: CircularProgressIndicator(
                  backgroundColor: Color(0xffe7005c),
                )
              ) : 
              Center(
                child: snapshot.data.hasError ? 
                  Column(
                    children: <Widget>[
                      Text(
                        "${snapshot.data.errorMessage}"
                      ),
                      RaisedButton(
                        onPressed: () async {
                          sessionBloc.getSessions();
                        },
                        child: Text(
                          "Try Again"
                        ),
                      )
                    ],
                  )
                  :
                  ListView.builder(
                    itemCount: snapshot.data.rows.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data.rows[index];
                      
                      return item.sessionType == 'day' ? 
                        Container(
                          color: Color(0xffe7005c),
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "${item.day} - ${item.time}",
                            style: TextStyle(
                              color: Colors.white
                            ),
                          )
                        ) : Container(
                          child: Card(
                            elevation: 0,
                            color: item.sessionGroup == "odd" ? Color(0xfff2f2f2) : Colors.white,
                            child:InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  settings: RouteSettings(isInitialRoute: true),
                                  builder: (context) => BlocProvider<DetailBloc>(bloc: DetailBloc(), child: DetailPage(item.link, item.title))
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
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontFamily: "FiraSansRegular"
                                  ),
                                ),
                                subtitle: Text("Author 1, Author 2")
                              )
                            )
                          )
                        );
                    },
                  ),
              );
          },
        ),
      )
    );
  }
}
