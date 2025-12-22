import 'package:hive/hive.dart';

part 'home_preferences.g.dart';

@HiveType(typeId: 21)
class HomePreferences extends HiveObject {
  @HiveField(0)
  List<String> sectionOrder = ['finance', 'calendar', 'upcoming'];

  @HiveField(1)
  int upcomingDaysRange = 7;
}
