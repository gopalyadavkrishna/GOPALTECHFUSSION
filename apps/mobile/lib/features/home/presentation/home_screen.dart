import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:power_alert/app/providers.dart';
import 'package:power_alert/core/config/app_environment.dart';
import 'package:power_alert/core/localization/app_localizations.dart';
import 'package:power_alert/domain/models/outage.dart';
import 'package:power_alert/shared/widgets/app_navigation_scaffold.dart';
import 'package:power_alert/shared/widgets/async_value_view.dart';
import 'package:power_alert/shared/widgets/outage_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outages = ref.watch(activeOutagesProvider);
    final strings = AppLocalizations.of(context);

    return AppNavigationScaffold(
      currentIndex: 0,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.text('appName'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const Text(
              'Good morning, Gopal',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Saved locations',
            onPressed: () {},
            icon: const Icon(Icons.bookmark_outline_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: 'Account menu',
            padding: const EdgeInsets.only(right: 16),
            onSelected: (value) async {
              if (value != 'logout') return;
              if (!AppEnvironment.useDemoData) {
                await FirebaseAuth.instance.signOut();
              }
              if (context.mounted) context.go('/');
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Secure logout'),
                ),
              ),
            ],
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Text('GY'),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(activeOutagesProvider),
        child: AsyncValueView(
          value: outages,
          data: (items) {
            final active = items.where((item) => item.isActive).toList();
            final primary = active.firstOrNull;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                _PowerStatusCard(outage: primary),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings.text('quickActions'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/outages'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const _QuickActions(),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings.text('activeOutages'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Badge(
                      label: Text('${active.length}'),
                      child: const Icon(Icons.electric_bolt_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...active
                    .take(2)
                    .map(
                      (outage) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: OutageCard(outage: outage),
                      ),
                    ),
                const SizedBox(height: 8),
                const _SafetyBanner(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PowerStatusCard extends StatelessWidget {
  const _PowerStatusCard({required this.outage});

  final Outage? outage;

  @override
  Widget build(BuildContext context) {
    final hasOutage = outage != null;
    final color = hasOutage ? outage!.status.color : Colors.green;
    return Semantics(
      liveRegion: true,
      label: hasOutage
          ? '${outage!.status.label} in ${outage!.areaName}'
          : 'Power available',
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.94),
              color.withValues(alpha: 0.66),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    hasOutage ? Icons.power_off_rounded : Icons.bolt_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              hasOutage ? outage!.status.label : 'Power Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              hasOutage ? outage!.areaName : 'Your monitored area',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasOutage) ...[
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: outage!.progress,
                  minHeight: 8,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      outage!.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (outage!.estimatedRestoreTime != null)
                    Text(
                      DateFormat.jm().format(outage!.estimatedRestoreTime!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('View outages', Icons.power_off_rounded, '/outages'),
      ('Live map', Icons.map_rounded, '/map'),
      ('Report issue', Icons.add_alert_rounded, '/report'),
      ('Notifications', Icons.notifications_rounded, '/notifications'),
      ('Saved areas', Icons.bookmark_rounded, '/home'),
      ('Emergency', Icons.emergency_rounded, '/home'),
      ('Provider', Icons.business_rounded, '/home'),
      ('Support', Icons.support_agent_rounded, '/home'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 600 ? 8 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.88,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.go(action.$3),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        action.$2,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 28,
                      ),
                      const SizedBox(height: 9),
                      Text(
                        action.$1,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner();

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: const Padding(
      padding: EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.health_and_safety_rounded),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'See a fallen wire? Keep at least 10 metres away and call '
              'your provider emergency line immediately.',
            ),
          ),
        ],
      ),
    ),
  );
}
