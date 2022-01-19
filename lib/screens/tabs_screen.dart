import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fadein/flutter_fadein.dart';

import '../screens/product_overview_screen.dart';
import '../screens/shopping_list_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products/bottom_filter_sheet.dart';
import '../widgets/products/search_bar.dart';
import '../providers/filter.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);
  static const routeName = '/tabs';

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
        title: Consumer<Filter>(
          builder: (context, filter, _) => FadeIn(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                filter.storeName,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          ),
        ),
        actions: [
          if (_selectedPageIndex == 0) const BottomFilterSheet(),
        ],
        bottom: _selectedPageIndex == 0
            ? const PreferredSize(
                child: SearchBar(),
                preferredSize: Size.fromHeight(kToolbarHeight),
              )
            : null,
      ),
      drawer: const AppDrawer(),
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.liquor),
            label: 'Produkter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Handleliste',
          ),
        ],
      ),
    );
  }
}
