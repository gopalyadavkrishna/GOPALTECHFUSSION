import 'package:flutter/material.dart';
import 'package:power_alert/shared/widgets/operations_dashboard.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationsDashboard(
    title: 'BESCOM Operations',
    subtitle: 'Provider command centre',
    metrics: const [
      DashboardMetric(
        label: 'Active outages',
        value: '18',
        icon: Icons.power_off_rounded,
        color: Colors.red,
        change: '-3 today',
      ),
      DashboardMetric(
        label: 'Open complaints',
        value: '247',
        icon: Icons.confirmation_number_rounded,
        color: Colors.orange,
      ),
      DashboardMetric(
        label: 'Technicians available',
        value: '64',
        icon: Icons.engineering_rounded,
        color: Colors.green,
      ),
      DashboardMetric(
        label: 'Restoration progress',
        value: '73%',
        icon: Icons.trending_up_rounded,
        color: Colors.blue,
        change: '+8%',
      ),
    ],
    sections: [
      DashboardSection(
        title: 'Priority incidents',
        actionLabel: 'View all',
        onAction: () {},
        child: Card(
          child: Column(
            children: const [
              _IncidentTile(
                id: 'OUT-2026-1048',
                area: 'Indiranagar',
                status: 'Repairing',
                severity: 'HIGH',
                color: Colors.red,
              ),
              Divider(height: 1),
              _IncidentTile(
                id: 'OUT-2026-1054',
                area: 'Whitefield',
                status: 'Investigating',
                severity: 'CRITICAL',
                color: Colors.deepOrange,
              ),
              Divider(height: 1),
              _IncidentTile(
                id: 'OUT-2026-1051',
                area: 'Koramangala',
                status: 'Scheduled',
                severity: 'MEDIUM',
                color: Colors.amber,
              ),
            ],
          ),
        ),
      ),
      DashboardSection(
        title: 'Restoration SLA',
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(child: Text('Resolved within target')),
                    Text(
                      '91.4%',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.914,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class _IncidentTile extends StatelessWidget {
  const _IncidentTile({
    required this.id,
    required this.area,
    required this.status,
    required this.severity,
    required this.color,
  });

  final String id;
  final String area;
  final String status;
  final String severity;
  final Color color;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    leading: CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.14),
      child: Icon(Icons.bolt_rounded, color: color),
    ),
    title: Text(area, style: const TextStyle(fontWeight: FontWeight.w800)),
    subtitle: Text('$id • $status'),
    trailing: Chip(
      label: Text(severity),
      labelStyle: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}
