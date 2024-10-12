import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentMortalityReportScreen extends StatefulWidget {
  @override
  _IncidentMortalityReportScreenState createState() => _IncidentMortalityReportScreenState();
}

class _IncidentMortalityReportScreenState extends State<IncidentMortalityReportScreen> {
  String? _selectedAnimalId;
  final TextEditingController _incidentDescriptionController = TextEditingController();
  final TextEditingController _mortalityReasonController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Future<void> _reportIncident() async {
    if (_selectedAnimalId == null || _incidentDescriptionController.text.isEmpty || _dateController.text.isEmpty) {
      _showAlertDialog('Por favor, complete todos los campos.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('incidents').add({
        'animalId': _selectedAnimalId,
        'description': _incidentDescriptionController.text,
        'date': _dateController.text,
      });

      _showAlertDialog('Incidencia reportada con éxito.');
      _clearFields();
    } catch (e) {
      _showAlertDialog('Error al reportar la incidencia.');
    }
  }

  Future<void> _reportMortality() async {
    if (_selectedAnimalId == null || _mortalityReasonController.text.isEmpty || _dateController.text.isEmpty) {
      _showAlertDialog('Por favor, complete todos los campos.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('mortality').add({
        'animalId': _selectedAnimalId,
        'reason': _mortalityReasonController.text,
        'date': _dateController.text,
      });

      _showAlertDialog('Mortalidad reportada con éxito.');
      _clearFields();
    } catch (e) {
      _showAlertDialog('Error al reportar la mortalidad.');
    }
  }

  void _clearFields() {
    setState(() {
      _selectedAnimalId = null;
      _incidentDescriptionController.clear();
      _mortalityReasonController.clear();
      _dateController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes de Incidencias y Mortalidad'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('animales').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los animales.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No hay animales registrados.'));
                }

                final animals = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: _selectedAnimalId,
                  hint: Text('Seleccione un Animal'),
                  items: animals.map((animal) {
                    return DropdownMenuItem<String>(
                      value: animal.id,
                      child: Text(animal['Nombre']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAnimalId = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Animal',
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _incidentDescriptionController,
              decoration: InputDecoration(labelText: 'Descripción de la Incidencia'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _mortalityReasonController,
              decoration: InputDecoration(labelText: 'Razón de Mortalidad'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Fecha (DD/MM/AAAA)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _reportIncident,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Reportar Incidencia'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _reportMortality,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Reportar Mortalidad'),
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
