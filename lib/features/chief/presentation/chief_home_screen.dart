import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/profile_menu.dart';
import 'analytics_screen.dart';
import 'attendance_screen.dart';
import 'chief_board_screen.dart';
import 'team_day_screen.dart';
import 'technician_map_screen.dart';

/// Five tabs (plan, "Chief technician dashboard"). Team day is the home
/// tab per the plan ("answers the first question of the day at a glance"),
/// and is the default now that chief.team_day exists.
class ChiefHomeScreen extends ConsumerWidget {
  const ChiefHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentials = ref.watch(authControllerProvider).credentials;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chief dashboard'),
          actions: [ProfileMenuButton(credentials: credentials)],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Team day'),
              Tab(text: 'Board'),
              Tab(text: 'Map'),
              Tab(text: 'Analytics'),
              Tab(text: 'Attendance'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TeamDayScreen(),
            ChiefBoardScreen(),
            TechnicianMapScreen(),
            AnalyticsScreen(),
            AttendanceScreen(),
          ],
        ),
      ),
    );
  }
}
