class User {
  final int id;
  final String name;
  final String email;
  final String ra;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.ra,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      ra: json['ra'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'ra': ra,
      'password': password,
    };
  }

  /// Método `copyWith`
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? ra,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      ra: ra ?? this.ra,
      password: password ?? this.password,
    );
  }
}
