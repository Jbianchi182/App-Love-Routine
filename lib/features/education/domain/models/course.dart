import 'package:hive/hive.dart';
import 'package:love_routine_app/features/education/domain/models/subject.dart';

part 'course.g.dart';

@HiveType(typeId: 25)
class Course extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String institution;

  @HiveField(2)
  int? gradingSchemeId;

  // Runtime apenas (não salvo diretamente aqui, relacional)
  List<Subject> subjects = [];
}
