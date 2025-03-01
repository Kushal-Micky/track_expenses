import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/expense_database.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(), // Show loading screen initially
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late Future<void> _databaseInitialization;

  @override
  void initState() {
    super.initState();
    _databaseInitialization = ExpenseDatabase.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _databaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Database is initialized, show the main app
          return ChangeNotifierProvider(
            create: (context) => ExpenseDatabase(),
            child: const HomePage(),
          );
        } else {
          // Database is still initializing, show loading indicator
          return const Scaffold(
            body: Center(child: Text("Loading...")),
          );
        }
      },
    );
  }
}
