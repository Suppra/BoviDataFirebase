import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentMortalityReportScreen extends StatefulWidget {
  @override
  _IncidentMortalityReportScreenState createState() =>
      _IncidentMortalityReportScreenState();
}

class _IncidentMortalityReportScreenState
    extends State<IncidentMortalityReportScreen> {
  String? _selectedAnimalId;
  final TextEditingController _incidentDescriptionController =
      TextEditingController();
  final TextEditingController _mortalityReasonController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Reportar Incidencias o Mortalidad',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green[800],
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.report, color: Colors.red),
                child: Text(
                  'Incidencia',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Tab(
                icon: Icon(Icons.warning, color: Colors.red),
                child: Text(
                  'Mortalidad',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildIncidentForm(),
            _buildMortalityForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('animales').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar los Bovinos.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay Bovinos registrados.'));
        }

        final animals = snapshot.data!.docs;
        return DropdownButtonFormField<String>(
          value: _selectedAnimalId,
          hint: Text('Seleccione un Bovino'),
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
            filled: true,
            fillColor: Colors.green[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncidentForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildAnimalDropdown(),
          SizedBox(height: 10),
          _buildTextField('Descripción de la Incidencia',
              _incidentDescriptionController),
          SizedBox(height: 10),
          _buildDateField(context, 'Fecha', _dateController),
          SizedBox(height: 20),
          _buildActionButton('Reportar Incidencia', _reportIncident),
        ],
      ),
    );
  }

  Widget _buildMortalityForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildAnimalDropdown(),
          SizedBox(height: 10),
          _buildTextField('Razón de Mortalidad', _mortalityReasonController),
          SizedBox(height: 10),
          _buildDateField(context, 'Fecha', _dateController),
          SizedBox(height: 20),
          _buildActionButton('Reportar Mortalidad', _reportMortality),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context, String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.green[50],
        suffixIcon: Icon(Icons.calendar_today, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: () async {
        DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          setState(() {
            _selectedDate = selectedDate;
            controller.text =
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
          });
        }
      },
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[800],
        padding: EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Future<void> _reportIncident() async {
    if (_selectedAnimalId == null ||
        _incidentDescriptionController.text.isEmpty ||
        _dateController.text.isEmpty) {
      _showAlertDialog('Por favor, complete todos los campos.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('incidents').add({
        'animalId': _selectedAnimalId,
        'description': _incidentDescriptionController.text,
        'date': Timestamp.fromDate(_selectedDate!), // Cambiado aquí
      });

      _showAlertDialog('Incidencia reportada con éxito.');
      _clearFields();
    } catch (e) {
      _showAlertDialog('Error al reportar la incidencia.');
    }
  }

  Future<void> _reportMortality() async {
    if (_selectedAnimalId == null ||
        _mortalityReasonController.text.isEmpty ||
        _dateController.text.isEmpty) {
      _showAlertDialog('Por favor, complete todos los campos.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('mortality').add({
        'animalId': _selectedAnimalId,
        'reason': _mortalityReasonController.text,
        'date': Timestamp.fromDate(_selectedDate!), // Cambiado aquí
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
      _selectedDate = null;
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
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.green[800])),
          ),
        ],
      ),
    );
  }
}
