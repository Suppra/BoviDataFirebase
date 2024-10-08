import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintsSuggestionsScreen extends StatefulWidget {
  @override
  _ComplaintsSuggestionsScreenState createState() => _ComplaintsSuggestionsScreenState();
}

class _ComplaintsSuggestionsScreenState extends State<ComplaintsSuggestionsScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _submitComplaintOrSuggestion() async {
    try {
      await FirebaseFirestore.instance.collection('complaints_suggestions').add({
        'subject': _subjectController.text,
        'description': _descriptionController.text,
        'date': DateTime.now().toIso8601String(),
      });

      _showAlertDialog('Queja o sugerencia enviada con éxito.');
    } catch (e) {
      _showAlertDialog('Error al enviar la queja o sugerencia.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quejas y Sugerencias'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: 'Asunto'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitComplaintOrSuggestion,
              child: Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Información'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
