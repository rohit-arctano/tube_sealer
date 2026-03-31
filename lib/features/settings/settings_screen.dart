// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import '../../core/config/display_config.dart';
import '../../core/services/responsive_service.dart';
import '../../widget/components/ui_components.dart';

class SettingsScreen extends StatefulWidget {
  final String username;

  const SettingsScreen({required this.username, Key? key})
      : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _day = 17;
  int _month = 5;
  int _year = 2019;
  int _hour = 16;
  int _minute = 13;
  String _language = 'English';
  bool _networkReset = false;

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
                title: 'Settings',
                username: widget.username,
                r: r,
              ),
              // Scrollable settings
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date setting
                      Text(
                        'Date',
                        style: TextStyle(
                          color: r.textLight(),
                          fontSize: r.scaled(18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: r.scaled(12)),
                      Wrap(
                        spacing: r.scaled(8),
                        runSpacing: r.scaled(8),
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(width: r.scaled(90), child: _TimeAdjuster(
                            label: 'Day',
                            value: _day,
                            min: 1,
                            max: 31,
                            onChanged: (v) => setState(() => _day = v),
                            r: r,
                          )),
                          SizedBox(width: r.scaled(90), child: _TimeAdjuster(
                            label: 'Month',
                            value: _month,
                            min: 1,
                            max: 12,
                            onChanged: (v) => setState(() => _month = v),
                            r: r,
                          )),
                          SizedBox(width: r.scaled(90), child: _TimeAdjuster(
                            label: 'Year',
                            value: _year,
                            min: 2000,
                            max: 2099,
                            onChanged: (v) => setState(() => _year = v),
                            r: r,
                          )),
                        ],
                      ),
                      SizedBox(height: r.scaled(24)),
                      // Time setting
                      Text(
                        'Time',
                        style: TextStyle(
                          color: r.textLight(),
                          fontSize: r.scaled(18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: r.scaled(12)),
                      Wrap(
                        spacing: r.scaled(8),
                        runSpacing: r.scaled(8),
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(width: r.scaled(110), child: _TimeAdjuster(
                            label: 'Hour',
                            value: _hour,
                            min: 0,
                            max: 23,
                            onChanged: (v) => setState(() => _hour = v),
                            r: r,
                          )),
                          SizedBox(width: r.scaled(110), child: _TimeAdjuster(
                            label: 'Minute',
                            value: _minute,
                            min: 0,
                            max: 59,
                            onChanged: (v) => setState(() => _minute = v),
                            r: r,
                          )),
                        ],
                      ),
                      SizedBox(height: r.scaled(24)),
                      // Language setting
                      Text(
                        'Language',
                        style: TextStyle(
                          color: r.textLight(),
                          fontSize: r.scaled(18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: r.scaled(12)),
                      SpinBox(
                        label: 'Select language',
                        options: ['English', 'German', 'Spanish'],
                        initialIndex: 0,
                        onChanged: (idx) {
                          setState(() {
                            final langs = [
                              'English',
                              'German',
                              'Spanish'
                            ];
                            _language = langs[idx];
                          });
                        },
                        r: r,
                      ),
                      SizedBox(height: r.scaled(24)),
                      // Network reset
                      GestureDetector(
                        onTap: () =>
                            setState(() => _networkReset = !_networkReset),
                        child: Container(
                          height: r.scaled(48),
                          padding: EdgeInsets.symmetric(
                              horizontal: r.scaled(12)),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: r.borderDark(), width: 2),
                            borderRadius:
                                BorderRadius.circular(r.scaled(4)),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Network Parameter Reset',
                                style: TextStyle(
                                  color: r.textLight(),
                                  fontSize: r.scaled(14),
                                ),
                              ),
                              Checkbox(
                                value: _networkReset,
                                onChanged: (v) => setState(
                                    () => _networkReset = v ?? false),
                                activeColor: r.accentColor(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: r.scaled(24)),
                    ],
                  ),
                ),
              ),
              // Action buttons
              ActionBar(
                r: r,
                onOk: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Settings saved',
                          style:
                              TextStyle(fontSize: r.scaled(14))),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop();
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

/// Helper widget for adjusting numeric values (date/time).
class _TimeAdjuster extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final Responsive r;

  const _TimeAdjuster({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: r.textLight(),
            fontSize: r.scaled(12),
          ),
        ),
        SizedBox(height: r.scaled(4)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: value > min
                  ? () => onChanged(value - 1)
                  : null,
              child: Container(
                width: r.scaled(32),
                height: r.scaled(32),
                decoration: BoxDecoration(
                  border: Border.all(color: r.borderDark(), width: 1),
                ),
                child: Center(
                  child: Text(
                    '−',
                    style: TextStyle(
                      color: r.textLight(),
                      fontSize: r.scaled(20),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: r.scaled(56),
              child: Center(
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: r.textLight(),
                    fontSize: r.scaled(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: value < max
                  ? () => onChanged(value + 1)
                  : null,
              child: Container(
                width: r.scaled(32),
                height: r.scaled(32),
                decoration: BoxDecoration(
                  border: Border.all(color: r.borderDark(), width: 1),
                ),
                child: Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      color: r.textLight(),
                      fontSize: r.scaled(20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
