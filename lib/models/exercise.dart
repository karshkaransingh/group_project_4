class Exercise {
  int? id;
  int sportId;
  String name;
  String description;
  String type;
  int duration;
  //String video;

  Exercise({
    this.id,
    required this.sportId,
    required this.name,
    required this.description,
    required this.type,
    required this.duration,
    //required this.video,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sportId': sportId,
      'name': name,
      'description': description,
      'type': type,
      'duration': duration,
      //'video': video,
    };
  }
}
