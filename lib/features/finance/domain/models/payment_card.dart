import 'package:hive/hive.dart';

part 'payment_card.g.dart';

@HiveType(typeId: 15)
class PaymentCard extends HiveObject {
  @HiveField(0)
  late String lastFourDigits;

  @HiveField(1)
  late String brand; // Visa, Mastercard, etc.

  @HiveField(2)
  late bool isCredit; // true for Credit, false for Debit

  @HiveField(3)
  String? nickname; // Optional: "Cartão do Nubank"

  PaymentCard({
    required this.lastFourDigits,
    required this.brand,
    required this.isCredit,
    this.nickname,
  });

  String get displayName => nickname ?? '$brand **** $lastFourDigits';
  String get typeLabel => isCredit ? 'Crédito' : 'Débito';
}
