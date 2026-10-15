import 'package:expense_tracker/expense.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('expense list round-trips through JSON', () {
    final list = [
      Expense(
          id: '1',
          title: 'Tea',
          amount: 2.5,
          category: 'Food',
          date: DateTime(2026, 1, 2))
    ];
    final out = Expense.decodeList(Expense.encodeList(list));
    expect(out.single.title, 'Tea');
    expect(out.single.amount, 2.5);
    expect(out.single.date, DateTime(2026, 1, 2));
  });
}
