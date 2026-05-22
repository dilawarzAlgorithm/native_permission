import 'package:flutter/material.dart';
import 'package:native_permission/screens/dashboard.dart';
import 'package:native_permission/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.delayed(const Duration(seconds: 2));

      final now = DateTime.now().toIso8601String();
      await prefs.setString('last_bg_run', 'Ran at: $now');

      debugPrint("Background task $task executed successfully");
      return Future.value(true);
    } catch (err) {
      debugPrint("Background task failed: $err");
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);

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
