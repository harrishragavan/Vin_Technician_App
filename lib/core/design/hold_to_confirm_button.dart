import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Start day, Check in and Complete are all hold-to-confirm with progress
/// and a haptic tick (design language, "Actions") — this is the one place
/// that behaviour lives, so every screen gets it identically.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.holdDuration = const Duration(milliseconds: 600),
    this.icon,
    this.enabled = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onConfirmed;
  final Duration holdDuration;
  final IconData? icon;
  final bool enabled;

  /// Shows a spinner instead of the label while an action triggered by a
  /// previous hold is still in flight.
  final bool isLoading;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _firedHaptic = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    )..addStatusListener(_onStatusChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onConfirmed();
      _controller.value = 0;
      _firedHaptic = false;
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    _firedHaptic = false;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) => _reset();

  void _onTapCancel() => _reset();

  void _reset() {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.value > 0.98 && !_firedHaptic) {
            _firedHaptic = true;
            HapticFeedback.mediumImpact();
          }
          return Container(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
            ),
            decoration: BoxDecoration(
              color: widget.enabled ? colors.signal : colors.muted,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _controller.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.onSignal.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onSignal,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: colors.onSignal,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                            Text(
                              widget.label,
                              style: AppTypography.bodyStrong.copyWith(
                                color: colors.onSignal,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
