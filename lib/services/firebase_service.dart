import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _expensesCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('expenses');
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
}