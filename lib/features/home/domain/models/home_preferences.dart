import 'package:hive/hive.dart';

part 'home_preferences.g.dart';

@HiveType(typeId: 21)
class HomePreferences extends HiveObject {
  @HiveField(0)
  List<String> sectionOrder = ['finance', 'upcoming'];

  @HiveField(1)
  int upcomingDaysRange = 7;

  @HiveField(2)
  List<String> pinnedModules = ['finance', 'health', 'education'];

  @HiveField(3)
  bool isGridView = true;
}
