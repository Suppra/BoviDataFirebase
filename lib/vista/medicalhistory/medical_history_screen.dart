import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final String animalId;
  final String animalName;

  const MedicalHistoryScreen({
    Key? key,
    required this.animalId,
    required this.animalName,
  }) : super(key: key);

  @override
  _MedicalHistoryScreenState createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  String _selectedCategory = 'Vacunas';
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Historial Médico de ${widget.animalName}',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
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
        child: Column(
          children: [
            _buildFilterSection(),
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (_selectedCategory == 'Vacunas') _buildVaccinesSection(),
                  if (_selectedCategory == 'Tratamientos')
                    _buildTreatmentsSection(),
                  if (_selectedCategory == 'Planificación de Vacunación')
                    _buildVaccinationPlansSection(),
                  if (_selectedCategory == 'Incidencias y Mortalidad')
                    _buildIncidentsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              items: [
                'Vacunas',
                'Tratamientos',
                'Planificación de Vacunación',
                'Incidencias y Mortalidad',
              ].map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
          ),
          SizedBox(width: 16),
          ElevatedButton(
            onPressed: () async {
              DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                setState(() {
                  _selectedDateRange = picked;
                });
              }
            },
            child: Text('Seleccionar Fechas'),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinesSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vaccines')
          .where('animalId', isEqualTo: widget.animalId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.green[800]));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay vacunas registradas.'));
        }
        final vaccines = snapshot.data!.docs.where((vaccine) {
          final date = (vaccine['date'] as Timestamp).toDate();
          if (_selectedDateRange != null) {
            return date.isAfter(_selectedDateRange!.start) &&
                date.isBefore(_selectedDateRange!.end);
          }
          return true;
        }).toList();
        return Column(
          children: vaccines.map((vaccine) {
            final vaccineName = vaccine['vaccineName'];
            final date = (vaccine['date'] as Timestamp).toDate();
            final dose = vaccine['dose'];
            return _buildListItem(
              icon: Icons.vaccines,
              title: vaccineName,
              subtitle:
                  'Dosis: $dose\nFecha: ${DateFormat('dd/MM/yyyy').format(date)}',
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTreatmentsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('treatments')
          .where('animalId', isEqualTo: widget.animalId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.green[800]));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay tratamientos registrados.'));
        }
        final treatments = snapshot.data!.docs.where((treatment) {
          final date = (treatment['date'] as Timestamp).toDate();
          if (_selectedDateRange != null) {
            return date.isAfter(_selectedDateRange!.start) &&
                date.isBefore(_selectedDateRange!.end);
          }
          return true;
        }).toList();
        return Column(
          children: treatments.map((treatment) {
            final treatmentName = treatment['treatmentName'];
            final date = (treatment['date'] as Timestamp).toDate();
            final details = treatment['details'];
            return _buildListItem(
              icon: Icons.healing,
              title: treatmentName,
              subtitle:
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(date)}\nDetalles: $details',
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildVaccinationPlansSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vaccination_plans')
          .where('animalId', isEqualTo: widget.animalId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.green[800]));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay planificaciones de vacunación.'));
        }
        final plans = snapshot.data!.docs.where((plan) {
          final date = (plan['date'] as Timestamp).toDate();
          if (_selectedDateRange != null) {
            return date.isAfter(_selectedDateRange!.start) &&
                date.isBefore(_selectedDateRange!.end);
          }
          return true;
        }).toList();
        return Column(
          children: plans.map((plan) {
            final vaccineName = plan['vaccineName'];
            final date = (plan['date'] as Timestamp).toDate();
            return _buildListItem(
              icon: Icons.event_note,
              title: vaccineName,
              subtitle:
                  'Fecha programada: ${DateFormat('dd/MM/yyyy').format(date)}',
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildIncidentsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('incidents')
          .where('animalId', isEqualTo: widget.animalId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.green[800]));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text('No hay incidencias o reportes de mortalidad.'));
        }
        final incidents = snapshot.data!.docs.where((incident) {
          final date = (incident['date'] as Timestamp).toDate();
          if (_selectedDateRange != null) {
            return date.isAfter(_selectedDateRange!.start) &&
                date.isBefore(_selectedDateRange!.end);
          }
          return true;
        }).toList();
        return Column(
          children: incidents.map((incident) {
            final description = incident['description'] ?? 'Sin descripción';
            final date = (incident['date'] as Timestamp).toDate();
            return _buildListItem(
              icon: Icons.report,
              title: 'Incidencia / Mortalidad',
              subtitle:
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(date)}\nDescripción: $description',
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700], size: 30),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
