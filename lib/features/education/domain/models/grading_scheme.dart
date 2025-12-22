import 'package:hive/hive.dart';

part 'grading_scheme.g.dart';

@HiveType(typeId: 20)
class GradingScheme extends HiveObject {
  @HiveField(0)
  late String name; // e.g., "Engineering Standard"

  @HiveField(1)
  late String formula; // e.g., "(N1 + N2) / 2"
}
