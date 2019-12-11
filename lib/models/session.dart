class Session {
  final String title;
  final String time;
  final String day;
  final String link;
  final String room;
  final String sessionType;
  final String sessionGroup;
  final List<dynamic> speakers;

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