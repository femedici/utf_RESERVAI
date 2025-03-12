import 'dart:convert';
import 'package:http/http.dart' as http;
import '../stores/user-store.dart';

class AuthService {
  final String baseUrl;

  AuthService(this.baseUrl);

  Future<Map<String, dynamic>> login({
    String? email,
    String? ra,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    // Define o corpo da requisição dinamicamente
    final body = email != null
        ? {'email': email, 'password': senha}
        : {'ra': ra, 'password': senha};

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200  || response.statusCode == 201) {
      return jsonDecode(response.body); // Retorna os dados do login
    } else {
      throw Exception('Erro ao realizar login: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchUserById(int id) async {
    final String? token = UserStore().token;
    final url = Uri.parse('$baseUrl/api/users/$id');
    print(url);
    print({
        'Content-Type': 'application/json',
        'Authorization': '$token', // Adiciona o token de sessão
      });
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token', // Adiciona o token de sessão
      },
    );

    if (response.statusCode == 200  || response.statusCode == 201) {
      print("Foi");
      return jsonDecode(response.body); // Retorna as informações do usuário
    } else {
      throw Exception('Erro ao buscar usuário: ${response.body}');
    }
  }
}
