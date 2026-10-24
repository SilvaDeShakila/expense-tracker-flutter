import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _budgetsCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('budgets');
  }

  String _monthId(DateTime month) {
    final year = month.year.toString();
    final monthNumber = month.month.toString().padLeft(2, '0');

    return '$year-$monthNumber';
  }

  Future<void> setMonthlyBudget({
    required DateTime month,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Budget amount must be greater than zero.');
    }

    await _budgetsCollection.doc(_monthId(month)).set({
      'amount': amount,
      'year': month.year,
      'month': month.month,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<double?> getMonthlyBudget(DateTime month) {
    return _budgetsCollection
        .doc(_monthId(month))
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data();
      final amount = data?['amount'];

      if (amount is num) {
        return amount.toDouble();
      }

      return null;
    });
  }
}
