import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaaksetu_mobile/data/services/tts_service.dart';
import 'package:vaaksetu_mobile/ui/core/interactive_word_reader.dart';

void main() {
  testWidgets('InteractiveWordReader renders words as touchable tiles', (WidgetTester tester) async {
    final ttsService = TtsService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InteractiveWordReader(
            text: 'ऋण अनुबंध पत्र',
            langCode: 'hi',
            ttsService: ttsService,
          ),
        ),
      ),
    );

    expect(find.text('ऋण'), findsOneWidget);
    expect(find.text('अनुबंध'), findsOneWidget);
    expect(find.text('पत्र'), findsOneWidget);

    // Tap on a word tile
    await tester.tap(find.text('अनुबंध'));
    await tester.pump();

    // Verify word stays rendered and active
    expect(find.text('अनुबंध'), findsOneWidget);
  });
}
