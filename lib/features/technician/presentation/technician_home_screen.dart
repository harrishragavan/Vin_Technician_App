import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/profile_menu.dart';

/// "Today" — the technician's home screen (plan, "Screens → Technician
/// portal", step 1). The day bar, active job and today's jobs list land in
/// Phase 3 once `tech.home` exists on the server; this is the navigation
/// shell and app-bar chrome that the rest of the portal builds inside.
class TechnicianHomeScreen extends ConsumerWidget {
  const TechnicianHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentials = ref.watch(authControllerProvider).credentials;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [ProfileMenuButton(credentials: credentials)],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.task_alt, size: 40, color: context.colors.muted),
              const SizedBox(height: AppSpacing.md),
              Text('Signed in', style: AppTypography.heading),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'The day bar and job list open here once tech.home ships.',
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
