import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense_model.dart';

void main() {
  group('ExpenseModel', () {
    final date = DateTime(2026, 10, 24, 10, 30);
    final createdAt = DateTime(2026, 10, 24, 11, 0);

    test('creates an expense with the supplied values', () {
      final expense = ExpenseModel(
        id: 'expense-1',
        title: 'Lunch',
        amount: 1250.50,
        category: 'Food',
        date: date,
        note: 'Lunch with friends',
        createdAt: createdAt,
      );

      expect(expense.id, 'expense-1');
      expect(expense.title, 'Lunch');
      expect(expense.amount, 1250.50);
      expect(expense.category, 'Food');
      expect(expense.date, date);
      expect(expense.note, 'Lunch with friends');
      expect(expense.createdAt, createdAt);
    });

    test('converts expense values to a Firestore map', () {
      final expense = ExpenseModel(
        id: 'expense-1',
        title: 'Lunch',
        amount: 1250.50,
        category: 'Food',
        date: date,
        note: 'Lunch',
        createdAt: createdAt,
      );

      final map = expense.toMap();

      expect(map['title'], 'Lunch');
      expect(map['amount'], 1250.50);
      expect(map['category'], 'Food');
      expect((map['date'] as Timestamp).toDate(), date);
      expect(map['note'], 'Lunch');
      expect((map['createdAt'] as Timestamp).toDate(), createdAt);
      expect(map.containsKey('id'), isFalse);
    });

    test('reads Firestore map values into an expense', () {
      final expense = ExpenseModel.fromMap('expense-2', {
        'title': 'Bus fare',
        'amount': 250,
        'category': 'Transport',
        'date': Timestamp.fromDate(date),
        'note': 'To town',
        'createdAt': Timestamp.fromDate(createdAt),
      });

      expect(expense.id, 'expense-2');
      expect(expense.title, 'Bus fare');
      expect(expense.amount, 250.0);
      expect(expense.category, 'Transport');
      expect(expense.date, date);
      expect(expense.note, 'To town');
      expect(expense.createdAt, createdAt);
    });

    test('uses defaults for missing map values', () {
      final expense = ExpenseModel.fromMap('expense-3', {});

      expect(expense.id, 'expense-3');
      expect(expense.title, '');
      expect(expense.amount, 0.0);
      expect(expense.category, '');
      expect(expense.note, '');
    });

    test('accepts DateTime values as dates', () {
      final expense = ExpenseModel.fromMap('expense-4', {
        'date': date,
        'createdAt': createdAt,
      });

      expect(expense.date, date);
      expect(expense.createdAt, createdAt);
    });
  });
}
