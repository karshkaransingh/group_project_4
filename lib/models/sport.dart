class Sport {
  int? id;
  String name;
  String description;
  String image;

  Sport({
    this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description, 'image': image};
  }
}
