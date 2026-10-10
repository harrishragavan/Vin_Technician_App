import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/secure_token_store.dart';
import '../application/auth_controller.dart';

/// Shown on both home screens' app bars. Gives a user with both role sets a
/// way to switch home screens (plan, "Screens": "a user with both roles
/// gets a switch in the profile menu") and is where sign-out lives.
class ProfileMenuButton extends ConsumerWidget {
  const ProfileMenuButton({super.key, required this.credentials});

  final AuthCredentials? credentials;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.person_outline),
      onSelected: (value) {
        switch (value) {
          case 'switch_technician':
            context.go('/technician');
          case 'switch_chief':
            context.go('/chief');
          case 'sign_out':
            ref.read(authControllerProvider.notifier).signOut();
        }
      },
      itemBuilder: (context) => [
        if (credentials?.hasBothHomes ?? false) ...[
          const PopupMenuItem(
            value: 'switch_technician',
            child: Text('Technician portal'),
          ),
          const PopupMenuItem(
            value: 'switch_chief',
            child: Text('Chief dashboard'),
          ),
          const PopupMenuDivider(),
        ],
        const PopupMenuItem(value: 'sign_out', child: Text('Sign out')),
      ],
    );
  }
}
