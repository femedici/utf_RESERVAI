import 'dart:convert';
import 'package:http/http.dart' as http;
import '../stores/user-store.dart';
import 'package:provider/provider.dart';

class RegistrationService {
  final String baseUrl;

  RegistrationService(this.baseUrl);

  Future<void> register({
    String? name,
    String? email,
    String? ra,
    required String password,
    String? role,
  }) async {
    final url = Uri.parse('$baseUrl/api/users/create-account');

    // Validação de entrada
    if (email == null) {
      throw ArgumentError('Você deve fornecer pelo menos um email');
    }

    // Define o corpo da requisição dinamicamente
    final body = {
      'name': name,
      'email': email,
      if (ra != null && ra.isNotEmpty) 'ra': ra, // Inclui 'ra' somente se não for null ou vazio
      'password': password,
      'role': role,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      throw Exception('Erro ao realizar o registro: ${response.body}');
    }
  }


  Future<void> alter({
    String? name,
    String? email,
    String? ra,
    required String password,
    String? newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/api/users/alter-user');

    // Recupera o token do UserStore global
    final String? token = UserStore().token;

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    // Define o corpo da requisição dinamicamente
    final body = jsonEncode({  
      'name': name,
      'email': email,
      'password': newPassword ?? password,
    });

    // Envia a requisição com o token nos headers
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token', // Adiciona o token de sessão
      },
      body: body, // Envia diretamente o corpo já codificado
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      return; // Retorna os dados da alteração do usuário
    } else {
      throw Exception('Erro ao alterar o usuário: ${response.body}');
    }
  }
}