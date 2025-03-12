import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/registration-service.dart';
import '../stores/user-store.dart';
import '../config/config.dart';

class AlterPassword extends StatefulWidget {
  const AlterPassword({super.key});

  @override
  State<AlterPassword> createState() => _AlterPasswordState();
}

class _AlterPasswordState extends State<AlterPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {

      if (_newPasswordController.text != _confirmNewPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não coincidem.')),
        );
        return;
      }

      setState(() => isLoading = true);

      try {
        final userStore = Provider.of<UserStore>(context, listen: false);
        final user = userStore.currentUser;

        if (user == null) {
          throw Exception('Usuário não encontrado.');
        }

        final registrationService = RegistrationService(Config.baseUrl);
        await registrationService.alter(
          name: user.nome,
          email: user.email,
          password: '', 
          newPassword: _newPasswordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso!')),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao alterar senha: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar senha'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha atual'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Informe a senha atual' : null,
            ),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nova senha'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Informe a nova senha' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _confirmNewPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar nova senha'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Confirme a nova senha' : null,
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
