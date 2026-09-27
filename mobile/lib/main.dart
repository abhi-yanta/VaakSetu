import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/repositories/document_repository.dart';
import 'data/services/haptic_service.dart';
import 'data/services/preset_service.dart';
import 'data/services/tts_service.dart';
import 'domain/models/document_analysis.dart';
import 'domain/models/localized_content.dart';
import 'ui/core/animated_logo.dart';
import 'ui/core/app_colors.dart';
import 'ui/core/speaking_caption_footer.dart';
import 'ui/core/vaaksetu_mascot.dart';
import 'ui/features/document_analyzer/document_analyzer_view.dart';
import 'ui/features/document_scanner/camera_scanner_view.dart';
import 'ui/features/language_selection/character_welcome_view.dart';
import 'ui/features/language_selection/language_selector_view.dart';
import 'ui/features/language_selection/welcome_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surfaceDark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Show UI immediately — TTS warms up after the first frame.
  final ttsService = TtsService();
  runApp(VaakSetuApp(ttsService: ttsService));
}

class VaakSetuApp extends StatelessWidget {
  final TtsService ttsService;

  const VaakSetuApp({super.key, required this.ttsService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaakSetu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.bgDark,
        primaryColor: AppColors.primarySaffron,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primarySaffron,
          secondary: AppColors.deepTeal,
          surface: AppColors.surfaceDark,
          error: AppColors.dangerRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      home: HomeScreen(ttsService: ttsService),
    );
  }
}

enum AppView {
  welcome,
  featureTour,
  language,
  scanner,
  loading,
  analyzer,
}

/// TEMP: Form Field Guide + mode chooser ("क्या करना है") are disabled.
/// After the feature tour, open the legal document scanner directly.
const bool kFormGuideEnabled = false;

class HomeScreen extends StatefulWidget {
  final TtsService ttsService;

  const HomeScreen({super.key, required this.ttsService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  AppView _currentView = AppView.welcome;
  String _selectedLang = 'hi';
  DocumentAnalysis? _analysis;
  String _loadingMessage = '';
  /// True after the user finishes (or skips) the post-language feature tour.
  bool _tourCompleted = false;
  late final DocumentRepository _documentRepository;
  GlobalKey<CharacterWelcomeViewState> _tourKey =
      GlobalKey<CharacterWelcomeViewState>();
  GlobalKey<DocumentAnalyzerViewState> _analyzerKey =
      GlobalKey<DocumentAnalyzerViewState>();
  DateTime? _lastRootBackAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _documentRepository = DocumentRepository();
    widget.ttsService.addListener(_onTtsStateChanged);
    // After welcome paints: warm TTS + mascot PNGs off the critical path.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.ttsService.ensureInitialized();
      VaakSetuMascot.precacheAll(context);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Do NOT pause on `inactive` — Android fires it for camera, dialogs,
    // and short transitions; that was killing TTS mid-sentence.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      widget.ttsService.pauseForBackground();
    } else if (state == AppLifecycleState.resumed) {
      widget.ttsService.resumeFromBackground();
    }
  }

  void _onTtsStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onStart() {
    HapticService.lightTap();
    widget.ttsService.stop();
    setState(() => _currentView = AppView.language);
    // Language picker: warm TTS/pipelines, then one Hindi welcome prompt.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _currentView != AppView.language) return;
      widget.ttsService.ensureInitialized();
      widget.ttsService.warmLanguagePipelines();
      widget.ttsService.speakPrompt('welcome', 'hi');
    });
  }

  void _onTourFinished() {
    HapticService.lightTap();
    setState(() => _tourCompleted = true);
    _openDocumentScanner();
  }

  void _onLanguageSelected(String langCode) {
    final goingToTour = !_tourCompleted;

    setState(() {
      _selectedLang = langCode;
      if (_tourCompleted) {
        _lastRootBackAt = null;
        _currentView = AppView.scanner;
      } else {
        _tourKey = GlobalKey<CharacterWelcomeViewState>();
        _currentView = AppView.featureTour;
      }
    });

    // Prefetch locale/pipeline for the chosen language, then speak the first
    // tour page immediately (speak() cancels the Hindi welcome). Do not call
    // stop() first — that would add an extra generation/queue stall.
    unawaited(widget.ttsService.prepareForLanguage(langCode));

    if (goingToTour) {
      final firstPageText =
          LocalizedContent.get(langCode, 'tour_scan_speak');
      unawaited(widget.ttsService.speak(firstPageText, langCode));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _currentView != AppView.scanner) return;
        widget.ttsService.speakPrompt('scan_prompt', _selectedLang);
      });
    }
  }

  void _openDocumentScanner() {
    HapticService.lightTap();
    widget.ttsService.stop();
    _lastRootBackAt = null; // don't inherit welcome double-back timing
    setState(() {
      _analysis = null;
      _currentView = AppView.scanner;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _currentView != AppView.scanner) return;
      widget.ttsService.speakPrompt('scan_prompt', _selectedLang);
    });
  }

  Future<void> _processImage(String imagePath) async {
    await widget.ttsService.stop();
    setState(() {
      _currentView = AppView.loading;
      _loadingMessage = LocalizedContent.get(_selectedLang, 'analyzing');
    });
    widget.ttsService.speakPrompt('processing', _selectedLang);

    try {
      final analysis = await _documentRepository.analyzeFromImagePath(
        imagePath,
        preferDevanagari: _selectedLang == 'hi' || _selectedLang == 'mr',
      );

      if (analysis.severity == DocumentSeverity.danger) {
        HapticService.dangerFeedback();
      } else if (analysis.severity == DocumentSeverity.warning) {
        HapticService.warningFeedback();
      }

      // Stop processing speech before the analyzer prompt.
      await widget.ttsService.stop();
      if (!mounted) return;
      setState(() {
        _analysis = analysis;
        _analyzerKey = GlobalKey<DocumentAnalyzerViewState>();
        _currentView = AppView.analyzer;
      });
    } catch (e) {
      debugPrint("Analysis error: $e");
      final fallback = DocumentAnalysis(
        category: DocumentCategory.unclear,
        severity: DocumentSeverity.unknown,
        warningKeys: ['alert_unclear_image'],
        rawText: '',
        analyzedAt: DateTime.now(),
        confidenceScore: 0.0,
      );
      await widget.ttsService.stop();
      if (!mounted) return;
      setState(() {
        _analysis = fallback;
        _analyzerKey = GlobalKey<DocumentAnalyzerViewState>();
        _currentView = AppView.analyzer;
      });
    }
  }

  void _processPreset(DocumentPreset preset) {
    widget.ttsService.stop();
    setState(() {
      _currentView = AppView.loading;
      _loadingMessage = LocalizedContent.get(_selectedLang, 'analyzing');
    });
    widget.ttsService.speakPrompt('processing', _selectedLang);

    Future.delayed(const Duration(milliseconds: 600), () async {
      final analysis = _documentRepository.analyzeFromText(preset.fullText);

      if (analysis.severity == DocumentSeverity.danger) {
        HapticService.dangerFeedback();
      } else if (analysis.severity == DocumentSeverity.warning) {
        HapticService.warningFeedback();
      }

      await widget.ttsService.stop();
      if (mounted) {
        setState(() {
          _analysis = analysis;
          _analyzerKey = GlobalKey<DocumentAnalyzerViewState>();
          _currentView = AppView.analyzer;
        });
      }
    });
  }

  void _resetToScanner() {
    widget.ttsService.stop();
    setState(() {
      _analysis = null;
      _currentView = AppView.scanner;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _currentView != AppView.scanner) return;
      widget.ttsService.speakPrompt('scan_prompt', _selectedLang);
    });
  }

  void _resetToLanguage() {
    widget.ttsService.stop();
    setState(() {
      _analysis = null;
      _currentView = AppView.language;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _currentView != AppView.language) return;
      widget.ttsService.ensureInitialized();
      widget.ttsService.warmLanguagePipelines();
      widget.ttsService.speakPrompt('welcome', 'hi');
    });
  }

  void _resetToWelcome() {
    widget.ttsService.stop();
    setState(() {
      _analysis = null;
      _currentView = AppView.welcome;
    });
  }

  void _onAnalyzerReset() {
    _resetToScanner();
  }

  /// Android system back — mirrors in-app Back through the state-based flow.
  void _handleSystemBack() {
    switch (_currentView) {
      case AppView.welcome:
        _handleRootDoubleBack();
        return;
      case AppView.language:
        _resetToWelcome();
        return;
      case AppView.featureTour:
        if (_tourKey.currentState?.handleSystemBack() ?? false) return;
        _resetToLanguage();
        return;
      case AppView.scanner:
        // Same as in-app back arrow — never exit the app from scanner.
        HapticService.lightTap();
        _resetToLanguage();
        return;
      case AppView.loading:
        _resetToScanner();
        return;
      case AppView.analyzer:
        if (_analyzerKey.currentState?.handleSystemBack() ?? false) return;
        widget.ttsService.stop();
        HapticService.lightTap();
        _resetToScanner();
        return;
    }
  }

  /// Double-back-to-exit only on the welcome screen.
  void _handleRootDoubleBack() {
    final now = DateTime.now();
    if (_lastRootBackAt != null &&
        now.difference(_lastRootBackAt!) < const Duration(seconds: 2)) {
      widget.ttsService.stop();
      SystemNavigator.pop();
      return;
    }
    _lastRootBackAt = now;
    HapticService.lightTap();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          LocalizedContent.get(_selectedLang, 'press_back_again'),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Replay the prompt that belongs to the current screen only.
  void _replayCurrentScreenPrompt() {
    switch (_currentView) {
      case AppView.welcome:
        break;
      case AppView.language:
        widget.ttsService.speakPrompt('welcome', 'hi');
        break;
      case AppView.featureTour:
        // Tour pages store the spoken text in TtsService; replay that.
        widget.ttsService.replayLast();
        break;
      case AppView.scanner:
        widget.ttsService.speakPrompt('scan_prompt', _selectedLang);
        break;
      case AppView.loading:
        widget.ttsService.speakPrompt('processing', _selectedLang);
        break;
      case AppView.analyzer:
        // Prefer last spoken safety/warning text; fall back to result_ready.
        if (widget.ttsService.hasLastSpoken) {
          widget.ttsService.replayLast();
        } else {
          widget.ttsService.speakPrompt('result_ready', _selectedLang);
        }
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.ttsService.stop();
    widget.ttsService.removeListener(_onTtsStateChanged);
    _documentRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isScanner = _currentView == AppView.scanner;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleSystemBack();
      },
      child: Scaffold(
        backgroundColor: isScanner ? Colors.black : AppColors.bgDark,
        // Full-screen scanner: no global AppBar / footer / body padding.
        appBar: isScanner
            ? null
            : AppBar(
                backgroundColor: AppColors.surfaceDark,
                elevation: 0,
                title: InkWell(
                  onTap: _resetToLanguage,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VaakSetu',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'AI Document Assistant',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  AnimatedBuilder(
                    animation: widget.ttsService,
                    builder: (context, _) {
                      final isPlaying = widget.ttsService.isPlaying;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? AppColors.primarySaffron.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isPlaying
                              ? Border.all(
                                  color: AppColors.primarySaffronLight
                                      .withOpacity(0.6),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            color: isPlaying
                                ? AppColors.primarySaffronLight
                                : AppColors.textMuted,
                            size: 24,
                          ),
                          onPressed: () {
                            HapticService.lightTap();
                            if (widget.ttsService.isPlaying) {
                              widget.ttsService.stop();
                            } else {
                              _replayCurrentScreenPrompt();
                            }
                          },
                          tooltip: isPlaying
                              ? LocalizedContent.get(_selectedLang, 'mute')
                              : LocalizedContent.get(_selectedLang, 'unmute'),
                        ),
                      );
                    },
                  ),
                ],
              ),
        body: isScanner
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _buildCurrentView(),
                  // Captions sit in the footer zone; IgnorePointer keeps
                  // gallery / shutter / flash tappable underneath.
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SpeakingCaptionFooter(
                      ttsService: widget.ttsService,
                      showIdleBrand: false,
                    ),
                  ),
                ],
              )
            : SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _buildCurrentView(),
                ),
              ),
        bottomNavigationBar: isScanner
            ? null
            : SpeakingCaptionFooter(ttsService: widget.ttsService),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case AppView.welcome:
        return WelcomeView(onStart: _onStart);

      case AppView.featureTour:
        return CharacterWelcomeView(
          key: _tourKey,
          ttsService: widget.ttsService,
          selectedLang: _selectedLang,
          onFinished: _onTourFinished,
          // Parent already kicked page-0 speak on language confirm.
          skipInitialSpeak: true,
        );

      case AppView.language:
        return LanguageSelectorView(
          onLanguageSelected: _onLanguageSelected,
          ttsService: widget.ttsService,
        );

      case AppView.scanner:
        return CameraScannerView(
          selectedLang: _selectedLang,
          forFormGuide: kFormGuideEnabled,
          onImageCaptured: _processImage,
          onPresetSelected: _processPreset,
          onBack: _resetToLanguage,
        );

      case AppView.loading:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AnimatedLogo(size: 80, isLoading: true),
              const SizedBox(height: 32),
              Text(
                _loadingMessage,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                LocalizedContent.get(_selectedLang, 'please_wait'),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        );

      case AppView.analyzer:
        return DocumentAnalyzerView(
          key: _analyzerKey,
          analysis: _analysis!,
          selectedLang: _selectedLang,
          ttsService: widget.ttsService,
          onReset: _onAnalyzerReset,
          initialShowFormGuide: false,
          formGuideEnabled: kFormGuideEnabled,
        );
    }
  }
}
