import 'package:flutter/material.dart';

import 'activity_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'schedule_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  void _select(int index) {
    if (index == _index) {
      return;
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _index,
      children: [
        HomeScreen(onSelectTab: _select),
        ActivityScreen(onSelectTab: _select),
        ScheduleScreen(onSelectTab: _select),
        ProfileScreen(onSelectTab: _select),
      ],
    );
  }
}
