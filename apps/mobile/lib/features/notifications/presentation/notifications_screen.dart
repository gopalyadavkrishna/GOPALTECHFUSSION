import 'package:flutter/material.dart';
import 'package:power_alert/shared/widgets/app_navigation_scaffold.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.engineering_rounded,
        Colors.orange,
        'Repair team arrived',
        'Technicians are working on feeder F-17 in Indiranagar.',
        '4 min ago',
      ),
      (
        Icons.power_rounded,
        Colors.green,
        'Power restored',
        'Supply has been restored in Shivaji Nagar.',
        '22 min ago',
      ),
      (
        Icons.calendar_month_rounded,
        Colors.amber,
        'Maintenance tomorrow',
        'Koramangala 5th Block: 2:00 PM to 4:00 PM.',
        '1 hr ago',
      ),
      (
        Icons.confirmation_number_rounded,
        Colors.blue,
        'Complaint assigned',
        'Ticket PA-72841 was assigned to technician R. Kumar.',
        'Yesterday',
      ),
    ];
    return AppNavigationScaffold(
      currentIndex: 4,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark all read')),
          IconButton(
            tooltip: 'Notification settings',
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor: item.$2.withValues(alpha: 0.14),
                child: Icon(item.$1, color: item.$2),
              ),
              title: Text(
                item.$3,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text('${item.$4}\n${item.$5}'),
              ),
              isThreeLine: true,
              trailing: index == 0
                  ? const Badge(smallSize: 9, child: SizedBox.shrink())
                  : null,
            ),
          );
        },
      ),
    );
  }
}
