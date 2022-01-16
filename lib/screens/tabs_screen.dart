import 'package:flutter/material.dart';

import '../screens/product_overview_screen.dart';
import '../screens/shopping_list_screen.dart';
import '../widgets/app_drawer.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late List<Map<String, dynamic>> _pages;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    _pages = [
      {
        'page': const ProductOverviewScreen(),
        'title': 'Produkter',
      },
      {
        'page': const ShoppingListScreen(),
        'title': 'Handleliste',
      },
    ];
    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          _pages[_selectedPageIndex]['title'],
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          if (_selectedPageIndex == 0)
            TextButton(
              onPressed: () {
                // Open filters
                showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return const Text('Filter her');
                    });
              },
              child: const Text(
                'Filter',
                style: TextStyle(color: Colors.white),
              ),
            )
        ],
      ),
      drawer: const AppDrawer(),
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Produkter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Handleliste',
          ),
        ],
      ),
    );
  }
}
