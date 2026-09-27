import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../services/firebase_service.dart';
import '../add_expense/add_expense_screen.dart';
import '../../widgets/expense_card.dart';

class AllExpensesScreen extends StatefulWidget {
  final List<ExpenseModel> expenses;

  const AllExpensesScreen({
    super.key,
    required this.expenses,
  });

  @override
  State<AllExpensesScreen> createState() =>
      _AllExpensesScreenState();
}

class _AllExpensesScreenState
    extends State<AllExpensesScreen> {
  static const int _pageSize = 10;

  final FirebaseService _firebaseService =
      FirebaseService();

  late List<ExpenseModel> _expenses;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _expenses =
        List<ExpenseModel>.from(widget.expenses);
  }

  int get _totalPages {
    if (_expenses.isEmpty) {
      return 1;
    }

    return (_expenses.length + _pageSize - 1) ~/
        _pageSize;
  }

  List<ExpenseModel> get _currentPageExpenses {
    final startIndex =
        _currentPage * _pageSize;

    return _expenses
        .skip(startIndex)
        .take(_pageSize)
        .toList();
  }

  int get _startItem {
    if (_expenses.isEmpty) {
      return 0;
    }

    return (_currentPage * _pageSize) + 1;
  }

  int get _endItem {
    final end =
        (_currentPage + 1) * _pageSize;

    if (end > _expenses.length) {
      return _expenses.length;
    }

    return end;
  }

  Future<void> _refreshExpenses() async {
    try {
      final updatedExpenses =
          await _firebaseService
              .getExpenses()
              .first;

      if (!mounted) return;

      setState(() {
        _expenses = updatedExpenses;

        if (_currentPage >= _totalPages) {
          _currentPage = _totalPages - 1;
        }

        if (_currentPage < 0) {
          _currentPage = 0;
        }
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to refresh expenses.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editExpense(
    ExpenseModel expense,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          expense: expense,
        ),
      ),
    );

    await _refreshExpenses();
  }

  Future<void> _deleteExpense(
    ExpenseModel expense,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Expense?',
          ),
          content: Text(
            'Are you sure you want to delete '
            '"${expense.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _firebaseService.deleteExpense(
        expense.id,
      );

      if (!mounted) return;

      setState(() {
        _expenses.removeWhere(
          (item) => item.id == expense.id,
        );

        if (_currentPage >= _totalPages) {
          _currentPage = _totalPages - 1;
        }

        if (_currentPage < 0) {
          _currentPage = 0;
        }
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Expense deleted successfully.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete expense.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showExpenseDetails(
    ExpenseModel expense,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return _ExpenseDetailsSheet(
          expense: expense,
          onEdit: () {
            Navigator.pop(context);
            _editExpense(expense);
          },
          onDelete: () {
            Navigator.pop(context);
            _deleteExpense(expense);
          },
        );
      },
    );
  }

  void _goToPreviousPage() {
    if (_currentPage <= 0) {
      return;
    }

    setState(() {
      _currentPage--;
    });
  }

  void _goToNextPage() {
    if (_currentPage >= _totalPages - 1) {
      return;
    }

    setState(() {
      _currentPage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final pageExpenses =
        _currentPageExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Expenses',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _expenses.isEmpty
          ? _buildEmptyState(
              theme,
              colorScheme,
            )
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Expense History',
                              style: theme
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Showing $_startItem–$_endItem '
                              'of ${_expenses.length} expenses',
                              style: theme
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration:
                            BoxDecoration(
                          color: colorScheme
                              .primaryContainer,
                          borderRadius:
                              BorderRadius
                                  .circular(20),
                        ),
                        child: Text(
                          'Page ${_currentPage + 1}'
                          ' / $_totalPages',
                          style: TextStyle(
                            color: colorScheme
                                .onPrimaryContainer,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      16,
                    ),
                    itemCount:
                        pageExpenses.length,
                    itemBuilder:
                        (context, index) {
                      final expense =
                          pageExpenses[index];

                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 12,
                        ),
                        child: GestureDetector(
                          onTap: () =>
                              _showExpenseDetails(
                            expense,
                          ),
                          child: ExpenseCard(
                            expense: expense,
                            onEdit: () =>
                                _editExpense(
                              expense,
                            ),
                            onDelete: () =>
                                _deleteExpense(
                              expense,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildPagination(
                  colorScheme,
                ),
              ],
            ),
    );
  }

  Widget _buildPagination(
    ColorScheme colorScheme,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          16,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _currentPage > 0
                        ? _goToPreviousPage
                        : null,
                icon: const Icon(
                  Icons
                      .chevron_left_rounded,
                ),
                label:
                    const Text('Previous'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed:
                    _currentPage <
                            _totalPages - 1
                        ? _goToNextPage
                        : null,
                icon: const Icon(
                  Icons
                      .chevron_right_rounded,
                ),
                label:
                    const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: colorScheme
                    .primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 44,
                color: colorScheme
                    .onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Expenses Found',
              style: theme
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no expenses to display.',
              textAlign:
                  TextAlign.center,
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseDetailsSheet
    extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseDetailsSheet({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getCategoryIcon(
    String category,
  ) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_outlined;

      case 'Transport':
        return Icons
            .directions_car_outlined;

      case 'Shopping':
        return Icons
            .shopping_bag_outlined;

      case 'Bills':
        return Icons
            .receipt_long_outlined;

      case 'Health':
        return Icons
            .health_and_safety_outlined;

      case 'Education':
        return Icons.school_outlined;

      case 'Entertainment':
        return Icons.movie_outlined;

      default:
        return Icons.more_horiz_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final formattedDate =
        DateFormat('dd MMMM yyyy')
            .format(expense.date);

    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration:
                      BoxDecoration(
                    color: colorScheme
                        .primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(
                      expense.category,
                    ),
                    color: colorScheme
                        .onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        expense.title,
                        style: theme
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        expense.category,
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon:
                  Icons.payments_outlined,
              label: 'Amount',
              value:
                  'LKR ${expense.amount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 14),
            _DetailRow(
              icon: Icons
                  .calendar_month_outlined,
              label: 'Date',
              value: formattedDate,
            ),
            if (expense.note.isNotEmpty) ...[
              const SizedBox(height: 14),
              _DetailRow(
                icon:
                    Icons.notes_outlined,
                label: 'Note',
                value: expense.note,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons
                          .edit_outlined,
                    ),
                    label:
                        const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child:
                      FilledButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons
                          .delete_outline,
                    ),
                    label:
                        const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.45),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color:
                colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  label,
                  style: theme
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}