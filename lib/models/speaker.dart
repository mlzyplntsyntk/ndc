class Speaker {
  String link;
  String name;
  String job;
  String photo;

  Speaker({
    this.link,
    this.name,
    this.job,
    this.photo
  });

  Speaker.fromJson(Map<String, dynamic> json) :
    link = json['link'],
    name = json['name'],
    job = json['job'],
    photo = json['photo'];
}