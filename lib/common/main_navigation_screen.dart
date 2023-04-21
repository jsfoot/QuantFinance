import 'package:flutter/material.dart';
import 'package:quant_finance/views/binance_chart_screen.dart';
import 'package:quant_finance/views/home_screen.dart';
import 'package:quant_finance/views/indicator_settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 1;
  double groupAligment = -1;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;

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
                  icon: Icon(Icons.bookmark_border),
                  selectedIcon: Icon(Icons.book),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.auto_graph_sharp),
                  selectedIcon: Icon(Icons.auto_graph_outlined),
                  label: Text(
                    'Binance\nChart',
                    textAlign: TextAlign.center,
                  ),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.star_border),
                  selectedIcon: Icon(Icons.star),
                  label: Text(
                    'Indicator\nSetting',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  Offstage(
                    offstage: _selectedIndex != 0,
                    child: const HomeScreen(),
                  ),
                  Offstage(
                    offstage: _selectedIndex != 1,
                    child: const BinanceChartScreen(),
                  ),
                  Offstage(
                    offstage: _selectedIndex != 2,
                    child: const IndicatorSettingsScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
