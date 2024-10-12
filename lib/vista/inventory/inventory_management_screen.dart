import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryManagementScreen extends StatefulWidget {
  @override
  _InventoryManagementScreenState createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final TextEditingController _medicationNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  String? _selectedMedicationId;

  Future<void> _addOrUpdateMedication() async {
    try {
      if (_selectedMedicationId == null) {
        // Si no hay medicamento seleccionado, creamos uno nuevo
        DocumentReference newMedicationRef = FirebaseFirestore.instance.collection('medications').doc();

        await newMedicationRef.set({
          'name': _medicationNameController.text,
          'quantity': int.parse(_quantityController.text),
          'expirationDate': _expirationDateController.text,
          'medicationId': newMedicationRef.id, // Asignar el ID único generado al medicamento
        });

        _showAlertDialog('Medicamento agregado con éxito.');
      } else {
        // Si hay un medicamento seleccionado, actualizamos sus datos
        await FirebaseFirestore.instance.collection('medications').doc(_selectedMedicationId).update({
          'name': _medicationNameController.text,
          'quantity': int.parse(_quantityController.text),
          'expirationDate': _expirationDateController.text,
        });

        _showAlertDialog('Medicamento actualizado con éxito.');
      }

      _clearFields();
    } catch (e) {
      _showAlertDialog('Error al agregar o actualizar el medicamento.');
    }
  }

  void _loadMedicationData(String medicationId) async {
    DocumentSnapshot medicationDoc = await FirebaseFirestore.instance.collection('medications').doc(medicationId).get();
    if (medicationDoc.exists) {
      setState(() {
        _selectedMedicationId = medicationId;
        _medicationNameController.text = medicationDoc['name'];
        _quantityController.text = medicationDoc['quantity'].toString();
        _expirationDateController.text = medicationDoc['expirationDate'];
      });
    }
  }

  void _clearFields() {
    setState(() {
      _selectedMedicationId = null;
      _medicationNameController.clear();
      _quantityController.clear();
      _expirationDateController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Inventario'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('medications').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
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
                      final expirationDate = medication['expirationDate'];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(medicationName),
                          subtitle: Text('Cantidad: $medicationQuantity\nFecha de Expiración: $expirationDate'),
                          leading: Icon(Icons.medication, color: Colors.teal),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: Colors.teal),
                            onPressed: () {
                              _loadMedicationData(medication.id);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _medicationNameController,
              decoration: InputDecoration(labelText: 'Nombre del Medicamento'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _expirationDateController,
              decoration: InputDecoration(labelText: 'Fecha de Expiración (DD/MM/AAAA)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addOrUpdateMedication,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(_selectedMedicationId == null ? 'Agregar Medicamento' : 'Actualizar Medicamento'),
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
