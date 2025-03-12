import 'package:flutter/material.dart';
import '../../services/booking-service.dart';
import '../../models/booking.dart';
import '../../components/background-container.dart';

class BookingRequests extends StatefulWidget {
  const BookingRequests({super.key});

  @override
  _BookingRequestsState createState() => _BookingRequestsState();
}

class _BookingRequestsState extends State<BookingRequests> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _filterName = "";
  DateTime? _filterDate;

  final BookingService _bookingService = BookingService('http://localhost:3000');

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final bookings = await _bookingService.fetchBookings();
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

  void _showConfirmationDialog(String action, int bookingId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$action Reserva'),
          content: Text('Deseja realmente $action esta reserva?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  if (action == "Aprovar") {
                    await _bookingService.approveBooking(bookingId);
                  } else if (action == "Rejeitar") {
                    await _bookingService.rejectBooking(bookingId);
                  }
                  await _fetchBookings(); // Atualiza a lista após a ação
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao $action a reserva: $e')),
                  );
                }
              },
              child: Text(action),
            ),
          ],
        );
      },
    );
  }

  String getSafeValue(dynamic data, String key, {String defaultValue = "Desconhecido"}) {
  if (data == null) {
    return defaultValue;
  }

  // Verifica se o objeto é um Map
  if (data is Map) {
    return data[key]?.toString() ?? defaultValue;
  }

  // Verifica se o objeto é uma instância de uma classe e acessa os campos diretamente
  switch (key) {
    case 'name':
      return data.name?.toString() ?? defaultValue;
    case 'email':
      return data.email?.toString() ?? defaultValue;
    case 'ra':
      return data.ra?.toString() ?? defaultValue;
    case 'role':
      return data.role?.toString() ?? defaultValue;
    case 'opening':
      return data.opening?.toString() ?? defaultValue;
    case 'closing':
      return data.closing?.toString() ?? defaultValue;
    case 'week_day':
      return data.weekDay?.toString() ?? defaultValue;
    case 'informations':
      return data.informations?.toString() ?? defaultValue;
    case 'opening_hour':
      return data.openingHour?.toString() ?? defaultValue;
    case 'closing_hour':
      return data.closingHour?.toString() ?? defaultValue;
    default:
      return defaultValue;
  }
}

  @override
  Widget build(BuildContext context) {
    List<Booking> filteredBookings = _bookings.where((booking) {
      bool matchesName = _filterName.isEmpty || booking.room!.name.toLowerCase().contains(_filterName.toLowerCase());
      bool matchesDate = _filterDate == null || booking.createdAt!.split("T")[0] == _filterDate!.toIso8601String().split("T")[0];
      return matchesName && matchesDate;
    }).toList();

    filteredBookings.sort((a, b) => a.state == "PENDING" ? -1 : 1);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: "Filtrar por nome da sala"),
                    onChanged: (value) => setState(() => _filterName = value),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2026),
                    );
                    if (pickedDate != null) {
                      setState(() => _filterDate = pickedDate);
                    }
                  },
                  child: const Text("Selecionar Data"),
                ),
              ],
            ),
          ),
          Expanded(
            child: BackgroundContainer(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredBookings.length,
                          itemBuilder: (context, index) {
                            final booking = filteredBookings[index];
                            Color statusColor;

                            switch (booking.state) {
                              case "PENDING":
                                statusColor = Colors.amber;
                                break;
                              case "APPROVED":
                                statusColor = Colors.green;
                                break;
                              case "REJECTED":
                              case "CANCELED":
                                statusColor = Colors.red;
                                break;
                              default:
                                statusColor = Colors.grey;
                            }

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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${getSafeValue(booking.user, "name")} - ${getSafeValue(booking.room, "name")}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text("Horário: ${getSafeValue(booking.hour, "opening")} - ${getSafeValue(booking.hour, "closing")}"),
                                    Text("Data: ${booking.createdAt!.split("T")[0]}"),
                                    const SizedBox(height: 8),
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
                                        const SizedBox(width: 8),
                                        Text(booking.state!.toUpperCase()),
                                        const Spacer(),
                                        if (booking.state != "APPROVED" || booking.state != "APPROVED") ...[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                                            onPressed: () => _showConfirmationDialog("Aprovar", booking.id!),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.check, color: Colors.black),
                                                SizedBox(width: 4),
                                                Text("Aprovar", style: TextStyle(color: Colors.black)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            onPressed: () => _showConfirmationDialog("Rejeitar", booking.id!),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.close, color: Colors.white),
                                                SizedBox(width: 4),
                                                Text("Rejeitar", style: TextStyle(color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}