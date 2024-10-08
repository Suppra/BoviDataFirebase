import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentVaccineManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Tratamiento o Vacuna'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('animales').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay animales registrados'));
          }

          final animals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: animals.length,
            itemBuilder: (context, index) {
              final animal = animals[index];
              final animalData = animal.data() as Map<String, dynamic>;
              final animalName = animalData['Nombre'] ?? 'Sin nombre';
              final animalId = animalData.containsKey('AnimalID') && animalData['AnimalID'] != null
                  ? animalData['AnimalID']
                  : 'ID no disponible';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(animalName),
                  subtitle: Text('ID: $animalId'),
                  leading: Icon(Icons.pets, color: Colors.teal),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.vaccines, color: Colors.teal),
                        onPressed: () {
                          if (animalId != 'ID no disponible') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VaccineRegistrationScreen(animalId: animalId),
                              ),
                            );
                          } else {
                            _showAlertDialog(context, 'El animal seleccionado no tiene un ID asignado.');
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.medical_services, color: Colors.blue),
                        onPressed: () {
                          if (animalId != 'ID no disponible') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TreatmentRegistrationScreen(animalId: animalId),
                              ),
                            );
                          } else {
                            _showAlertDialog(context, 'El animal seleccionado no tiene un ID asignado.');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
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

// Pantalla para registrar vacunas
class VaccineRegistrationScreen extends StatefulWidget {
  final String animalId;

  VaccineRegistrationScreen({required this.animalId});

  @override
  _VaccineRegistrationScreenState createState() => _VaccineRegistrationScreenState();
}

class _VaccineRegistrationScreenState extends State<VaccineRegistrationScreen> {
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();

  Future<void> _registerVaccine() async {
    if (_vaccineNameController.text.isEmpty || _dateController.text.isEmpty || _doseController.text.isEmpty) {
      _showAlertDialog('Por favor, complete todos los campos.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('vaccines').add({
        'animalId': widget.animalId,
        'vaccineName': _vaccineNameController.text,
        'date': _dateController.text,
        'dose': _doseController.text,
      });

      _showAlertDialog('Vacuna registrada con éxito.');
      _clearFields();
    } catch (e) {
      _showAlertDialog('Error al registrar la vacuna.');
    }
  }

  void _clearFields() {
    setState(() {
      _vaccineNameController.clear();
      _dateController.clear();
      _doseController.clear();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Vacuna para el Animal ${widget.animalId}'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _vaccineNameController,
              decoration: InputDecoration(labelText: 'Nombre de la Vacuna'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _doseController,
              decoration: InputDecoration(labelText: 'Dosis'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Fecha (DD/MM/AAAA)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerVaccine,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Registrar Vacuna'),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla para registrar tratamientos
class TreatmentRegistrationScreen extends StatefulWidget {
  final String animalId;

  TreatmentRegistrationScreen({required this.animalId});

  @override
  _TreatmentRegistrationScreenState createState() => _TreatmentRegistrationScreenState();
}

class _TreatmentRegistrationScreenState extends State<TreatmentRegistrationScreen> {
  final TextEditingController _treatmentNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  Future<void> _registerTreatment() async {
    if (_treatmentNameController.text.isEmpty || _dateController.text.isEmpty || _detailsController.text.isEmpty) {
      _showAlertDialog('Por favor, complete todos los campos.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('treatments').add({
        'animalId': widget.animalId,
        'treatmentName': _treatmentNameController.text,
        'date': _dateController.text,
        'details': _detailsController.text,
      });

      _showAlertDialog('Tratamiento registrado con éxito.');
      _clearFields();
    } catch (e) {
      _showAlertDialog('Error al registrar el tratamiento.');
    }
  }

  void _clearFields() {
    setState(() {
      _treatmentNameController.clear();
      _dateController.clear();
      _detailsController.clear();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Tratamiento para el Animal ${widget.animalId}'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _treatmentNameController,
              decoration: InputDecoration(labelText: 'Nombre del Tratamiento'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(labelText: 'Detalles del Tratamiento'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Fecha (DD/MM/AAAA)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerTreatment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Registrar Tratamiento'),
            ),
          ],
        ),
      ),
    );
  }
}
