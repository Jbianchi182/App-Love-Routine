enum CalendarEventType { routine, diet, medication, appointment }

class CalendarEvent {
  final String id;
  final String title;
  final DateTime time;
  final CalendarEventType type;
  final dynamic originalObject;
  final bool isCompleted;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.time,
    required this.type,
    required this.originalObject,
    this.isCompleted = false,
  });
}
