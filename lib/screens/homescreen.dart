import 'package:flutter/material.dart';
import 'package:night_walkers_app/widgets/panic_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Night Walkers App'),
      ),
      body: Center(
        child: PanicButton(),
      ),
    );
  }
}