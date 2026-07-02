import 'package:flutter/material.dart';
import 'package:power_alert/shared/widgets/operations_dashboard.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationsDashboard(
    title: 'Platform overview',
    subtitle: 'Super admin • Live telemetry',
    metrics: const [
      DashboardMetric(
        label: 'Total users',
        value: '1.24M',
        icon: Icons.groups_rounded,
        color: Colors.blue,
        change: '+4.8%',
      ),
      DashboardMetric(
        label: 'Daily active users',
        value: '286K',
        icon: Icons.insights_rounded,
        color: Colors.purple,
        change: '+2.3%',
      ),
      DashboardMetric(
        label: 'Open complaints',
        value: '8,492',
        icon: Icons.support_agent_rounded,
        color: Colors.orange,
      ),
      DashboardMetric(
        label: 'Satisfaction',
        value: '4.62',
        icon: Icons.star_rounded,
        color: Colors.amber,
        change: '+0.12',
      ),
    ],
    sections: const [
      DashboardSection(title: 'Daily outages', child: _OutageChart()),
      DashboardSection(
        title: 'Platform health',
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _HealthRow(
                  label: 'API availability',
                  value: '99.99%',
                  healthy: true,
                ),
                Divider(),
                _HealthRow(
                  label: 'Notification delivery',
                  value: '98.7%',
                  healthy: true,
                ),
                Divider(),
                _HealthRow(
                  label: 'P95 API latency',
                  value: '184 ms',
                  healthy: true,
                ),
                Divider(),
                _HealthRow(
                  label: 'Crash-free users',
                  value: '99.72%',
                  healthy: true,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class _OutageChart extends StatelessWidget {
  const _OutageChart();

  @override
  Widget build(BuildContext context) {
    const values = [32.0, 41, 28, 54, 46, 38, 24];
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 16),
        child: SizedBox(
          height: 210,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (index) {
              final value = values[index];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 5),
                      Flexible(
                        child: FractionallySizedBox(
                          heightFactor: value / 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(labels[index]),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.label,
    required this.value,
    required this.healthy,
  });

  final String label;
  final String value;
  final bool healthy;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(
          healthy ? Icons.check_circle_rounded : Icons.warning_rounded,
          color: healthy ? Colors.green : Colors.orange,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );
}
