import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/profile_menu.dart';

/// "Team day" — the chief's home screen (plan, "Screens → Chief technician
/// dashboard", step 1). The time-axis view, board, map, analytics and
/// attendance tabs land in Phase 5 once `chief.*` exists on the server;
/// this is the navigation shell they build inside.
class ChiefHomeScreen extends ConsumerWidget {
  const ChiefHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentials = ref.watch(authControllerProvider).credentials;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team day'),
        actions: [ProfileMenuButton(credentials: credentials)],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.groups_outlined,
                size: 40,
                color: context.colors.muted,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Signed in', style: AppTypography.heading),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Team day, Board, Map, Analytics and Attendance open here\n'
                'once chief.team_day and chief.board ship.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: context.colors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
