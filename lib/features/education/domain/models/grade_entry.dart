import 'package:hive/hive.dart';

part 'grade_entry.g.dart';

@HiveType(typeId: 6)
class GradeEntry extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String name; // e.g. "Midterm Exam"

  @HiveField(2)
  late double score;

  @HiveField(3)
  double? weight;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late int subjectId;
}
