import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2) // Added HiveType for the enum
enum TransactionType { 
  @HiveField(0) income, 
  @HiveField(1) expense 
}

@HiveType(typeId: 3) // Added HiveType for the enum
enum TransactionCategory {
  @HiveField(0) food,
  @HiveField(1) transport,
  @HiveField(2) entertainment,
  @HiveField(3) utilities,
  @HiveField(4) shopping,
  @HiveField(5) health,
  @HiveField(6) education,
  @HiveField(7) other,
  @HiveField(8) salary,
  @HiveField(9) freelance,
  @HiveField(10) bonus,
}

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final TransactionCategory category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final DateTime createdAt;

  Transaction({
    String? id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Transaction.empty() {
    return Transaction(
      amount: 0,
      type: TransactionType.expense,
      category: TransactionCategory.food,
      date: DateTime.now(),
    );
  }

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? description,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}