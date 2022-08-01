import 'package:flutter3_firestore_driver/screens/home.dart';
import 'package:flutter3_firestore_driver/map/my_map.dart';
import 'package:flutter3_firestore_driver/screens/orders.dart';
import 'package:flutter3_firestore_driver/screens/wallets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class TabsScreen extends StatefulWidget {
  TabsScreen({Key? key}) : super(key: key);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late PageController pageController;

  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    pageController = PageController();

    setState(() {
      pageIndex = 0;
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: PageView(
          children: <Widget>[
            HomeScreen(),
            Orders(),
            Wallets(),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
      ), //page
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Colors.green,
        backgroundColor: Colors.grey.shade200,
        inactiveColor: Colors.black,
        items: [
          BottomNavigationBarItem(
              //icon: Icon(Icons.shopping_cart),
              icon: Icon(Icons.local_taxi),
              label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_special),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_search_sharp), label: "Profile"),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.map),
          // ),
        ],
      ),
    );
  }
}
