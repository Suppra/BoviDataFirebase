import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalHistoryScreen extends StatelessWidget {
  final String animalId;
  final String animalName;

  const MedicalHistoryScreen({
    Key? key,
    required this.animalId,
    required this.animalName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial Médico de $animalName'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          _buildSectionTitle('Vacunas'),
          _buildVaccinesSection(),
          _buildSectionTitle('Tratamientos'),
          _buildTreatmentsSection(),
          _buildSectionTitle('Planificación de Vacunación'),
          _buildVaccinationPlansSection(),
          _buildSectionTitle('Incidencias y Mortalidad'),
          _buildIncidentsSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }


  Widget _buildVaccinesSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vaccines')
          .where('animalId', isEqualTo: animalId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay vacunas registradas.'));
        }

        final vaccines = snapshot.data!.docs;

        return Column(
          children: vaccines.map((vaccine) {
            final vaccineName = vaccine['vaccineName'];
            final date = vaccine['date'];
            final dose = vaccine['dose'];
            return ListTile(
              title: Text(vaccineName),
              subtitle: Text('Dosis: $dose\nFecha: $date'),
              leading: Icon(Icons.vaccines, color: Colors.teal),
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
          .where('animalId', isEqualTo: animalId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay tratamientos registrados.'));
        }

        final treatments = snapshot.data!.docs;

        return Column(
          children: treatments.map((treatment) {
            final treatmentName = treatment['treatmentName'];
            final date = treatment['date'];
            final details = treatment['details'];
            return ListTile(
              title: Text(treatmentName),
              subtitle: Text('Fecha: $date\nDetalles: $details'),
              leading: Icon(Icons.healing, color: Colors.teal),
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
          .where('animalId', isEqualTo: animalId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay planificaciones de vacunación.'));
        }

        final plans = snapshot.data!.docs;

        return Column(
          children: plans.map((plan) {
            final vaccineName = plan['vaccineName'];
            final date = plan['date'];
            return ListTile(
              title: Text(vaccineName),
              subtitle: Text('Fecha programada: $date'),
              leading: Icon(Icons.event_note, color: Colors.teal),
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
          .where('animalId', isEqualTo: animalId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay incidencias o reportes de mortalidad.'));
        }

        final incidents = snapshot.data!.docs;

        return Column(
          children: incidents.map((incident) {
            final description = incident['description'] ?? 'Sin descripción';
            final date = incident['date'];
            return ListTile(
              title: Text('Incidencia / Mortalidad'),
              subtitle: Text('Fecha: $date\nDescripción: $description'),
              leading: Icon(Icons.report, color: Colors.teal),
            );
          }).toList(),
        );
      },
    );
  }
}
