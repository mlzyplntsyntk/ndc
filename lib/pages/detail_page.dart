import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ndc/blocs/detail_bloc.dart';
import 'package:ndc/models/detail.dart';
import 'package:ndc/models/entity_state.dart';

import '../util/bloc.dart';

class DetailPage extends StatelessWidget {
  DetailPage(this.link, this.title);

  final String title;
  final String link;

  @override
  Widget build(BuildContext context) {
    final DetailBloc detailBloc = BlocProvider.of<DetailBloc>(context);

    detailBloc.getDetails(link);

    return Scaffold(
      appBar: AppBar(
        title: Text("Session Detail"),
        actions: <Widget>[
          FlatButton(
              child: Icon(Icons.favorite_border),
              onPressed: () async {
                
              }
            ),
        ],
      ),
      body: StreamBuilder<EntityState<Detail>>(
        stream: detailBloc.outDetail,
        builder: (BuildContext context, AsyncSnapshot<EntityState<Detail>> snapshot) {
          return snapshot == null || snapshot.data == null || snapshot.data.isRefreshing ? 
            Center(child: CircularProgressIndicator(),) : 
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: "FiraSansRegular",
                        color: Color(0xffe7005c), 
                      ),
                    ),
                    SizedBox(height: 30,),
                    Html(
                      data: snapshot.data.row.spotContent,
                      defaultTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "FiraSansRegular",
                        fontSize: 20
                      ),
                    ),
                    Html(
                      data: snapshot.data.row.content,
                      defaultTextStyle: TextStyle(
                        fontSize: 16,
                        fontFamily: "FiraSansRegular",
                      ),
                    )
                  ],
                ),
              )
            );
        },
      ),
    );
  }
  
}