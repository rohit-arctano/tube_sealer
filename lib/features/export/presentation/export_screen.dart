import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';

class ExportScreen extends StatefulWidget {
  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final AuthService _authService = AuthService();
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isExporting = false;

  void _export() async {
    setState(() {
      _isExporting = true;
    });
    // Mock export
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isExporting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export completed', style: TextStyle(fontSize: 18))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final canExport = user?.role == UserRole.supervisor || user?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text('Export Records', style: TextStyle(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Select Date Range', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('Start: ${_startDate.toLocal()}'.split(' ')[0], style: TextStyle(fontSize: 18)),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, size: 32),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text('End: ${_endDate.toLocal()}'.split(' ')[0], style: TextStyle(fontSize: 18)),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, size: 32),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 40),
            if (canExport)
              _isExporting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _export,
                      child: Text('Export to USB', style: TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 60),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}