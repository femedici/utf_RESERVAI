import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de datas
import '../../services/booking-service.dart'; // Importa o serviço de reservas
import '../../services/room-service.dart'; // Importa o serviço de salas
import '../../models/room.dart'; // Importa a classe Room
import '../../models/booking.dart'; // Importa a classe Hour
import '../../config/config.dart';

class CreateBooking extends StatefulWidget {
  const CreateBooking({Key? key}) : super(key: key);

  @override
  _CreateBookingState createState() => _CreateBookingState();
}

class _CreateBookingState extends State<CreateBooking> {
  final BookingService _bookingService = BookingService(Config.baseUrl);
  final RoomService _roomService = RoomService(Config.baseUrl);
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  int _currentStep = 0; // Controla a etapa atual do formulário
  Room? _selectedRoom; // Sala selecionada
  Hour? _selectedHour; // Horário selecionado
  DateTime? _selectedDate; // Data selecionada
  List<Room> _rooms = []; // Lista de salas disponíveis
  List<Hour> _hours = []; // Lista de horários disponíveis

  @override
  void initState() {
    super.initState();
    _fetchRooms(); // Carrega as salas ao iniciar
  }

  // Carrega a lista de salas
  Future<void> _fetchRooms() async {
    try {
      final rooms = await _roomService.fetchRooms();
      setState(() {
        _rooms = rooms;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar salas: $e')),
      );
    }
  }

  // Carrega a lista de horários para a sala selecionada
  Future<void> _fetchHours() async {
    if (_selectedRoom == null) return;

    try {
      final hours = await _bookingService.listTimeSlotsFromRoom(_selectedRoom!);
      setState(() {
        _hours = hours;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar horários: $e')),
      );
    }
  }

  // Formata o horário para exibição (ex: 08:00:00 -> 08h)
  String _formatTime(String time) {
    final timeParts = time.split(':');
    if (timeParts.length >= 2) {
      return '${timeParts[0]}h';
    }
    return time; // Caso o formato não seja o esperado
  }

  // Formata o intervalo de horários (ex: 08:00:00 - 09:00:00 -> 08h às 09h)
  String _formatTimeSlot(Hour hour) {
    final startTime = _formatTime(hour.opening);
    final endTime = _formatTime(hour.closing);
    return '$startTime às $endTime';
  }

  // Avança para a próxima etapa
  void _nextStep() {
    if (_currentStep == 0 && _selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma sala para continuar.')),
      );
      return;
    }
    if (_currentStep == 1 && _selectedHour == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um horário para continuar.')),
      );
      return;
    }
    if (_currentStep == 2 && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma data para continuar.')),
      );
      return;
    }

    setState(() {
      _currentStep++;
    });
  }

  // Volta para a etapa anterior
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // Confirma a reserva
Future<void> _confirmBooking() async {
  if (_selectedRoom == null || _selectedHour == null || _selectedDate == null) {
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Efetuar Reserva'),
      content: const Text('Deseja confirmar a reserva?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
  try {
    // Formata a data no padrão YYYY-MM-DD
    final formattedDate =
        '${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    // Faz a requisição para criar a reserva
    final response = await _bookingService.book(Booking(
      roomId: _selectedRoom!.id,
      hourId: _selectedHour!.id,
      day: formattedDate, // Usa a data formatada
    ));

    // Verifica se a resposta foi bem-sucedida (status 201)
    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva confirmada com sucesso!')),
      );

    } else {
      // Se o status não for 201, exibe uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao confirmar reserva: ${response.body}')),
      );
    }
  } catch (e) {
    // Captura e exibe erros inesperados
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao confirmar reserva: $e')),
    );
  }
}
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Reserva'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _previousStep,
        controlsBuilder: (BuildContext context, ControlsDetails details) {
  return Row(
    children: <Widget>[
      TextButton(
        onPressed: details.onStepCancel,
        child: const Text('Voltar'),
      ), // Empurra o próximo para a direita
      if (_currentStep < 2) // Só exibe "Próximo" se não for o último passo
        ElevatedButton(
          onPressed: details.onStepContinue,
          child: const Text('Próximo'),
        ),
    ],
  );
        },
        steps: [
          // Etapa 1: Seleção da Sala
          Step(
            title: const Text('Selecione a Sala'),
            content: _rooms.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return RadioListTile<Room>(
                        title: Text(room.name),
                        value: room,
                        groupValue: _selectedRoom,
                        onChanged: (value) {
                          setState(() {
                            _selectedRoom = value;
                            _fetchHours(); // Carrega os horários da sala selecionada
                          });
                        },
                      );
                    },
                  ),
          ),
          // Etapa 2: Seleção do Horário
          Step(
  title: const Text('Selecione o Horário'),
  content: _hours.isEmpty
      ? const Center(child: Text('Nenhum horário disponível.'))
      : SizedBox(
          height: 400, // Define uma altura máxima para evitar overflow
          child: Scrollbar(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 colunas
                childAspectRatio: 3.5, // Ajuste para melhor visualização
                crossAxisSpacing: 10, // Espaço entre colunas
                mainAxisSpacing: 5, // Espaço entre linhas
              ),
              itemCount: _hours.length,
              itemBuilder: (context, index) {
                final hour = _hours[index];
                return RadioListTile<Hour>(
                  title: Text(_formatTimeSlot(hour)), // Formata o horário
                  value: hour,
                  groupValue: _selectedHour,
                  onChanged: (value) {
                    setState(() {
                      _selectedHour = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
),
          // Etapa 3: Seleção da Data
          Step(
            title: const Text('Selecione a Data'),
            content: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      selectableDayPredicate: (day) {
                        // Permite apenas dias úteis (Segunda a Sexta)
                        return day.weekday >= DateTime.monday && day.weekday <= DateTime.friday;
                      },
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: Text(_selectedDate == null
                      ? 'Selecionar Data'
                      : 'Data Selecionada: ${_dateFormat.format(_selectedDate!)}'),
                ),
                const SizedBox(height: 16),
                if (_selectedDate != null)
                  ElevatedButton(
                    onPressed: _confirmBooking,
                    child: const Text('Confirmar Reserva'),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}