import 'package:flutter/material.dart';

import '../../models/workplace_model.dart';
import '../../services/workplace_service.dart';

class WorkplaceManagementScreen extends StatefulWidget {
  const WorkplaceManagementScreen({super.key});

  @override
  State<WorkplaceManagementScreen> createState() =>
      _WorkplaceManagementScreenState();
}

class _WorkplaceManagementScreenState
    extends State<WorkplaceManagementScreen> {
  final WorkplaceService _service = WorkplaceService();

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => _WorkplaceFormDialog(
        onSave: (data) async {
          await _service.createWorkplace(
            name: data['name']!,
            address: data['address']!,
            latitude: data['latitude']!,
            longitude: data['longitude']!,
            allowedRadius: data['allowedRadius']!,
          );
        },
      ),
    );
  }

  void _showEditDialog(WorkplaceModel workplace) {
    showDialog(
      context: context,
      builder: (_) => _WorkplaceFormDialog(
        workplace: workplace,
        onSave: (data) async {
          await _service.updateWorkplace(
            workplace.id,
            name: data['name']!,
            address: data['address']!,
            latitude: data['latitude']!,
            longitude: data['longitude']!,
            allowedRadius: data['allowedRadius']!,
          );
        },
      ),
    );
  }

  Future<void> _toggleActive(WorkplaceModel workplace) async {
    await _service.toggleActive(workplace.id, !workplace.active);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Lugares'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<WorkplaceModel>>(
        stream: _service.getAllWorkplaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay lugares de trabajo'));
          }

          final workplaces = snapshot.data!;

          return ListView.builder(
            itemCount: workplaces.length,
            itemBuilder: (context, index) =>
                _buildWorkplaceTile(workplaces[index]),
          );
        },
      ),
    );
  }

  Widget _buildWorkplaceTile(WorkplaceModel workplace) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: workplace.active
              ? Colors.orange.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          child: Icon(
            Icons.business,
            color: workplace.active ? Colors.orange : Colors.grey,
          ),
        ),
        title: Text(workplace.name),
        subtitle: Text(
          'Radio: ${workplace.allowedRadius}m',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDialog(workplace);
            } else if (value == 'toggle') {
              _toggleActive(workplace);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: ListTile(
                leading: Icon(
                  workplace.active ? Icons.block : Icons.check_circle,
                ),
                title:
                    Text(workplace.active ? 'Desactivar' : 'Activar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkplaceFormDialog extends StatefulWidget {
  final WorkplaceModel? workplace;
  final Function(Map<String, dynamic>) onSave;

  const _WorkplaceFormDialog({this.workplace, required this.onSave});

  @override
  State<_WorkplaceFormDialog> createState() =>
      _WorkplaceFormDialogState();
}

class _WorkplaceFormDialogState extends State<_WorkplaceFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _latController;
  late final TextEditingController _lonController;
  late final TextEditingController _radiusController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final w = widget.workplace;
    _nameController = TextEditingController(text: w?.name ?? '');
    _addressController = TextEditingController(text: w?.address ?? '');
    _latController =
        TextEditingController(text: w?.latitude.toString() ?? '');
    _lonController =
        TextEditingController(text: w?.longitude.toString() ?? '');
    _radiusController =
        TextEditingController(text: w?.allowedRadius.toString() ?? '100');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.workplace != null;

    return AlertDialog(
      title: Text(isEdit ? 'Editar Lugar' : 'Nuevo Lugar'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration:
                  const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            TextField(
              controller: _latController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Latitud'),
            ),
            TextField(
              controller: _lonController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Longitud'),
            ),
            TextField(
              controller: _radiusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Radio permitido (metros)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  setState(() => _loading = true);
                  await widget.onSave({
                    'name': _nameController.text.trim(),
                    'address': _addressController.text.trim(),
                    'latitude':
                        double.parse(_latController.text.trim()),
                    'longitude':
                        double.parse(_lonController.text.trim()),
                    'allowedRadius': double.parse(
                      _radiusController.text.trim(),
                    ),
                  });
                  if (!context.mounted) return;
                  setState(() => _loading = false);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? 'Lugar actualizado'
                            : 'Lugar creado',
                      ),
                    ),
                  );
                },
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
