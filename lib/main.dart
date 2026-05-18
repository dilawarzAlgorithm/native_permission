import 'package:flutter/material.dart';
import 'package:native_permission/screens/dashboard.dart';
import 'package:native_permission/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: const MyApp()));
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
