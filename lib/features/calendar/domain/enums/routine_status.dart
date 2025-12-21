import 'package:hive/hive.dart';

part 'routine_status.g.dart';

@HiveType(typeId: 7)
enum RoutineStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completedOnTime,
  @HiveField(2)
  completedLate,
  @HiveField(3)
  notCompleted,
  @HiveField(4)
  canceled;

  String get label {
    switch (this) {
      case RoutineStatus.pending:
        return 'Pendente';
      case RoutineStatus.completedOnTime:
        return 'Concluído em tempo';
      case RoutineStatus.completedLate:
        return 'Concluído com atraso';
      case RoutineStatus.notCompleted:
        return 'Não concluído';
      case RoutineStatus.canceled:
        return 'Cancelado';
    }
  }
}
