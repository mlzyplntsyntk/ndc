import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ndc/blocs/fav_bloc.dart';
import 'package:ndc/models/detail.dart';
import 'package:ndc/models/session.dart';

import '../blocs/detail_bloc.dart';
import '../models/list_state.dart';
import '../util/bloc.dart';
import 'detail_page.dart';

class FavPageCalendar extends StatelessWidget {
  FavPageCalendar({Key key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    final FavBloc favBloc = BlocProvider.of<FavBloc>(context);

    return Scaffold(
      body: Center(
        child: StreamBuilder<ListState<Session>>(
          stream: favBloc.outFavCalendar,
          builder: (BuildContext context, AsyncSnapshot<ListState<Session>> snapshot) {
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
                          favBloc.getFavouritesBoard();
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
                            "${item.day}",
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
                                if (item.link == null) {
                                  return;
                                }
                                Navigator.push(context, MaterialPageRoute(
                                  settings: RouteSettings(isInitialRoute: true),
                                  builder: (context) => BlocProvider<DetailBloc>(
                                    bloc: DetailBloc(), 
                                    child: DetailPage(item.link, item.title, onChange: () async {
                                      await Future.delayed(Duration(milliseconds: 500));
                                      favBloc.getFavouritesBoard();
                                    },)
                                  )
                                ));
                              },
                              child: ListTile(
                                leading: Text(
                                  item.time
                                ),
                                title: item.title != null ? 
                                  Html(
                                    data: item.title,
                                    defaultTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "FiraSansRegular",
                                      fontSize: 16
                                    ),
                                  ) 
                                  : 
                                  Text(
                                    "Empty",
                                  ),
                                subtitle: item.room != null ? 
                                  Text(
                                    item.room
                                  ) 
                                  : 
                                  Text(
                                    ""
                                  )
                              )
                            )
                          )
                        );
                    },
                  ),
              );
          },
        ),
      ),
    );
  }
}