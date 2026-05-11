import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fellow 4U Home'),
      ),
      body: const Center(
        child: Text('Welcome to Fellow 4U'),
      ),
    );
  }
}
