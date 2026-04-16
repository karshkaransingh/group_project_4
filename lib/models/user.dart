// model class for user data
class User {
  int? id; // primary key

  String username; // user name

  String email; // user email

  String password; // user password

  // constructor
  User({
    this.id,

    required this.username,

    required this.email,

    required this.password,
  });

  // convert object to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'username': username,

      'email': email,

      'password': password,
    };
  }
}
