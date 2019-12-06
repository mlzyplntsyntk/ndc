import 'package:flutter/material.dart';
import 'package:ndc/blocs/session_bloc.dart';
import 'package:ndc/pages/empty_page.dart';
import 'package:ndc/pages/schedule_page.dart';
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

  void initState() {
    super.initState();
    _pages.add(BlocProvider<SessionBloc>(bloc: sessionBloc, child: SchedulePage(key: PageStorageKey("SchedulePage")),));
    _pages.add(EmptyPage(key: PageStorageKey("EmptyPage2"),));
    _pages.add(EmptyPage(key: PageStorageKey("EmptyPage3"),));
  }

  int _selectedIndex = 0;

  Widget _bottomNavigationBar(int selectedIndex)=>BottomNavigationBar(
    fixedColor: Color(0xffe7005c),
    onTap: (int index)=>setState(() => _selectedIndex=index),
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

