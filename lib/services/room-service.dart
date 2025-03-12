import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';
import '../stores/user-store.dart';

class RoomService {
  final String baseUrl;

  RoomService(this.baseUrl);

  /// Criação de uma nova sala
  Future<void> createRoom({
    required String name,
    required Map<String, dynamic> informations,
    required String openingHour, // Alterado para String
    required String closingHour, // Alterado para String
  }) async {
    final url = Uri.parse('$baseUrl/api/rooms/new');

    // Recupera o token do UserStore global
    final String? token = UserStore().token;

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final body = {
      'name': name,
      'informations': informations,
      'opening_hour': openingHour, // Envia no formato "HH:mm"
      'closing_hour': closingHour, // Envia no formato "HH:mm"
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token', // Adiciona o token de sessão
      },
      body: jsonEncode(body),
    );

    print(jsonEncode(body));

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      throw Exception('Erro ao criar a sala: ${response.body}');
    }
  }

  /// Atualização de uma sala existente
  Future<void> updateRoom({
    required int id,
    String? name,
    Map<String, dynamic>? informations,
    String? openingHour, // Alterado para String
    String? closingHour, // Alterado para String
  }) async {
    final url = Uri.parse('$baseUrl/api/rooms/$id/update');
    
     // Recupera o token do UserStore global
    final String? token = UserStore().token;

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final body = {
      if (name != null) 'name': name,
      if (informations != null) 'informations': informations,
      if (openingHour != null) 'opening_hour': openingHour, // Envia como String
      if (closingHour != null) 'closing_hour': closingHour, // Envia como String
    };

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token', // Adiciona o token de sessão
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      throw Exception('Erro ao atualizar a sala: ${response.body}');
    }
  }

  /// Deletar uma sala
  Future<void> deleteRoom (int id) async {
    final url = Uri.parse('$baseUrl/api/rooms/$id/del');
    
     // Recupera o token do UserStore global
    final String? token = UserStore().token;

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token', // Adiciona o token de sessão
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception('Erro ao deletar a sala: ${response.body}');
    }
  }

  /// Listagem de todas as salas
  Future<List<Room>> fetchRooms() async {
    final url = Uri.parse('$baseUrl/api/rooms');

    // Recupera o token do UserStore global
    final String? token = UserStore().token;

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token', // Adiciona o token de sessão
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = jsonDecode(response.body);

      // Extrai a lista de salas no campo 'data'
      final List<dynamic> roomsJson = responseJson['data'];
      return roomsJson.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar as salas: ${response.body}');
    }
  }
}
