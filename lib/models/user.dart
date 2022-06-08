class User {
  String id;
  final String username;
  final String password;
  final String email;

  User({
    this.id = '',
    required this.username,
    required this.password,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'email': email,
      };
}
