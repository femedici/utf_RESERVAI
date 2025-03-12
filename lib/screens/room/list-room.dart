import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importe o Provider
import '../../models/room.dart';
import '../../components/background-container.dart';
import '../../services/room-service.dart';
import 'create-room.dart';
import '../../stores/user-store.dart'; // Importe o UserStore

class ListRooms extends StatefulWidget {
  const ListRooms({super.key});

  @override
  _ListRoomsState createState() => _ListRoomsState();
}

class _ListRoomsState extends State<ListRooms> {
  List<Room> _rooms = [];
  bool _isLoading = true;
  String? _errorMessage;

  final RoomService _roomService = RoomService('http://localhost:3000'); 

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final rooms = await _roomService.fetchRooms();
      setState(() {
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar as salas: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> handleDeleteRoom(Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Deseja deletar a sala?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Deletar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _roomService.deleteRoom(room.id);
        setState(() {
          _rooms.remove(room);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sala deletada com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar sala: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserStore>(context).currentUser; // Acesse o usuário atual
    
    final isAdmin = user?.role == 'ADMIN'; // Apenas ADMIN pode editar/excluir/criar salas

    return Scaffold(
      body: BackgroundContainer(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 8,
                                height: 100,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      room.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: room.informations.entries.map((entry) {
                                        return Text(
                                          '${entry.key}: ${entry.value}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'Entrada: ${room.opening_hour}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Saída: ${room.closing_hour}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isAdmin) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateRooms(
                                          room: room,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => handleDeleteRoom(room),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      // Botão flutuante para adicionar uma nova sala
      floatingActionButton: isAdmin
      ? FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateRooms(),
              ),
            );
          },
          backgroundColor: Colors.yellow, // Cor de fundo amarela
          child: const Icon(
            Icons.add,
            color: Colors.black, // Ícone preto
            size: 32, // Tamanho do ícone
          ),
          elevation: 8, // Sombra do botão
        )
      : null, // Se não for ADMIN, o botão não será exibido
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Posição do botão
    );
  }
}