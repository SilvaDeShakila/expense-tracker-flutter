import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../services/firebase_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;

  const AddExpenseScreen({
    super.key,
    this.expense,
  });

  @override
  State<AddExpenseScreen> createState() =>
      _AddExpenseScreenState();
}

class _AddExpenseScreenState
    extends State<AddExpenseScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _titleController =
      TextEditingController();

  final _amountController =
      TextEditingController();

  final _noteController =
      TextEditingController();

  final FirebaseService
      _firebaseService =
      FirebaseService();

  String? _selectedCategory;

  DateTime _selectedDate =
      DateTime.now();

  bool _isSaving = false;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Education',
    'Entertainment',
    'Other',
  ];

  bool get _isEditing =>
      widget.expense != null;

  @override
  void initState() {
    super.initState();

    final expense =
        widget.expense;

    if (expense != null) {
      _titleController.text =
          expense.title;

      _amountController.text =
          expense.amount
              .toStringAsFixed(2);

      _noteController.text =
          expense.note;

      _selectedCategory =
          expense.category;

      _selectedDate =
          expense.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  IconData _getCategoryIcon(
    String category,
  ) {
    switch (category) {
      case 'Food':
        return Icons
            .restaurant_outlined;

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
        return Icons
            .school_outlined;

      case 'Entertainment':
        return Icons
            .movie_outlined;

      default:
        return Icons
            .more_horiz_outlined;
    }
  }

  Future<void> _selectDate() async {
    final pickedDate =
        await showDatePicker(
      context: context,
      initialDate:
          _selectedDate,
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime.now(),
      helpText:
          'Select expense date',
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate =
            pickedDate;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_selectedCategory ==
        null) {
      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a category.',
          ),
          behavior:
              SnackBarBehavior
                  .floating,
        ),
      );

      return;
    }

    final amount =
        double.tryParse(
      _amountController.text
          .trim(),
    );

    if (amount == null ||
        amount <= 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final expense =
        ExpenseModel(
      id: widget.expense?.id ??
          DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
      title:
          _titleController.text
              .trim(),
      amount: amount,
      category:
          _selectedCategory!,
      date: _selectedDate,
      note:
          _noteController.text
              .trim(),
      createdAt:
          widget.expense
                  ?.createdAt ??
              DateTime.now(),
    );

    try {
      if (_isEditing) {
        await _firebaseService
            .updateExpense(
          expense,
        );
      } else {
        await _firebaseService
            .addExpense(
          expense,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Expense updated successfully!'
                : 'Expense added successfully!',
          ),
          behavior:
              SnackBarBehavior
                  .floating,
        ),
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to save expense. Please try again.',
          ),
          behavior:
              SnackBarBehavior
                  .floating,
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final formattedDate =
        DateFormat(
      'dd MMMM yyyy',
    ).format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Edit Expense'
              : 'Add Expense',
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
                const EdgeInsets
                    .all(20),
            children: [
              _buildSectionTitle(
                'Expense Details',
                'Enter the basic information',
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _titleController,
                textInputAction:
                    TextInputAction
                        .next,
                maxLength: 50,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Expense Title',
                  hintText:
                      'e.g. Lunch, Bus fare',
                  prefixIcon:
                      Icon(
                    Icons
                        .title_outlined,
                  ),
                  counterText: '',
                ),
                validator:
                    (value) {
                  if (value ==
                          null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Please enter an expense title';
                  }

                  final title =
                      value.trim();

                  if (title.length <
                      2) {
                    return 'Title must contain at least 2 characters';
                  }

                  if (title.length >
                      50) {
                    return 'Title cannot exceed 50 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _amountController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                textInputAction:
                    TextInputAction
                        .next,
                inputFormatters: [
                  _AmountInputFormatter(),
                ],
                decoration:
                    const InputDecoration(
                  labelText:
                      'Amount',
                  hintText:
                      '0.00',
                  prefixIcon:
                      Icon(
                    Icons
                        .payments_outlined,
                  ),
                  prefixText:
                      'LKR ',
                ),
                validator:
                    (value) {
                  if (value ==
                          null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Please enter the amount';
                  }

                  final amount =
                      double.tryParse(
                    value.trim(),
                  );

                  if (amount ==
                      null) {
                    return 'Please enter a valid number';
                  }

                  if (amount <=
                      0) {
                    return 'Amount must be greater than 0';
                  }

                  if (value
                      .contains('.')) {
                    final decimalPart =
                        value
                            .split('.')
                            .last;

                    if (decimalPart
                            .length >
                        2) {
                      return 'Amount can have maximum 2 decimal places';
                    }
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 28,
              ),

              _buildSectionTitle(
                'Category',
                'Choose an expense category',
              ),

              const SizedBox(
                height: 16,
              ),

              _buildCategorySelector(),

              const SizedBox(
                height: 28,
              ),

              _buildSectionTitle(
                'Date & Notes',
                'Add additional information',
              ),

              const SizedBox(
                height: 16,
              ),

              InkWell(
                onTap:
                    _selectDate,
                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),
                child:
                    InputDecorator(
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Expense Date',
                    prefixIcon:
                        Icon(
                      Icons
                          .calendar_month_outlined,
                    ),
                  ),
                  child: Text(
                    formattedDate,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight
                              .w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _noteController,
                maxLines: 4,
                maxLength: 200,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Note',
                  hintText:
                      'Add an optional description...',
                  prefixIcon:
                      Icon(
                    Icons
                        .notes_outlined,
                  ),
                  alignLabelWithHint:
                      true,
                  counterText: '',
                ),
              ),

              const SizedBox(
                height: 32,
              ),

              SizedBox(
                height: 56,
                child:
                    FilledButton
                        .icon(
                  onPressed:
                      _isSaving
                          ? null
                          : _saveExpense,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : Icon(
                          _isEditing
                              ? Icons
                                  .update_outlined
                              : Icons
                                  .save_outlined,
                        ),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : _isEditing
                            ? 'Update Expense'
                            : 'Save Expense',
                    style:
                        const TextStyle(
                      fontSize:
                          16,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(
              context,
            )
                .colorScheme
                .onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          _categories.map(
        (category) {
          final isSelected =
              _selectedCategory ==
                  category;

          return ChoiceChip(
            selected:
                isSelected,
            onSelected:
                (_) {
              setState(() {
                _selectedCategory =
                    category;
              });
            },
            avatar:
                Icon(
              _getCategoryIcon(
                category,
              ),
              size: 18,
            ),
            label:
                Text(category),
            showCheckmark:
                false,
          );
        },
      ).toList(),
    );
  }
}

class _AmountInputFormatter
    extends TextInputFormatter {
  @override
  TextEditingValue
      formatEditUpdate(
    TextEditingValue
        oldValue,
    TextEditingValue
        newValue,
  ) {
    final text =
        newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    if (!RegExp(
      r'^\d*\.?\d{0,2}$',
    ).hasMatch(text)) {
      return oldValue;
    }

    final parts =
        text.split('.');

    final integerPart =
        parts[0];

    // Maximum 9 digits before the decimal point.
    if (integerPart.length >
        9) {
      return oldValue;
    }

    // Prevent unnecessary leading zeros.
    if (integerPart.length >
            1 &&
        integerPart.startsWith(
            '0') &&
        !text.startsWith(
            '0.')) {
      return oldValue;
    }

    return newValue;
  }
}