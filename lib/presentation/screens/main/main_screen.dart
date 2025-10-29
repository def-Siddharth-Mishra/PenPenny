import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';
import 'package:penpenny/presentation/screens/accounts/accounts_screen.dart';
import 'package:penpenny/presentation/screens/categories/categories_screen.dart';
import 'package:penpenny/presentation/screens/home/home_screen.dart';
import 'package:penpenny/presentation/screens/onboard/onboard_screen.dart';
import 'package:penpenny/presentation/screens/settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _controller = PageController(keepPage: true);
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, state) {
        if (state is AppSettingsLoaded) {
          if (state.settings.currency == null || state.settings.username == null) {
            return const OnboardScreen();
          }
        }

        return Scaffold(
          body: PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              HomeScreen(),
              AccountsScreen(),
              CategoriesScreen(),
              SettingsScreen(),
            ],
            onPageChanged: (int index) {
              setState(() {
                _selected = index;
              });
            },
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              NavigationDestination(
                icon: Icon(Icons.wallet),
                label: "Accounts",
              ),
              NavigationDestination(
                icon: Icon(Icons.category),
                label: "Categories",
              ),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: "Settings",
              ),
            ],
            onDestinationSelected: (int selected) {
              _controller.jumpToPage(selected);
            },
          ),
        );
      },
    );
  }
}