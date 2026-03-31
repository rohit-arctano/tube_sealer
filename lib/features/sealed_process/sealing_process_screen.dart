// lib/features/sealed_process/sealing_process_screen.dart
import 'package:flutter/material.dart';
import '../../core/config/display_config.dart';
import '../../core/models/sealing_models.dart';
import '../../core/services/responsive_service.dart';
import '../../core/services/mock_machine.dart';
import '../../widget/components/ui_components.dart';

class SealingProcessScreen extends StatefulWidget {
  final String username;
  final String tubingType;
  final String tubingSize;

  const SealingProcessScreen({
    required this.username,
    required this.tubingType,
    required this.tubingSize,
    Key? key,
  }) : super(key: key);

  @override
  State<SealingProcessScreen> createState() => _SealingProcessScreenState();
}

class _SealingProcessScreenState extends State<SealingProcessScreen> {
  late MockMachine _machine;
  PhaseUpdate? _currentUpdate;
  bool _isProcessing = false;
  String _timestamp = '';

  @override
  void initState() {
    super.initState();
    _machine = MockMachine();
    _machine.setTubing(widget.tubingType, widget.tubingSize);
    _machine.onPhaseUpdate.listen((update) {
      setState(() {
        _currentUpdate = update;
        if (update.phase == SealingPhase.complete) {
          _isProcessing = false;
        }
      });
    });
    _updateTimestamp();
  }

  void _updateTimestamp() {
    final now = DateTime.now();
    _timestamp = 
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _machine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);

    return Scaffold(
      backgroundColor: r.bgDark(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(r.scaled(12)),
          child: Column(
            children: [
              // Header
              HeaderBar(
                timestamp: _timestamp,
                title: 'Supervis',
                username: widget.username,
                r: r,
              ),
              // Title
              ScreenTitle(text: 'Sealing process', r: r),
              SizedBox(height: r.scaled(16)),
              // Tubing info
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(r.scaled(12)),
                decoration: BoxDecoration(
                  border: Border.all(color: r.borderDark(), width: 1),
                  borderRadius: BorderRadius.circular(r.scaled(4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tubing Type: ${widget.tubingType}',
                      style: TextStyle(
                        color: r.textLight(),
                        fontSize: r.scaled(12),
                      ),
                    ),
                    SizedBox(height: r.scaled(4)),
                    Text(
                      'Tubing Size: ${widget.tubingSize}',
                      style: TextStyle(
                        color: r.textLight(),
                        fontSize: r.scaled(12),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.scaled(16)),
              // Phase display
              if (_currentUpdate != null)
                ProgressPhase(
                  label: _currentUpdate!.label,
                  progress: _currentUpdate!.progress,
                  timeRemaining: 
                      _currentUpdate!.timeRemainingSeconds > 0
                          ? '${_currentUpdate!.timeRemainingSeconds}s'
                          : null,
                  r: r,
                )
              else
                ProgressPhase(
                  label: 'Ready',
                  progress: 0.0,
                  r: r,
                ),
              Spacer(),
              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play button
                  SizedBox(
                    width: r.touchTargetDp(),
                    height: r.touchTargetDp(),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isProcessing
                            ? null
                            : () async {
                                setState(() => _isProcessing = true);
                                await _machine.startProcess();
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isProcessing
                                  ? Colors.grey
                                  : r.textLight(),
                              width: 2,
                            ),
                            borderRadius:
                                BorderRadius.circular(r.scaled(4)),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_arrow,
                              size: r.scaled(32),
                              color: _isProcessing
                                  ? Colors.grey
                                  : r.textLight(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: r.scaled(12)),
                  // Stop button
                  SizedBox(
                    width: r.touchTargetDp(),
                    height: r.touchTargetDp(),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isProcessing
                            ? () async {
                                await _machine.abortProcess();
                                setState(() => _isProcessing = false);
                              }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isProcessing
                                  ? r.textLight()
                                  : Colors.grey,
                              width: 2,
                            ),
                            borderRadius:
                                BorderRadius.circular(r.scaled(4)),
                          ),
                          child: Center(
                            child: Container(
                              width: r.scaled(16),
                              height: r.scaled(16),
                              color: _isProcessing
                                  ? r.textLight()
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.scaled(16)),
              // Action buttons (OK / Cancel) at bottom-right
              ActionBar(
                r: r,
                onOk: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Process confirmed',
                          style: TextStyle(fontSize: r.scaled(14))),
                      duration: Duration(seconds: 2),
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
