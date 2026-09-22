import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaaksetu_mobile/data/services/tts_service.dart';
import 'package:vaaksetu_mobile/ui/core/document_text_reader.dart';

void main() {
  testWidgets('DocumentTextReader renders full text audio button and sentence list', (WidgetTester tester) async {
    final ttsService = TtsService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentTextReader(
            text: 'यह ऋण अनुबंध पत्र है। इसमें ब्याज दर 36% है।',
            langCode: 'hi',
            ttsService: ttsService,
          ),
        ),
      ),
    );

    // Verify full text speech button is displayed
    expect(find.text('पूरा पाठ सुनें'), findsOneWidget);

    // Verify sentences are split into tappable cards
    expect(find.text('यह ऋण अनुबंध पत्र है।'), findsOneWidget);
    expect(find.text('इसमें ब्याज दर 36% है।'), findsOneWidget);

    // Tap on sentence card
    await tester.tap(find.text('इसमें ब्याज दर 36% है।'));
    await tester.pump();

    // Tap on Read Full Document Text button
    await tester.tap(find.text('पूरा पाठ सुनें'));
    await tester.pump();

    expect(find.byType(DocumentTextReader), findsOneWidget);
  });
}
