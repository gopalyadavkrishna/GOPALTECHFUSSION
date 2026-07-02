import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:power_alert/app/providers.dart';
import 'package:power_alert/domain/models/outage.dart';
import 'package:power_alert/shared/widgets/async_value_view.dart';

class OutageDetailScreen extends ConsumerStatefulWidget {
  const OutageDetailScreen({required this.outageId, super.key});

  final String outageId;

  @override
  ConsumerState<OutageDetailScreen> createState() => _OutageDetailScreenState();
}

class _OutageDetailScreenState extends ConsumerState<OutageDetailScreen> {
  bool _following = false;

  @override
  Widget build(BuildContext context) {
    final outage = ref.watch(outageProvider(widget.outageId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outage details'),
        actions: [
          IconButton(
            tooltip: 'Share outage',
            onPressed: () {},
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: AsyncValueView(
        value: outage,
        data: (item) => item == null
            ? const Center(child: Text('Outage not found'))
            : _details(context, item),
      ),
    );
  }

  Widget _details(BuildContext context, Outage outage) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
    children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: outage.status.color,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  outage.status.label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              outage.areaName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              outage.providerName,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 22),
            LinearProgressIndicator(
              value: outage.progress,
              minHeight: 9,
              color: Colors.white,
              backgroundColor: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 8),
            Text(
              '${(outage.progress * 100).round()}% restoration progress',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _DetailRow(
                icon: Icons.tag_rounded,
                label: 'Outage ID',
                value: outage.id,
              ),
              _DetailRow(
                icon: Icons.info_outline_rounded,
                label: 'Cause',
                value: outage.reason,
              ),
              _DetailRow(
                icon: Icons.warning_amber_rounded,
                label: 'Severity',
                value: outage.severity.name,
              ),
              _DetailRow(
                icon: Icons.schedule_rounded,
                label: 'Started',
                value: DateFormat('d MMM, h:mm a').format(outage.startTime),
              ),
              _DetailRow(
                icon: Icons.settings_backup_restore_rounded,
                label: 'Estimated restoration',
                value: outage.estimatedRestoreTime == null
                    ? 'Under assessment'
                    : DateFormat(
                        'd MMM, h:mm a',
                      ).format(outage.estimatedRestoreTime!),
              ),
              _DetailRow(
                icon: Icons.groups_rounded,
                label: 'People affected',
                value: NumberFormat.compact().format(outage.affectedPopulation),
                showDivider: false,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      Text(
        'Live timeline',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 12),
      const _Timeline(),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: () async {
          final next = !_following;
          await ref
              .read(outageRepositoryProvider)
              .setFollowing(outage.id, following: next);
          if (mounted) {
            setState(() => _following = next);
          }
        },
        icon: Icon(
          _following
              ? Icons.notifications_active_rounded
              : Icons.add_alert_rounded,
        ),
        label: Text(_following ? 'Following updates' : 'Follow updates'),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.report_problem_outlined),
        label: const Text('Report related issue'),
      ),
    ],
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      if (showDivider) const Divider(height: 1),
    ],
  );
}

class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    const events = [
      ('Repair team on site', '11:42 AM', true),
      ('Fault isolated on feeder F-17', '11:08 AM', true),
      ('Technician dispatched', '10:31 AM', true),
      ('Outage detected', '10:14 AM', true),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: events
              .map(
                (event) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.$1,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(event.$2),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
