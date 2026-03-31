// lib/features/home/menu_screen.dart
import 'package:flutter/material.dart';
import '../../core/config/display_config.dart';
import '../../core/services/responsive_service.dart';
import '../../widget/components/ui_components.dart';

class MenuScreen extends StatelessWidget {
  final String username;

  const MenuScreen({required this.username, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);
    final now = DateTime.now();
    final timestamp = 
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final menuItems = [
      IconGridItem(icon: Icons.settings, label: 'Settings'),
      IconGridItem(icon: Icons.storage, label: 'Log data'),
      IconGridItem(icon: Icons.info, label: 'Info'),
      IconGridItem(icon: Icons.build, label: 'Tubing'),
      IconGridItem(icon: Icons.thermostat, label: 'Temp Valid'),
      IconGridItem(icon: Icons.sd_card, label: 'Service Pos'),
      IconGridItem(icon: Icons.language, label: 'Language'),
      IconGridItem(icon: Icons.access_time, label: 'Date/Time'),
      IconGridItem(icon: Icons.memory, label: 'Memory'),
      IconGridItem(icon: Icons.network_check, label: 'Network'),
      IconGridItem(icon: Icons.upgrade, label: 'Update'),
      IconGridItem(icon: Icons.security, label: 'Secure'),
    ];

    return Scaffold(
      backgroundColor: r.bgDark(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(r.scaled(12)),
          child: Column(
            children: [
              // Header
              HeaderBar(
                timestamp: timestamp,
                title: 'Menu',
                username: username,
                r: r,
              ),
              SizedBox(height: r.scaled(16)),
              // Icon grid
              Expanded(
                child: IconGrid(
                  items: menuItems,
                  r: r,
                  onItemTap: (index) {
                    _handleMenuTap(context, index, r);
                  },
                ),
              ),
              SizedBox(height: r.scaled(16)),
              // Cancel button
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: r.touchTargetDp(),
                  height: r.touchTargetDp(),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: r.textLight(), width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: r.scaled(32),
                            color: r.textLight(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuTap(BuildContext context, int index, Responsive r) {
    // Simple routing based on menu index
    String message = '';
    switch (index) {
      case 0:
        message = 'Settings';
        break;
      case 1:
        message = 'Log Data';
        break;
      case 2:
        message = 'Info';
        break;
      case 3:
        message = 'Tubing Selection';
        break;
      case 4:
        message = 'Temp Validation';
        break;
      case 5:
        message = 'Service Position';
        break;
      case 6:
        message = 'Language';
        break;
      case 7:
        message = 'Date/Time';
        break;
      case 8:
        message = 'Memory';
        break;
      case 9:
        message = 'Network Settings';
        break;
      case 10:
        message = 'Update';
        break;
      case 11:
        message = 'Secure';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: r.scaled(14))),
        duration: Duration(milliseconds: 800),
      ),
    );
  }
}
