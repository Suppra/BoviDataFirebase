import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinationPlanningScreen extends StatefulWidget {
  @override
  _VaccinationPlanningScreenState createState() => _VaccinationPlanningScreenState();
}

class _VaccinationPlanningScreenState extends State<VaccinationPlanningScreen> {
  String? _selectedAnimalId;
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Future<void> _planVaccination() async {
    if (_selectedAnimalId == null || _vaccineNameController.text.isEmpty || _dateController.text.isEmpty) {
      _showAlertDialog('Por favor, complete todos los campos.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('vaccination_plans').add({
        'animalId': _selectedAnimalId,
        'vaccineName': _vaccineNameController.text,
        'date': _dateController.text,
      });

      _showAlertDialog('Vacunación planificada con éxito.');
    } catch (e) {
      _showAlertDialog('Error al planificar la vacunación.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planificación de Vacunación'),
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
              controller: _vaccineNameController,
              decoration: InputDecoration(labelText: 'Nombre de la Vacuna'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Fecha (DD/MM/AAAA)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _planVaccination,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Planificar Vacunación'),
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
