import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:power_alert/domain/models/outage.dart';

class OutageCard extends StatelessWidget {
  const OutageCard({required this.outage, super.key});

  final Outage outage;

  @override
  Widget build(BuildContext context) {
    final restoreTime = outage.estimatedRestoreTime;
    return Semantics(
      button: true,
      label: '${outage.status.label} in ${outage.areaName}. ${outage.reason}.',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/outages/${outage.id}'),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: outage.status.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: outage.status.color.withValues(alpha: 0.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        outage.status.label,
                        style: TextStyle(
                          color: outage.status.color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      outage.id,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  outage.areaName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  outage.reason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (restoreTime != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Restore ${DateFormat.jm().format(restoreTime)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
