// model class for sport data
class Sport {
  int? id; // primary key

  String name; // sport name

  String description; // sport details

  String image; // image path

  // constructor
  Sport({
    this.id,

    required this.name,

    required this.description,

    required this.image,
  });

  // convert object to map for database
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description, 'image': image};
  }
}
