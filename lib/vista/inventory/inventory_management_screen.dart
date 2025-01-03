import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class InventoryManagementScreen extends StatefulWidget {
  @override
  _InventoryManagementScreenState createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final TextEditingController _medicationNameController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();
  String? _selectedMedicationId;
  DateTime? _selectedDate;

  Future<void> _addOrUpdateMedication() async {
    try {
      if (_selectedMedicationId == null) {
        DocumentReference newMedicationRef =
            FirebaseFirestore.instance.collection('medications').doc();
        await newMedicationRef.set({
          'name': _medicationNameController.text,
          'quantity': int.parse(_quantityController.text),
          'expirationDate': Timestamp.fromDate(_selectedDate!), // Cambiado aquí
          'medicationId': newMedicationRef.id,
        });
        // Enviar notificación al ganadero y al empleado
        await _sendNotification(
          'Nuevo Medicamento Agregado',
          'Se ha agregado un nuevo medicamento: ${_medicationNameController.text}.',
          'Ganadero',
        );

        await _sendNotification(
          'Nuevo Medicamento Agregado',
          'Se ha agregado un nuevo medicamento: ${_medicationNameController.text}.',
          'Empleado',
        );
        _showAlertDialog('Medicamento agregado con éxito.');
      } else {
        await FirebaseFirestore.instance
            .collection('medications')
            .doc(_selectedMedicationId)
            .update({
          'name': _medicationNameController.text,
          'quantity': int.parse(_quantityController.text),
          'expirationDate': Timestamp.fromDate(_selectedDate!), // Cambiado aquí
        });
        // Enviar notificación al ganadero y al empleado
        await _sendNotification(
          'Medicamento Actualizado',
          'Se ha actualizado el medicamento: ${_medicationNameController.text}.',
          'Ganadero',
        );

        await _sendNotification(
          'Medicamento Actualizado',
          'Se ha actualizado el medicamento: ${_medicationNameController.text}.',
          'Empleado',
        );
        _showAlertDialog('Medicamento actualizado con éxito.');
      }
      _clearFields();
    } catch (e) {
      _showAlertDialog('Error al agregar o actualizar el medicamento.');
    }
  }
     Future<void> _sendNotification(String title, String message, String userType) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'message': message,
      'timestamp': Timestamp.now(),
      'userType': userType,
    });
  }
  void _loadMedicationData(String medicationId) async {
    DocumentSnapshot medicationDoc = await FirebaseFirestore.instance
        .collection('medications')
        .doc(medicationId)
        .get();
    if (medicationDoc.exists) {
      setState(() {
        _selectedMedicationId = medicationId;
        _medicationNameController.text = medicationDoc['name'];
        _quantityController.text = medicationDoc['quantity'].toString();
        _selectedDate = (medicationDoc['expirationDate'] as Timestamp).toDate();
        _expirationDateController.text =
            '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
      });
    }
  }

  void _clearFields() {
    setState(() {
      _selectedMedicationId = null;
      _medicationNameController.clear();
      _quantityController.clear();
      _expirationDateController.clear();
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Inventario', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildMedicationList()),
            SizedBox(height: 10),
            _buildTextField(
                'Nombre del Medicamento', _medicationNameController),
            SizedBox(height: 10),
            _buildTextField(
              'Cantidad',
              _quantityController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            _buildDateField(
                context, 'Fecha de Expiración', _expirationDateController),
            SizedBox(height: 20),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medications').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.green[800]));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar los medicamentos.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay medicamentos registrados.'));
        }

        final medications = snapshot.data!.docs;
        return ListView.builder(
          itemCount: medications.length,
          itemBuilder: (context, index) {
            final medication = medications[index];
            final medicationName = medication['name'];
            final medicationQuantity = medication['quantity'];
            final expirationDate = (medication['expirationDate'] as Timestamp).toDate();

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: ListTile(
                leading: Icon(Icons.medication, color: Colors.green[700], size: 30),
                title: Text(
                  medicationName,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800]),
                ),
                subtitle: Text(
                  'Cantidad: $medicationQuantity\nExpira: ${DateFormat('dd/MM/yyyy').format(expirationDate)}',
                  style: TextStyle(color: Colors.green[600]),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.green[400]),
                  onPressed: () {
                    _loadMedicationData(medication.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.green[50],
        contentPadding:
            EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
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
        contentPadding:
            EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
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

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _addOrUpdateMedication,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 18),
        backgroundColor: Colors.green[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        _selectedMedicationId == null
            ? 'Agregar Medicamento'
            : 'Actualizar Medicamento',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Future<void> _showAlertDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
