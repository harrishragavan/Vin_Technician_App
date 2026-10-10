import 'package:flutter/material.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_typography.dart';

/// Shown only for the moment it takes to resolve a site URL and read the
/// stored token — the router moves on as soon as `AuthController` knows
/// where to go.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Vin Chakra', style: AppTypography.title),
            const SizedBox(height: 16),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.signal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
