import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'dart:convert';

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
        'date': Timestamp.now(),
      });

      await _sendEmail(
        subject: _subjectController.text,
        description: _descriptionController.text,
      );

      _showAlertDialog('Queja o sugerencia enviada con éxito.');
      _clearFields();
    } catch (e) {
      _showAlertDialog('Error al enviar la queja o sugerencia.');
    }
  }

  Future<void> _sendEmail({required String subject, required String description}) async {
    final clientId = ClientId('YOUR_CLIENT_ID', 'YOUR_CLIENT_SECRET');
    final scopes = [gmail.GmailApi.gmailSendScope];

    await clientViaUserConsent(clientId, scopes, (url) {
      debugPrint('Please go to the following URL and grant access:');
      debugPrint('  => $url');
      debugPrint('');
    }).then((AuthClient client) async {
      final api = gmail.GmailApi(client);
      final message = gmail.Message()
        ..raw = base64Url.encode(utf8.encode('Content-Type: text/plain; charset="UTF-8"\n'
            'MIME-Version: 1.0\n'
            'Content-Transfer-Encoding: 7bit\n'
            'to: cristianfwc@gmail.com\n'
            'from: atencionclientebovidata@gmail.com\n'
            'subject: Nueva Queja o Sugerencia: $subject\n\n'
            'Asunto: $subject\n\nDescripción:\n$description'));

      try {
        await api.users.messages.send(message, 'me');
        debugPrint('Message sent.');
      } catch (e) {
        debugPrint('Message not sent. \n' + e.toString());
      } finally {
        client.close();
      }
    });
  }

  void _clearFields() {
    setState(() {
      _subjectController.clear();
      _descriptionController.clear();
    });
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
}
