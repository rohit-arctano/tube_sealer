// import 'package:flutter/material.dart';
// import 'package:tube_sealer/app/theme/app_colors.dart';
// import '../../../core/services/auth_service.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _usernameController = TextEditingController(text: 'Admin');
//   final TextEditingController _passwordController = TextEditingController();
//   final List<String> _userOptions = ['Admin', 'Supervisor', 'Operator'];
//   int _userIndex = 0;
//   String? _error;
//   bool _isLoading = false;
//   bool _logoActive = false;

//   void _cycleUser() {
//     setState(() {
//       _userIndex = (_userIndex + 1) % _userOptions.length;
//       _usernameController.text = _userOptions[_userIndex];
//     });
//   }

//   void _login() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     final username = _usernameController.text;
//     final password = _passwordController.text;

//     if (password.isEmpty) {
//       setState(() {
//         _error = 'Password cannot be empty';
//         _isLoading = false;
//       });
//       return;
//     }

//     try {
//       final user = await AuthService().login(username, password);
//       if (!mounted) return;
//       if (user != null) {
//         Navigator.of(context).pushReplacementNamed('/shell');
//       } else {
//         setState(() {
//           _error = 'Invalid username or password';
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = 'Login failed: $e';
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
     
//       body: Padding(
//         padding: const EdgeInsets.all(28.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 220,
//               height: 180,
//               decoration: BoxDecoration(
//                 color:  Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               alignment: Alignment.center,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'KAIRISH',
//                     style: TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.w900,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     'Innotech',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primary.withValues(alpha: 0.8),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 24),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text('User name', style: TextStyle(fontSize: 20)),
//             ),
//             SizedBox(height: 8),
//             SizedBox(
//               height: 70,
//               child: TextFormField(
//                 controller: _usernameController,
//                 readOnly: true,
//                 style: TextStyle(fontSize: 24),
//                 decoration: InputDecoration(
//                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.blueAccent, width: 3),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.blueAccent, width: 4),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   suffixIcon: SizedBox(
//                     height: 70,
//                     width: 70,
//                     child: IconButton(
//                       icon: Icon(Icons.arrow_drop_down, size: 36),
//                       onPressed: _cycleUser,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text('Password', style: TextStyle(fontSize: 20)),
//             ),
//             SizedBox(height: 8),
//             SizedBox(
//               height: 70,
//               child: TextFormField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 style: TextStyle(fontSize: 24),
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.blueAccent, width: 3),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               height: 70,
//               child: ElevatedButton(
//                 onPressed: _login,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: Colors.white, // ensures text/icon color is white
//                 ),
//                 child: _isLoading
//                     ? CircularProgressIndicator(color: Colors.white)
//                     : Text(
//                         '✔',
//                         style: TextStyle(
//                           fontSize: 42,
//                           fontWeight: FontWeight.bold,
//                           // color here is optional when foregroundColor is enforced
//                         ),
//                       ),
//               ),
//             ),
//             if (_error != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 20),
//                 child: Text(_error!, style: TextStyle(color: Colors.red, fontSize: 18)),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }