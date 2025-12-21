import 'package:hive/hive.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_type.dart';
import 'package:love_routine_app/features/finance/domain/enums/transaction_category.dart';

part 'finance_transaction.g.dart';

@HiveType(typeId: 12)
class FinanceTransaction extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late TransactionType type;

  @HiveField(5)
  late TransactionCategory category;
}
