import 'package:flutter/material.dart';
import '../../services/booking-service.dart';
import '../../models/booking.dart';
import '../../components/background-container.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  final BookingService _bookingService =
      BookingService('http://localhost:3000');

  @override
  void initState() {
    super.initState();
    _fetchUserBookings();
  }

  Future<void> _fetchUserBookings() async {
    try {
      final bookings = await _bookingService.fetchUserBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar as reservas: $e';
        _isLoading = false;
      });
    }
  }

  void _showReservaDetailsPopup(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalhes da Reserva'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sala: ${booking.room!.name}'),
              SizedBox(height: 8),
              Text(
                  'Horário: ${booking.hour!.opening} - ${booking.hour!.closing}'),
              SizedBox(height: 8),
              Text('Data: ${booking.createdAt!.split("T")[0]}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o popup de detalhes
                _showCancelConfirmationDialog(
                    context, booking.id!); // Abre o diálogo de confirmação
              },
              child: Text(
                'Cancelar Reserva',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCancelConfirmationDialog(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cancelar Reserva'),
          content: Text('Tem certeza que deseja cancelar esta reserva?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo de confirmação
              },
              child: Text('Não'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o diálogo de confirmação
                try {
                  await _bookingService.cancelBooking(
                      bookingId); // Faz a requisição de cancelamento
                  await _fetchUserBookings(); // Atualiza a lista de reservas
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reserva cancelada com sucesso!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao cancelar a reserva: $e')),
                  );
                }
              },
              child: Text(
                'Sim',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final approvedBookings =
        _bookings.where((booking) => booking.state == "APPROVED").toList();
    final otherBookings =
        _bookings.where((booking) => booking.state != "APPROVED").toList();

    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReservasAgendadas(context, approvedBookings),
              SizedBox(height: 20),
              _buildReservasPendentes(otherBookings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservasAgendadas(BuildContext context, List<Booking> bookings) {
    return _buildReservaCard(
      title: 'Reservas Agendadas',
      children: [
        Divider(color: Colors.grey[400], thickness: 1),
        SizedBox(height: 10),
        if (bookings.isEmpty)
          Center(
            child: Text(
              'Sem reservas agendadas',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        else
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: bookings.map((booking) {
              return InkWell(
                onTap: () {
                  _showReservaDetailsPopup(context, booking);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        booking.room!.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${booking.hour!.opening.split(':').sublist(0, 2).join('h')} - ${booking.hour!.closing.split(':').sublist(0, 2).join('h')}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildReservasPendentes(List<Booking> bookings) {
    return _buildReservaCard(
      title: 'Reservas Pendentes',
      children: [
        Divider(color: Colors.grey[400], thickness: 1),
        SizedBox(height: 10),
        if (bookings.isEmpty)
          Center(
            child: Text(
              'Sem reservas pendentes',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        else
          Column(
            children: bookings.map((booking) {
              Color statusColor;

              switch (booking.state) {
                case "PENDING":
                  statusColor = Colors.yellow;
                  break;
                case "REJECTED":
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(booking.room!.name,
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(booking.state!,
                            style: TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildReservaCard(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          ...children,
        ],
      ),
    );
  }
}
