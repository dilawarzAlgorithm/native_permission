import 'package:flutter/material.dart';
import 'package:native_permission/screens/dashboard.dart';
import 'package:native_permission/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Permisssions App',
      home: DashboardScreen(),
      theme: theme,
    );
  }
}
