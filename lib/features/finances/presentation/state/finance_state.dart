import 'package:equatable/equatable.dart';
import '../../domain/entities/finance_entities.dart';

// Events
abstract class FinanceEvent extends Equatable {
  const FinanceEvent();
  @override
  List<Object?> get props => [];
}

class LoadFinancesEvent extends FinanceEvent {}

class AddTransactionEvent extends FinanceEvent {
  final TransactionEntity transaction;
  const AddTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

// States
abstract class FinanceState extends Equatable {
  const FinanceState();
  @override
  List<Object?> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<AccountEntity> accounts;
  final List<TransactionEntity> transactions;
  final List<BudgetEntity> budgets;
  final List<FinanceCategoryEntity> categories;
  final double totalBalance;
  final double monthIncome;
  final double monthExpense;
  const FinanceLoaded({
    required this.accounts,
    required this.transactions,
    required this.budgets,
    required this.categories,
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpense,
  });
  @override
  List<Object?> get props => [accounts, transactions, budgets, totalBalance];
}

class FinanceError extends FinanceState {
  final String message;
  const FinanceError(this.message);
  @override
  List<Object?> get props => [message];
}
