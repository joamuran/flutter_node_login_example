import 'package:flutter/material.dart';

class PantallaPrincipal extends StatelessWidget {
  PantallaPrincipal({required this.user, super.key});

  String user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Benvingut $user')),
      body: const Center(
        child: Text('Accés concedit!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
