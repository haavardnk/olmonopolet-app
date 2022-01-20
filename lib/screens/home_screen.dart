import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fadein/flutter_fadein.dart';

import 'product_overview_tab.dart';
import 'cart_tab.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products/bottom_filter_sheet.dart';
import '../widgets/products/search_bar.dart';
import '../providers/filter.dart';
import '../providers/cart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/tabs';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  // Pages if you click bottom navigation
  final List<Widget> _contentPages = <Widget>[
    const ProductOverviewTab(),
    const CartTab(),
  ];

  @override
  void initState() {
    // set initial pages for navigation to home page
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_handleTabSelection);
    super.initState();
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          if (_currentIndex == 0) const BottomFilterSheet(),
        ],
        bottom: _currentIndex == 0
            ? const PreferredSize(
                child: SearchBar(),
                preferredSize: Size.fromHeight(kToolbarHeight),
              )
            : null,
      ),
      drawer: const AppDrawer(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _contentPages.map((Widget content) {
          return content;
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (value) {
          _currentIndex = value;
          _pageController.jumpToPage(value);
          // this unfocus is to prevent show keyboard in the wishlist page when focus on search text field
          FocusScope.of(context).unfocus();
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.liquor),
            label: 'Produkter',
          ),
          BottomNavigationBarItem(
            icon: Consumer<Cart>(
              builder: (_, cart, __) => Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.receipt_long),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        // color: Theme.of(context).accentColor,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.pink,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 11,
                          minHeight: 11,
                        ),
                        child: Text(
                          cart.itemCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
            label: 'Handleliste',
          )
        ],
      ),
    );
  }
}
