import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_typography.dart';
import '../application/technician_map_controller.dart';
import '../application/technicians_provider.dart';
import '../data/map_models.dart';

/// "Map" (plan, step 3): full-screen map with every technician's latest
/// check-in/check-out, or one technician's numbered route for a date with
/// visit times, first in/last out and time on site.
///
/// Needs a real Google Maps Android API key (decision 6, Google only) to
/// render tiles — without `MAPS_API_KEY` set at build time this shows
/// blank/grey tiles; the data layer (markers, route, summary) works
/// regardless.
class TechnicianMapScreen extends ConsumerWidget {
  const TechnicianMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianMapControllerProvider);
    final controller = ref.read(technicianMapControllerProvider.notifier);
    final techniciansAsync = ref.watch(techniciansProvider);

    final markers = <Marker>{};
    if (state.isRouteMode) {
      for (var i = 0; i < state.routeVisits.length; i++) {
        final visit = state.routeVisits[i];
        markers.add(
          Marker(
            markerId: MarkerId(visit.ticket),
            position: LatLng(visit.latitude, visit.longitude),
            infoWindow: InfoWindow(
              title: '${i + 1}. ${visit.ticket}',
              snippet: visit.customer,
            ),
          ),
        );
      }
    } else {
      for (final marker in state.markers) {
        markers.add(
          Marker(
            markerId: MarkerId(marker.technician),
            position: LatLng(marker.latitude, marker.longitude),
            infoWindow: InfoWindow(
              title: marker.technicianName,
              snippet: marker.customer,
            ),
          ),
        );
      }
    }

    final polyline = state.isRouteMode && state.routeVisits.length > 1
        ? {
            Polyline(
              polylineId: const PolylineId('route'),
              color: context.colors.signal,
              width: 3,
              points: state.routeVisits
                  .map((v) => LatLng(v.latitude, v.longitude))
                  .toList(),
            ),
          }
        : <Polyline>{};

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => controller.setDate(
                  state.date.subtract(const Duration(days: 1)),
                ),
              ),
              Text(
                DateFormat('d MMM').format(state.date),
                style: AppTypography.bodyStrong,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () =>
                    controller.setDate(state.date.add(const Duration(days: 1))),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: techniciansAsync.when(
                  data: (technicians) => DropdownButtonFormField<String?>(
                    initialValue: state.selectedTechnician,
                    isDense: true,
                    decoration: const InputDecoration(labelText: 'Technician'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      for (final technician in technicians)
                        DropdownMenuItem(
                          value: technician.value,
                          child: Text(
                            technician.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: controller.selectTechnician,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              state.errorMessage!,
              style: AppTypography.body.copyWith(color: context.colors.danger),
            ),
          ),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: markers.isNotEmpty
                        ? markers.first.position
                        : const LatLng(20.5937, 78.9629), // India, fallback
                    zoom: markers.isNotEmpty ? 12 : 4,
                  ),
                  markers: markers,
                  polylines: polyline,
                  myLocationButtonEnabled: false,
                ),
        ),
        if (state.isRouteMode && state.routeSummary != null)
          _RouteSummaryBar(summary: state.routeSummary!),
      ],
    );
  }
}

class _RouteSummaryBar extends StatelessWidget {
  const _RouteSummaryBar({required this.summary});

  final RouteSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: context.colors.surfaceAlt,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Stat(label: 'Visits', value: '${summary.totalVisits}'),
          _Stat(
            label: 'Total time',
            value: _formatDuration(summary.totalDurationSeconds),
          ),
          _Stat(
            label: 'Avg/visit',
            value: _formatDuration(summary.avgTimeSeconds),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).round();
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (hours > 0) return '${hours}h ${remaining}m';
    return '${remaining}m';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.mono.copyWith(fontSize: 16)),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: context.colors.muted),
        ),
      ],
    );
  }
}
