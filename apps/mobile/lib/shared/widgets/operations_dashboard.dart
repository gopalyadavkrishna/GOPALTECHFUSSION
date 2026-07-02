import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:power_alert/core/config/app_environment.dart';

class OperationsDashboard extends StatelessWidget {
  const OperationsDashboard({
    required this.title,
    required this.subtitle,
    required this.metrics,
    required this.sections,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<DashboardMetric> metrics;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Search',
          onPressed: () {},
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          tooltip: 'Secure logout',
          onPressed: () async {
            if (!AppEnvironment.useDemoData) {
              await FirebaseAuth.instance.signOut();
            }
            if (context.mounted) context.go('/');
          },
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width > 1000
                  ? 4
                  : width > 560
                  ? 2
                  : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: width < 400 ? 1.12 : 1.5,
                ),
                itemCount: metrics.length,
                itemBuilder: (context, index) =>
                    _MetricCard(metric: metrics[index]),
              );
            },
          ),
          const SizedBox(height: 24),
          ...sections.expand(
            (section) => [section, const SizedBox(height: 18)],
          ),
        ],
      ),
    ),
  );
}

class DashboardMetric {
  const DashboardMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.change,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? change;
}

class DashboardSection extends StatelessWidget {
  const DashboardSection({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
      const SizedBox(height: 10),
      child,
    ],
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final DashboardMetric metric;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(metric.icon, color: metric.color),
              ),
              const Spacer(),
              if (metric.change != null)
                Text(
                  metric.change!,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            metric.value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(metric.label),
        ],
      ),
    ),
  );
}
