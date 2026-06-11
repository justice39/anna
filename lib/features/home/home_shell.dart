import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';
import '../../widgets/anna_tab_bar.dart';
import '../all_reminders/all_reminders_screen.dart';
import '../settings/settings_screen.dart';
import '../voice/voice_screen.dart';
import 'today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  static const _screens = <Widget>[
    TodayScreen(),
    AllRemindersScreen(),
    VoiceScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _tab, children: _screens),
      floatingActionButton: _tab != 2
          ? Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FloatingActionButton(
                backgroundColor: AnnaColors.gold,
                elevation: 0,
                onPressed: () {
                  if (_tab == 1) {
                    // From "All" tab, plus button creates reminder
                    context.go('/reminder/new');
                  } else {
                    setState(() => _tab = 2);
                  }
                },
                child: Icon(
                  _tab == 1 ? Icons.add : Icons.mic,
                  color: AnnaColors.bg,
                  size: 26,
                ),
              ),
            )
          : null,
      bottomNavigationBar: AnnaTabBar(
        current: _tab,
        onChange: (i) => setState(() => _tab = i),
      ),
    );
  }
}
