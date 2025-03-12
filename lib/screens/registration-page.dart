import 'package:flutter/material.dart';
import '../services/registration-service.dart';
import 'package:provider/provider.dart';
import '../config/config.dart';
import '../stores/user-store.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController raController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RegistrationService registrationService = RegistrationService(Config.baseUrl);
  bool isLoading = false;
  String selectedRole = 'STUDENT';

  void onRegisterPressed() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('As senhas não correspondem.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await registrationService.register(
        name: nameController.text,
        email: emailController.text,
        ra: selectedRole == 'STUDENT' ? raController.text : "",
        password: passwordController.text,
        role: selectedRole,
      );

      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Usuário criado com sucesso'),
            content: const Text('Você será redirecionado para a tela de login.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  final userStore = Provider.of<UserStore>(context, listen: false);
                  userStore.clearUser();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/utfpr_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'images/logo_reservai.png',
                      width: 200,
                      height: 120,
                    ),
                    SizedBox(height: 20),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(10), // Borda arredondada
                      fillColor: Colors.white, // Fundo branco quando selecionado
                      borderColor: Colors.grey, // Cor da borda
                      selectedBorderColor: const Color.fromARGB(255, 93, 42, 160), // Cor da borda quando selecionado
                      selectedColor: const Color.fromARGB(255, 93, 42, 160), // Cor do texto quando selecionado
                      color: Colors.black, // Cor do texto padrão
                      isSelected: [selectedRole == 'STUDENT', selectedRole == 'SERVANT'],
                      onPressed: (index) {
                        setState(() {
                          selectedRole = index == 0 ? 'STUDENT' : 'SERVANT';
                        });
                      },
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Text('Aluno'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Text('Servidor'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: selectedRole == 'STUDENT' ? buildStudentForm() : buildServantForm(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStudentForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTextField(nameController, 'Nome'),
        buildTextField(emailController, 'Email'),
        buildTextField(raController, 'RA'),
        buildTextField(passwordController, 'Senha', obscureText: true),
        buildTextField(confirmPasswordController, 'Confirmar Senha', obscureText: true),
        SizedBox(height: 20),
        isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: onRegisterPressed,
                child: Text('Registrar'),
              ),
        TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text('Já tem uma conta? Voltar ao login'),
                    ),
      ],
    );
  }

  Widget buildServantForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTextField(nameController, 'Nome'),
        buildTextField(emailController, 'Email'),
        buildTextField(passwordController, 'Senha', obscureText: true),
        buildTextField(confirmPasswordController, 'Confirmar Senha', obscureText: true),
        SizedBox(height: 20),
        isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: onRegisterPressed,
                child: Text('Registrar'),
              ),
              TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text('Já tem uma conta? Voltar ao login'),
                    ),
      ],
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        obscureText: obscureText,
      ),
    );
  }
}
