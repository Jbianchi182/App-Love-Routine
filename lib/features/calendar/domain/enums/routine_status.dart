enum RoutineStatus {
  pending,
  completedOnTime,
  completedLate,
  notCompleted,
  canceled;

  String get label {
     switch (this) {
      case RoutineStatus.pending: return 'Pendente';
      case RoutineStatus.completedOnTime: return 'Concluído em tempo';
      case RoutineStatus.completedLate: return 'Concluído com atraso';
      case RoutineStatus.notCompleted: return 'Não concluído';
      case RoutineStatus.canceled: return 'Cancelado';
    }
  }
}
