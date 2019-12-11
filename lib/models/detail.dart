class Detail {
  int id;
  String title;
  String spotContent;
  String content;
  List<dynamic> tags;
  String link;
  String day;
  String time;
  String room;
  bool isFav = false;

  Detail({
    this.title,
    this.spotContent,
    this.content,
    this.tags,
    this.link,
    this.time,
    this.day,
    this.room,
    this.isFav,
    this.id
  });
}