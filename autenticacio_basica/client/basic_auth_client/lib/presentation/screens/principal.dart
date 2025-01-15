import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Benvingut')),
      body: Center(
        child: Text('Accés concedit!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
