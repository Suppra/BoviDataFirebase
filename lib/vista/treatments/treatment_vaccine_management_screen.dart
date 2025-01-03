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
            return Center(child: Text('Error al cargar los Bovinos.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay Bovinos registrados.'));
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
  final TextEditingController _doseController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedVaccine;
  DocumentSnapshot? _selectedVaccineDoc;

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
    if (_selectedVaccine == null || _doseController.text.isEmpty || _selectedDate == null) {
      _showAlertDialog('Por favor, complete todos los campos.');
      return;
    }

    try {
      final int dose = int.parse(_doseController.text);
      final int currentQuantity = _selectedVaccineDoc!['quantity'];

      if (dose > currentQuantity) {
        _showAlertDialog('No hay suficientes dosis disponibles.');
        return;
      }

      await FirebaseFirestore.instance.collection('vaccines').add({
        'animalId': widget.animalId,
        'vaccineName': _selectedVaccine,
        'dose': dose,
        'date': Timestamp.fromDate(_selectedDate!), // Cambiado aquí
      });

      await FirebaseFirestore.instance.collection('medications').doc(_selectedVaccineDoc!.id).update({
        'quantity': currentQuantity - dose,
      });

      _showAlertDialog('Vacuna registrada con éxito.');
      _clearFields();
    } catch (e) {
      _showAlertDialog('Error al registrar la vacuna.');
    }
  }

  void _clearFields() {
    setState(() {
      _selectedVaccine = null;
      _selectedVaccineDoc = null;
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
            _buildVaccineDropdown(),
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

  Widget _buildVaccineDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medications').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final medications = snapshot.data!.docs;
        List<DropdownMenuItem<String>> items = medications.map((medication) {
          return DropdownMenuItem<String>(
            value: medication.id,
            child: Text(medication['name']),
          );
        }).toList();

        return DropdownButtonFormField<String>(
          value: _selectedVaccine,
          onChanged: (value) {
            setState(() {
              _selectedVaccine = value;
              _selectedVaccineDoc = medications.firstWhere((medication) => medication.id == value);
            });
          },
          decoration: InputDecoration(
            labelText: 'Vacuna',
            filled: true,
            fillColor: Colors.green[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.vaccines, color: Colors.green[800]),
          ),
          items: items,
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
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
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 18)),
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
        'date': Timestamp.fromDate(_selectedDate!), // Cambiado aquí
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
