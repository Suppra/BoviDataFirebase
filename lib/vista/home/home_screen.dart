import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String userType =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('BoviData', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildHeader(),
            Expanded(
              child: _buildOptionsGrid(context, userType),
            ),
            SizedBox(height: 20),
            _buildAnimatedLogoutButton(context),
            SizedBox(height: 20),
            _buildLogo(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Text(
        'Bienvenido a BoviData',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildOptionsGrid(BuildContext context, String userType) {
    final List<Map<String, dynamic>> options = [
      {'label': 'Gestión de Animales', 'icon': Icons.pets, 'route': '/animal_management'},
      {'label': 'Listado de Animales', 'icon': Icons.list, 'route': '/animal_list'},
      if (userType == 'Veterinario') ...[
        {'label': 'Tratamientos y Vacunas', 'icon': Icons.medical_services, 'route': '/treatment_vaccine_management'},
        {'label': 'Inventario de Medicamentos', 'icon': Icons.inventory, 'route': '/inventory_management'},
        {'label': 'Planificación Vacunación', 'icon': Icons.calendar_today, 'route': '/vaccination_planning'},
        {'label': 'Reportar Incidencias', 'icon': Icons.report, 'route': '/incident_mortality_report'},
        {'label': 'Historial Médico', 'icon': Icons.history, 'route': '/animal_list', 'args': {'isMedicalHistory': true}},
      ],
      if (userType == 'Ganadero') ...[
        {'label': 'Quejas y Sugerencias', 'icon': Icons.feedback, 'route': '/complaints_suggestions'},
        {'label': 'Exportación de Datos', 'icon': Icons.file_download, 'route': '/data_export'},
        {'label': 'Historial Médico', 'icon': Icons.history, 'route': '/animal_list', 'args': {'isMedicalHistory': true}},
      ],
      if (userType == 'Empleado') ...[
        {'label': 'Reportar Incidencias', 'icon': Icons.report_problem, 'route': '/incident_mortality_report'},
        {'label': 'Quejas y Sugerencias', 'icon': Icons.feedback, 'route': '/complaints_suggestions'},
      ],
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        return _buildOptionCard(
          context,
          option['icon'],
          option['label'],
          option['route'],
          args: option['args'],
        );
      },
    );
  }

  Widget _buildOptionCard(BuildContext context, IconData icon, String label, String route, {Map<String, dynamic>? args}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route, arguments: args);
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.green[100]!, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.green[800]),
              SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _logout(context);
      },
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [Colors.red[400]!, Colors.red[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Cerrar Sesión',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/images/logoBovidata.jpg',
        height: 120,
        width: 120,
      ),
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }
}
