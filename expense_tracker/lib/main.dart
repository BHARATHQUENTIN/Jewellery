import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'expense.dart';

void main() => runApp(const ExpenseApp());

const categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Other'];

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _key = 'expenses';
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s != null) setState(() => _expenses = Expense.decodeList(s));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Expense.encodeList(_expenses));
  }

  double get _monthTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (a, e) => a + e.amount);
  }

  Map<String, double> get _byCategory {
    final m = <String, double>{};
    for (final e in _expenses) {
      m[e.category] = (m[e.category] ?? 0) + e.amount;
    }
    return m;
  }

  Future<void> _add() async {
    final title = TextEditingController();
    final amount = TextEditingController();
    var category = categories.first;
    final result = await showDialog<Expense>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Add expense'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Title')),
            TextField(
                controller: amount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount')),
            DropdownButton<String>(
              value: category,
              isExpanded: true,
              items: [
                for (final c in categories)
                  DropdownMenuItem(value: c, child: Text(c))
              ],
              onChanged: (v) => setD(() => category = v!),
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final a = double.tryParse(amount.text.trim());
                if (title.text.trim().isEmpty || a == null || a <= 0) return;
                Navigator.pop(
                    ctx,
                    Expense(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      title: title.text.trim(),
                      amount: a,
                      category: category,
                      date: DateTime.now(),
                    ));
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      setState(() => _expenses.insert(0, result));
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      floatingActionButton:
          FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
      body: Column(children: [
        Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('This month: ${_monthTotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge),
              for (final e in _byCategory.entries)
                Text('${e.key}: ${e.value.toStringAsFixed(2)}'),
            ]),
          ),
        ),
        Expanded(
          child: _expenses.isEmpty
              ? const Center(child: Text('No expenses yet'))
              : ListView.builder(
                  itemCount: _expenses.length,
                  itemBuilder: (_, i) {
                    final e = _expenses[i];
                    return Dismissible(
                      key: ValueKey(e.id),
                      onDismissed: (_) {
                        setState(() => _expenses.removeAt(i));
                        _save();
                      },
                      child: ListTile(
                        title: Text(e.title),
                        subtitle: Text(
                            '${e.category} • ${e.date.toString().substring(0, 10)}'),
                        trailing: Text(e.amount.toStringAsFixed(2)),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
