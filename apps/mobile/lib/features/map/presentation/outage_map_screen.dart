import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:power_alert/app/providers.dart';
import 'package:power_alert/shared/widgets/app_navigation_scaffold.dart';

class OutageMapScreen extends ConsumerWidget {
  const OutageMapScreen({super.key});

  static const _initial = CameraPosition(
    target: LatLng(12.9716, 77.5946),
    zoom: 11.5,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outages = ref.watch(activeOutagesProvider).value ?? const [];
    final markers = outages
        .map(
          (outage) => Marker(
            markerId: MarkerId(outage.id),
            position: LatLng(outage.latitude, outage.longitude),
            infoWindow: InfoWindow(
              title: outage.areaName,
              snippet: '${outage.status.label} • ${outage.providerName}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              outage.isActive
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueGreen,
            ),
          ),
        )
        .toSet();

    return AppNavigationScaffold(
      currentIndex: 2,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initial,
            markers: markers,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SearchBar(
                    hintText: 'Search area, feeder, or landmark',
                    leading: const Icon(Icons.search_rounded),
                    trailing: [
                      IconButton(
                        tooltip: 'Map filters',
                        onPressed: () {},
                        icon: const Icon(Icons.tune_rounded),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const _MapLegend(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: const [
          _LegendItem(color: Colors.green, label: 'Available'),
          _LegendItem(color: Colors.red, label: 'Outage'),
          _LegendItem(color: Colors.amber, label: 'Maintenance'),
          _LegendItem(color: Colors.orange, label: 'Emergency'),
        ],
      ),
    ),
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}
