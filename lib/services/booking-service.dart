import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking.dart';
import '../models/room.dart';
import '../stores/user-store.dart';

class BookingService {
  final String baseUrl;

  BookingService(this.baseUrl);

  /// Aprovar uma reserva
  Future<void> approveBooking(int bookingId) async {
    final url = Uri.parse('$baseUrl/api/bookings/$bookingId/approve-intent');

    // Recupera o token do UserStore global
    final String? token = UserStore().token;

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token', // Adiciona o token de sessão
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Erro ao aprovar a reserva: ${response.body}');
    }
  }

  /// Rejeitar uma reserva
  Future<void> rejectBooking(int bookingId) async {
    final url = Uri.parse('$baseUrl/api/bookings/$bookingId/reject');

    // Recupera o token do UserStore global
    final String? token = UserStore().token;

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token', // Adiciona o token de sessão
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Erro ao rejeitar a reserva: ${response.body}');
    }
  }

  /// Cancelar uma reserva
  Future<void> cancelBooking(int bookingId) async {
    final url = Uri.parse('$baseUrl/api/bookings/$bookingId/cancel');

    // Recupera o token do UserStore global
    final String? token = UserStore().token;

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token', // Adiciona o token de sessão
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Erro ao cancelar a reserva: ${response.body}');
    }
  }

  /// Listagem de todas as reservas
  Future<List<Booking>> fetchBookings() async {
    final url = Uri.parse('$baseUrl/api/bookings');

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

      // Extrai a lista de reservas no campo 'data'
      final List<dynamic> bookingsJson = responseJson['data'];
      return bookingsJson.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar as reservas: ${response.body}');
    }
  }


  /// Listagem de todas as reservas de um usuario
  Future<List<Booking>> fetchUserBookings() async {
    // Obtém o ID do usuário da sessão atual
    final int? userId = UserStore().currentUser!.id;

    if (userId == null) {
      throw Exception('ID do usuário não encontrado. Faça login novamente.');
    }

    // Monta a URL com o ID do usuário
    final url = Uri.parse('$baseUrl/api/bookings/users/$userId');

    // Recupera o token do UserStore global
    final String? token = UserStore().token;

    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    // Faz a requisição GET
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

      // Extrai a lista de reservas no campo 'data'
      final List<dynamic> bookingsJson = responseJson['data'];
      return bookingsJson.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar as reservas: ${response.body}');
    }
  }

    /// Listar horários disponíveis para uma sala específica
  Future<List<Hour>> listTimeSlotsFromRoom(Room room) async {
    final url = Uri.parse('$baseUrl/api/rooms/${room.id}');

    final String? token = UserStore().token;
    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = jsonDecode(response.body);
      final List<dynamic> hoursRaw = responseJson['hours'];
      return hoursRaw.map((e) => Hour.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar horários da sala: ${response.body}');
    }
  }

  /// Cria uma nova reserva
  Future<http.Response> book(Booking booking) async {
    final url = Uri.parse('$baseUrl/api/bookings/new-intent');

    final String? token = UserStore().token;
    if (token == null) {
      throw Exception('Token não encontrado. Faça login novamente.');
    }

    final Map<String, dynamic> data = {
      'room_id': booking.roomId,
      'hour_id': booking.hourId,
      'date': booking.day,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
      body: jsonEncode(data),
    );

    return response; // Retorna a resposta completa
  }
}