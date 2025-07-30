import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yasart_frontend/main.dart'; // Make sure this path matches your actual file

void main() {
  testWidgets('YASART SCADA Login screen renders', (WidgetTester tester) async {
    // Build the YASART SCADA app and trigger a frame.
    await tester.pumpWidget(const YasartSCADAApp());

    // Verify the presence of login fields.
    expect(find.text('YASART SCADA Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
