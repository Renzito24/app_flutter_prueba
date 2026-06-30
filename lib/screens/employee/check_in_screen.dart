import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/attendance_model.dart';
import '../../models/workplace_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/attendance_service.dart';
import '../../services/workplace_service.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final WorkplaceService _workplaceService = WorkplaceService();

  AttendanceModel? _todayAttendance;
  WorkplaceModel? _workplace;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) return;

      if (user.workplaceId != null) {
        _workplace =
            await _workplaceService.getWorkplace(user.workplaceId!);
      }

      _todayAttendance =
          await _attendanceService.getTodayAttendance(user.uid);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doCheckIn() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    if (_workplace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes un lugar de trabajo asignado.'),
        ),
      );
      return;
    }

    try {
      setState(() => _loading = true);
      await _attendanceService.checkIn(
        userId: user.uid,
        workplace: _workplace!,
      );
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in registrado exitosamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doCheckOut() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    if (_workplace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes un lugar de trabajo asignado.'),
        ),
      );
      return;
    }

    try {
      setState(() => _loading = true);
      await _attendanceService.checkOut(
        userId: user.uid,
        workplace: _workplace!,
      );
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out registrado exitosamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final canCheckIn = _todayAttendance == null;
    final canCheckOut = _todayAttendance != null &&
        _todayAttendance!.checkOut == null;
    final completed = _todayAttendance != null &&
        _todayAttendance!.checkOut != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              completed
                  ? Icons.check_circle
                  : canCheckIn
                      ? Icons.fingerprint
                      : Icons.access_time,
              size: 100,
              color: completed
                  ? Colors.green
                  : canCheckIn
                      ? Colors.blue
                      : Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              completed
                  ? 'Jornada completada'
                  : canCheckIn
                      ? 'Listo para check-in'
                      : 'Check-in realizado',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_workplace != null) ...[
              const SizedBox(height: 8),
              Text(
                'Lugar: ${_workplace!.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (_workplace == null) ...[
              const SizedBox(height: 8),
              Text(
                'Sin lugar de trabajo asignado',
                style: TextStyle(color: Colors.red[400]),
              ),
            ],
            const SizedBox(height: 32),
            if (canCheckIn)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _workplace != null ? _doCheckIn : null,
                  icon: const Icon(Icons.login),
                  label: const Text('Check-In'),
                ),
              ),
            if (canCheckOut)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _workplace != null ? _doCheckOut : null,
                  icon: const Icon(Icons.logout),
                  label: const Text('Check-Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
