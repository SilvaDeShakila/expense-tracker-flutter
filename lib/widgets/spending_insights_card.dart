import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_model.dart';

class SpendingInsightsCard extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const SpendingInsightsCard({
    super.key,
    required this.expenses,
  });

  double _monthlyTotal(
    List<ExpenseModel> expenses,
    DateTime month,
  ) {
    return expenses
        .where(
          (expense) =>
              expense.date.year == month.year &&
              expense.date.month == month.month,
        )
        .fold(
          0.0,
          (sum, expense) => sum + expense.amount,
        );
  }

  Map<String, double> _categoryTotals(
    List<ExpenseModel> expenses,
    DateTime month,
  ) {
    final Map<String, double> totals = {};

    for (final expense in expenses) {
      if (expense.date.year != month.year ||
          expense.date.month != month.month) {
        continue;
      }

      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    return totals;
  }

  String _getTopCategory(
    Map<String, double> categoryTotals,
  ) {
    if (categoryTotals.isEmpty) {
      return 'No spending yet';
    }

    String topCategory = categoryTotals.keys.first;
    double topAmount = categoryTotals[topCategory]!;

    for (final entry in categoryTotals.entries) {
      if (entry.value > topAmount) {
        topCategory = entry.key;
        topAmount = entry.value;
      }
    }

    return topCategory;
  }

  double _percentageChange(
    double current,
    double previous,
  ) {
    if (previous == 0) {
      return current == 0 ? 0 : 100;
    }

    return ((current - previous) / previous) * 100;
  }

  String _getInsightMessage({
    required double currentTotal,
    required double previousTotal,
    required String topCategory,
    required int expenseCount,
  }) {
    if (expenseCount == 0) {
      return 'No expenses recorded this month. Start tracking your spending to see useful insights.';
    }

    if (previousTotal == 0 && currentTotal > 0) {
      return 'You have started tracking your spending this month. Keep recording expenses to understand your spending habits.';
    }

    final change = _percentageChange(
      currentTotal,
      previousTotal,
    );

    if (change > 20) {
      return 'Your spending is noticeably higher than last month. Consider reviewing your $topCategory expenses.';
    }

    if (change > 0) {
      return 'Your spending is slightly higher than last month. Keep an eye on your $topCategory expenses.';
    }

    if (change < -20) {
      return 'Great progress! Your spending is significantly lower than last month.';
    }

    if (change < 0) {
      return 'Your spending is lower than last month. Keep maintaining your spending habits.';
    }

    return 'Your spending is similar to last month. Continue tracking your expenses consistently.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final now = DateTime.now();

    final previousMonth = DateTime(
      now.year,
      now.month - 1,
    );

    final currentTotal = _monthlyTotal(
      expenses,
      now,
    );

    final previousTotal = _monthlyTotal(
      expenses,
      previousMonth,
    );

    final currentMonthExpenses = expenses.where(
      (expense) =>
          expense.date.year == now.year &&
          expense.date.month == now.month,
    );

    final categoryTotals = _categoryTotals(
      expenses,
      now,
    );

    final topCategory = _getTopCategory(
      categoryTotals,
    );

    final change = _percentageChange(
      currentTotal,
      previousTotal,
    );

    final isIncrease = change > 0;
    final isDecrease = change < 0;

    final insightMessage = _getInsightMessage(
      currentTotal: currentTotal,
      previousTotal: previousTotal,
      topCategory: topCategory,
      expenseCount: currentMonthExpenses.length,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    color:
                        colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending Insights',
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat(
                          'MMMM yyyy',
                        ).format(now),
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color:
                              colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _InsightItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'This Month',
                    value: NumberFormat.currency(
                      symbol: 'LKR ',
                      decimalDigits: 0,
                    ).format(currentTotal),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InsightItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Expenses',
                    value:
                        '${currentMonthExpenses.length}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _InsightItem(
                    icon: Icons.category_outlined,
                    label: 'Top Category',
                    value: topCategory,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InsightItem(
                    icon: isIncrease
                        ? Icons.trending_up_rounded
                        : isDecrease
                            ? Icons.trending_down_rounded
                            : Icons.trending_flat_rounded,
                    label: 'vs Last Month',
                    value: previousTotal == 0
                        ? 'No data'
                        : '${change.abs().toStringAsFixed(1)}%',
                    iconColor: isIncrease
                        ? Colors.orange
                        : isDecrease
                            ? Colors.green
                            : colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.55),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    size: 21,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insightMessage,
                      style: theme
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        height: 1.45,
                        color:
                            colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _InsightItem({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? colorScheme.primary,
          ),
          const SizedBox(height: 9),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme
                .textTheme
                .titleSmall
                ?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}