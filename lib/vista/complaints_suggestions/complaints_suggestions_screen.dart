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
        'date': Timestamp.now(), // Cambiado aquí
      });

      _showAlertDialog('Queja o sugerencia enviada con éxito.');
      _clearFields();
    } catch (e) {
      _showAlertDialog('Error al enviar la queja o sugerencia.');
    }
  }

  void _clearFields() {
    setState(() {
      _subjectController.clear();
      _descriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quejas y Sugerencias', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField('Asunto', _subjectController, 1),
            SizedBox(height: 15),
            _buildTextField('Descripción', _descriptionController, 5),
            SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, int maxLines) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.teal[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitComplaintOrSuggestion,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal[800],
        padding: EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        'Enviar',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Future<void> _showAlertDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Información'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Colors.teal[800])),
          ),
        ],
      ),
    );
  }
}
