import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../services/budget_service.dart';
import '../../services/firebase_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final BudgetService _budgetService = BudgetService();
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _amountController = TextEditingController();

  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _chooseMonth() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: 'Choose a date in the month',
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
        _amountController.clear();
      });
    }
  }

  Future<void> _saveBudget() async {
    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', ''),
    );

    if (amount == null || !amount.isFinite || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid budget amount greater than zero.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _budgetService.setMonthlyBudget(
        month: _selectedMonth,
        amount: amount,
      );

      if (!mounted) return;

      _amountController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly budget saved successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save budget: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  double _monthlyExpenses(List<ExpenseModel> expenses) {
    return expenses
        .where(
          (expense) =>
              expense.date.year == _selectedMonth.year &&
              expense.date.month == _selectedMonth.month,
        )
        .fold<double>(0, (total, expense) => total + expense.amount);
  }

  String _money(double amount) {
    return 'LKR ${NumberFormat('#,##0.00').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Budget Tracking',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: _firebaseService.getExpenses(),
        builder: (context, expenseSnapshot) {
          if (expenseSnapshot.hasError) {
            return Center(
              child: Text('Could not load expenses. Please try again.'),
            );
          }

          if (expenseSnapshot.connectionState == ConnectionState.waiting &&
              !expenseSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final expenses = expenseSnapshot.data ?? <ExpenseModel>[];
          final spent = _monthlyExpenses(expenses);

          return StreamBuilder<double?>(
            stream: _budgetService.getMonthlyBudget(_selectedMonth),
            builder: (context, budgetSnapshot) {
              if (budgetSnapshot.hasError) {
                return Center(
                  child: Text('Could not load budget: ${budgetSnapshot.error}'),
                );
              }

              if (budgetSnapshot.connectionState ==
                      ConnectionState.waiting &&
                  !budgetSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final budget = budgetSnapshot.data;
              final hasBudget = budget != null && budget > 0;
              final remaining = hasBudget ? budget - spent : 0.0;
              final progress = hasBudget
                  ? (spent / budget).clamp(0.0, 1.0).toDouble()
                  : 0.0;
              final exceeded = hasBudget && spent > budget;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget month',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _chooseMonth,
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: Text(monthLabel),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: hasBudget
                                  ? 'Update monthly budget (LKR)'
                                  : 'Monthly budget (LKR)',
                              hintText: hasBudget
                                  ? budget.toStringAsFixed(2)
                                  : 'e.g. 50000',
                              prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _isSaving ? null : _saveBudget,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                _isSaving ? 'Saving...' : 'Save Budget',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly overview',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _OverviewRow(
                            label: 'Total spent',
                            value: _money(spent),
                            icon: Icons.payments_outlined,
                          ),
                          const SizedBox(height: 14),
                          _OverviewRow(
                            label: 'Monthly budget',
                            value: hasBudget ? _money(budget) : 'Not set',
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                          if (hasBudget) ...[
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 12,
                                color: exceeded
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${(spent / budget * 100).toStringAsFixed(1)}% of budget used',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              exceeded
                                  ? 'Over budget by ${_money(spent - budget)}'
                                  : '${_money(remaining)} remaining',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: exceeded
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Set a budget above to track your monthly spending progress.',
                            ),
                          ],
                          if (exceeded) ...[
                            const SizedBox(height: 12),
                            Text(
                              'You have exceeded your monthly budget.',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _OverviewRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Flexible(child: Text(label)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}



