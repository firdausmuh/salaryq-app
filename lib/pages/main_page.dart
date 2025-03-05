import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:intl/intl.dart';
import 'package:salaryq_app/pages/category_page.dart';
import 'package:salaryq_app/pages/home_page.dart';
import 'package:salaryq_app/pages/transactions_page.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainPageState();
}

class _MainPageState extends State<Mainpage> {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex;

  @override
  void initState() {
    updateView(0, DateTime.now());
    super.initState();
  }

  // void onTapTapped(int index) {
  //   setState(() {
  //     currentIndex = index;
  //   });
  // }

  void updateView(int index, DateTime? date) {
    setState(() {
      if (date != null) {
        selectedDate == DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }
      currentIndex = index;
      _children = [
        HomePage(selectedDate: selectedDate),
        CategoryPage(),
      ];
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
                onDateChanged: (value) {
                  setState(() {
                    print('SELECTED : ' + value.toString());
                    selectedDate = value;
                    updateView(0, selectedDate);
                  });
                },
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
                    updateView(0, DateTime.now());
                  },
                  icon: const Icon(Icons.home)),
              const SizedBox(width: 20),
              IconButton(
                  onPressed: () {
                    updateView(1, null);
                  },
                  icon: const Icon(Icons.list)),
            ],
          ),
        ));
  }
}
