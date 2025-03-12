import 'user.dart'; // Importando o modelo User
import 'room.dart'; // Importando o modelo Room

//------------------------------------------------
//  MODELO DE RESERVA (BOOKING)
//------------------------------------------------

class Booking {
  final int? id;
  final int roomId;
  final int hourId;
  final int? userId;
  final String day;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? state;
  final String? approvedAt;
  final String? rejectedAt;
  final String? canceledAt;
  final Hour? hour;
  final Room? room;
  final User? user;

  Booking({
    this.id,
    required this.roomId,
    required this.hourId,
    this.userId,
    required this.day,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.state,
    this.approvedAt,
    this.rejectedAt,
    this.canceledAt,
    this.hour,
    this.room,
    this.user,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      hourId: json['hour_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      day: json['day'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
      state: json['state'] ?? '',
      approvedAt: json['approved_at'],
      rejectedAt: json['rejected_at'],
      canceledAt: json['canceled_at'],
      hour: Hour.fromJson(json['hour'] ?? {}),
      room: Room.fromJson(json['room'] ?? {}),
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'hour_id': hourId,
      'user_id': userId,
      'day': day,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'state': state,
      'approved_at': approvedAt,
      'rejected_at': rejectedAt,
      'canceled_at': canceledAt,
    };
  }
}

//------------------------------------------------
//  MODELO DE HORÁRIO (HOUR)
//------------------------------------------------

class Hour {
  final int id;
  final int weekDay;
  final String opening;
  final String closing;

  Hour({
    required this.id,
    required this.weekDay,
    required this.opening,
    required this.closing,
  });

  factory Hour.fromJson(Map<String, dynamic> json) {
    return Hour(
      id: json['id'] ?? 0,
      weekDay: json['week_day'] ?? 0,
      opening: json['opening'] ?? '00:00:00',
      closing: json['closing'] ?? '00:00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_day': weekDay,
      'opening': opening,
      'closing': closing,
    };
  }
}