import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/profile_menu.dart';
import 'chief_board_screen.dart';

/// Five tabs (plan, "Chief technician dashboard"). Team day, Map,
/// Analytics and Attendance need chief.team_day/map/analytics/attendance,
/// which don't exist yet — Board ships first since chief.board does, and
/// is the default tab for now.
class ChiefHomeScreen extends ConsumerWidget {
  const ChiefHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentials = ref.watch(authControllerProvider).credentials;

    return DefaultTabController(
      length: 5,
      initialIndex: 1,
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
            _ComingSoonTab(
              message: 'Team day opens here once chief.team_day ships.',
            ),
            ChiefBoardScreen(),
            _ComingSoonTab(
              message: 'The technician map opens here once chief.map ships.',
            ),
            _ComingSoonTab(
              message: 'Analytics opens here once chief.analytics ships.',
            ),
            _ComingSoonTab(
              message: 'Attendance opens here once chief.attendance ships.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: context.colors.muted),
        ),
      ),
    );
  }
}
