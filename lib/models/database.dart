import 'dart:io';

import 'package:drift/drift.dart';
// These imports are used to open the database
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:salaryq_app/models/category.dart';
import 'package:salaryq_app/models/transaction.dart';
import 'package:salaryq_app/models/transaction_with_category.dart';

part 'database.g.dart';

@DriftDatabase(
    // relative import for the drift file. Drift also supports `package:`
    // imports
    tables: [Categories, Transactions])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD Category

  // Create
  Future<List<Category>> getAllCategoryRepo(int type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
        .get();
  }

  // Update
  Future updateCategoryRepo(int id, String name) async {
    return (update(categories)..where((tbl) => tbl.id.equals(id)))
        .write(CategoriesCompanion(name: Value(name)));
  }

  // Delete
  Future deleteCategoryRepo(int id) async {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  // TRANSACTION

  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(
      DateTime date) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ])
      ..where(transactions.transaction_date.equals(date)));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
            row.readTable(transactions), row.readTable(categories));
      }).toList();
    });
  }

  // Update for Transaction
  Future updateTransactionRepo(int id, int amount, DateTime transactionDate,
      String nameDetail, int categoryId) async {
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
        TransactionsCompanion(
            name: Value(nameDetail),
            category_id: Value(categoryId),
            transaction_date: Value(transactionDate),
            amount: Value(amount)));
  }

  // Delete for Transaction

  Future deleteTransactionRepo(int id) async {
    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Sum Transaction
  // Future<int> sumTransactionRepo(DateTime date) async {
  //   final query = select(transactions)
  //     ..where((tbl) => tbl.transaction_date.equals(date));

  Future<int> sumTransactionByTypeRepo(int type, DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);

    final query = customSelect(
      'SELECT SUM(amount) as total FROM transactions WHERE category_id IN '
      '(SELECT id FROM categories WHERE type = ?) '
      'AND transaction_date BETWEEN ? AND ?',
      variables: [
        Variable.withInt(type),
        Variable.withDateTime(startOfMonth),
        Variable.withDateTime(endOfMonth),
      ],
    );

    final result = await query.getSingle();
    return result.data['total'] ?? 0;
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
