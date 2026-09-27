import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/expense_chart.dart';
import '../../widgets/expense_summary_card.dart';
import '../../widgets/spending_insights_card.dart';
import '../add_expense/add_expense_screen.dart';
import 'all_expenses_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _recentExpenseLimit = 10;

  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String? _selectedCategory;
  DateTime? _selectedMonth;

  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  final List<String> _categories = const [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Education',
    'Entertainment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    _loadUserProfile();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getUserProfile();

      if (!mounted) return;

      setState(() {
        _userProfile = profile;
        _isLoadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  String get _displayName {
    final fullName = _userProfile?['fullName'];

    if (fullName is String && fullName.trim().isNotEmpty) {
      return fullName.trim();
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user?.displayName != null &&
        user!.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }

    return 'there';
  }

  String get _firstName {
    final name = _displayName;

    if (name == 'there') {
      return name;
    }

    return name.split(' ').first;
  }

  String get _greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 17) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }

  bool get _hasActiveFilters {
    return _selectedCategory != null ||
        _selectedMonth != null ||
        _searchQuery.isNotEmpty;
  }

  int get _activeFilterCount {
    int count = 0;

    if (_selectedCategory != null) {
      count++;
    }

    if (_selectedMonth != null) {
      count++;
    }

    if (_searchQuery.isNotEmpty) {
      count++;
    }

    return count;
  }

  List<ExpenseModel> _filterExpenses(
    List<ExpenseModel> expenses,
  ) {
    return expenses.where((expense) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          expense.title.toLowerCase().contains(_searchQuery) ||
          expense.category.toLowerCase().contains(_searchQuery) ||
          expense.note.toLowerCase().contains(_searchQuery);

      final matchesCategory =
          _selectedCategory == null ||
          expense.category == _selectedCategory;

      final matchesMonth =
          _selectedMonth == null ||
          (expense.date.year == _selectedMonth!.year &&
              expense.date.month == _selectedMonth!.month);

      return matchesSearch && matchesCategory && matchesMonth;
    }).toList();
  }

  double _calculateTotal(
    List<ExpenseModel> expenses,
  ) {
    return expenses.fold(
      0.0,
      (totalAmount, expense) => totalAmount + expense.amount,
    );
  }

  Map<String, double> _calculateCategoryTotals(
    List<ExpenseModel> expenses,
  ) {
    final Map<String, double> totals = {};

    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    return totals;
  }

  String _getTopCategory(
    Map<String, double> totals,
  ) {
    if (totals.isEmpty) {
      return '';
    }

    return totals.entries
        .reduce(
          (a, b) => a.value >= b.value ? a : b,
        )
        .key;
  }

  double _getTopCategoryAmount(
    Map<String, double> totals,
  ) {
    if (totals.isEmpty) {
      return 0;
    }

    return totals.entries
        .reduce(
          (a, b) => a.value >= b.value ? a : b,
        )
        .value;
  }

  Future<void> _selectMonth() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      helpText: 'Select a month',
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedMonth = DateTime(
        picked.year,
        picked.month,
      );
    });
  }

  void _clearAllFilters() {
    _searchController.clear();

    setState(() {
      _selectedCategory = null;
      _selectedMonth = null;
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  void _clearCategoryFilter() {
    setState(() {
      _selectedCategory = null;
    });
  }

  void _clearMonthFilter() {
    setState(() {
      _selectedMonth = null;
    });
  }

  Future<void> _showCategoryFilter() async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Category',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a category to view matching expenses.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildCategoryOption(
                          context,
                          label: 'All Categories',
                          icon: Icons.category_outlined,
                          value: null,
                          selected: _selectedCategory == null,
                        ),
                        ..._categories.map(
                          (category) {
                            return _buildCategoryOption(
                              context,
                              label: category,
                              icon: _getCategoryIcon(category),
                              value: category,
                              selected:
                                  _selectedCategory == category,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    setState(() {
      _selectedCategory = selected;
    });
  }

  Widget _buildCategoryOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String? value,
    required bool selected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: selected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.35,
            ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected
              ? colorScheme.onPrimaryContainer
              : colorScheme.primary,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected
                ? FontWeight.w800
                : FontWeight.w600,
            color: selected
                ? colorScheme.onPrimaryContainer
                : null,
          ),
        ),
        trailing: selected
            ? Icon(
                Icons.check_circle_rounded,
                color: colorScheme.onPrimaryContainer,
              )
            : null,
        onTap: () {
          Navigator.pop(context, value);
        },
      ),
    );
  }

  Future<void> _addExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddExpenseScreen(),
      ),
    );
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
  }

  Future<void> _deleteExpense(
    ExpenseModel expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete expense?',
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
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(
                  dialogContext,
                ).colorScheme.error,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _firebaseService.deleteExpense(
        expense.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Expense deleted successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to delete expense. '
            'Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showExpenseDetails(
    ExpenseModel expense,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor:
          Theme.of(context).colorScheme.surface,
      builder: (context) {
        return _ExpenseDetailsSheet(
          expense: expense,
          onEdit: () async {
            Navigator.pop(context);

            await _editExpense(expense);
          },
          onDelete: () async {
            Navigator.pop(context);

            await _deleteExpense(expense);
          },
        );
      },
    );
  }

  Future<void> _openAllExpenses(
    List<ExpenseModel> expenses,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllExpensesScreen(
          expenses: expenses,
        ),
      ),
    );
  }

  Future<void> _showProfileMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final user = FirebaseAuth.instance.currentUser;

        final email =
            _userProfile?['email'] ??
            user?.email ??
            '';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              8,
              24,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(
                    _firstName.isEmpty
                        ? '?'
                        : _firstName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _displayName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email.toString(),
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.palette_outlined,
                  ),
                  title: const Text(
                    'Appearance',
                  ),
                  subtitle: Text(
                    widget.isDarkMode
                        ? 'Dark mode'
                        : 'Light mode',
                  ),
                  trailing: Switch(
                    value: widget.isDarkMode,
                    onChanged: (_) {
                      Navigator.pop(context);

                      widget.onThemeToggle();
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .error,
                  ),
                  title: Text(
                    'Sign out',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    _confirmLogout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Sign out?',
          ),
          content: const Text(
            'You will need to sign in again '
            'to access your expenses.',
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
                'Sign out',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _authService.logout();
    }
  }

  IconData _getCategoryIcon(
    String category,
  ) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_outlined;

      case 'Transport':
        return Icons.directions_car_outlined;

      case 'Shopping':
        return Icons.shopping_bag_outlined;

      case 'Bills':
        return Icons.receipt_long_outlined;

      case 'Health':
        return Icons.health_and_safety_outlined;

      case 'Education':
        return Icons.school_outlined;

      case 'Entertainment':
        return Icons.movie_outlined;

      case 'Other':
        return Icons.more_horiz_outlined;

      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: _showProfileMenu,
            icon: const Icon(
              Icons.account_circle_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: _firebaseService.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
                  ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final allExpenses = snapshot.data ?? [];

          final filteredExpenses =
              _filterExpenses(allExpenses);

          final total =
              _calculateTotal(filteredExpenses);

          final categoryTotals =
              _calculateCategoryTotals(filteredExpenses);

          final topCategory =
              _getTopCategory(categoryTotals);

          final topCategoryAmount =
              _getTopCategoryAmount(categoryTotals);

          final recentExpenses =
              filteredExpenses
                  .take(_recentExpenseLimit)
                  .toList();

          final hasMoreExpenses =
              filteredExpenses.length >
                  _recentExpenseLimit;

          return RefreshIndicator(
            onRefresh: () async {
              await Future<void>.delayed(
                const Duration(milliseconds: 500),
              );
            },
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                120,
              ),
              children: [
                _buildWelcomeHeader(colorScheme),

                const SizedBox(height: 20),

                _buildMonthlyOverview(
                  total,
                  colorScheme,
                ),

                const SizedBox(height: 18),

                _buildSearchField(),

                const SizedBox(height: 14),

                _buildFilterSection(),

                if (_hasActiveFilters) ...[
                  const SizedBox(height: 12),
                  _buildActiveFilters(),
                ],

                const SizedBox(height: 20),

                if (filteredExpenses.isEmpty &&
                    allExpenses.isEmpty)
                  _buildEmptyState()
                else if (filteredExpenses.isEmpty)
                  _buildNoResultsState()
                else ...[
                  ExpenseSummaryCard(
                    total: total,
                    expenseCount:
                        filteredExpenses.length,
                    highestCategory:
                        topCategory,
                    highestCategoryAmount:
                        topCategoryAmount,
                  ),

                  const SizedBox(height: 20),

                  ExpenseChart(
                    categoryTotals: categoryTotals,
                  ),

                  const SizedBox(height: 20),

                  SpendingInsightsCard(
                    expenses: allExpenses,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recent Expenses',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        filteredExpenses.length >
                                _recentExpenseLimit
                            ? 'Showing 10 of '
                                '${filteredExpenses.length}'
                            : '${filteredExpenses.length} records',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  ...recentExpenses.map(
                    (expense) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: GestureDetector(
                          behavior:
                              HitTestBehavior.opaque,
                          onTap: () =>
                              _showExpenseDetails(
                            expense,
                          ),
                          child: ExpenseCard(
                            expense: expense,
                            onEdit: () =>
                                _editExpense(expense),
                            onDelete: () =>
                                _deleteExpense(expense),
                          ),
                        ),
                      );
                    },
                  ),

                  if (hasMoreExpenses) ...[
                    const SizedBox(height: 4),
                    _buildSeeAllButton(
                      filteredExpenses.length,
                      () => _openAllExpenses(
                        filteredExpenses,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search expenses...',
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                tooltip: 'Clear search',
                onPressed: _clearSearch,
                icon: const Icon(
                  Icons.close_rounded,
                ),
              )
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Filter Expenses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (_hasActiveFilters)
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text(
                  'Clear all',
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildFilterButton(
                icon: Icons.category_outlined,
                label: _selectedCategory ??
                    'Category',
                selected:
                    _selectedCategory != null,
                onPressed: _showCategoryFilter,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildFilterButton(
                icon: Icons.calendar_month_outlined,
                label: _selectedMonth == null
                    ? 'Month'
                    : DateFormat(
                        'MMM yyyy',
                      ).format(_selectedMonth!),
                selected: _selectedMonth != null,
                onPressed: _selectMonth,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (_hasActiveFilters)
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                size: 17,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '$_activeFilterCount active '
                '${_activeFilterCount == 1 ? 'filter' : 'filters'}',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          48,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        alignment: Alignment.centerLeft,
        backgroundColor: selected
            ? colorScheme.primaryContainer
            : colorScheme.surface,
        foregroundColor: selected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface,
        side: BorderSide(
          color: selected
              ? colorScheme.primary
              : colorScheme.outlineVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      icon: Icon(
        icon,
        size: 19,
      ),
      label: Expanded(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary
              .withValues(alpha: 0.15),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_searchQuery.isNotEmpty)
            InputChip(
              avatar: const Icon(
                Icons.search_rounded,
                size: 17,
              ),
              label: Text(
                _searchController.text.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onDeleted: _clearSearch,
            ),

          if (_selectedCategory != null)
            InputChip(
              avatar: Icon(
                _getCategoryIcon(
                  _selectedCategory!,
                ),
                size: 17,
              ),
              label: Text(
                _selectedCategory!,
              ),
              onDeleted: _clearCategoryFilter,
            ),

          if (_selectedMonth != null)
            InputChip(
              avatar: const Icon(
                Icons.calendar_month_outlined,
                size: 17,
              ),
              label: Text(
                DateFormat(
                  'MMMM yyyy',
                ).format(
                  _selectedMonth!,
                ),
              ),
              onDeleted: _clearMonthFilter,
            ),
        ],
      ),
    );
  }

  Widget _buildSeeAllButton(
    int totalCount,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'See All Expenses',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'View all $totalCount expenses '
                      'in pages of 10',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                _isLoadingProfile
                    ? 'Welcome back 👋'
                    : '$_greeting, $_firstName 👋',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Track your spending with confidence.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        CircleAvatar(
          radius: 25,
          backgroundColor:
              colorScheme.primaryContainer,
          child: Text(
            _firstName == 'there'
                ? '?'
                : _firstName[0].toUpperCase(),
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyOverview(
    double total,
    ColorScheme colorScheme,
  ) {
    final monthText = _selectedMonth == null
        ? DateFormat(
            'MMMM yyyy',
          ).format(
            DateTime.now(),
          )
        : DateFormat(
            'MMMM yyyy',
          ).format(
            _selectedMonth!,
          );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: colorScheme.onPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                monthText.toUpperCase(),
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'LKR ${total.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            _hasActiveFilters
                ? 'Filtered spending'
                : 'Total spending',
            style: TextStyle(
              color: colorScheme.onPrimary.withValues(
                alpha: 0.8,
              ),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 44,
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(height: 18),
            const Text(
              'No expenses yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your spending '
              'by adding your first expense.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _addExpense,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add First Expense',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 40,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'No matching expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your search or filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: _clearAllFilters,
              child: const Text(
                'Clear all filters',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 60,
              color: Theme.of(context)
                  .colorScheme
                  .error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load expenses',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection '
              'and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() {});
              },
              child: const Text(
                'Try again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EXPENSE DETAILS BOTTOM SHEET
// ============================================================

class _ExpenseDetailsSheet extends StatelessWidget {
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
        return Icons.directions_car_outlined;

      case 'Shopping':
        return Icons.shopping_bag_outlined;

      case 'Bills':
        return Icons.receipt_long_outlined;

      case 'Health':
        return Icons.health_and_safety_outlined;

      case 'Education':
        return Icons.school_outlined;

      case 'Entertainment':
        return Icons.movie_outlined;

      case 'Other':
        return Icons.more_horiz_outlined;

      default:
        return Icons.category_outlined;
    }
  }

  Color _getCategoryColor(
    BuildContext context,
    String category,
  ) {
    switch (category) {
      case 'Food':
        return Colors.orange;

      case 'Transport':
        return Colors.blue;

      case 'Shopping':
        return Colors.purple;

      case 'Bills':
        return Colors.red;

      case 'Health':
        return Colors.green;

      case 'Education':
        return Colors.teal;

      case 'Entertainment':
        return Colors.pink;

      case 'Other':
        return Colors.grey;

      default:
        return Theme.of(context)
            .colorScheme
            .primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final categoryColor = _getCategoryColor(
      context,
      expense.category,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Expense Details',
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: categoryColor.withValues(
                      alpha: 0.20,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(
                          alpha: 0.15,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(
                          expense.category,
                        ),
                        color: categoryColor,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      expense.title,
                      textAlign: TextAlign.center,
                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            categoryColor.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Text(
                        expense.category,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'LKR ${expense.amount.toStringAsFixed(2)}',
                      style: theme
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _DetailRow(
                icon: Icons.calendar_today_outlined,
                title: 'Expense Date',
                value: DateFormat(
                  'dd MMMM yyyy',
                ).format(
                  expense.date,
                ),
              ),

              const SizedBox(height: 12),

              _DetailRow(
                icon: Icons.access_time_outlined,
                title: 'Added On',
                value: DateFormat(
                  'dd MMM yyyy, hh:mm a',
                ).format(
                  expense.createdAt,
                ),
              ),

              if (expense.note.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.notes_outlined,
                  title: 'Note',
                  value: expense.note,
                  isMultiline: true,
                ),
              ],

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                      label: const Text(
                        'Edit',
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            colorScheme.error,
                      ),
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                      ),
                      label: const Text(
                        'Delete',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isMultiline;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme
            .surfaceContainerHighest
            .withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color:
                  colorScheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                  maxLines: isMultiline ? 5 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}