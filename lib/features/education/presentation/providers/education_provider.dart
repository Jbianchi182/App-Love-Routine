import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/features/education/domain/models/subject.dart';
import 'package:love_routine_app/features/education/domain/models/grade_entry.dart';

class EducationNotifier extends AsyncNotifier<List<Subject>> {
  late Box<Subject> _subjectBox;
  late Box<GradeEntry> _gradeBox;

  @override
  Future<List<Subject>> build() async {
    _subjectBox = Hive.box<Subject>('subjects');
    _gradeBox = Hive.box<GradeEntry>('grade_entries');
    return _fetchSubjects();
  }

  Future<List<Subject>> _fetchSubjects() async {
    // Load subjects including their grades
    final subjects = _subjectBox.values.toList();
    final allGrades = _gradeBox.values.toList();

    for (var subject in subjects) {
      // Manually populate grades
      subject.grades = allGrades
          .where((g) => g.subjectId == subject.key)
          .toList(); // Use .key for Hive ID
      // Optional: sort grades if needed
      subject.grades.sort((a, b) => a.date.compareTo(b.date));
    }
    return subjects;
  }

  Future<void> addSubject(Subject subject) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _subjectBox.add(subject);
      return _fetchSubjects();
    });
  }

  Future<void> addGrade(dynamic subjectKey, GradeEntry grade) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Ensure subjectId is set
      // Assuming subjectKey handles the ID (int)
      grade.subjectId = subjectKey as int;
      await _gradeBox.add(grade);

      // Update local state if needed for responsiveness, or just re-fetch
      return _fetchSubjects();
    });
  }

  Future<void> deleteSubject(Subject subject) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Delete associated grades too?
      final gradesToDelete = _gradeBox.values
          .where((g) => g.subjectId == subject.key)
          .toList();
      for (var g in gradesToDelete) {
        await g.delete();
      }
      await subject.delete();
      return _fetchSubjects();
    });
  }

  Future<void> deleteGrade(GradeEntry grade) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await grade.delete();
      return _fetchSubjects();
    });
  }
}

final educationProvider =
    AsyncNotifierProvider<EducationNotifier, List<Subject>>(() {
      return EducationNotifier();
    });
