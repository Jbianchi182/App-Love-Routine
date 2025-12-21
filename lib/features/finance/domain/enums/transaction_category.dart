import 'package:hive/hive.dart';

part 'transaction_category.g.dart';

@HiveType(typeId: 11)
enum TransactionCategory {
  @HiveField(0)
  salary,
  @HiveField(1)
  food,
  @HiveField(2)
  transport,
  @HiveField(3)
  health,
  @HiveField(4)
  entertainment,
  @HiveField(5)
  education,
  @HiveField(6)
  others,
  @HiveField(7)
  housing,
  @HiveField(8)
  bills;

  String get label {
    switch (this) {
      case TransactionCategory.salary:
        return 'Salário';
      case TransactionCategory.food:
        return 'Alimentação';
      case TransactionCategory.transport:
        return 'Transporte';
      case TransactionCategory.health:
        return 'Saúde';
      case TransactionCategory.entertainment:
        return 'Lazer';
      case TransactionCategory.education:
        return 'Educação';
      case TransactionCategory.others:
        return 'Outros';
      case TransactionCategory.housing:
        return 'Moradia';
      case TransactionCategory.bills:
        return 'Contas';
    }
  }
}
