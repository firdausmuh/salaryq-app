import 'package:flutter/material.dart';
import 'package:salaryq_app/pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Mainpage(),
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}
