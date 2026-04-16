// model class for exercise data
class Exercise {
  int? id; // primary key

  int sportId; // linked sport id

  String name; // exercise name

  String description; // exercise details

  String type; // indoor or outdoor

  int duration; // duration in seconds/minutes

  // constructor
  Exercise({
    this.id,

    required this.sportId,

    required this.name,

    required this.description,

    required this.type,

    required this.duration,
  });

  // convert object to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'sportId': sportId,

      'name': name,

      'description': description,

      'type': type,

      'duration': duration,
    };
  }
}
