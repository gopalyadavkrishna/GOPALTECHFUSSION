import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:power_alert/core/localization/app_localizations.dart';

class AppNavigationScaffold extends StatelessWidget {
  const AppNavigationScaffold({
    required this.currentIndex,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    super.key,
  });

  final int currentIndex;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          const paths = [
            '/home',
            '/outages',
            '/map',
            '/report',
            '/notifications',
          ];
          context.go(paths[index]);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: strings.text('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.power_off_outlined),
            selectedIcon: const Icon(Icons.power_off_rounded),
            label: strings.text('outages'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map_rounded),
            label: strings.text('map'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_alert_outlined),
            selectedIcon: const Icon(Icons.add_alert_rounded),
            label: strings.text('report'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications_rounded),
            label: strings.text('alerts'),
          ),
        ],
      ),
    );
  }
}
