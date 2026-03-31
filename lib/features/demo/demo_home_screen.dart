// lib/features/demo/demo_home_screen.dart
import 'package:flutter/material.dart';
import '../../core/config/display_config.dart';
import '../../core/services/responsive_service.dart';
import '../auth/login_screen.dart';
import '../home/menu_screen.dart';
import '../run/tubing_selection_screen.dart';
import '../sealed_process/sealing_process_screen.dart';
import '../settings/settings_screen.dart';

class DemoHomeScreen extends StatelessWidget {
  const DemoHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);

    return Scaffold(
      backgroundColor: r.bgDark(),
      appBar: AppBar(
        backgroundColor: r.borderDark(),
        title: const Text('Tube Sealer Prototype'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(r.scaled(16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tube Sealer UI Prototype',
                  style: TextStyle(
                    color: r.textLight(),
                    fontSize: r.scaled(28),
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: r.scaled(8)),
                Text(
                  'Display: 800×480 (5"), Touch: Resistive',
                  style: TextStyle(
                    color: r.accentColor(),
                    fontSize: r.scaled(14),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: r.scaled(32)),
                Text(
                  'Navigate to screens:',
                  style: TextStyle(
                    color: r.textLight(),
                    fontSize: r.scaled(16),
                  ),
                ),
                SizedBox(height: r.scaled(16)),
                _DemoButton(
                  label: '1. Login',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const LoginScreen(),
                    ),
                  ),
                  r: r,
                ),
                SizedBox(height: r.scaled(12)),
                _DemoButton(
                  label: '2. Menu (Icon Grid)',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) =>
                          const MenuScreen(username: 'Supervis'),
                    ),
                  ),
                  r: r,
                ),
                SizedBox(height: r.scaled(12)),
                _DemoButton(
                  label: '3. Tubing Selection',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const TubingSelectionScreen(
                          username: 'Supervis'),
                    ),
                  ),
                  r: r,
                ),
                SizedBox(height: r.scaled(12)),
                _DemoButton(
                  label: '4. Sealing Process',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const SealingProcessScreen(
                        username: 'Supervis',
                        tubingType: 'TuFlux TPE',
                        tubingSize: 'ID 1/4 x OD 7/16 Red',
                      ),
                    ),
                  ),
                  r: r,
                ),
                SizedBox(height: r.scaled(12)),
                _DemoButton(
                  label: '5. Settings',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) =>
                          const SettingsScreen(username: 'Supervis'),
                    ),
                  ),
                  r: r,
                ),
                SizedBox(height: r.scaled(32)),
                Container(
                  padding: EdgeInsets.all(r.scaled(12)),
                  decoration: BoxDecoration(
                    border: Border.all(color: r.borderDark(), width: 1),
                    borderRadius: BorderRadius.circular(r.scaled(4)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Config Details',
                        style: TextStyle(
                          color: r.accentColor(),
                          fontSize: r.scaled(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: r.scaled(8)),
                      Text(
                        'Resolution: ${displayConfig.widthPx}×${displayConfig.heightPx}\n'
                        'Diagonal: ${displayConfig.diagonalInches}"\n'
                        'Min Touch: ${displayConfig.minTouchDp} dp\n'
                        'Scale: ${(Responsive(displayConfig, MediaQuery.of(context).size).scale * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: r.textLight(),
                          fontSize: r.scaled(12),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Responsive r;

  const _DemoButton({
    required this.label,
    required this.onTap,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: r.scaled(56),
        decoration: BoxDecoration(
          border: Border.all(color: r.accentColor(), width: 2),
          borderRadius: BorderRadius.circular(r.scaled(4)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: r.accentColor(),
              fontSize: r.scaled(16),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
