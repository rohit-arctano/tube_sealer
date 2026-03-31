import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/machine_ui_state.dart';
import '../../core/services/machine_service.dart';
import '../../core/services/auth_service.dart';
import '../alarms/presentation/alarm_screen.dart';
import '../history/presentation/history_screen.dart';
import '../home/presentation/home_screen.dart';
import '../recipes/presentation/recipe_screen.dart';
import '../run/presentation/run_screen.dart';
import '../settings/presentation/settings_screen.dart';
import 'bottom_nav_bar.dart';
import 'top_status_bar.dart';

/// Root shell that wraps every screen with the status bar and bottom nav.
class MainShellScreen extends StatefulWidget {
  final MachineService machineService;

  const MainShellScreen({super.key, required this.machineService});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;
  MachineUiState _machineState = const MachineUiState();
  StreamSubscription<MachineUiState>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.machineService.watchMachineState().listen((s) {
      setState(() => _machineState = s);
      // Auto-navigate to alarm screen when alarm is raised.
      if (s.activeAlarm != null && _selectedIndex != 5) {
        setState(() => _selectedIndex = 5);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(service: widget.machineService);
      case 1:
        return RunScreen(service: widget.machineService);
      case 2:
        return const RecipeScreen();
      case 3:
        return const HistoryScreen();
      case 4:
        return const SettingsScreen();
      case 5:
        return AlarmScreen(service: widget.machineService);
      default:
        return HomeScreen(service: widget.machineService);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopStatusBar(
              status: _machineState.status,
              userRole: _machineState.userRole,
            ),
            Expanded(child: _buildBody()),
            BottomNavBar(
              selectedIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
            ),
          ],
        ),
      ),
    );
  }
}
