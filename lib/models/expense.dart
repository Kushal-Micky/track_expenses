import 'package:isar/isar.dart';

//This line is needed to generate the isar file
//run cmd in terminal : dart run build_runner build
part 'expense.g.dart';

@Collection()
class Expense {
  Id id = Isar.autoIncrement;
  late String name;
  late double amount;
  late DateTime date;

  Expense({required this.name, required this.amount, required this.date});
}