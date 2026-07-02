import 'package:go_router/go_router.dart';
import 'package:power_alert/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:power_alert/features/auth/presentation/login_screen.dart';
import 'package:power_alert/features/complaints/presentation/report_issue_screen.dart';
import 'package:power_alert/features/home/presentation/home_screen.dart';
import 'package:power_alert/features/map/presentation/outage_map_screen.dart';
import 'package:power_alert/features/notifications/presentation/notifications_screen.dart';
import 'package:power_alert/features/outages/presentation/outage_detail_screen.dart';
import 'package:power_alert/features/outages/presentation/outage_list_screen.dart';
import 'package:power_alert/features/provider/presentation/provider_dashboard_screen.dart';
import 'package:power_alert/features/technician/presentation/technician_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/outages',
      builder: (context, state) => const OutageListScreen(),
    ),
    GoRoute(
      path: '/outages/:id',
      builder: (context, state) =>
          OutageDetailScreen(outageId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/map', builder: (context, state) => const OutageMapScreen()),
    GoRoute(
      path: '/report',
      builder: (context, state) => const ReportIssueScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/provider',
      builder: (context, state) => const ProviderDashboardScreen(),
    ),
    GoRoute(
      path: '/technician',
      builder: (context, state) => const TechnicianDashboardScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);
