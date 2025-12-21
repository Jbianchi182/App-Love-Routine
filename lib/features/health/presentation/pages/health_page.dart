import 'package:flutter/material.dart';
import 'package:love_routine_app/features/health/presentation/pages/health_view.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bem-Estar')),
      body: const HealthView(),
    );
  }
}
