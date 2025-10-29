import 'package:flutter/material.dart';
import 'package:penpenny/presentation/screens/accounts/accounts_screen.dart';
import 'package:penpenny/presentation/screens/categories/categories_screen.dart';
import 'package:penpenny/presentation/screens/home/home_screen.dart';
import 'package:penpenny/presentation/screens/settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  Widget _getCurrentScreen() {
    // Use keys to ensure screens are rebuilt when switching tabs
    switch (_currentIndex) {
      case 0:
        return const HomeScreen(key: ValueKey('home'));
      case 1:
        return const AccountsScreen(key: ValueKey('accounts'));
      case 2:
        return const CategoriesScreen(key: ValueKey('categories'));
      case 3:
        return const SettingsScreen(key: ValueKey('settings'));
      default:
        return const HomeScreen(key: ValueKey('home'));
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
