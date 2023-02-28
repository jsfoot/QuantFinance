import 'package:flutter/material.dart';
import 'package:quant_finance/pages/page_1.dart';
import 'package:quant_finance/pages/page_2.dart';
import 'package:quant_finance/pages/page_3.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  double groupAligment = -1;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;

  Widget buildPages() {
    switch (_selectedIndex) {
      case 0:
        return const Page1();
      case 1:
        return const Page2();
      case 2:
        return const Page3();
      default:
        return const Page1();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              groupAlignment: groupAligment,
              labelType: labelType,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              trailing: const Icon(Icons.more_horiz_rounded),
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: Text('First'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bookmark_border),
                  selectedIcon: Icon(Icons.book),
                  label: Text('Second'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.star_border),
                  selectedIcon: Icon(Icons.star),
                  label: Text('Third'),
                ),
              ],
            ),
            Expanded(child: buildPages()),
          ],
        ),
      ),
    );
  }
}
