import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moliyaviy Boshqaruv',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Ma'lumotlar modellari
class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });
}

class Debt {
  final String id;
  final String personName;
  final double amount;
  final String description;
  final DateTime date;
  final DebtType type;

  Debt({
    required this.id,
    required this.personName,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
  });
}

enum TransactionType { income, expense }
enum DebtType { given, taken }

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Transaction> transactions = [];
  List<Debt> debts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardScreen(transactions: transactions, debts: debts),
          TransactionsScreen(
            transactions: transactions,
            onAddTransaction: _addTransaction,
            onDeleteTransaction: _deleteTransaction,
          ),
          DebtScreen(
            debts: debts,
            onAddDebt: _addDebt,
            onDeleteDebt: _deleteDebt,
          ),
          AnalyticsScreen(transactions: transactions, debts: debts),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Asosiy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Tranzaksiyalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Qarzlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Tahlil',
          ),
        ],
      ),
    );
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      transactions.removeWhere((t) => t.id == id);
    });
  }

  void _addDebt(Debt debt) {
    setState(() {
      debts.add(debt);
    });
  }

  void _deleteDebt(String id) {
    setState(() {
      debts.removeWhere((d) => d.id == id);
    });
  }
}

// Dashboard ekrani
class DashboardScreen extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Debt> debts;

  DashboardScreen({required this.transactions, required this.debts});

  @override
  Widget build(BuildContext context) {
    double totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    double totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    double totalGivenDebt = debts
        .where((d) => d.type == DebtType.given)
        .fold(0.0, (sum, d) => sum + d.amount);
    
    double totalTakenDebt = debts
        .where((d) => d.type == DebtType.taken)
        .fold(0.0, (sum, d) => sum + d.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Moliyaviy Boshqaruv'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Balans kartasi
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Umumiy Balans',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${(totalIncome - totalExpense).toStringAsFixed(0)} so\'m',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kirim',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              '+${totalIncome.toStringAsFixed(0)}',
                              style: TextStyle(color: Colors.green[300], fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chiqim',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              '-${totalExpense.toStringAsFixed(0)}',
                              style: TextStyle(color: Colors.red[300], fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // Qarzlar kartasi
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Bergan Qarzlar',
                    totalGivenDebt,
                    Colors.orange[600]!,
                    Icons.trending_up,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Olgan Qarzlar',
                    totalTakenDebt,
                    Colors.purple[600]!,
                    Icons.trending_down,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Oxirgi tranzaksiyalar
            _buildSectionTitle('Oxirgi Tranzaksiyalar'),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: transactions.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Hozircha tranzaksiyalar yo\'q',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: transactions.length > 5 ? 5 : transactions.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final transaction = transactions.reversed.toList()[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction.type == TransactionType.income
                                ? Colors.green[100]
                                : Colors.red[100],
                            child: Icon(
                              transaction.type == TransactionType.income
                                  ? Icons.add
                                  : Icons.remove,
                              color: transaction.type == TransactionType.income
                                  ? Colors.green[600]
                                  : Colors.red[600],
                            ),
                          ),
                          title: Text(
                            transaction.title,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(transaction.category),
                          trailing: Text(
                            '${transaction.type == TransactionType.income ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} so\'m',
                            style: TextStyle(
                              color: transaction.type == TransactionType.income
                                  ? Colors.green[600]
                                  : Colors.red[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${amount.toStringAsFixed(0)} so\'m',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}

// Tranzaksiyalar ekrani
class TransactionsScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onAddTransaction;
  final Function(String) onDeleteTransaction;

  TransactionsScreen({
    required this.transactions,
    required this.onAddTransaction,
    required this.onDeleteTransaction,
  });

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tranzaksiyalar'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: widget.transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Hozircha tranzaksiyalar yo\'q',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Yangi tranzaksiya qo\'shish uchun + tugmasini bosing',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: widget.transactions.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final transaction = widget.transactions.reversed.toList()[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.type == TransactionType.income
                          ? Colors.green[100]
                          : Colors.red[100],
                      child: Icon(
                        transaction.type == TransactionType.income
                            ? Icons.add
                            : Icons.remove,
                        color: transaction.type == TransactionType.income
                            ? Colors.green[600]
                            : Colors.red[600],
                      ),
                    ),
                    title: Text(
                      transaction.title,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transaction.category),
                        Text(
                          '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${transaction.type == TransactionType.income ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} so\'m',
                          style: TextStyle(
                            color: transaction.type == TransactionType.income
                                ? Colors.green[600]
                                : Colors.red[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[400]),
                          onPressed: () => _confirmDelete(transaction.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tranzaksiyani o\'chirish'),
        content: Text('Ushbu tranzaksiyani o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteTransaction(id);
              Navigator.pop(context);
            },
            child: Text('O\'chirish', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Umumiy';
    TransactionType selectedType = TransactionType.expense;

    final categories = [
      'Umumiy', 'Oziq-ovqat', 'Transport', 'Kommunal', 'O\'yin-kulgi',
      'Kiyim-kechak', 'Sog\'liqni saqlash', 'Ta\'lim', 'Uy-joy'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Yangi Tranzaksiya'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Sarlavha',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Miqdor (so\'m)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategoriya',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedCategory = value!);
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<TransactionType>(
                        title: Text('Kirim', style: TextStyle(fontSize: 14)),
                        value: TransactionType.income,
                        groupValue: selectedType,
                        onChanged: (value) {
                          setDialogState(() => selectedType = value!);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<TransactionType>(
                        title: Text('Chiqim', style: TextStyle(fontSize: 14)),
                        value: TransactionType.expense,
                        groupValue: selectedType,
                        onChanged: (value) {
                          setDialogState(() => selectedType = value!);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  final transaction = Transaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    amount: double.parse(amountController.text),
                    category: selectedCategory,
                    date: DateTime.now(),
                    type: selectedType,
                  );
                  widget.onAddTransaction(transaction);
                  Navigator.pop(context);
                }
              },
              child: Text('Qo\'shish'),
            ),
          ],
        ),
      ),
    );
  }
}

// Qarzlar ekrani
class DebtScreen extends StatefulWidget {
  final List<Debt> debts;
  final Function(Debt) onAddDebt;
  final Function(String) onDeleteDebt;

  DebtScreen({
    required this.debts,
    required this.onAddDebt,
    required this.onDeleteDebt,
  });

  @override
  _DebtScreenState createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Qarz Hisob-kitoblari'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: widget.debts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Hozircha qarzlar yo\'q',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Yangi qarz qo\'shish uchun + tugmasini bosing',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: widget.debts.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final debt = widget.debts.reversed.toList()[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: debt.type == DebtType.given
                          ? Colors.orange[100]
                          : Colors.purple[100],
                      child: Icon(
                        debt.type == DebtType.given
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: debt.type == DebtType.given
                            ? Colors.orange[600]
                            : Colors.purple[600],
                      ),
                    ),
                    title: Text(
                      debt.personName,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(debt.description),
                        Text(
                          '${debt.date.day}/${debt.date.month}/${debt.date.year}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${debt.amount.toStringAsFixed(0)} so\'m',
                              style: TextStyle(
                                color: debt.type == DebtType.given
                                    ? Colors.orange[600]
                                    : Colors.purple[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              debt.type == DebtType.given ? 'Bergan' : 'Olgan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[400]),
                          onPressed: () => _confirmDelete(debt.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Qarzni o\'chirish'),
        content: Text('Ushbu qarzni o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteDebt(id);
              Navigator.pop(context);
            },
            child: Text('O\'chirish', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDebtDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DebtType selectedType = DebtType.given;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Yangi Qarz'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Shaxs nomi',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Miqdor (so\'m)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Tavsif (ixtiyoriy)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<DebtType>(
                        title: Text('Bergan', style: TextStyle(fontSize: 14)),
                        value: DebtType.given,
                        groupValue: selectedType,
                        onChanged: (value) {
                          setDialogState(() => selectedType = value!);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<DebtType>(
                        title: Text('Olgan', style: TextStyle(fontSize: 14)),
                        value: DebtType.taken,
                        groupValue: selectedType,
                        onChanged: (value) {
                          setDialogState(() => selectedType = value!);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  final debt = Debt(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    personName: nameController.text,
                    amount: double.parse(amountController.text),
                    description: descriptionController.text.isEmpty 
                        ? 'Tavsif yo\'q' 
                        : descriptionController.text,
                    date: DateTime.now(),
                    type: selectedType,
                  );
                  widget.onAddDebt(debt);
                  Navigator.pop(context);
                }
              },
              child: Text('Qo\'shish'),
            ),
          ],
        ),
      ),
    );
  }
}

// Tahlil ekrani
class AnalyticsScreen extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Debt> debts;

  AnalyticsScreen({required this.transactions, required this.debts});

  @override
  Widget build(BuildContext context) {
    Map<String, double> expensesByCategory = {};
    double totalIncome = 0;
    double totalExpense = 0;

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
        expensesByCategory[transaction.category] = 
            (expensesByCategory[transaction.category] ?? 0) + transaction.amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Moliyaviy Tahlil'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Umumiy statistika
            Text(
              'Umumiy Ma\'lumotlar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Jami Kirim',
                    totalIncome,
                    Colors.green[600]!,
                    Icons.trending_up,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Jami Chiqim',
                    totalExpense,
                    Colors.red[600]!,
                    Icons.trending_down,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Sof Balans',
                    totalIncome - totalExpense,
                    totalIncome > totalExpense ? Colors.green[600]! : Colors.red[600]!,
                    Icons.account_balance_wallet,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Tranzaksiyalar',
                    transactions.length.toDouble(),
                    Colors.blue[600]!,
                    Icons.receipt,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            // Kategoriya bo'yicha harajatlar
            if (expensesByCategory.isNotEmpty) ...[
              Text(
                'Kategoriya bo\'yicha Harajatlar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: expensesByCategory.entries.map((entry) {
                      final percentage = (entry.value / totalExpense * 100);
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${entry.value.toStringAsFixed(0)} so\'m (${percentage.toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 32),
            ],
            // Qarzlar tahlili
            if (debts.isNotEmpty) ...[
              Text(
                'Qarzlar Tahlili',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDebtAnalysisRow(
                        'Bergan Qarzlar:',
                        debts.where((d) => d.type == DebtType.given)
                            .fold(0.0, (sum, d) => sum + d.amount),
                        Colors.orange[600]!,
                      ),
                      SizedBox(height: 16),
                      _buildDebtAnalysisRow(
                        'Olgan Qarzlar:',
                        debts.where((d) => d.type == DebtType.taken)
                            .fold(0.0, (sum, d) => sum + d.amount),
                        Colors.purple[600]!,
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jami Qarz Holati:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(debts.where((d) => d.type == DebtType.given).fold(0.0, (sum, d) => sum + d.amount) - debts.where((d) => d.type == DebtType.taken).fold(0.0, (sum, d) => sum + d.amount)).toStringAsFixed(0)} so\'m',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
            ],
            // Oylik statistika
            Text(
              'Bu Oyning Statistikasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMonthlyStatRow(
                      'Bu oydagi tranzaksiyalar:',
                      transactions.where((t) => 
                        t.date.month == DateTime.now().month &&
                        t.date.year == DateTime.now().year
                      ).length.toString(),
                    ),
                    SizedBox(height: 12),
                    _buildMonthlyStatRow(
                      'Bu oydagi kirimlar:',
                      '${transactions.where((t) => 
                        t.type == TransactionType.income &&
                        t.date.month == DateTime.now().month &&
                        t.date.year == DateTime.now().year
                      ).fold(0.0, (sum, t) => sum + t.amount).toStringAsFixed(0)} so\'m',
                    ),
                    SizedBox(height: 12),
                    _buildMonthlyStatRow(
                      'Bu oydagi chiqimlar:',
                      '${transactions.where((t) => 
                        t.type == TransactionType.expense &&
                        t.date.month == DateTime.now().month &&
                        t.date.year == DateTime.now().year
                      ).fold(0.0, (sum, t) => sum + t.amount).toStringAsFixed(0)} so\'m',
                    ),
                    SizedBox(height: 12),
                    _buildMonthlyStatRow(
                      'Bu oydagi qarzlar:',
                      debts.where((d) => 
                        d.date.month == DateTime.now().month &&
                        d.date.year == DateTime.now().year
                      ).length.toString(),
                    ),
                  ],
                ),
              ),
            ),
            // Agar ma'lumot yo'q bo'lsa
            if (transactions.isEmpty && debts.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
                    Icon(
                      Icons.analytics,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tahlil uchun ma\'lumot yo\'q',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Biror tranzaksiya yoki qarz qo\'shing',
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, double value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title == 'Tranzaksiyalar' 
                ? value.toInt().toString()
                : '${value.toStringAsFixed(0)} so\'m',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtAnalysisRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(0)} so\'m',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue[600],
          ),
        ),
      ],
    );
  }
}