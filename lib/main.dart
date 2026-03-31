import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tube_sealer/features/auth/login_screen.dart';
import 'app/theme/app_theme.dart';
import 'core/services/mock_machine_service.dart';
import 'core/services/screen_rotation_service.dart';
import 'features/shell/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow all orientations — rotation is handled in-app via RotatedBox.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide system UI for kiosk-style display.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const TubeSealerApp());
}

class TubeSealerApp extends StatefulWidget {
  const TubeSealerApp({super.key});

  @override
  State<TubeSealerApp> createState() => _TubeSealerAppState();
}

class _TubeSealerAppState extends State<TubeSealerApp> {
  final _machineService = MockMachineService();
  final _rotation = ScreenRotationService();
  bool _semanticsReady = false;

  @override
  void initState() {
    super.initState();
    _rotation.addListener(_onRotation);
    // Delay enabling semantics until after the first frame is fully laid out.
    // This prevents the accessibility bridge from receiving partial tree
    // updates during the initial build cascade.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _semanticsReady = true);
    });
  }

  void _onRotation() => setState(() {});

  @override
  void dispose() {
    _rotation.removeListener(_onRotation);
    _machineService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kairish Tube Sealer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/login',
      routes: {
        // '/demo': (context) => const DemoHomeScreen(),
        '/login': (context) => LoginScreen(),
        '/shell': (context) => ExcludeSemantics(
          excluding: !_semanticsReady,
          child: RotatedBox(
            quarterTurns: _rotation.quarterTurns,
            child: MainShellScreen(machineService: _machineService),
          ),
        ),
      },
    );
  }
}
