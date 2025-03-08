import 'package:flutter/material.dart';
import 'package:salaryq_app/models/database.dart';
import 'package:salaryq_app/models/transaction_with_category.dart';
import 'package:salaryq_app/pages/transactions_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();

  int totalIncome = 0;
  int totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactionSummary();
  }

  Future<void> _loadTransactionSummary() async {
    final income =
        await database.sumTransactionByTypeRepo(1, widget.selectedDate);
    final expense =
        await database.sumTransactionByTypeRepo(2, widget.selectedDate);

    setState(() {
      totalIncome = income;
      totalExpense = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // dashboard total income and expense
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        child: Icon(Icons.download, color: Colors.green),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Income",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            "Rp. ${totalIncome.toString()}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Container(
                        child: Icon(Icons.upload, color: Colors.red),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Expensive",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            "Rp. ${totalExpense.toString()}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          //Text Transactions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Transactions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, Index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Card(
                                elevation: 10,
                                child: ListTile(
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () async {
                                            await database
                                                .deleteTransactionRepo(snapshot
                                                    .data![Index]
                                                    .transaction
                                                    .id);
                                            setState(() {});
                                          }),
                                      SizedBox(width: 10),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TransactionsPage(
                                                        transactionWithCategory:
                                                            snapshot
                                                                .data![Index],
                                                      )));
                                        },
                                      )
                                    ],
                                  ),
                                  title: Text("Rp. " +
                                      snapshot.data![Index].transaction.amount
                                          .toString()),
                                  subtitle: Text(snapshot
                                          .data![Index].category.name +
                                      " (" +
                                      snapshot.data![Index].transaction.name +
                                      ")"),
                                  leading: Container(
                                    child: (snapshot
                                                .data![Index].category.type ==
                                            2)
                                        ? Icon(Icons.upload, color: Colors.red)
                                        : Icon(Icons.download,
                                            color: Colors.green),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      return Center(
                        child: Text("Data transaksi masih kosong"),
                      );
                    }
                  } else {
                    return Center(
                      child: Text("Tidak ada data"),
                    );
                  }
                }
              }),
        ],
      )),
    );
  }
}
