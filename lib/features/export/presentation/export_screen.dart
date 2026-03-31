import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/machine_primary_button.dart';
import '../../../core/config/display_config.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/responsive_service.dart';
import '../../../widget/components/ui_components.dart';

class ExportScreen extends StatefulWidget {
  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final AuthService _authService = AuthService();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isExporting = false;

  void _export() async {
    setState(() {
      _isExporting = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isExporting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export completed')),
    );
  }

  String _timestamp() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final canExport =
        user?.role == UserRole.supervisor || user?.role == UserRole.admin;
    final r = Responsive(displayConfig, MediaQuery.of(context).size);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(r.scaled(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeaderBar(
                timestamp: _timestamp(),
                title: 'Log data',
                username: user?.username ?? 'Supervis',
                r: r,
              ),
              _ExportField(
                label: 'Start date',
                value: _startDate.toLocal().toString().split(' ')[0],
                icon: Icons.calendar_today,
                onTap: () async {
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
                r: r,
              ),
              SizedBox(height: r.scaled(10)),
              _ExportField(
                label: 'End date',
                value: _endDate.toLocal().toString().split(' ')[0],
                icon: Icons.calendar_today,
                onTap: () async {
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
                r: r,
              ),
              const Spacer(),
              if (canExport)
                _isExporting
                    ? const Center(child: CircularProgressIndicator())
                    : MachinePrimaryButton(
                        label: 'Export to USB',
                        icon: Icons.save_alt,
                        onPressed: _export,
                      ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final Responsive r;

  const _ExportField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.scaled(10)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                SizedBox(height: r.scaled(6)),
                Text(value, style: AppTextStyles.bodyLarge),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white, size: r.scaled(22)),
          ),
        ],
      ),
    );
  }
}
