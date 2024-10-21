import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TreatmentVaccineManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tratamientos y Vacunas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: animals.length,
            itemBuilder: (context, index) {
              final animal = animals[index];
              final animalName = animal['Nombre'] ?? 'Sin nombre';
              final animalId = animal['AnimalID'] ?? 'ID no disponible';

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: ListTile(
                  title: Text(animalName, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ID: $animalId'),
                  leading: Icon(Icons.pets, color: Colors.green[800]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconButton(
                        context,
                        Icons.vaccines,
                        'Registrar Vacuna',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VaccineRegistrationScreen(animalId: animalId),
                            ),
                          );
                        },
                      ),
                      _buildIconButton(
                        context,
                        Icons.medical_services,
                        'Registrar Tratamiento',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TreatmentRegistrationScreen(animalId: animalId),
                            ),
                          );
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

  Widget _buildIconButton(BuildContext context, IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.green[800]),
      tooltip: tooltip,
      onPressed: onPressed,
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
  final TextEditingController _doseController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _registerVaccine() async {
    if (_vaccineNameController.text.isEmpty || _doseController.text.isEmpty || _selectedDate == null) {
      _showAlertDialog('Por favor, complete todos los campos.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('vaccines').add({
        'animalId': widget.animalId,
        'vaccineName': _vaccineNameController.text,
        'dose': _doseController.text,
        'date': DateFormat('dd/MM/yyyy').format(_selectedDate!),
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
      _doseController.clear();
      _selectedDate = null;
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
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.green[800])),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Registrar Vacuna', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(_vaccineNameController, 'Nombre de la Vacuna', Icons.vaccines),
            SizedBox(height: 10),
            _buildTextField(_doseController, 'Dosis', Icons.medical_services),
            SizedBox(height: 10),
            ListTile(
              title: Text(_selectedDate == null ? 'Seleccionar Fecha' : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
              trailing: Icon(Icons.calendar_today, color: Colors.green[800]),
              onTap: _selectDate,
            ),
            SizedBox(height: 20),
            _buildSubmitButton('Registrar Vacuna', _registerVaccine),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[800]),
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSubmitButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[800],
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}


class TreatmentRegistrationScreen extends StatefulWidget {
  final String animalId;

  TreatmentRegistrationScreen({required this.animalId});

  @override
  _TreatmentRegistrationScreenState createState() => _TreatmentRegistrationScreenState();
}

class _TreatmentRegistrationScreenState extends State<TreatmentRegistrationScreen> {
  final TextEditingController _treatmentNameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _registerTreatment() async {
    if (_treatmentNameController.text.isEmpty || _detailsController.text.isEmpty || _selectedDate == null) {
      _showAlertDialog('Por favor, complete todos los campos.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('treatments').add({
        'animalId': widget.animalId,
        'treatmentName': _treatmentNameController.text,
        'details': _detailsController.text,
        'date': DateFormat('dd/MM/yyyy').format(_selectedDate!),
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
      _detailsController.clear();
      _selectedDate = null;
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
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.green[800])),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Registrar Tratamiento', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(_treatmentNameController, 'Nombre del Tratamiento', Icons.medical_services),
            SizedBox(height: 10),
            _buildTextField(_detailsController, 'Detalles del Tratamiento', Icons.description),
            SizedBox(height: 10),
            ListTile(
              title: Text(_selectedDate == null ? 'Seleccionar Fecha' : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
              trailing: Icon(Icons.calendar_today, color: Colors.green[800]),
              onTap: _selectDate,
            ),
            SizedBox(height: 20),
            _buildSubmitButton('Registrar Tratamiento', _registerTreatment),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[800]),
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[800],
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 18)),
    );
  }
}
