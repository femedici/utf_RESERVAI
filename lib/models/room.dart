//------------------------------------------------
//  MODELO DE SALA
//------------------------------------------------

class Room {
  final int id;
  final String name;
  final Map<String, dynamic> informations; // Representa o campo Record
  final String opening_hour; // Alterado para String no formato "HH:mm"
  final String closing_hour; // Alterado para String no formato "HH:mm"

  Room({
    required this.id,
    required this.name,
    required this.informations,
    required this.opening_hour,
    required this.closing_hour,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      informations: json['informations'] ?? {},
      opening_hour: json['opening_hour'] ?? '00:00', // Recebe no formato "HH:mm"
      closing_hour: json['closing_hour'] ?? '00:00', // Recebe no formato "HH:mm"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'informations': informations,
      'opening_hour': opening_hour, // Enviado no formato "HH:mm"
      'closing_hour': closing_hour, // Enviado no formato "HH:mm"
    };
  }
}
