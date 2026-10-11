import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/profile_menu.dart';
import 'jobs_tab.dart';
import 'today_tab.dart';

/// Today and Jobs (plan, "Technician portal" steps 1-2). Job sheet is a
/// pushed route (`/technician/ticket/:ticketId`), not a tab.
class TechnicianHomeScreen extends ConsumerWidget {
  const TechnicianHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentials = ref.watch(authControllerProvider).credentials;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Technician portal'),
          actions: [ProfileMenuButton(credentials: credentials)],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'Jobs'),
            ],
          ),
        ),
        body: const TabBarView(children: [TodayTab(), JobsTab()]),
      ),
    );
  }
}
