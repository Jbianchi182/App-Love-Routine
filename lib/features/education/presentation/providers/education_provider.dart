import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:love_routine_app/features/education/domain/models/subject.dart';
import 'package:love_routine_app/features/education/domain/models/course.dart';
import 'package:love_routine_app/features/education/domain/models/grade_entry.dart';

class EducationNotifier extends AsyncNotifier<List<Course>> {
  late Box<Course> _courseBox;
  late Box<Subject> _subjectBox;
  late Box<GradeEntry> _gradeBox;

  @override
  Future<List<Course>> build() async {
    _courseBox = Hive.box<Course>('courses');
    _subjectBox = Hive.box<Subject>('subjects');
    _gradeBox = Hive.box<GradeEntry>('grade_entries');
    return _fetchData();
  }

  Future<List<Course>> _fetchData() async {
    // 1. Data Migration: Create default course for orphan subjects
    final subjects = _subjectBox.values.toList();
    final orphanSubjects = subjects.where((s) => s.courseId == null).toList();
    
    if (orphanSubjects.isNotEmpty) {
      Course? defaultCourse;
      try {
        defaultCourse = _courseBox.values.firstWhere((c) => c.name == 'Curso Geral');
      } catch (e) {
        defaultCourse = Course()
          ..name = 'Curso Geral'
          ..institution = 'Geral'
          ..gradingSchemeId = null;
        await _courseBox.add(defaultCourse);
      }
      
      for (var s in orphanSubjects) {
        s.courseId = defaultCourse.key;
        await s.save();
      }
    }

    // 2. Load Courses
    final courses = _courseBox.values.toList();
    final allGrades = _gradeBox.values.toList();

    for (var course in courses) {
      course.subjects = _subjectBox.values
          .where((s) => s.courseId == course.key)
          .toList();
      
      for (var subject in course.subjects) {
        subject.grades = allGrades
            .where((g) => g.subjectId == subject.key)
            .toList();
        subject.grades.sort((a, b) => a.date.compareTo(b.date));
      }
    }
    
    return courses;
  }

  Future<void> addCourse(Course course) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _courseBox.add(course);
      return _fetchData();
    });
  }

  Future<void> deleteCourse(Course course) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final subjectsToDelete = _subjectBox.values.where((s) => s.courseId == course.key).toList();
      for (var s in subjectsToDelete) {
        await deleteSubject(s, skipFetch: true);
      }
      await course.delete();
      return _fetchData();
    });
  }

  Future<void> addSubject(Subject subject) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _subjectBox.add(subject);
      return _fetchData();
    });
  }

  Future<void> addGrade(dynamic subjectKey, GradeEntry grade) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      grade.subjectId = subjectKey as int;
      await _gradeBox.add(grade);
      return _fetchData();
    });
  }

  Future<void> deleteSubject(Subject subject, {bool skipFetch = false}) async {
    if (!skipFetch) state = const AsyncValue.loading();
    
    final gradesToDelete = _gradeBox.values.where((g) => g.subjectId == subject.key).toList();
    for (var g in gradesToDelete) {
      await g.delete();
    }
    await subject.delete();
    
    if (!skipFetch) {
      state = await AsyncValue.guard(() async => _fetchData());
    }
  }

  Future<void> deleteGrade(GradeEntry grade) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await grade.delete();
      return _fetchData();
    });
  }

  Future<void> addNote(Subject subject, String note) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      subject.notes.add(note);
      await subject.save();
      return _fetchData();
    });
  }

  Future<void> removeNote(Subject subject, String note) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      subject.notes.remove(note);
      await subject.save();
      return _fetchData();
    });
  }
}

final educationProvider =
    AsyncNotifierProvider<EducationNotifier, List<Course>>(() {
      return EducationNotifier();
    });
