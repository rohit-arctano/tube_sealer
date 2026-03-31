import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';

class MaintenanceScreen extends StatefulWidget {
  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final AuthService _authService = AuthService();
  int _cycleCount = 1000; // Mock data
  bool _maintenanceDue = true;

  void _resetCounters() {
    if (_authService.currentUser?.role == UserRole.admin) {
      setState(() {
        _cycleCount = 0;
        _maintenanceDue = false;
      });
      // Save to DB
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text('Maintenance', style: TextStyle(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Cycle Count: $_cycleCount', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 10),
                    Text(
                      _maintenanceDue ? 'Maintenance Due' : 'Maintenance OK',
                      style: TextStyle(
                        fontSize: 18,
                        color: _maintenanceDue ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (isAdmin)
              ElevatedButton(
                onPressed: _resetCounters,
                child: Text('Reset Counters', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),
                ),
              ),
            // Add more maintenance items as needed
          ],
        ),
      ),
    );
  }
}