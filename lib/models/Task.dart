class Task {
  Task(this.content);

  bool completed = false;
  String content;
  int id;

  Task.fromJson(Map<String, dynamic> json)
      : content = json["title"],
        completed = json["completed"],
        id = json["id"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': content,
        'completed': completed,
        'userId': 1,
      };
}
