// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../core/config/display_config.dart';
import '../../core/services/responsive_service.dart';
import '../../widget/components/ui_components.dart';
import '../home/menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _users = ['Supervis', 'Technician', 'Admin'];
  int _selectedUserIndex = 0;
  String _password = '';
  bool _showPassword = false;

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
                title: '',
                username: 'Login',
                r: r,
              ),
              SizedBox(height: r.scaled(32)),
              // User selection
              SpinBox(
                label: 'User name',
                options: _users,
                initialIndex: _selectedUserIndex,
                onChanged: (idx) => setState(() => _selectedUserIndex = idx),
                r: r,
              ),
              SizedBox(height: r.scaled(24)),
              // Password input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(
                      color: r.textLight(),
                      fontSize: r.scaled(14),
                    ),
                  ),
                  SizedBox(height: r.scaled(8)),
                  GestureDetector(
                    onTap: () => _showPasswordInput(r),
                    child: Container(
                      height: r.scaled(48),
                      decoration: BoxDecoration(
                        border: Border.all(color: r.borderDark(), width: 2),
                        borderRadius: BorderRadius.circular(r.scaled(4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: r.scaled(12)),
                            child: Text(
                              _showPassword ? _password : '*' * _password.length,
                              style: TextStyle(
                                color: r.textLight(),
                                fontSize: r.scaled(16),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(right: r.scaled(12)),
                            child: Icon(
                              Icons.edit,
                              color: r.textLight(),
                              size: r.scaled(24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              // Action buttons
              ActionBar(
                r: r,
                onOk: () {
                  if (_password.isNotEmpty) {
                    // After login, route to the shell route which uses ExcludeSemantics -> MainShellScreen
                    Navigator.of(context).pushReplacementNamed('/shell');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Enter password',
                            style: TextStyle(fontSize: r.scaled(14))),
                      ),
                    );
                  }
                },
                onCancel: () {
                  setState(() {
                    _password = '';
                    _selectedUserIndex = 0;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordInput(Responsive r) {
    showDialog(
      context: context,
      builder: (ctx) => _NumericKeyboardDialog(
        title: 'Enter Password',
        initialValue: _password,
        onSubmit: (value) {
          setState(() => _password = value);
          Navigator.pop(ctx);
        },
        r: r,
      ),
    );
  }
}

/// Numeric keyboard dialog — constrained to avoid intrinsic viewport errors
class _NumericKeyboardDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final ValueChanged<String> onSubmit;
  final Responsive r;

  const _NumericKeyboardDialog({
    required this.title,
    required this.initialValue,
    required this.onSubmit,
    required this.r,
  });

  @override
  State<_NumericKeyboardDialog> createState() =>
      _NumericKeyboardDialogState();
}

class _NumericKeyboardDialogState extends State<_NumericKeyboardDialog> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    // Constrain dialog size to a fraction of the viewport and make it scrollable
    final maxW = widget.r.scaled(480);
    final maxH = MediaQuery.of(context).size.height * 0.9;

    return Dialog(
      backgroundColor: widget.r.bgDark(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxW,
          maxHeight: maxH,
          minWidth: widget.r.scaled(280),
        ),
        child: SingleChildScrollView(
          padding: MediaQuery.of(context).viewInsets +
              EdgeInsets.all(widget.r.scaled(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.r.textLight(),
                  fontSize: widget.r.scaled(18),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: widget.r.scaled(12)),
              // Display
              Container(
                width: double.infinity,
                height: widget.r.scaled(48),
                decoration: BoxDecoration(
                  border: Border.all(color: widget.r.borderDark(), width: 2),
                  borderRadius: BorderRadius.circular(widget.r.scaled(4)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '*' * _currentValue.length,
                  style: TextStyle(
                    color: widget.r.textLight(),
                    fontSize: widget.r.scaled(18),
                  ),
                ),
              ),
              SizedBox(height: widget.r.scaled(12)),
              // Keypad (fixed height)
              SizedBox(
                height: widget.r.scaled(260),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: widget.r.scaled(6),
                  crossAxisSpacing: widget.r.scaled(6),
                  childAspectRatio: 1.2,
                  children: List.generate(12, (i) {
                    String label;
                    VoidCallback onTap;
                    if (i < 9) {
                      label = '${i + 1}';
                      onTap = () => setState(() => _currentValue += label);
                    } else if (i == 9) {
                      label = '0';
                      onTap = () => setState(() => _currentValue += label);
                    } else if (i == 10) {
                      label = '←';
                      onTap = () => setState(() {
                        if (_currentValue.isNotEmpty) {
                          _currentValue = _currentValue.substring(0, _currentValue.length - 1);
                        }
                      });
                    } else {
                      label = 'Clear';
                      onTap = () => setState(() => _currentValue = '');
                    }

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(widget.r.scaled(6)),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: widget.r.borderDark(), width: 1),
                            borderRadius: BorderRadius.circular(widget.r.scaled(6)),
                            // color: widget.r.cardBg(),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: widget.r.textLight(),
                                fontSize: widget.r.scaled(18),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: widget.r.scaled(12)),
              // Action buttons: Correct / Close
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: widget.r.touchTargetDp(),
                    height: widget.r.touchTargetDp(),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          widget.onSubmit(_currentValue);
                        },
                        borderRadius: BorderRadius.circular(widget.r.scaled(6)),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: widget.r.textLight(), width: 2),
                            borderRadius: BorderRadius.circular(widget.r.scaled(6)),
                            color: widget.r.accentColor(),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              size: widget.r.scaled(28),
                              // color: widget.r.bgLight(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: widget.r.scaled(12)),
                  SizedBox(
                    width: widget.r.touchTargetDp(),
                    height: widget.r.touchTargetDp(),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(widget.r.scaled(6)),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: widget.r.textLight(), width: 2),
                            borderRadius: BorderRadius.circular(widget.r.scaled(6)),
                            color: widget.r.bgDark(),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.close,
                              size: widget.r.scaled(28),
                              color: widget.r.textLight(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
