import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/attendance_model.dart';
import '../../services/attendance_service.dart';

class AttendanceViewScreen extends StatefulWidget {
  const AttendanceViewScreen({super.key});

  @override
  State<AttendanceViewScreen> createState() => _AttendanceViewScreenState();
}

class _AttendanceViewScreenState extends State<AttendanceViewScreen> {
  late DateTime _selectedDate;
  final AttendanceService _attendanceService = AttendanceService();
  Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadUserNames();
  }

  Future<void> _loadUserNames() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    if (!mounted) return;
    setState(() {
      _userNames = {
        for (final doc in snapshot.docs)
          doc.id:
              '${doc.data()['name'] ?? ''} ${doc.data()['lastname'] ?? ''}'.trim(),
      };
    });
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final tomorrow = _selectedDate.add(const Duration(days: 1));
    if (!DateTime(tomorrow.year, tomorrow.month, tomorrow.day).isAfter(todayDate)) {
      setState(() {
        _selectedDate = tomorrow;
      });
    }
  }

  String _formatDate(DateTime d) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${d.day} de ${months[d.month - 1]} de ${d.year}';
  }

  bool get _canGoForward {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return _selectedDate.isBefore(todayDate);
  }

  String _userName(String uid) {
    final name = _userNames[uid];
    if (name != null && name.isNotEmpty) return name;
    return 'Usuario #${uid.length > 6 ? uid.substring(0, 6) : uid}';
  }

  @override
  Widget build(BuildContext context) {
    final startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousDay,
                  tooltip: 'Día anterior',
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(_selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _canGoForward ? _nextDay : null,
                  tooltip: 'Día siguiente',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<AttendanceModel>>(
              key: ValueKey(_selectedDate.toIso8601String()),
              future: _attendanceService.getAttendanceByDateRange(
                start: startOfDay,
                end: endOfDay,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final attendances = snapshot.data ?? [];

                if (attendances.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Sin asistencias registradas este día',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: attendances.length,
                  itemBuilder: (context, index) {
                    final a = attendances[index];
                    final checkIn = a.checkIn != null
                        ? '${a.checkIn!.hour.toString().padLeft(2, '0')}:${a.checkIn!.minute.toString().padLeft(2, '0')}'
                        : '--';
                    final checkOut = a.checkOut != null
                        ? '${a.checkOut!.hour.toString().padLeft(2, '0')}:${a.checkOut!.minute.toString().padLeft(2, '0')}'
                        : '--';

                    final bool isComplete = a.status == 'completed';
                    final bool isCheckedIn = a.status == 'checked_in';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isComplete
                              ? Colors.green.withValues(alpha: 0.2)
                              : isCheckedIn
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.2),
                          child: Icon(
                            isComplete
                                ? Icons.check_circle
                                : isCheckedIn
                                    ? Icons.access_time
                                    : Icons.pending,
                            color: isComplete
                                ? Colors.green
                                : isCheckedIn
                                    ? Colors.orange
                                    : Colors.grey,
                          ),
                        ),
                        title: Text(_userName(a.userId)),
                        subtitle: Text('Entrada: $checkIn  Salida: $checkOut'),
                      ),
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
