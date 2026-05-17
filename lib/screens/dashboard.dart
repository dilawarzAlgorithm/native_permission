import 'package:flutter/material.dart';
import 'package:native_permission/widgets/bluetooth.dart';
import 'package:native_permission/widgets/camera.dart';
import 'package:native_permission/widgets/gps.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedInd = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Native App'), centerTitle: false),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedInd,
        onDestinationSelected: (index) {
          setState(() {
            _selectedInd = index;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.camera), label: 'Camera'),
          NavigationDestination(
            icon: Icon(Icons.bluetooth),
            label: 'Bluetooth',
          ),
          NavigationDestination(icon: Icon(Icons.gps_fixed), label: 'GPS'),
        ],
      ),
      body: <Widget>[Camera(), Bluetooth(), Gps()][_selectedInd],
    );
  }
}
