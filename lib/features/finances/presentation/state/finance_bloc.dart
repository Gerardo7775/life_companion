import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/finance_local_datasource.dart';
import 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final FinanceLocalDataSource _dataSource;

  FinanceBloc(this._dataSource) : super(FinanceInitial()) {
    on<LoadFinancesEvent>(_onLoad);
    on<AddTransactionEvent>(_onAddTransaction);
  }

  Future<void> _onLoad(
    LoadFinancesEvent event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());
    try {
      final accounts = await _dataSource.getAccounts();
      final transactions = await _dataSource.getTransactions(limit: 50);
      final budgets = await _dataSource.getBudgets();
      final categories = await _dataSource.getCategories();
      final totalBalance = await _dataSource.getTotalBalance();
      final summary = await _dataSource.getMonthSummary();
      emit(
        FinanceLoaded(
          accounts: accounts,
          transactions: transactions,
          budgets: budgets,
          categories: categories,
          totalBalance: totalBalance,
          monthIncome: summary['income'] ?? 0,
          monthExpense: summary['expense'] ?? 0,
        ),
      );
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<FinanceState> emit,
  ) async {
    try {
      await _dataSource.insertTransaction(event.transaction);
      add(LoadFinancesEvent());
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }
}
