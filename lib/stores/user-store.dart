import 'package:flutter/material.dart';

class User {
  final int id;
  final String nome;
  final String email;
  final String? ra;
  final String role;

  User({
    required this.id,
    required this.nome,
    required this.email,
    required this.ra,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nome: json['name'],
      email: json['email'],
      ra: json['ra'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': nome,
      'email': email,
      'ra': ra,
      'role': role,
    };
  }

  /// Método copyWith para criar uma nova instância com valores alterados
  User copyWith({
    String? nome,
    String? email,
    String? ra,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      ra: ra ?? this.ra,
      role: role ?? this.role,
    );
  }
}

class UserStore with ChangeNotifier {
  static final UserStore _instance = UserStore._internal();

  User? _currentUser;
  String? _token;

  UserStore._internal();

  factory UserStore() => _instance;

  User? get currentUser => _currentUser;
  String? get token => _token;

  void setUser(User user) {
    _currentUser = user;
  }

  void setToken(String token) {
    _token = token;
  }

  void clearUser() {
    _currentUser = null;
    _token = null;
  }
}
