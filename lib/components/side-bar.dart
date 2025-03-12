import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/user-store.dart';

class SideBar extends StatelessWidget {
  final Function(int)? onNavigate; // Função opcional para navegação

  const SideBar({Key? key, this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserStore>(context).currentUser;
    final isStudent = user?.role == 'STUDENT';

    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Cabeçalho
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Row(
                  children: [
                    const Text(
                      'UTFPR - CM || ReservAi',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 1,
              ),
              // Menu de navegação
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home Page'),
                onTap: () {
                  onNavigate?.call(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_list_rounded),
                title: const Text('Salas Cadastradas'),
                onTap: () {
                  onNavigate?.call(1); 
                },
              ),
              if (!isStudent) ...[
                ListTile(
                  leading: const Icon(Icons.approval_rounded),
                  title: const Text('Aprovar Reservas'),
                  onTap: () {
                    onNavigate?.call(3);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.room_preferences_rounded),
                title: const Text('Reservar Sala'),
                onTap: () {
                    onNavigate?.call(4);
                  },
              ),
            ],
          ),
          // Botão de Sair
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              leading: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmar saída'),
                      content: const Text('Tem certeza que deseja desconectar?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancelar'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Fecha o modal
                          },
                        ),
                        TextButton(
                          child: const Text('Sim'),
                          onPressed: () {
                            // Limpa as informações do usuário e token no UserStore
                            final userStore = Provider.of<UserStore>(context, listen: false);
                            userStore.clearUser(); // Limpa o usuário e token

                            Navigator.of(context).pushReplacementNamed('/login'); // Redireciona para a tela de login
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}