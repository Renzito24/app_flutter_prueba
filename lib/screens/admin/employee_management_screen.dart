import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../models/workplace_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/employee_service.dart';
import '../../services/workplace_service.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState
    extends State<EmployeeManagementScreen> {
  final EmployeeService _service = EmployeeService();
  final TextEditingController _searchController =
      TextEditingController();
  List<UserModel> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _searching = false;
      });
      return;
    }

    setState(() => _searching = true);
    final results = await _service.searchEmployees(query);
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  Future<void> _toggleActive(UserModel employee) async {
    await _service.toggleActive(employee.uid, !employee.active);
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => _EmployeeFormDialog(
        onSave: (data) async {
          final authProvider = context.read<AuthProvider>();
          await authProvider.register(
            email: data['email']!,
            password: data['dni']!,
            name: data['name']!,
            lastname: data['lastname']!,
            dni: data['dni']!,
            phone: data['phone']!,
            address: data['address']!,
            category: data['category']!,
            workplaceId: data['workplaceId'],
          );
        },
      ),
    );
  }

  void _showEditDialog(UserModel employee) {
    showDialog(
      context: context,
      builder: (_) => _EmployeeFormDialog(
        employee: employee,
        onSave: (data) async {
          await _service.updateEmployee(
            employee.uid,
            name: data['name']!,
            lastname: data['lastname']!,
            dni: data['dni']!,
            email: data['email']!,
            phone: data['phone']!,
            address: data['address']!,
            category: data['category']!,
            workplaceId: data['workplaceId'],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Empleados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar empleado...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : _buildEmployeeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return const Center(child: Text('Sin resultados'));
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) =>
          _buildEmployeeTile(_results[index]),
    );
  }

  Widget _buildEmployeeList() {
    return StreamBuilder<List<UserModel>>(
      stream: _service.getAllEmployees(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay empleados'));
        }

        final employees = snapshot.data!;

        return ListView.builder(
          itemCount: employees.length,
          itemBuilder: (context, index) =>
              _buildEmployeeTile(employees[index]),
        );
      },
    );
  }

  Widget _buildEmployeeTile(UserModel employee) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              employee.active ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
          child: Icon(
            employee.active ? Icons.person : Icons.person_off,
            color: employee.active ? Colors.green : Colors.red,
          ),
        ),
        title: Text(employee.fullName),
        subtitle: Text(
          '${employee.dni} - ${employee.category}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDialog(employee);
            } else if (value == 'toggle') {
              _toggleActive(employee);
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
                  employee.active ? Icons.block : Icons.check_circle,
                ),
                title: Text(employee.active ? 'Desactivar' : 'Activar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeFormDialog extends StatefulWidget {
  final UserModel? employee;
  final Function(Map<String, String?>) onSave;

  const _EmployeeFormDialog({this.employee, required this.onSave});

  @override
  State<_EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

const _categories = [
  'Construcción',
  'Personal Doméstico',
  'Gastronomía',
  'Niñera',
  'Jardinería',
  'Administrativo',
  'Otro',
];

class _EmployeeFormDialogState extends State<_EmployeeFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _lastnameController;
  late final TextEditingController _dniController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  String? _selectedCategory;
  String? _selectedWorkplaceId;
  List<WorkplaceModel> _workplaces = [];
  bool _loading = false;
  bool _loadingWorkplaces = true;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _nameController = TextEditingController(text: e?.name ?? '');
    _lastnameController = TextEditingController(text: e?.lastname ?? '');
    _dniController = TextEditingController(text: e?.dni ?? '');
    _emailController = TextEditingController(text: e?.email ?? '');
    _phoneController = TextEditingController(text: e?.phone ?? '');
    _addressController = TextEditingController(text: e?.address ?? '');
    _selectedCategory = e?.category;
    _loadWorkplaces();
  }

  Future<void> _loadWorkplaces() async {
    final workplaces = await WorkplaceService().getActiveWorkplaces();
    if (!mounted) return;
    setState(() {
      _workplaces = workplaces;
      _loadingWorkplaces = false;
      if (widget.employee?.workplaceId != null) {
        _selectedWorkplaceId = widget.employee!.workplaceId;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.employee != null;

    return AlertDialog(
      title: Text(isEdit ? 'Editar Empleado' : 'Nuevo Empleado'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _lastnameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: _dniController,
              decoration: const InputDecoration(labelText: 'DNI'),
              enabled: !isEdit,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: _categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            const SizedBox(height: 8),
            _loadingWorkplaces
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<String>(
                    initialValue: _selectedWorkplaceId,
                    decoration: const InputDecoration(
                      labelText: 'Lugar de trabajo',
                    ),
                    items: _workplaces.map((w) {
                      return DropdownMenuItem(
                        value: w.id,
                        child: Text('${w.name} - ${w.address}'),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => _selectedWorkplaceId = v),
                  ),
            if (!isEdit)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Contraseña inicial: DNI',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
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
                    'lastname': _lastnameController.text.trim(),
                    'dni': _dniController.text.trim(),
                    'email': _emailController.text.trim(),
                    'phone': _phoneController.text.trim(),
                    'address': _addressController.text.trim(),
                    'category': _selectedCategory ?? '',
                    'workplaceId': _selectedWorkplaceId,
                  });
                  if (!context.mounted) return;
                  setState(() => _loading = false);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? 'Empleado actualizado'
                            : 'Empleado creado (password: DNI)',
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
