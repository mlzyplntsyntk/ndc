class Session {
  String title;
  String time;
  String day;
  String link;
  String room;
  String sessionType;
  String sessionGroup;
  List<dynamic> speakers;

  Session({
    this.title,
    this.time,
    this.day,
    this.link,
    this.room,
    this.sessionType,
    this.sessionGroup,
    this.speakers
  });

  Session.fromJson(Map<String, dynamic> json, String groupName) :
    title = json['title'],
    time = json['time'],
    day = json['day'],
    link = json['link'],
    room = json['room'],
    speakers = json['speakers'],
    sessionGroup = groupName,
    sessionType = 'session';
}