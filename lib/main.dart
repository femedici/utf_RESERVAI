import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stores/user-store.dart';
import 'screens/login-page.dart';
import 'screens/main-page.dart';
import 'screens/registration-page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserStore()), // Provedor para o estado do usuário
      ],
      child: MaterialApp(
        title: 'Reserva Ai!',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegistrationPage(),
          '/home': (context) => MainScreen(), // Estrutura principal
        },
      ),
    );
  }
}
