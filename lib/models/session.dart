class Session {
  final String title;
  final String time;
  final String day;
  final String link;
  final String room;

  Session({
    this.title,
    this.time,
    this.day,
    this.link,
    this.room
  });

  Session.fromJson(Map<String, dynamic> json) :
    title = json['title'],
    time = json['time'],
    day = json['day'],
    link = json['link'],
    room = json['room'];
}

