import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vin_technician_app/core/design/app_colors.dart';
import 'package:vin_technician_app/core/design/app_theme.dart';

void main() {
  testWidgets('light theme exposes the AppColors extension with the '
      'workshop-ledger palette', (tester) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    final colors = capturedContext.colors;
    expect(colors.paper, const Color(0xFFF3F1EC));
    expect(colors.ink, const Color(0xFF1B1A17));
    expect(colors.signal, const Color(0xFFE4572E));
  });

  testWidgets('dark theme keeps the same signal colour', (tester) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(capturedContext.colors.signal, const Color(0xFFE4572E));
    expect(capturedContext.colors.paper, const Color(0xFF141413));
  });
}
