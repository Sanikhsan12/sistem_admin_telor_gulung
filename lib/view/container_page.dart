import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

// !
import './home_page.dart';
import './product_page.dart';
import './order_page.dart';
import './user_approval_page.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  _ContainerPageState createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    ProductPage(),
    OrderPage(),
    UserApprovalPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.blue,
      body: Container(child: _pages[_currentIndex]),

      // ! Bottom Navbar
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.white,
        height: 60,
        index: _currentIndex,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.blue),
          Icon(Icons.shopping_bag, size: 30, color: Colors.blue),
          Icon(Icons.receipt_long, size: 30, color: Colors.blue),
          Icon(
            Icons.supervised_user_circle_outlined,
            size: 30,
            color: Colors.blue,
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
