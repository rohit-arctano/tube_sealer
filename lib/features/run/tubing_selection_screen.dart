// lib/features/run/tubing_selection_screen.dart
import 'package:flutter/material.dart';
import '../../core/config/display_config.dart';
import '../../core/services/responsive_service.dart';
import '../../widget/components/ui_components.dart';
import '../sealed_process/sealing_process_screen.dart';

class TubingSelectionScreen extends StatefulWidget {
  final String username;

  const TubingSelectionScreen({required this.username, Key? key})
      : super(key: key);

  @override
  State<TubingSelectionScreen> createState() =>
      _TubingSelectionScreenState();
}

class _TubingSelectionScreenState extends State<TubingSelectionScreen> {
  final _tubingTypes = ['TuFlux TPE', 'Silicone Tube', 'PVC'];
  final _tubingSizes = [
    'ID 1/4 x OD 7/16 Red',
    'ID 3/8 x OD 5/8 Clear',
    'ID 1/2 x OD 3/4 Blue'
  ];

  int _selectedTypeIndex = 0;
  int _selectedSizeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);
    final now = DateTime.now();
    final timestamp = 
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

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
                title: 'Supervis',
                username: widget.username,
                r: r,
              ),
              // Title
              ScreenTitle(text: 'Tubing', r: r),
              SizedBox(height: r.scaled(16)),
              // Tubing type selection
              SpinBox(
                label: 'Select tubing type',
                options: _tubingTypes,
                initialIndex: _selectedTypeIndex,
                onChanged: (idx) =>
                    setState(() => _selectedTypeIndex = idx),
                r: r,
              ),
              SizedBox(height: r.scaled(20)),
              // Tubing size selection
              SpinBox(
                label: 'Select tubing size',
                options: _tubingSizes,
                initialIndex: _selectedSizeIndex,
                onChanged: (idx) =>
                    setState(() => _selectedSizeIndex = idx),
                r: r,
              ),
              Spacer(),
              // Action buttons
              ActionBar(
                r: r,
                onOk: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (ctx) => SealingProcessScreen(
                        username: widget.username,
                        tubingType: _tubingTypes[_selectedTypeIndex],
                        tubingSize: _tubingSizes[_selectedSizeIndex],
                      ),
                    ),
                  );
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
