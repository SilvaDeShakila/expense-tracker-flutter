import 'package:flutter/material.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final double total;
  final int expenseCount;
  final String highestCategory;
  final double highestCategoryAmount;

  const ExpenseSummaryCard({
    super.key,
    required this.total,
    required this.expenseCount,
    required this.highestCategory,
    required this.highestCategoryAmount,
  });

  @override
  Widget build(BuildContext context) {
    final currency = 'LKR ${total.toStringAsFixed(2)}';

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Total',
                    value: currency,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Expenses',
                    value: expenseCount.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _SummaryItem(
              icon: Icons.category_outlined,
              title: 'Top Category',
              value: highestCategory.isEmpty
                  ? 'No data'
                  : '$highestCategory • '
                      'LKR ${highestCategoryAmount.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}