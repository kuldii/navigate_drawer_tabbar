class Tag {
  int? id;
  String? title;

  Tag({this.id, this.title});

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    return data;
  }

  static List<Tag> fromJsonList(List? data) {
    if (data == null) {
      return [];
    }
    return data.map((e) => Tag.fromJson(e)).toList();
  }
}
