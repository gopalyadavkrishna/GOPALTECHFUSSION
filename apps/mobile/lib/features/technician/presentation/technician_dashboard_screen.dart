import 'package:flutter/material.dart';
import 'package:power_alert/shared/widgets/operations_dashboard.dart';

class TechnicianDashboardScreen extends StatelessWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => OperationsDashboard(
    title: 'My field jobs',
    subtitle: 'R. Kumar • Team East-4',
    metrics: const [
      DashboardMetric(
        label: 'Assigned today',
        value: '6',
        icon: Icons.assignment_rounded,
        color: Colors.blue,
      ),
      DashboardMetric(
        label: 'In progress',
        value: '2',
        icon: Icons.build_circle_rounded,
        color: Colors.orange,
      ),
      DashboardMetric(
        label: 'Completed',
        value: '4',
        icon: Icons.task_alt_rounded,
        color: Colors.green,
      ),
      DashboardMetric(
        label: 'Completion rate',
        value: '94%',
        icon: Icons.speed_rounded,
        color: Colors.purple,
        change: '+2.1%',
      ),
    ],
    sections: [
      DashboardSection(
        title: 'Current assignment',
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Chip(label: Text('URGENT')),
                    Spacer(),
                    Text('PA-72841'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Low voltage • Indiranagar',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Repeated evening voltage fluctuations affecting '
                  'multiple homes near 12th Main.',
                ),
                const SizedBox(height: 18),
                const LinearProgressIndicator(value: 0.45, minHeight: 10),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.navigation_rounded),
                        label: const Text('Navigate'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Update status'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      DashboardSection(
        title: 'Next jobs',
        child: Card(
          child: Column(
            children: const [
              ListTile(
                leading: CircleAvatar(child: Text('2')),
                title: Text('Transformer inspection'),
                subtitle: Text('Domlur • 3.2 km'),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
              Divider(height: 1),
              ListTile(
                leading: CircleAvatar(child: Text('3')),
                title: Text('Street light outage'),
                subtitle: Text('HAL 2nd Stage • 4.8 km'),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
