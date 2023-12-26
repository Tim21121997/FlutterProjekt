import 'package:flutter/material.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key, required this.onIndexChanged});
  final void Function(int) onIndexChanged;

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        widget.onIndexChanged(index);
        currentPageIndex = index;
      },
      indicatorColor: Colors.amber,
      selectedIndex: currentPageIndex,
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_outlined),
          label: 'Übersicht',
        ),
        NavigationDestination(
          icon: Badge(child: Icon(Icons.directions_run)),
          label: 'Fitness',
        ),
      ],
    );
  }
}
