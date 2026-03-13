import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final int? id;
  final int accountId;
  final String accountName;
  final int? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final double amount;
  final String type; // income | expense | transfer
  final DateTime date;
  final String? note;

  const TransactionEntity({
    this.id,
    required this.accountId,
    this.accountName = '',
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [id, amount, date, type];
}

class AccountEntity extends Equatable {
  final int? id;
  final String name;
  final String type;
  final double balance;
  final String currency;

  const AccountEntity({
    this.id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.currency = 'MXN',
  });

  @override
  List<Object?> get props => [id, name, balance];
}

class FinanceCategoryEntity extends Equatable {
  final int? id;
  final String name;
  final String type; // income | expense
  final String? colorHex;
  final String? iconName;

  const FinanceCategoryEntity({
    this.id,
    required this.name,
    required this.type,
    this.colorHex,
    this.iconName,
  });

  @override
  List<Object?> get props => [id, name, type];
}

class BudgetEntity extends Equatable {
  final int? id;
  final int categoryId;
  final String? categoryName;
  final String? categoryColor;
  final double amountLimit;
  final double amountSpent;
  final String period;

  const BudgetEntity({
    this.id,
    required this.categoryId,
    this.categoryName,
    this.categoryColor,
    required this.amountLimit,
    this.amountSpent = 0,
    this.period = 'monthly',
  });

  double get percentage =>
      amountLimit > 0 ? (amountSpent / amountLimit).clamp(0.0, 1.0) : 0;
  bool get isOverBudget => amountSpent > amountLimit;

  @override
  List<Object?> get props => [id, categoryId, amountLimit, amountSpent];
}
