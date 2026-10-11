import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/site_setup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/chief/presentation/chief_home_screen.dart';
import '../../features/technician/presentation/job_sheet_screen.dart';
import '../../features/technician/presentation/technician_home_screen.dart';

/// Notifies go_router's `redirect` whenever [AuthState.status] changes, so
/// a push that ends in "sign-in needed" (a rotated-out token, a dropped
/// session) moves the user back to `/sign-in` without any screen having to
/// check auth state itself.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.status != next.status) notifyListeners();
    });
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      switch (auth.status) {
        case AuthStatus.loading:
          return location == '/splash' ? null : '/splash';
        case AuthStatus.needsSiteUrl:
        case AuthStatus.bootstrapFailed:
          return location == '/site-setup' ? null : '/site-setup';
        case AuthStatus.signedOut:
          return location == '/sign-in' ? null : '/sign-in';
        case AuthStatus.signedIn:
          final preGate = {'/splash', '/site-setup', '/sign-in'};
          if (!preGate.contains(location)) return null;
          return auth.credentials?.homeScreen == 'chief'
              ? '/chief'
              : '/technician';
      }
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/site-setup',
        builder: (context, state) => const SiteSetupScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/technician',
        builder: (context, state) => const TechnicianHomeScreen(),
      ),
      GoRoute(
        path: '/technician/ticket/:ticketId',
        builder: (context, state) =>
            JobSheetScreen(ticketId: state.pathParameters['ticketId']!),
      ),
      GoRoute(
        path: '/chief',
        builder: (context, state) => const ChiefHomeScreen(),
      ),
    ],
  );
});
