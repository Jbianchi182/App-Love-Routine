import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/education/domain/models/course.dart';
import 'package:love_routine_app/features/education/domain/models/grading_scheme.dart';
import 'package:love_routine_app/features/education/presentation/providers/education_provider.dart';
import 'package:love_routine_app/features/education/presentation/pages/course_details_page.dart';
import 'package:love_routine_app/features/education/presentation/pages/grading_schemes_page.dart';
import 'package:love_routine_app/features/education/presentation/providers/grading_scheme_provider.dart';

class EducationPage extends ConsumerWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(educationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Cursos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_course',
        onPressed: () => _showCourseDialog(context, ref),
        label: const Text('+ Adicionar Curso'),
      ),
      body: subjectsAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(child: Text('Nenhum curso cadastrado.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildCourseCard(context, ref, course);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    WidgetRef ref,
    Course course,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CourseDetailsPage(course: course),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(Icons.school, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.institution,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCourseDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    String? selectedInstitution;
    String? customInstitutionName;
    int? customSchemeId;

    // Tabela de Presets (Nome da Instituição -> Fórmula)
    final presets = {
      'USP / FATEC (Simples)': '(P1 + P2) / 2',
      'USP / Unicamp (Ponderada)': '(P1 + P2 * 2) / 3',
      'UFRJ / UFSC / UnB': '(P1 + P2 + P3) / 3',
      'UFMG (100 pts)': 'P1 + P2 + P3',
      'USCS': '(P1 + ((P2 + Atividades) / 2)) / 2',
      'Padrão c/ Atividades': '(P1 * 4 + P2 * 4 + Atividades * 2) / 10',
    };

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final schemes = ref.watch(gradingSchemeProvider).asData?.value ?? [];
            final isCustom = selectedInstitution == 'Outra Instituição';
            
            return AlertDialog(
              title: const Text('Novo Curso'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome do Curso (ex: Engenharia)'),
                    ),
                    const SizedBox(height: 16),
                    DropdownMenu<String>(
                      label: const Text('Instituição'),
                      expandedInsets: EdgeInsets.zero,
                      dropdownMenuEntries: [
                        ...presets.keys.map((k) => DropdownMenuEntry<String>(value: k, label: k)),
                        const DropdownMenuEntry<String>(value: 'Outra Instituição', label: 'Outra Instituição'),
                      ],
                      onSelected: (val) {
                        setState(() {
                          selectedInstitution = val;
                        });
                      },
                    ),
                    
                    if (isCustom) ...[
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (val) {
                          customInstitutionName = val;
                        },
                        decoration: const InputDecoration(labelText: 'Nome da Instituição'),
                      ),
                      const SizedBox(height: 16),
                      if (schemes.isNotEmpty)
                        DropdownMenu<int>(
                          label: const Text('Fórmula de Avaliação'),
                          expandedInsets: EdgeInsets.zero,
                          dropdownMenuEntries: schemes.map((s) => DropdownMenuEntry<int>(value: s.key, label: s.name)).toList(),
                          onSelected: (val) {
                            setState(() {
                              customSchemeId = val;
                            });
                          },
                        )
                      else
                        const Text(
                          'Nenhuma fórmula cadastrada. Crie uma em "Fórmulas de avaliação" primeiro.',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                    ] else if (selectedInstitution != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'Fórmula selecionada automaticamente:',
                                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              presets[selectedInstitution]!,
                              style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && selectedInstitution != null) {
                      String finalInstitutionName = isCustom ? (customInstitutionName ?? 'Desconhecida') : selectedInstitution!;
                      int? finalSchemeId;

                      if (isCustom) {
                        finalSchemeId = customSchemeId;
                      } else {
                        // Look for an existing scheme with this exact formula, or create a new one!
                        final formulaStr = presets[selectedInstitution]!;
                        final existingScheme = schemes.firstWhere(
                          (s) => s.formula == formulaStr,
                          orElse: () {
                            final newScheme = GradingScheme()
                              ..name = 'Fórmula $selectedInstitution'
                              ..formula = formulaStr;
                            ref.read(gradingSchemeProvider.notifier).addScheme(newScheme);
                            return newScheme;
                          },
                        );
                        finalSchemeId = existingScheme.key;
                      }

                      final course = Course()
                        ..name = nameController.text
                        ..institution = finalInstitutionName
                        ..gradingSchemeId = finalSchemeId;
                      
                      ref.read(educationProvider.notifier).addCourse(course);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
