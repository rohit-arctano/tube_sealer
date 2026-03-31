import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AuthService _authService = AuthService();
  List<User> _users = [
    User(username: 'operator1', role: UserRole.operator),
    User(username: 'supervisor1', role: UserRole.supervisor),
  ]; // Mock data

  void _addUser() {
    // Show dialog to add user
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(onAdd: (user) {
        setState(() {
          _users.add(user);
        });
      }),
    );
  }

  void _editUser(User user) {
    // Show dialog to edit
  }

  void _deleteUser(User user) {
    setState(() {
      _users.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final canManage = user?.role == UserRole.supervisor || user?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Management', style: TextStyle(fontSize: 24)),
        actions: [
          if (canManage)
            IconButton(
              icon: Icon(Icons.add, size: 32),
              onPressed: _addUser,
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user.username, style: TextStyle(fontSize: 20)),
            subtitle: Text(user.role.toString().split('.').last, style: TextStyle(fontSize: 18)),
            trailing: canManage
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 32),
                        onPressed: () => _editUser(user),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 32),
                        onPressed: () => _deleteUser(user),
                      ),
                    ],
                  )
                : null,
          );
        },
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
    return AlertDialog(
      title: Text('Add User', style: TextStyle(fontSize: 24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Username'),
            style: TextStyle(fontSize: 20),
          ),
          DropdownButton<UserRole>(
            value: _selectedRole,
            items: UserRole.values.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role.toString().split('.').last, style: TextStyle(fontSize: 20)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
          onPressed: _add,
          child: Text('Add', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}