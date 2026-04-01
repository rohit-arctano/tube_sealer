import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/machine_primary_button.dart';
import '../../../core/config/display_config.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/responsive_service.dart';
import '../../../widget/components/ui_components.dart';

class MaintenanceScreen extends StatefulWidget {
  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final AuthService _authService = AuthService();
  int _cycleCount = 1000;
  bool _maintenanceDue = true;

  void _resetCounters() {
    if (_authService.currentUser?.role == UserRole.admin) {
      setState(() {
        _cycleCount = 0;
        _maintenanceDue = false;
      });
    }
  }

  String _timestamp() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isAdmin = user?.role == UserRole.admin;
    final r = Responsive(displayConfig, MediaQuery.of(context).size);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(r.scaled(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeaderBar(
                timestamp: _timestamp(),
                title: 'Maintenance',
                username: user?.username ?? 'Supervis',
                r: r,
              ),
              Container(
                padding: EdgeInsets.all(r.scaled(12)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.divider, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cycle Count', style: AppTextStyles.caption),
                    SizedBox(height: r.scaled(6)),
                    Text('$_cycleCount', style: AppTextStyles.bigValue),
                    SizedBox(height: r.scaled(10)),
                    Text(
                      _maintenanceDue ? 'Maintenance Due' : 'Maintenance OK',
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isAdmin)
                MachinePrimaryButton(
                  label: 'Reset Counters',
                  icon: Icons.restart_alt,
                  onPressed: _resetCounters,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
