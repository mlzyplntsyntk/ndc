import 'package:flutter/material.dart';
import 'package:ndc/blocs/fav_bloc.dart';
import 'package:ndc/blocs/session_bloc.dart';
import 'package:ndc/blocs/speakers_bloc.dart';
import 'package:ndc/models/speaker.dart';
import 'package:ndc/pages/empty_page.dart';
import 'package:ndc/pages/fav_page.dart';
import 'package:ndc/pages/fav_page_calendar.dart';
import 'package:ndc/pages/schedule_page.dart';
import 'package:ndc/pages/speakers_page.dart';
import 'package:ndc/util/bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NDC London',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          color: Colors.white, 
          textTheme: TextTheme(
            title: TextStyle(
              color: Color(0xffe7005c), 
              fontSize: 20.0, 
              fontFamily: "FiraSansRegular"
            )
          ),
          iconTheme:  IconThemeData(
            color: Color(0xffe7005c), 
          ),
          actionsIconTheme:  IconThemeData(
            color: Color(0xffe7005c), 
          )
        )
      ),
      home: BlocProvider<SessionBloc>(
        bloc:SessionBloc(),
        child: NavigationPage()
      ),
    );
  }
}


class NavigationPage extends StatefulWidget {
  NavigationPage({
    Key key
  }) : super(key: key);

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  //final AlbumBloc albumBloc = AlbumBloc();

  final PageStorageBucket bucket = PageStorageBucket();

  List<Widget> _pages = List<Widget>();

  final SessionBloc sessionBloc = SessionBloc();
  final FavBloc favBloc = FavBloc();
  final SpeakersBloc speakersBloc = SpeakersBloc();

  final FavPageCalendar favPage = FavPageCalendar(key: PageStorageKey("FavPage"));

  void initState() {
    super.initState();

    speakersBloc.getSpeakers();

    _pages.add(BlocProvider<SessionBloc>(bloc: sessionBloc, child: SchedulePage(key: PageStorageKey("SchedulePage")),));
    _pages.add(BlocProvider<SpeakersBloc>(bloc: speakersBloc, child: SpeakersPage(key: PageStorageKey("SpeakersPage")),));
    _pages.add(BlocProvider<FavBloc>(bloc: favBloc, child: favPage));
  }

  int _selectedIndex = 0;

  Widget _bottomNavigationBar(int selectedIndex)=>BottomNavigationBar(
    fixedColor: Color(0xffe7005c),
    onTap: (int index)=>setState(() {
      _selectedIndex=index;
      if (_selectedIndex == 2) {
        favBloc.getFavouritesBoard();
      }
    }),
    type: BottomNavigationBarType.fixed,
    currentIndex: selectedIndex,
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_view_day), title: Text("Schedule")
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.mic), title: Text("Speakers")
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today), title: Text("My Agenda")
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NDC {London}"),
      ),
      bottomNavigationBar: _bottomNavigationBar(_selectedIndex),
      body: IndexedStack(
        children: _pages,
        index: _selectedIndex,
      ),
    );
  }
}

