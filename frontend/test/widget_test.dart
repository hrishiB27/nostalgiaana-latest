import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/auth/presentation/splash_screen.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App boots into the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NostalgiaanaApp()));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
