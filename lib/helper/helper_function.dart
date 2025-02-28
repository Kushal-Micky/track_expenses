/*
Helpful Functions Used through the APP
 */

import 'package:intl/intl.dart';

// Convert String to Double
double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

// Format Double into dollars and cents
String formatAmount(double amount) {
  final format = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );
  return format.format(amount);
}

// Calculate the number of months since the first start month

int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth) {
  int monthCount =
      (currentYear - startYear) * 12 * currentMonth - startMonth + 1;
  return monthCount;
}

// get current month name
String getCurrentMonthName() {
  DateTime now = DateTime.now();
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[now.month - 1];
}
