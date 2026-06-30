import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/report_service.dart';

const _categories = [
  'Todas',
  'Construcción',
  'Personal Doméstico',
  'Gastronomía',
  'Niñera',
  'Jardinería',
  'Administrativo',
  'Otro',
];

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService _service = ReportService();
  final DateFormat _df = DateFormat('yyyy-MM-dd');

  DateTime _start = DateTime.now().subtract(const Duration(days: 30));
  DateTime _end = DateTime.now();
  String _categoryFilter = 'Todas';
  List<Map<String, dynamic>> _reports = [];
  bool _loading = false;

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    try {
      _reports = await _service.getGeneralReport(
        start: _start,
        end: _end,
        category: _categoryFilter == 'Todas' ? null : _categoryFilter,
      );
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

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _start, end: _end),
    );
    if (range != null) {
      setState(() {
        _start = range.start;
        _end = range.end;
      });
      _loadReports();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  '${_df.format(_start)} - ${_df.format(_end)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _categoryFilter,
                  items: _categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _categoryFilter = v);
                    _loadReports();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                    ? const Center(child: Text('Sin datos'))
                    : ListView.builder(
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          final r = _reports[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: ListTile(
                              title: Text(r['name'] ?? ''),
                              subtitle: Text(
                                'Asistencias: ${r['attendanceCount']}  '
                                'Horas: ${r['totalHours']}  '
                                'Ausencias: ${r['absences']}',
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
