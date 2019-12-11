import 'package:flutter/material.dart';
import 'package:ndc/blocs/fav_bloc.dart';
import 'package:ndc/models/detail.dart';

import '../blocs/detail_bloc.dart';
import '../models/list_state.dart';
import '../util/bloc.dart';
import 'detail_page.dart';

class FavPage extends StatelessWidget {
  FavPage({Key key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    final FavBloc favBloc = BlocProvider.of<FavBloc>(context);

    return Scaffold(
      body: Center(
        child: StreamBuilder<ListState<Detail>>(
          stream: favBloc.outFavourites,
          builder: (BuildContext context, AsyncSnapshot<ListState<Detail>> snapshot) {
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
                          favBloc.getFavourites();
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
                                  builder: (context) => BlocProvider<DetailBloc>(
                                    bloc: DetailBloc(), 
                                    child: DetailPage(item.link, item.title, onChange: () async {
                                      await Future.delayed(Duration(milliseconds: 500));
                                      favBloc.getFavourites();
                                    },)
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
                                title: Text(
                                  item.title.toString(),
                                  style: TextStyle(
                                    fontFamily: "FiraSansRegular"
                                  ),
                                ),
                                subtitle: Text("${item.day}, ${item.time}")
                              )
                            )
                          )
                        ); 
                      },
                    )
                    :
                    Center(
                      child: Text(
                        "You haven't added any favourite sessions yet."
                      )
                    )
              );
          },
        ),
      ),
    );
  }
}