import 'package:hive/hive.dart';

part 'transaction_type.g.dart';

@HiveType(typeId: 10)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense;

  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Receita';
      case TransactionType.expense:
        return 'Despesa';
    }
  }
}
