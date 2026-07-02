import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:power_alert/app/power_alert_app.dart';

void main() {
  testWidgets('shows production authentication choices', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PowerAlertApp()));
    await tester.pumpAndSettle();

    expect(find.text('Power Alert'), findsOneWidget);
    expect(find.text('Mobile OTP'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Preview role'), findsNothing);
    expect(
      find.text(
        'Protected by Firebase Authentication and device verification.',
      ),
      findsOneWidget,
    );
  });
}
