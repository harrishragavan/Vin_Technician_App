import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/design/app_theme.dart';
import 'core/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase (push) is wired up in Phase 6 once a Firebase project and
  // android/app/google-services.json exist — see README "Local setup".
  runApp(const ProviderScope(child: VinTechnicianApp()));
}

class VinTechnicianApp extends ConsumerWidget {
  const VinTechnicianApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Vin Technician',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
