import 'package:flutter/material.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/machine_primary_button.dart';
import '../../../core/config/display_config.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/responsive_service.dart';
import '../../../widget/components/ui_components.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AuthService _authService = AuthService();
  final List<User> _users = [
    User(username: 'operator1', role: UserRole.operator),
    User(username: 'supervisor1', role: UserRole.supervisor),
  ];

  void _addUser() {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(onAdd: (user) {
        setState(() {
          _users.add(user);
        });
      }),
    );
  }

  void _editUser(User user) {}

  void _deleteUser(User user) {
    setState(() {
      _users.remove(user);
    });
  }

  String _timestamp() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final canManage =
        user?.role == UserRole.supervisor || user?.role == UserRole.admin;
    final r = Responsive(displayConfig, MediaQuery.of(context).size);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(r.scaled(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeaderBar(
                timestamp: _timestamp(),
                title: 'User management',
                username: user?.username ?? 'Supervis',
                r: r,
              ),
              if (canManage) ...[
                MachinePrimaryButton(
                  label: 'Add User',
                  icon: Icons.add,
                  onPressed: _addUser,
                ),
                SizedBox(height: r.scaled(10)),
              ],
              Expanded(
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final item = _users[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: r.scaled(8)),
                      padding: EdgeInsets.all(r.scaled(10)),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.username, style: AppTextStyles.bodyLarge),
                                SizedBox(height: r.scaled(4)),
                                Text(
                                  item.role.toString().split('.').last,
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          if (canManage) ...[
                            _ActionSquareButton(
                              icon: Icons.edit,
                              onTap: () => _editUser(item),
                              r: r,
                            ),
                            SizedBox(width: r.scaled(8)),
                            _ActionSquareButton(
                              icon: Icons.delete,
                              onTap: () => _deleteUser(item),
                              r: r,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Responsive r;

  const _ActionSquareButton({
    required this.icon,
    required this.onTap,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: r.scaled(40),
        height: r.scaled(40),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: r.scaled(20)),
      ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  final Function(User) onAdd;

  AddUserDialog({required this.onAdd});

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _usernameController = TextEditingController();
  UserRole _selectedRole = UserRole.operator;

  void _add() {
    final user = User(username: _usernameController.text, role: _selectedRole);
    widget.onAdd(user);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);
    final roleOptions =
        UserRole.values.map((role) => role.toString().split('.').last).toList();

    return AlertDialog(
      backgroundColor: r.bgDark(),
      title: Text(
        'Add User',
        style: TextStyle(fontSize: 24, color: r.textLight()),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: r.textLight().withOpacity(0.85)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: r.borderDark(), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: r.accentColor(), width: 1.5),
              ),
            ),
            style: TextStyle(fontSize: 20, color: r.textLight()),
          ),
          SizedBox(height: r.scaled(16)),
          SpinBox(
            label: 'Role',
            options: roleOptions,
            initialIndex: UserRole.values.indexOf(_selectedRole),
            onChanged: (index) {
              setState(() {
                _selectedRole = UserRole.values[index];
              });
            },
            r: r,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 20, color: r.textLight()),
          ),
        ),
        ElevatedButton(
          onPressed: _add,
          child: Text('Add', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
