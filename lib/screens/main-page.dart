import 'package:flutter/material.dart';
import 'package:produto_front/screens/create-booking.dart';
import '../components/side-bar.dart';
import '../components/custom-app-bar.dart';
import 'home-with-bottom-bar.dart'; // Página que inclui o BottomBar
import 'booking-requests.dart'; // Página que inclui o BottomBar
import 'room/list-room.dart'; // Importa a página de salas cadastradas
import 'room/create-room.dart'; // Importa a página de salas cadastradas
import 'create-booking.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  // Lista de páginas controladas pelo SideBar
  final List<Widget> _pages = [
    HomeWithBottomBar(),
    ListRooms(), 
    CreateRooms(), 
    BookingRequests(),
    CreateBooking(),
  ];

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pop(context); // Fecha o drawer
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background do aplicativo
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/utfpr_background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
          drawer: SideBar(
            onNavigate: _navigateToPage,
          ),
          body: _pages[_currentIndex], // Renderiza a página correspondente
        ),
      ],
    );
  }
}
