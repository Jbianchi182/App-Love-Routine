import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:love_routine_app/features/education/domain/models/course.dart';
import 'package:love_routine_app/features/education/domain/models/subject.dart';
import 'package:love_routine_app/features/education/presentation/providers/education_provider.dart';
import 'package:love_routine_app/features/education/presentation/pages/subject_details_page.dart';

class CourseDetailsPage extends ConsumerWidget {
  final Course course;

  const CourseDetailsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep UI reactive
    final courses = ref.watch(educationProvider).asData?.value ?? [];
    final currentCourse = courses.firstWhere(
      (c) => c.key == course.key,
      orElse: () => course,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentCourse.name} - ${currentCourse.institution}'),
      ),
      body: currentCourse.subjects.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Nenhuma matéria cadastrada neste curso.\nToque no + para adicionar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: currentCourse.subjects.length,
              itemBuilder: (context, index) {
                final subject = currentCourse.subjects[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(Icons.menu_book, color: Theme.of(context).primaryColor),
                    ),
                    title: Text(subject.name),
                    subtitle: Text('Professor(a): ${subject.teacherName ?? "N/A"}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubjectDetailsPage(subject: subject, course: currentCourse),
                        ),
                      );
                    },
                    onLongPress: () => _confirmDeleteSubject(context, ref, subject),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubjectDialog(context, ref, currentCourse),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Matéria'),
      ),
    );
  }

  Future<void> _showAddSubjectDialog(BuildContext context, WidgetRef ref, Course currentCourse) async {
    final nameController = TextEditingController();
    final teacherController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Matéria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome da Matéria'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: teacherController,
              decoration: const InputDecoration(labelText: 'Professor(a)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newSubject = Subject()
                  ..name = nameController.text
                  ..teacherName = teacherController.text.isEmpty ? null : teacherController.text
                  ..courseId = currentCourse.key;

                ref.read(educationProvider.notifier).addSubject(newSubject);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSubject(BuildContext context, WidgetRef ref, Subject subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Matéria'),
        content: Text('Tem certeza que deseja excluir ${subject.name}? Todas as notas serão perdidas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(educationProvider.notifier).deleteSubject(subject);
              Navigator.pop(ctx);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
