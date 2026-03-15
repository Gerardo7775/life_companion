import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/finance_entities.dart';
import '../state/finance_bloc.dart';
import '../state/finance_state.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({super.key});
  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  final _fmt = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceBloc>().add(LoadFinancesEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (ctx, state) {
            if (state is FinanceLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is FinanceLoaded) return _buildContent(ctx, state);
            return const Center(
              child: Text(
                'Cargando finanzas...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          },
        ),
      ),
      floatingActionButton: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (ctx, state) => FloatingActionButton.extended(
          onPressed: state is FinanceLoaded
              ? () => _showAddTransaction(ctx, state)
              : null,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Movimiento'),
          backgroundColor: AppColors.catFinance,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext ctx, FinanceLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Finanzas', style: Theme.of(ctx).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text('Mes actual', style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 16),
                _buildBalanceHero(ctx, state),
                const SizedBox(height: 16),
                _buildIncomeExpenseRow(ctx, state),
                const SizedBox(height: 16),
                if (state.budgets.isNotEmpty) ...[
                  Text(
                    'Presupuestos',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...state.budgets.map((b) => _buildBudgetCard(ctx, b)),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Movimientos recientes',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        if (state.transactions.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                'Sin movimientos aún.\nToca + para agregar uno.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _buildTransactionTile(ctx, state.transactions[i]),
              childCount: state.transactions.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildBalanceHero(BuildContext ctx, FinanceLoaded state) {
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Text('Balance Total', style: Theme.of(ctx).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            _fmt.format(state.totalBalance),
            style: Theme.of(ctx).textTheme.headlineLarge?.copyWith(
              color: state.totalBalance >= 0
                  ? AppColors.success
                  : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: state.accounts
                .map(
                  (a) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Chip(
                      label: Text(
                        '${a.name}: ${_fmt.format(a.balance)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow(BuildContext ctx, FinanceLoaded state) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.all(14),
            borderColor: AppColors.success.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_downward_rounded,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ingresos',
                      style: Theme.of(
                        ctx,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _fmt.format(state.monthIncome),
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GlassCard(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.all(14),
            borderColor: AppColors.error.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_upward_rounded,
                      color: AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Gastos',
                      style: Theme.of(
                        ctx,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _fmt.format(state.monthExpense),
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(BuildContext ctx, BudgetEntity budget) {
    final color = budget.categoryColor != null
        ? Color(int.parse(budget.categoryColor!.replaceFirst('#', '0xFF')))
        : AppColors.primary;
    final f = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 0,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(14),
        borderColor: budget.isOverBudget
            ? AppColors.error.withValues(alpha: 0.5)
            : AppColors.glassBorder,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  budget.categoryName ?? 'Sin categoría',
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleMedium?.copyWith(fontSize: 14),
                ),
                const Spacer(),
                Text(
                  '${f.format(budget.amountSpent)} / ${f.format(budget.amountLimit)}',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: budget.isOverBudget
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: budget.percentage,
                backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                color: budget.isOverBudget ? AppColors.error : color,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext ctx, TransactionEntity tx) {
    final isIncome = tx.type == 'income';
    final catColor = tx.categoryColor != null
        ? Color(int.parse(tx.categoryColor!.replaceFirst('#', '0xFF')))
        : (isIncome ? AppColors.success : AppColors.error);
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: catColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.note ??
                      tx.categoryName ??
                      (isIncome ? 'Ingreso' : 'Gasto'),
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleMedium?.copyWith(fontSize: 14),
                ),
                Text(
                  '${DateFormat('d MMM', 'es').format(tx.date)} · ${tx.accountName}',
                  style: Theme.of(
                    ctx,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${_fmt.format(tx.amount)}',
            style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
              color: isIncome ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransaction(BuildContext ctx, FinanceLoaded state) {
    String type = 'expense';
    int? selectedAccountId = state.accounts.isNotEmpty
        ? state.accounts.first.id
        : null;
    int? selectedCategoryId;
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bsCtx) => StatefulBuilder(
        builder: (_, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(bsCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nuevo Movimiento',
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              // Type selector
              Row(
                children: [
                  Expanded(
                    child: _typeBtn(
                      'Gasto',
                      'expense',
                      type,
                      (v) => setModalState(() {
                        type = v;
                        selectedCategoryId = null;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _typeBtn(
                      'Ingreso',
                      'income',
                      type,
                      (v) => setModalState(() {
                        type = v;
                        selectedCategoryId = null;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monto *',
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(
                    fontSize: 24,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Account selector
              DropdownButtonFormField<int>(
                initialValue: selectedAccountId,
                dropdownColor: AppColors.bgCard,
                decoration: const InputDecoration(labelText: 'Cuenta'),
                items: state.accounts
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(
                          a.name,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setModalState(() => selectedAccountId = v),
              ),
              const SizedBox(height: 12),
              // Category selector
              DropdownButtonFormField<int>(
                initialValue: selectedCategoryId,
                dropdownColor: AppColors.bgCard,
                decoration: const InputDecoration(
                  labelText: 'Categoría (opcional)',
                ),
                items: state.categories
                    .where((c) => c.type == type)
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          c.name,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setModalState(() => selectedCategoryId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type == 'income'
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  onPressed: () {
                    final amount = double.tryParse(
                      amountCtrl.text.replaceAll(',', '.'),
                    );
                    if (amount == null ||
                        amount <= 0 ||
                        selectedAccountId == null) {
                      return;
                    }
                    ctx.read<FinanceBloc>().add(
                      AddTransactionEvent(
                        TransactionEntity(
                          accountId: selectedAccountId!,
                          categoryId: selectedCategoryId,
                          amount: amount,
                          type: type,
                          date: DateTime.now(),
                          note: noteCtrl.text.trim().isEmpty
                              ? null
                              : noteCtrl.text.trim(),
                        ),
                      ),
                    );
                    Navigator.pop(bsCtx);
                  },
                  child: Text(
                    type == 'income' ? 'Registrar Ingreso' : 'Registrar Gasto',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeBtn(
    String label,
    String value,
    String current,
    Function(String) onTap,
  ) {
    final isSelected = current == value;
    final color = value == 'income' ? AppColors.success : AppColors.error;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? color : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}
