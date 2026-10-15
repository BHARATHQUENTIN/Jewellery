import 'dart:convert';

class Expense {
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
      };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] as String,
        title: j['title'] as String,
        amount: (j['amount'] as num).toDouble(),
        category: j['category'] as String,
        date: DateTime.parse(j['date'] as String),
      );

  static String encodeList(List<Expense> l) =>
      jsonEncode(l.map((e) => e.toJson()).toList());

  static List<Expense> decodeList(String s) => (jsonDecode(s) as List)
      .map((e) => Expense.fromJson(e as Map<String, dynamic>))
      .toList();
}
