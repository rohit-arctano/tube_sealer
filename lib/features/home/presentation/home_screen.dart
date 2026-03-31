import 'package:flutter/material.dart';
import '../../../app/constants/app_sizes.dart';
import '../../../core/services/machine_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';
import '../../maintenance/presentation/maintenance_screen.dart';
import '../../user_management/presentation/user_management_screen.dart';
import '../../export/presentation/export_screen.dart';
import '../controller/home_controller.dart';
import 'widgets/cycle_counter_card.dart';
import 'widgets/machine_status_card.dart';
import 'widgets/recipe_summary_card.dart';
import 'widgets/start_cycle_button.dart';
import 'widgets/tube_detection_card.dart';

class HomeScreen extends StatefulWidget {
  final MachineService service;
  const HomeScreen({super.key, required this.service});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = HomeController(widget.service);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.init();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    final isSupervisorOrAdmin = user?.role == UserRole.supervisor || user?.role == UserRole.admin;
    final isAdmin = user?.role == UserRole.admin;

    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final s = _ctrl.state;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            children: [
              MachineStatusCard(status: s.status),
              RecipeSummaryCard(recipe: s.selectedRecipe),
              TubeDetectionCard(detected: s.tubeDetected),
              CycleCounterCard(today: s.todayCount, total: s.totalCount),
              const SizedBox(height: AppSizes.lg),
              StartCycleButton(
                enabled: s.canStartCycle,
                onPressed: _ctrl.startCycle,
              ),
              const SizedBox(height: AppSizes.lg),
              // Maintenance button for all roles
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MaintenanceScreen()),
                  );
                },
                child: Text('Maintenance', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),
                ),
              ),
              if (isSupervisorOrAdmin) ...[
                const SizedBox(height: AppSizes.md),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => UserManagementScreen()),
                    );
                  },
                  child: Text('User Management', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ExportScreen()),
                    );
                  },
                  child: Text('Export Records', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
