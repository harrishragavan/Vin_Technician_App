import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/api/app_config.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../application/auth_controller.dart';
import '../application/auth_state.dart';

/// Staging/debug builds only: a URL field and a QR scanner, per the plan's
/// "Login and setup" step 2. The release build never reaches this screen
/// for entry — it only reaches the error half of it if the baked-in
/// production URL turns out to be unreachable.
class SiteSetupScreen extends ConsumerStatefulWidget {
  const SiteSetupScreen({super.key});

  @override
  ConsumerState<SiteSetupScreen> createState() => _SiteSetupScreenState();
}

class _SiteSetupScreenState extends ConsumerState<SiteSetupScreen> {
  final _controller = TextEditingController();
  bool _scanning = false;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit([String? url]) async {
    final value = (url ?? _controller.text).trim();
    setState(() => _submitting = true);
    if (value.isEmpty) {
      // The compiled production URL just failed to bootstrap — retry it
      // rather than asking for a URL that was never editable.
      await ref.read(authControllerProvider.notifier).start();
    } else {
      await ref.read(authControllerProvider.notifier).setSiteUrl(value);
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final failed = authState.status == AuthStatus.bootstrapFailed;
    final editable = !AppConfig.hasCompiledBaseUrl;

    if (_scanning && editable) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan site QR code'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _scanning = false),
          ),
        ),
        body: MobileScanner(
          onDetect: (capture) {
            final value = capture.barcodes.firstOrNull?.rawValue;
            if (value != null) {
              setState(() => _scanning = false);
              _submit(value);
            }
          },
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Vin Chakra', style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                failed
                    ? (authState.errorMessage ?? "Can't reach this site.")
                    : 'Connect to your workshop site to continue.',
                style: AppTypography.body.copyWith(
                  color: failed ? context.colors.danger : context.colors.muted,
                ),
              ),
              if (failed && authState.errorDetail != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    authState.errorDetail!,
                    style: AppTypography.mono.copyWith(
                      fontSize: 11,
                      color: context.colors.muted,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (editable) ...[
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Site URL',
                    hintText: 'https://yourcompany.frappe.cloud',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _scanning = true),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR code instead'),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              FilledButton(
                onPressed: _submitting ? null : () => _submit(),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(failed ? 'Retry' : 'Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on List<Barcode> {
  Barcode? get firstOrNull => isEmpty ? null : first;
}
