import 'package:flutter/material.dart';
import '../../../app/widgets/machine_primary_button.dart';
import '../../../core/config/display_config.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/machine_service.dart';
import '../../../core/services/responsive_service.dart';
import '../../export/presentation/export_screen.dart';
import '../../maintenance/presentation/maintenance_screen.dart';
import '../../user_management/presentation/user_management_screen.dart';
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
    final isSupervisorOrAdmin =
        user?.role == UserRole.supervisor || user?.role == UserRole.admin;
    final r = Responsive(displayConfig, MediaQuery.of(context).size);

    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final s = _ctrl.state;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            r.scaled(10),
            0,
            r.scaled(10),
            r.scaled(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MachineStatusCard(status: s.status),
              RecipeSummaryCard(recipe: s.selectedRecipe),
              TubeDetectionCard(detected: s.tubeDetected),
              CycleCounterCard(today: s.todayCount, total: s.totalCount),
              SizedBox(height: r.scaled(10)),
              StartCycleButton(
                enabled: s.canStartCycle,
                onPressed: _ctrl.startCycle,
              ),
              SizedBox(height: r.scaled(10)),
              MachinePrimaryButton(
                label: 'Maintenance',
                icon: Icons.build,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MaintenanceScreen()),
                  );
                },
              ),
              if (isSupervisorOrAdmin) ...[
                SizedBox(height: r.scaled(10)),
                MachinePrimaryButton(
                  label: 'User Management',
                  icon: Icons.manage_accounts,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => UserManagementScreen()),
                    );
                  },
                ),
                SizedBox(height: r.scaled(10)),
                MachinePrimaryButton(
                  label: 'Export Records',
                  icon: Icons.save_alt,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ExportScreen()),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
