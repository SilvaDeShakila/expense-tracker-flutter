import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>>
      get _expensesCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('expenses');
  }

  CollectionReference<Map<String, dynamic>>
      get _categoriesCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('categories');
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _expensesCollection
        .doc(expense.id)
        .set(expense.toMap());
  }

  Stream<List<ExpenseModel>> getExpenses() {
    return _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExpenseModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  Future<void> updateExpense(
    ExpenseModel expense,
  ) async {
    await _expensesCollection
        .doc(expense.id)
        .update(expense.toMap());
  }

  Future<void> deleteExpense(
    String expenseId,
  ) async {
    await _expensesCollection
        .doc(expenseId)
        .delete();
  }

  Stream<List<String>> getCustomCategories() {
    return _categoriesCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();
    });
  }

  Future<void> addCategory(String name) async {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }

    final existing = await _categoriesCollection
        .where('name', isEqualTo: normalizedName)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('This category already exists.');
    }

    await _categoriesCollection.add({
      'name': normalizedName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCategory(
    String oldName,
    String newName,
  ) async {
    final normalizedName = newName.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }

    final duplicate = await _categoriesCollection
        .where('name', isEqualTo: normalizedName)
        .limit(1)
        .get();

    if (duplicate.docs.any(
      (doc) => doc.data()['name'] != oldName,
    )) {
      throw Exception('This category already exists.');
    }

    final matching = await _categoriesCollection
        .where('name', isEqualTo: oldName)
        .get();

    final batch = _firestore.batch();

    for (final doc in matching.docs) {
      batch.update(doc.reference, {
        'name': normalizedName,
      });
    }

    final expenses = await _expensesCollection
        .where('category', isEqualTo: oldName)
        .get();

    for (final doc in expenses.docs) {
      batch.update(doc.reference, {
        'category': normalizedName,
      });
    }

    await batch.commit();
  }

  Future<void> deleteCategory(String name) async {
    final matching = await _categoriesCollection
        .where('name', isEqualTo: name)
        .get();

    final batch = _firestore.batch();

    for (final doc in matching.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
