import 'package:flutter_test/flutter_test.dart';
import 'package:vaaksetu_mobile/data/services/tts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TtsService pauseForBackground and resumeFromBackground state transition', () async {
    final ttsService = TtsService();

    // Verify initial state
    expect(ttsService.isPlaying, false);
    expect(ttsService.wasSpeakingBeforePause, false);

    // Call pause & resume methods when not playing
    await ttsService.pauseForBackground();
    expect(ttsService.wasSpeakingBeforePause, false);

    await ttsService.resumeFromBackground();
    expect(ttsService.wasSpeakingBeforePause, false);

    // Call stop
    await ttsService.stop();
    expect(ttsService.isPlaying, false);
    expect(ttsService.wasSpeakingBeforePause, false);
  });
}
