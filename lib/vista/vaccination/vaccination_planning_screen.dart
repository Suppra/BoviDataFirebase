import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VaccinationPlanningScreen extends StatefulWidget {
  @override
  _VaccinationPlanningScreenState createState() => _VaccinationPlanningScreenState();
}

class _VaccinationPlanningScreenState extends State<VaccinationPlanningScreen> {
  String? _selectedAnimalId;
  final TextEditingController _doseController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedVaccine;

  Future<void> _planVaccination() async {
    if (_selectedAnimalId == null || _selectedVaccine == null || _doseController.text.isEmpty || _selectedDate == null) {
      _showAlertDialog('Por favor, complete todos los campos.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('vaccination_plans').add({
        'animalId': _selectedAnimalId,
        'vaccineName': _selectedVaccine,
        'dose': _doseController.text,
        'date': Timestamp.fromDate(_selectedDate!), // Cambiado aquí
      });

      _showAlertDialog('Vacunación planificada con éxito.');
      _clearFields();
    } catch (e) {
      _showAlertDialog('Error al planificar la vacunación.');
    }
  }

  void _clearFields() {
    setState(() {
      _selectedAnimalId = null;
      _selectedVaccine = null;
      _doseController.clear();
      _selectedDate = null;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!,
              onPrimary: Colors.white,
              surface: Colors.green[100]!,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Planificación de Vacunación', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              SizedBox(height: 20),
              _buildAnimalDropdown(),
              SizedBox(height: 20),
              _buildVaccineDropdown(),
              SizedBox(height: 20),
              _buildTextField(_doseController, 'Dosis', Icons.medical_services),
              SizedBox(height: 20),
              _buildDateSelector(context),
              SizedBox(height: 30),
              _buildPlanButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Planificar Vacunación',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.green[800],
      ),
    );
  }

  Widget _buildAnimalDropdown() {
    return StreamBuilder<QuerySnapshot>(
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
            filled: true,
            fillColor: Colors.green[50],
            labelText: 'Animal',
            prefixIcon: Icon(Icons.pets, color: Colors.green[800]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
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

  Widget _buildDateSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: _selectedDate == null
                ? 'Seleccionar Fecha'
                : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
            prefixIcon: Icon(Icons.calendar_today, color: Colors.green[800]),
            filled: true,
            fillColor: Colors.green[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _planVaccination,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Text(
          'Planificar Vacunación',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Información', style: TextStyle(color: Colors.green[800])),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: TextStyle(color: Colors.green[800]),
            ),
          ),
        ],
      ),
    );
  }
}
