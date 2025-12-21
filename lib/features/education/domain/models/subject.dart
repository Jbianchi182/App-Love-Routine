import 'package:hive/hive.dart';
import 'package:love_routine_app/features/education/domain/models/grade_entry.dart';

part 'subject.g.dart';

@HiveType(typeId: 5)
class Subject extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String name; // e.g. Mathematics

  @HiveField(2)
  String? teacherName;

  @HiveField(3)
  String? room;

  // Grading specifics
  @HiveField(4)
  double? passingScore;

  @HiveField(5)
  double? maxScore;

  // Runtime only - populated by provider
  List<GradeEntry> grades = [];
}
