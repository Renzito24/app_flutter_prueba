import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/attendance_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance_service.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }

    return StreamBuilder<List<AttendanceModel>>(
      stream: AttendanceService().getAttendanceByUser(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Sin registros de asistencia'),
              ],
            ),
          );
        }

        final attendances = snapshot.data!;

        return ListView.builder(
          itemCount: attendances.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final a = attendances[index];
            final date =
                '${a.date.day.toString().padLeft(2, '0')}/'
                '${a.date.month.toString().padLeft(2, '0')}/'
                '${a.date.year}';

            final checkIn = a.checkIn != null
                ? '${a.checkIn!.hour.toString().padLeft(2, '0')}:'
                  '${a.checkIn!.minute.toString().padLeft(2, '0')}'
                : '--';

            final checkOut = a.checkOut != null
                ? '${a.checkOut!.hour.toString().padLeft(2, '0')}:'
                  '${a.checkOut!.minute.toString().padLeft(2, '0')}'
                : '--';

            final hours = a.workedHours != null
                ? '${a.workedHours!.toStringAsFixed(1)}h'
                : '--';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: a.status == 'completed'
                      ? Colors.green.withValues(alpha: 0.2)
                      : a.status == 'checked_in'
                          ? Colors.orange.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                  child: Icon(
                    a.status == 'completed'
                        ? Icons.check_circle
                        : a.status == 'checked_in'
                            ? Icons.access_time
                            : Icons.pending,
                    color: a.status == 'completed'
                        ? Colors.green
                        : a.status == 'checked_in'
                            ? Colors.orange
                            : Colors.grey,
                  ),
                ),
                title: Text(date),
                subtitle: Text('In: $checkIn  Out: $checkOut'),
                trailing: Text(
                  hours,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: a.status == 'completed'
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
