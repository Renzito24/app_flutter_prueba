import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/report_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ReportService().getDashboardStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stats = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              (context as Element).markNeedsBuild();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCard(
                  context,
                  icon: Icons.people,
                  title: 'Total Empleados',
                  value: '${stats['totalEmployees']}',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildCard(
                  context,
                  icon: Icons.person,
                  title: 'Empleados Activos',
                  value: '${stats['activeEmployees']}',
                  color: const Color(0xFF22C55E),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  context,
                  icon: Icons.check_circle,
                  title: 'Presentes Hoy',
                  value: '${stats['present']}',
                  color: Colors.teal,
                ),
                const SizedBox(height: 12),
                _buildCard(
                  context,
                  icon: Icons.cancel,
                  title: 'Ausentes Hoy',
                  value: '${stats['absent']}',
                  color: const Color(0xFFEF4444),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  context,
                  icon: Icons.business,
                  title: 'Lugares Activos',
                  value: '${stats['activeWorkplaces']}',
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  context,
                  icon: Icons.description,
                  title: 'Docs. Médicos',
                  value: '${stats['employeesWithMedicalDocs']}',
                  color: Colors.purple,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Actividad Reciente'),
                const SizedBox(height: 12),
                _buildRecentActivity(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRecentActivity() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendances')
          .orderBy('date', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin actividad reciente'),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _buildActivityCard(context, data);
          }).toList(),
        );
      },
    );
  }

  Widget _buildActivityCard(BuildContext context, Map<String, dynamic> data) {
    final userId = data['userId'] as String? ?? '';
    final date = (data['date'] as dynamic)?.toDate();
    final checkIn = (data['checkIn'] as dynamic)?.toDate();
    final checkOut = (data['checkOut'] as dynamic)?.toDate();
    final status = data['status'] as String? ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, userSnap) {
        String userName = 'Usuario #${userId.length > 6 ? userId.substring(0, 6) : userId}';
        if (userSnap.hasData && userSnap.data!.exists) {
          final userData = userSnap.data!.data() as Map<String, dynamic>?;
          if (userData != null) {
            final name = userData['name'] as String? ?? '';
            final lastname = userData['lastname'] as String? ?? '';
            if (name.isNotEmpty || lastname.isNotEmpty) {
              userName = '$name $lastname';
            }
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: status == 'completed'
                  ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                  : const Color(0xFFF59E0B).withValues(alpha: 0.15),
              child: Icon(
                status == 'completed' ? Icons.check : Icons.access_time,
                color: status == 'completed'
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFF59E0B),
              ),
            ),
            title: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${date != null ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}' : ''}'
              ' - Ingreso: ${checkIn != null ? '${checkIn.hour.toString().padLeft(2, '0')}:${checkIn.minute.toString().padLeft(2, '0')}' : '-'}'
              ' | Egreso: ${checkOut != null ? '${checkOut.hour.toString().padLeft(2, '0')}:${checkOut.minute.toString().padLeft(2, '0')}' : '-'}',
            ),
            trailing: Text(
              status == 'completed' ? 'Completo' : 'En curso',
              style: TextStyle(
                color: status == 'completed'
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFF59E0B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
