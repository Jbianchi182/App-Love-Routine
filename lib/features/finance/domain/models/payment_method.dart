import 'package:hive/hive.dart';

part 'payment_method.g.dart';

@HiveType(typeId: 22)
class PaymentMethod extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String type; // 'credit', 'debit', 'cash', 'pix', 'other'

  @HiveField(3)
  late int colorValue; // ARGB int

  @HiveField(4)
  double? limit;

  @HiveField(5)
  int? closingDay;

  @HiveField(6)
  int? dueDay;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.colorValue,
    this.limit,
    this.closingDay,
    this.dueDay,
  });
}
