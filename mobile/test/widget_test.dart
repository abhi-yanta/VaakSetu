import 'package:flutter_test/flutter_test.dart';
import 'package:vaaksetu_mobile/data/services/tts_service.dart';
import 'package:vaaksetu_mobile/main.dart';

void main() {
  testWidgets('VaakSetu app smoke test', (WidgetTester tester) async {
    final ttsService = TtsService();
    await tester.pumpWidget(VaakSetuApp(ttsService: ttsService));

    // Verify that the title or brand is rendered
    expect(find.text('VaakSetu'), findsWidgets);
  });
}

