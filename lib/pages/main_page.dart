import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:salaryq_app/pages/category_page.dart';
import 'package:salaryq_app/pages/home_page.dart';
import 'package:salaryq_app/pages/transactions_page.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainPageState();
}

class _MainPageState extends State<Mainpage> {
  final List<Widget> _children = [HomePage(), CategoryPage()];
  int currentIndex = 0;

  void onTapTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (currentIndex == 0)
            ? CalendarAppBar(
                accent: Colors.green,
                backButton: false,
                locale: 'id',
                onDateChanged: (value) => print(value),
                firstDate: DateTime.now().subtract(const Duration(days: 140)),
                lastDate: DateTime.now(),
              )
            : PreferredSize(
                child: Container(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                  child: Text(
                    'Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )),
                preferredSize: Size.fromHeight(100)),
        floatingActionButton: Visibility(
          //visible untuk mengkondisikan floatingbutton untuk tidak muncul di halaman category
          visible: (currentIndex == 0) ? true : false,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => TransactionsPage(),
              ))
                  .then((value) {
                setState(() {});
              });
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ),
        body: _children[currentIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () {
                    onTapTapped(0);
                  },
                  icon: const Icon(Icons.home)),
              const SizedBox(width: 20),
              IconButton(
                  onPressed: () {
                    onTapTapped(1);
                  },
                  icon: const Icon(Icons.list)),
            ],
          ),
        ));
  }
}
