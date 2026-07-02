import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:power_alert/app/providers.dart';
import 'package:power_alert/shared/widgets/app_navigation_scaffold.dart';
import 'package:power_alert/shared/widgets/async_value_view.dart';
import 'package:power_alert/shared/widgets/outage_card.dart';

class OutageListScreen extends ConsumerStatefulWidget {
  const OutageListScreen({super.key});

  @override
  ConsumerState<OutageListScreen> createState() => _OutageListScreenState();
}

class _OutageListScreenState extends ConsumerState<OutageListScreen> {
  bool _activeOnly = true;

  @override
  Widget build(BuildContext context) {
    final outages = ref.watch(activeOutagesProvider);
    return AppNavigationScaffold(
      currentIndex: 1,
      appBar: AppBar(
        title: const Text(
          'Outages',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Search locations',
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'Filter outages',
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SegmentedButton<bool>(
              expandedInsets: EdgeInsets.zero,
              segments: const [
                ButtonSegment(value: true, label: Text('Active')),
                ButtonSegment(value: false, label: Text('All updates')),
              ],
              selected: {_activeOnly},
              onSelectionChanged: (value) =>
                  setState(() => _activeOnly = value.first),
            ),
          ),
          Expanded(
            child: AsyncValueView(
              value: outages,
              data: (items) {
                final visible = _activeOnly
                    ? items.where((item) => item.isActive).toList()
                    : items;
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(activeOutagesProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) =>
                        OutageCard(outage: visible[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
