import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:minor_project/models/expense.dart';
import 'package:path_provider/path_provider.dart';

@Collection()
class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Expense> _allExpenses = [];

  /* S E T U P */

  //Initialize the database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  /* G E T T E R S */

  List<Expense> get allExpenses => _allExpenses;

  /* O P E R A T I O N S */

  // CREATE

  Future<void> createNewExpense(Expense newExpense) async {
    //add to database
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    //reread from database
    await readExpenses();
  }

  // READ

  Future<void> readExpenses() async {
    //fetch all existing expenses from db

    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    //give to local Expense list

    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    //update UI

    notifyListeners();
  }

  //UPDATE
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    //make sure new Expense has the same id as the old one

    updatedExpense.id = id;

    //update it in db

    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    //re read from db

    await readExpenses();
  }
  // DELETE

  Future<void> deleteExpense(int id) async {
    //delete from db
    await isar.writeTxn(() => isar.expenses.delete(id));

    //re read from db
    await readExpenses();
  }

  /* H E L P E R */

  // Calculate the total expenses per month
  Future<Map<int, double>> calculateMonthlyTotals() async {
    //ensure all expenses are read from db
    await readExpenses();

    // create a map to keep track of total expenses per month
    Map<int, double> monthlyTotals = {};

    //iterate over all expenses

    for (var expense in _allExpenses) {
      //get the month and year of the expense
      int month = expense.date.month;
      //if the month is not yet in the map, add it
      if (!monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = 0;
      }
      //add the expense amount to the total for the month
      monthlyTotals[month] = monthlyTotals[month]! + expense.amount;
    }
    return monthlyTotals;
  }

  // calculate current month total
  Future<double> calculateCurrentMonthTotal() async {
    //ensure expenses are read from db first
    await readExpenses();
    //get current month, year
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;
    //filter the expenses to include only those for the current month and year
    List<Expense> currentMonthExpenses =
        _allExpenses.where((expense) {
          return expense.date.month == currentMonth &&
              expense.date.year == currentYear;
        }).toList();
    //calculate total amount for the current month
    double total = currentMonthExpenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
    );
    return total;
  }

  // get the start month
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }

    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.month;
  }

  // get the start year
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }

    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.year;
  }
}
