import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tube_sealer/features/auth/login_screen.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_theme_controller.dart';
import 'core/config/display_config.dart';
import 'core/services/mock_machine_service.dart';
import 'core/services/screen_rotation_service.dart';
import 'features/shell/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow all orientations - rotation is handled in-app via RotatedBox.
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
  final _themeController = AppThemeController.instance;
  bool _semanticsReady = false;
  bool _launchRatioPrinted = false;

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

  void _printLaunchRatio(BuildContext context) {
    if (_launchRatioPrinted) return;

    final size = MediaQuery.sizeOf(context);
    if (size.isEmpty) return;

    _launchRatioPrinted = true;
    final width = size.width.round();
    final height = size.height.round();
    final ratioLabel = _aspectRatioLabel(width, height);
    final ratioValue = (size.width / size.height).toStringAsFixed(3);

    debugPrint(
      'Launch viewport: ${width}x$height | ratio: $ratioLabel ($ratioValue) | '
      'config: ${displayConfig.resolutionLabel} (${displayConfig.aspectRatioLabel})',
    );
  }

  @override
  void dispose() {
    _rotation.removeListener(_onRotation);
    _machineService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Kairish Tube Sealer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeController.themeMode,
          builder: (context, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _printLaunchRatio(context);
              }
            });
            return child ?? const SizedBox.shrink();
          },
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
      },
    );
  }
}

String _aspectRatioLabel(int width, int height) {
  final divisor = _greatestCommonDivisor(width, height);
  return '${width ~/ divisor}:${height ~/ divisor}';
}

int _greatestCommonDivisor(int a, int b) {
  var x = a.abs();
  var y = b.abs();

  while (y != 0) {
    final remainder = x % y;
    x = y;
    y = remainder;
  }

  return x == 0 ? 1 : x;
}
