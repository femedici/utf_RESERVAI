import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de datas
import '../../services/room-service.dart'; // Importa o serviço de criação e atualização de sala
import '../../config/config.dart'; // Para obter a URL base
import '../../components/background-container.dart'; // Importa o componente de fundo
import '../../models/room.dart'; // Importa a classe Room

class CreateRooms extends StatefulWidget {
  final Room? room; // Recebe uma sala opcional, se estiver editando

  const CreateRooms({Key? key, this.room}) : super(key: key);

  @override
  _CreateRoomPageState createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRooms> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _instrumentController = TextEditingController();
  final TextEditingController _openingHourController = TextEditingController();
  final TextEditingController _closingHourController = TextEditingController();
  List<String> _instruments = []; // Armazena os instrumentos adicionados
  bool isLoading = false;
  bool isEditMode = false; // Flag para saber se é modo de edição

  @override
  void initState() {
    super.initState();

    // Se houver uma sala recebida via props, configurar o modo de edição
    if (widget.room != null) {
      isEditMode = true;
      _nameController.text = widget.room!.name;
      _instrumentController.text = widget.room!.informations['equipamentos'] ?? '';
      _openingHourController.text = widget.room!.opening_hour;
      _closingHourController.text = widget.room!.closing_hour;

      // Extraímos os instrumentos da sala existente para preencher a lista
      _instruments = widget.room!.informations['equipamentos']?.split(', ') ?? [];
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      try {
        String formatHour(String hour) {
          if (!hour.contains(':')) {
            return hour + ":00"; // Adiciona os segundos
          }
          final parts = hour.split(':');
          // Garante que sempre tenha 2 dígitos nas horas e minutos e 00 segundos
          return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00';
        }

        final roomService = RoomService(Config.baseUrl);

        String openingHourFormatted = formatHour(_openingHourController.text);
        String closingHourFormatted = formatHour(_closingHourController.text);

        // Se estiver em modo de edição, fazemos um update, senão criamos uma nova sala
        if (isEditMode) {
          await roomService.updateRoom(
            id: widget.room!.id,
            name: _nameController.text,
            informations: {'equipamentos': _instruments.join(', ')},
            openingHour: openingHourFormatted,
            closingHour: closingHourFormatted,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sala atualizada com sucesso!')),
          );
        } else {
          await roomService.createRoom(
            name: _nameController.text,
            informations: {'equipamentos': _instruments.join(', ')},
            openingHour: openingHourFormatted,
            closingHour: closingHourFormatted,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sala criada com sucesso!')),
          );
        }

        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao ${isEditMode ? 'atualizar' : 'criar'} sala: $e')),
        );
      }
    }
  }

  void _addInstrument(String instrument) {
    setState(() {
      _instruments.add(instrument);
      _instrumentController.clear();
    });
  }

  void _goToHomePage() {
    Navigator.of(context).pop(); // Navega de volta à página anterior
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // Ícone de seta para voltar
            onPressed: _goToHomePage, // Navega de volta à página anterior
          ),
          title: Text(isEditMode ? 'Editar Sala' : 'Cadastrar Nova Sala'),
          actions: isEditMode
              ? [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _submitForm,
                    tooltip: 'Atualizar Sala',
                  ),
                ]
              : null, // Se não estiver em modo de edição, não exibe ações
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preencha as informações para ${isEditMode ? 'editar' : 'criar'} a sala:',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Sala',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Informe o nome da sala' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _instrumentController,
                        decoration: const InputDecoration(
                          labelText: 'Adicionar Equipamentos',
                          border: OutlineInputBorder(),
                          hintText: 'Digite e pressione Enter',
                        ),
                        onFieldSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _addInstrument(value);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _instruments.map((instrument) {
                          return Chip(
                            label: Text(instrument),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                _instruments.remove(instrument);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _openingHourController,
                        decoration: const InputDecoration(
                          labelText: 'Horário de Abertura (HH:mm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o horário de abertura';
                          }
                          if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                            return 'Formato inválido (use HH:mm)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _closingHourController,
                        decoration: const InputDecoration(
                          labelText: 'Horário de Fechamento (HH:mm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o horário de fechamento';
                          }
                          if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                            return 'Formato inválido (use HH:mm)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  isEditMode ? 'Atualizar Sala' : 'Criar Sala',
                                  style: const TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}