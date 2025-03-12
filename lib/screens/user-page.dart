import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/config.dart';
import '../models/user.dart';
import '../services/registration-service.dart';
import '../stores/user-store.dart';
import '../components/background-container.dart';
import '../components/alter-password.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserStore>(context).currentUser;

    return BackgroundContainer(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, size: 80),
              const SizedBox(height: 20),
              if (user != null) ...[
                Text('${user.role}', style: const TextStyle(fontSize: 12)),
                Text('${user.nome}', style: const TextStyle(fontSize: 24,fontWeight: FontWeight.bold, color: Colors.black87,)),
                Text('Email: ${user.email}', style: const TextStyle(fontSize: 16)),
                Text('RA: ${user.ra}', style: const TextStyle(fontSize: 16)),
              ] else
                const Text('Usuário não encontrado.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => const ChangeProfileForm(),
                  );
                },
                child: const Text('Editar perfil'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => const AlterPassword(),
                  );
                },
                child: const Text('Alterar senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeProfileForm extends StatefulWidget {
  const ChangeProfileForm({super.key});

  @override
  State<ChangeProfileForm> createState() => _ChangeProfileFormState();
}

class _ChangeProfileFormState extends State<ChangeProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _raController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserStore>(context, listen: false).currentUser;

    if (user != null) {
      _nameController.text = user.nome;
      _emailController.text = user.email;
      _raController.text = user.ra ?? '';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);
      try {
        final user = Provider.of<UserStore>(context, listen: false).currentUser;
        final registrationService = RegistrationService(Config.baseUrl);

        if (user != null) {
          await registrationService.alter(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );

          Provider.of<UserStore>(context, listen: false).setUser(
            user.copyWith(
              nome: _nameController.text,
              email: _emailController.text,
              ra: _raController.text,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil atualizado com sucesso.')),
          );
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar perfil'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Informe um email' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _raController,
              decoration: const InputDecoration(labelText: 'RA'),
              readOnly: true, // Impede a edição do RA
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha atual'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Informe a senha atual' : null,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _submitForm,
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text('Salvar'),
        ),
      ],
    );
  }
}