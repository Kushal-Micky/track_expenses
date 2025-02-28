import 'package:flutter/material.dart';
import 'package:minor_project/bargraph/bar_graph.dart';
import 'package:minor_project/components/my_list_tile.dart';
import 'package:minor_project/database/expense_database.dart';
import 'package:minor_project/helper/helper_function.dart';
import 'package:minor_project/models/expense.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Text Controller

  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  //Future to load graph data and month total
  Future<Map<int, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    //read the db
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    // load futures
    refreshData();

    super.initState();
  }

  //refresh graph data

  void refreshData() {
    _monthlyTotalsFuture =
        Provider.of<ExpenseDatabase>(
          context,
          listen: false,
        ).calculateMonthlyTotals();
    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(
          context,
          listen: false,
        ).calculateCurrentMonthTotal();
  }

  // Open a new expense box

  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('New Expense'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //User input -> Expense name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Name'),
                ),

                //User input -> Expense amount
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(hintText: 'Amount'),
                ),
              ],
            ),
            actions: [
              //Cancel Button
              _cancelButton(),

              //Save Button
              _createNewExpenseButton(),
            ],
          ),
    );
  }

  //open edit box
  void openEditBox(Expense expense) {
    //pre fill existing values
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Expense'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //User input -> Expense name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: existingName),
                ),

                //User input -> Expense amount
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(hintText: existingAmount),
                ),
              ],
            ),
            actions: [
              //Cancel Button
              _cancelButton(),

              //Save Button
              _editExpenseButton(expense),
            ],
          ),
    );
  }

  //open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Expense?'),
            content: Column(mainAxisSize: MainAxisSize.min),
            actions: [
              //Cancel Button
              _cancelButton(),

              //delete Button
              _deleteExpenseButton(expense.id),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        //get Dates
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        //calculate the number of months since the first month
        int monthCount = calculateMonthCount(
          startYear,
          startMonth,
          currentYear,
          currentMonth,
        );

        // only display the expenses for the current month
        List<Expense> currentMonthExpenses =
            value.allExpenses.where((expense) {
              return expense.date.year == currentYear &&
                  expense.date.month == currentMonth;
            }).toList();
        // Return UI
        return Scaffold(
          backgroundColor: Colors.grey[300],
          floatingActionButton: FloatingActionButton(
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: FutureBuilder<double>(
              future: _calculateCurrentMonthTotal,
              builder: (context, snapshot) {
                //loaded
                if (snapshot.connectionState == ConnectionState.done) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //amount total
                      Text('\$${snapshot.data!.toStringAsFixed(2)}'),
                      //month name
                      Text(getCurrentMonthName()),
                    ],
                  );
                } else {
                  return Text("loading..");
                }
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                //Graph UI
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapsot) {
                      // data is loaded
                      if (snapsot.connectionState == ConnectionState.done) {
                        final monthlyTotals = snapsot.data ?? {};

                        List<double> monthlySummary = List.generate(
                          monthCount,
                          (index) => monthlyTotals[startMonth + index] ??= 0,
                        );

                        return MyBarGraph(
                          monthlySummary: monthlySummary,
                          startMonth: startMonth,
                        );
                      }
                      // loading...
                      else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),

                //List of Expenses
                Expanded(
                  child: ListView.builder(
                    itemCount: currentMonthExpenses.length,
                    itemBuilder: (context, index) {
                      // reverse the list to show latest item first
                      int reversedIndex =
                          currentMonthExpenses.length - index - 1;
                      //get individual expense
                      Expense individualExpense =
                          currentMonthExpenses[reversedIndex];

                      //return the list tile UI
                      return MyListTile(
                        title: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        onDeletePressed:
                            (context) => openDeleteBox(individualExpense),
                        onEditPressed:
                            (context) => openEditBox(individualExpense),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //CANCEL BUTTON
  Widget _cancelButton() {
    return MaterialButton(
      child: const Text('Cancel'),
      onPressed: () {
        //pop box
        Navigator.pop(context);

        //clear controllers
        nameController.clear();
        amountController.clear();
      },
    );
  }

  //SAVE BUTTON -> new expense
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //create new expense
          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );

          //save to db
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          refreshData();
          //clear controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  //SAVE BUTTON -> Edit existing expense
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        //save as long as at least one text-field has been changed
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //create a new expense
          Expense updatedExpense = Expense(
            name:
                nameController.text.isNotEmpty
                    ? nameController.text
                    : expense.name,
            amount:
                amountController.text.isNotEmpty
                    ? convertStringToDouble(amountController.text)
                    : expense.amount,
            date: DateTime.now(),
          );
          // old expense id
          int existingId = expense.id;
          //save to db
          await context.read<ExpenseDatabase>().updateExpense(
            existingId,
            updatedExpense,
          );
          refreshData();
        }
      },
      child: const Text('Save'),
    );
  }

  //Delete Button
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        //pop box
        Navigator.pop(context);

        //delete from db
        await context.read<ExpenseDatabase>().deleteExpense(id);

        refreshData();
      },
      child: const Text('Delete'),
    );
  }
}
