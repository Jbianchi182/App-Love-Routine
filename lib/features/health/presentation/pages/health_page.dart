import 'package:flutter/material.dart';
import 'package:love_routine_app/features/diets/presentation/pages/diet_page.dart';
import 'package:love_routine_app/features/health/presentation/pages/health_view.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bem-Estar'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Saúde', icon: Icon(Icons.favorite)),
              Tab(text: 'Dieta', icon: Icon(Icons.restaurant)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HealthView(),
            DietPage(), // Reusing the existing DietPage
          ],
        ),
      ),
    );
  }
}
