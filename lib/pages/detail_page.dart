import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ndc/blocs/detail_bloc.dart';
import 'package:ndc/models/detail.dart';
import 'package:ndc/models/entity_state.dart';

import '../util/bloc.dart';

class DetailPage extends StatefulWidget {
  DetailPage(this.link, this.title, {this.onChange});

  final String title;
  final String link;
  final Function onChange;

  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    final DetailBloc detailBloc = BlocProvider.of<DetailBloc>(context);

    detailBloc.getDetails(widget.link);

    return Scaffold(
      appBar: AppBar(
        title: Text("Session Detail"),
        actions: <Widget>[
          StreamBuilder<EntityState<Detail>>(
            stream: detailBloc.outDetail,
            builder: (BuildContext context, AsyncSnapshot<EntityState<Detail>> snapshot) {
              return snapshot == null || snapshot.data == null || snapshot.data.row == null  ? 
                Container()
                :
                FlatButton(
                  child: Icon(snapshot.data.row.isFav ? Icons.favorite : Icons.favorite_border),
                  onPressed: () async {
                    detailBloc.addToFavourites(snapshot.data.row, context);
                    if (widget.onChange != null) {
                      widget.onChange();
                    }
                  }
                );
            },
          )
        ],
      ),
      body: StreamBuilder<EntityState<Detail>>(
        stream: detailBloc.outDetail,
        builder: (BuildContext context, AsyncSnapshot<EntityState<Detail>> snapshot) {
          return snapshot == null || snapshot.data == null || snapshot.data.isRefreshing ? 
            Center(child: CircularProgressIndicator(),) : 
            SingleChildScrollView(
              child: snapshot.data.hasError ? 
                Center(
                  child:Text(snapshot.data.errorMessage)
                )
                : 
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      Html(
                        data: snapshot.data.row.title,
                        defaultTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "FiraSansRegular",
                          fontSize: 30,
                          color: Color(0xffe7005c), 
                        ),
                      ),
                      SizedBox(height: 30,),
                      Wrap(
                        children: getChips(snapshot.data.row.tags),
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

  List<Widget> getChips(List<dynamic> tags) {
    List<Widget> widgets = List<Widget>();

    widgets.add(
        Container(
          padding:EdgeInsets.all(3), 
          child: Chip(
            label: Text(
              "Tags"
            ), 
            padding: EdgeInsets.all(5),
          )
        )
      );

    tags.forEach((item) {
      widgets.add(
        Container(
          padding:EdgeInsets.all(3), 
          child: Chip(
            backgroundColor: Colors.purpleAccent,
            labelStyle: TextStyle(color: Colors.white),
            label: Text(
              item.toString()
            ), 
            padding: EdgeInsets.all(5),
          )
        )
      );
    });

    return widgets;
  }
  
}