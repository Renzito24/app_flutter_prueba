import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/medical_document_model.dart';
import '../../services/medical_document_service.dart';

class MedicalDocumentsViewScreen extends StatelessWidget {
  const MedicalDocumentsViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documentos Médicos')),
      body: StreamBuilder<List<MedicalDocumentModel>>(
        stream: MedicalDocumentService().getAllDocuments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Sin documentos médicos'));
          }

          final docs = snapshot.data!;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: ListTile(
                  leading: Icon(
                    doc.fileType == 'pdf'
                        ? Icons.picture_as_pdf
                        : Icons.image,
                    color: doc.fileType == 'pdf'
                        ? Colors.red
                        : Colors.blue,
                  ),
                  title: Text('Usuario: ${doc.userId}'),
                  subtitle: Text(
                    'Tipo: ${doc.fileType.toUpperCase()}  '
                    'Estado: ${doc.status}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: doc.fileUrl.isNotEmpty
                        ? () => launchUrl(Uri.parse(doc.fileUrl))
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
