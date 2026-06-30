import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/medical_document_service.dart';

class UploadMedicalDocumentScreen extends StatefulWidget {
  const UploadMedicalDocumentScreen({super.key});

  @override
  State<UploadMedicalDocumentScreen> createState() =>
      _UploadMedicalDocumentScreenState();
}

class _UploadMedicalDocumentScreenState
    extends State<UploadMedicalDocumentScreen> {
  final MedicalDocumentService _service = MedicalDocumentService();
  PlatformFile? _selectedFile;
  bool _uploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _uploading = true);

    try {
      final bytes = _selectedFile!.bytes;
      final fileName = _selectedFile!.name;
      final ext = fileName.split('.').last.toLowerCase();

      String fileUrl;

      if (bytes != null) {
        fileUrl = await _service.uploadAndGetUrl(
          userId: user.uid,
          fileName: fileName,
          bytes: bytes,
        );
      } else if (_selectedFile!.path != null) {
        final storageRef = await _service.uploadDocument(
          userId: user.uid,
          filePath: _selectedFile!.path!,
          fileName: fileName,
          fileType: ext,
        );
        fileUrl = storageRef.fileUrl;
      } else {
        throw Exception('No se pudo leer el archivo');
      }

      await _service.saveDocument(
        userId: user.uid,
        fileUrl: fileUrl,
        fileType: ext,
      );

      setState(() => _selectedFile = null);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documento subido exitosamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upload_file,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Subir Documento Médico',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Formatos permitidos: PDF, JPG, PNG',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (_selectedFile != null)
              Card(
                child: ListTile(
                  leading: Icon(
                    _selectedFile!.name.endsWith('.pdf')
                        ? Icons.picture_as_pdf
                        : Icons.image,
                    color: _selectedFile!.name.endsWith('.pdf')
                        ? Colors.red
                        : Colors.blue,
                  ),
                  title: Text(_selectedFile!.name),
                  subtitle: Text(
                    '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        setState(() => _selectedFile = null),
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Seleccionar archivo'),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _selectedFile != null && !_uploading ? _upload : null,
                child: _uploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Subir Documento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
