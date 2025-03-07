import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salaryq_app/models/database.dart';
import 'package:salaryq_app/models/transaction_with_category.dart';

class TransactionsPage extends StatefulWidget {
  final TransactionWithCategory? transactionWithCategory;
  const TransactionsPage({Key? key, required this.transactionWithCategory})
      : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final AppDb database = AppDb();

  bool isExpense = true;
  late int type;
  List<String> list = ['Makan dan Jajan', 'Transportasi', 'Nonton Film'];
  late String dropDownValue = list.first;
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  Category? selectedCategory;

  Future insert(
      int amount, DateTime date, String nameDetail, int categoryId) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.transactions).insertReturning(
        TransactionsCompanion.insert(
            name: nameDetail,
            category_id: categoryId,
            transaction_date: date,
            amount: amount,
            createdAt: now,
            updatedAt: now));
    print('APA INI : ' + row.toString());

    // insert to database
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  // Update for transactions
  Future update(int transactionId, int amount, int categoryId,
      DateTime transactionDate, String nameDetail) async {
    return await database.updateTransactionRepo(
        transactionId, amount, transactionDate, nameDetail, categoryId);
  }

  @override
  void initState() {
    // TODO: implement initState ; here for made logic for update or insert
    if (widget.transactionWithCategory != null) {
      updateTransactionView(widget.transactionWithCategory!);
    } else {
      type = 2;
    }
    super.initState();
  }

  // Method for update view
  void updateTransactionView(TransactionWithCategory transactionWithCategory) {
    amountController.text =
        transactionWithCategory.transaction.amount.toString();
    detailController.text = transactionWithCategory.transaction.name;
    dateController.text = DateFormat('yyyy-MM-dd')
        .format(transactionWithCategory.transaction.transaction_date);
    type = transactionWithCategory.category.type;
    (Type == 2) ? isExpense = true : isExpense = false;
    selectedCategory = transactionWithCategory.category;
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Transactions")),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: 0.80, // Perbesar switc
                  child: Switch(
                    value: isExpense,
                    onChanged: (bool value) {
                      setState(() {
                        isExpense = value;
                        type = (isExpense) ? 2 : 1;
                        selectedCategory = null;
                      });
                    },
                    inactiveTrackColor: Colors.green[200],
                    inactiveThumbColor: Colors.green,
                    activeColor: Colors.red,
                  ),
                ),
                Text(
                  isExpense ? 'Expense' : 'Income',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: (isExpense ? Colors.red : Colors.green)),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: amountController,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(), labelText: "Amount"),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Category',
                style: TextStyle(fontSize: 16),
              ),
            ),
            FutureBuilder<List<Category>>(
                future: getAllCategory(type),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data!.length > 0) {
                        selectedCategory = (selectedCategory == null)
                            ? snapshot.data!.first
                            : selectedCategory;
                        print('APANIH? : ' + snapshot.toString());
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButton<Category>(
                              value: (selectedCategory == null)
                                  ? snapshot.data!.first
                                  : selectedCategory,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_downward),
                              items: snapshot.data!.map((Category item) {
                                return DropdownMenuItem<Category>(
                                  value: item,
                                  child: Text(item.name),
                                );
                              }).toList(),
                              onChanged: (Category? value) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              }),
                        );
                      } else {
                        return Center(
                          child: Text('Data Kosong'),
                        );
                      }
                    } else {
                      return Center(
                        child: Text('Tidak ada data'),
                      );
                    }
                  }
                }),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                readOnly: true,
                controller: dateController,
                decoration: InputDecoration(labelText: "Enter Date"),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2050));
                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);

                    dateController.text = formattedDate;
                  }
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: detailController,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(), labelText: "Detail"),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: ElevatedButton(
                    onPressed: () async {
                      (widget.transactionWithCategory == null)
                          ? insert(
                              int.parse(amountController.text),
                              DateTime.parse(dateController.text),
                              detailController.text,
                              selectedCategory!.id)
                          : await update(
                              widget.transactionWithCategory!.transaction.id,
                              int.parse(amountController.text),
                              selectedCategory!.id,
                              DateTime.parse(dateController.text),
                              detailController.text);
                      Navigator.pop(context, true);
                    },
                    child: Text('SAVE')))
          ],
        )),
      ),
    );
  }
}
