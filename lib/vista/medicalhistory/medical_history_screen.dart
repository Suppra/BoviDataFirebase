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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Historial Médico de $animalName',
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
        child: ListView(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
      ),
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

  Widget _buildVaccinesSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vaccines')
          .where('animalId', isEqualTo: animalId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.green[800]));
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
            return _buildListItem(
              icon: Icons.vaccines,
              title: vaccineName,
              subtitle: 'Dosis: $dose\nFecha: $date',
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
          return Center(
              child: CircularProgressIndicator(color: Colors.green[800]));
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
            return _buildListItem(
              icon: Icons.healing,
              title: treatmentName,
              subtitle: 'Fecha: $date\nDetalles: $details',
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
          return Center(
              child: CircularProgressIndicator(color: Colors.green[800]));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay planificaciones de vacunación.'));
        }
        final plans = snapshot.data!.docs;
        return Column(
          children: plans.map((plan) {
            final vaccineName = plan['vaccineName'];
            final date = plan['date'];
            return _buildListItem(
              icon: Icons.event_note,
              title: vaccineName,
              subtitle: 'Fecha programada: $date',
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
          return Center(
              child: CircularProgressIndicator(color: Colors.green[800]));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay incidencias o reportes de mortalidad.'));
        }
        final incidents = snapshot.data!.docs;
        return Column(
          children: incidents.map((incident) {
            final description = incident['description'] ?? 'Sin descripción';
            final date = incident['date'];
            return _buildListItem(
              icon: Icons.report,
              title: 'Incidencia / Mortalidad',
              subtitle: 'Fecha: $date\nDescripción: $description',
            );
          }).toList(),
        );
      },
    );
  }
}
