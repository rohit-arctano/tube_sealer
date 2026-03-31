// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../core/config/display_config.dart';
import '../../core/services/responsive_service.dart';
import '../../widget/components/ui_components.dart';

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
              HeaderBar(
                timestamp: timestamp,
                title: '',
                username: 'Login',
                r: r,
              ),
              SizedBox(height: r.scaled(32)),
              SpinBox(
                label: 'User name',
                options: _users,
                initialIndex: _selectedUserIndex,
                onChanged: (idx) => setState(() => _selectedUserIndex = idx),
                r: r,
              ),
              SizedBox(height: r.scaled(24)),
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
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: r.scaled(12)),
                            child: Text(
                              _showPassword ? _password : '*' * _password.length,
                              style: TextStyle(
                                color: r.textLight(),
                                fontSize: r.scaled(16),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: r.scaled(12)),
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
              const Spacer(),
              ActionBar(
                r: r,
                onOk: () {
                  if (_password.isNotEmpty) {
                    Navigator.of(context).pushReplacementNamed('/shell');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Enter password',
                          style: TextStyle(fontSize: r.scaled(14)),
                        ),
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

/// Numeric keyboard dialog that keeps its action row visible on shorter screens.
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
  State<_NumericKeyboardDialog> createState() => _NumericKeyboardDialogState();
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
    final maxW = widget.r.scaled(480);
    final maxH = MediaQuery.of(context).size.height * 0.9;
    final contentPadding =
        MediaQuery.of(context).viewInsets + EdgeInsets.all(widget.r.scaled(12));
    final keySpacing = widget.r.scaled(6);

    return Dialog(
      backgroundColor: widget.r.bgDark(),
      insetPadding: EdgeInsets.all(widget.r.scaled(10)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxW,
          maxHeight: maxH,
          minWidth: widget.r.scaled(280),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentHeight =
                (constraints.maxHeight - contentPadding.vertical)
                    .clamp(0.0, constraints.maxHeight)
                    .toDouble();

            return Padding(
              padding: contentPadding,
              child: SizedBox(
                height: contentHeight,
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.r.textLight(),
                        fontSize: widget.r.scaled(18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: widget.r.scaled(12)),
                    Container(
                      width: double.infinity,
                      height: widget.r.scaled(48),
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.r.borderDark(), width: 2),
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
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, keypadConstraints) {
                          final keyHeight =
                              ((keypadConstraints.maxHeight - (keySpacing * 3)) / 4)
                                  .clamp(widget.r.scaled(32), widget.r.scaled(64))
                                  .toDouble();

                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: 12,
                            physics: const ClampingScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: keySpacing,
                              crossAxisSpacing: keySpacing,
                              mainAxisExtent: keyHeight,
                            ),
                            itemBuilder: (context, i) {
                              String label;
                              VoidCallback onTap;

                              if (i < 9) {
                                label = '${i + 1}';
                                onTap = () => setState(() => _currentValue += label);
                              } else if (i == 9) {
                                label = '0';
                                onTap = () => setState(() => _currentValue += label);
                              } else if (i == 10) {
                                label = '<';
                                onTap = () => setState(() {
                                      if (_currentValue.isNotEmpty) {
                                        _currentValue = _currentValue.substring(
                                          0,
                                          _currentValue.length - 1,
                                        );
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: widget.r.borderDark(),
                                        width: 1,
                                      ),
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
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: widget.r.scaled(12)),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: widget.r.scaled(12),
                      runSpacing: widget.r.scaled(8),
                      children: [
                        _DialogActionButton(
                          r: widget.r,
                          backgroundColor: widget.r.accentColor(),
                          iconColor: Colors.black,
                          icon: Icons.check,
                          onTap: () => widget.onSubmit(_currentValue),
                        ),
                        _DialogActionButton(
                          r: widget.r,
                          backgroundColor: widget.r.bgDark(),
                          iconColor: widget.r.textLight(),
                          icon: Icons.close,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  final Responsive r;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;

  const _DialogActionButton({
    required this.r,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: r.touchTargetDp(),
      height: r.touchTargetDp(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: r.textLight(), width: 2),
              color: backgroundColor,
            ),
            child: Center(
              child: Icon(
                icon,
                size: r.scaled(28),
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
