import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/repositories/document_repository.dart';
import 'data/services/haptic_service.dart';
import 'data/services/preset_service.dart';
import 'data/services/tts_service.dart';
import 'domain/models/document_analysis.dart';
import 'ui/core/app_colors.dart';
import 'ui/features/document_analyzer/document_analyzer_view.dart';
import 'ui/features/document_scanner/camera_scanner_view.dart';
import 'ui/features/language_selection/language_selector_view.dart';
import 'ui/features/language_selection/welcome_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final ttsService = TtsService();
  await ttsService.init();

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        primaryColor: AppColors.primarySaffron,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primarySaffron,
          secondary: AppColors.deepTeal,
          surface: AppColors.surfaceDark,
          error: AppColors.dangerRed,
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
  language,
  scanner,
  loading,
  analyzer,
}

class HomeScreen extends StatefulWidget {
  final TtsService ttsService;

  const HomeScreen({super.key, required this.ttsService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppView _currentView = AppView.welcome;
  String _selectedLang = 'hi';
  DocumentAnalysis? _analysis;
  String _loadingMessage = 'दस्तावेज़ पढ़ा जा रहा है...';
  late final DocumentRepository _documentRepository;

  @override
  void initState() {
    super.initState();
    _documentRepository = DocumentRepository();
    widget.ttsService.addListener(_onTtsStateChanged);
  }

  void _onTtsStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onStart() {
    HapticService.lightTap();
    setState(() => _currentView = AppView.language);
    widget.ttsService.speakPrompt('welcome', 'hi');
  }

  void _onLanguageSelected(String langCode) {
    setState(() {
      _selectedLang = langCode;
      _currentView = AppView.scanner;
    });
    widget.ttsService.speakPrompt('scan_prompt', langCode);
  }

  Future<void> _processImage(String imagePath) async {
    setState(() {
      _currentView = AppView.loading;
      _loadingMessage = 'दस्तावेज़ की सुरक्षा जांच हो रही है...';
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

      setState(() {
        _analysis = analysis;
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
      setState(() {
        _analysis = fallback;
        _currentView = AppView.analyzer;
      });
    }
  }

  void _processPreset(DocumentPreset preset) {
    setState(() {
      _currentView = AppView.loading;
      _loadingMessage = 'दस्तावेज़ की जांच हो रही है...';
    });
    widget.ttsService.speakPrompt('processing', _selectedLang);

    Future.delayed(const Duration(milliseconds: 600), () {
      final analysis = _documentRepository.analyzeFromText(preset.fullText);

      if (analysis.severity == DocumentSeverity.danger) {
        HapticService.dangerFeedback();
      } else if (analysis.severity == DocumentSeverity.warning) {
        HapticService.warningFeedback();
      }

      if (mounted) {
        setState(() {
          _analysis = analysis;
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
    widget.ttsService.speakPrompt('scan_prompt', _selectedLang);
  }

  void _resetToLanguage() {
    widget.ttsService.stop();
    setState(() {
      _analysis = null;
      _currentView = AppView.language;
    });
  }

  @override
  void dispose() {
    widget.ttsService.removeListener(_onTtsStateChanged);
    _documentRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                      color: Colors.white,
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
                      ? Border.all(color: AppColors.primarySaffronLight.withOpacity(0.6), width: 1.5)
                      : null,
                ),
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    color: isPlaying ? AppColors.primarySaffronLight : AppColors.textMuted,
                    size: 24,
                  ),
                  onPressed: () {
                    HapticService.lightTap();
                    if (widget.ttsService.isPlaying) {
                      widget.ttsService.stop();
                    } else {
                      widget.ttsService.speakPrompt('welcome', _selectedLang);
                    }
                  },
                  tooltip: isPlaying ? 'आवाज बंद करें (Mute)' : 'आवाज सुनें (Audio Guide)',
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _buildCurrentView(),
        ),
      ),
      bottomNavigationBar: Container(
        height: 36,
        color: AppColors.surfaceDark,
        alignment: Alignment.center,
        child: const Text(
          'VaakSetu • AI Document Assistant',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case AppView.welcome:
        return WelcomeView(onStart: _onStart);

      case AppView.language:
        return LanguageSelectorView(onLanguageSelected: _onLanguageSelected);

      case AppView.scanner:
        return CameraScannerView(
          selectedLang: _selectedLang,
          onImageCaptured: _processImage,
          onPresetSelected: _processPreset,
          onBack: _resetToLanguage,
        );

      case AppView.loading:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primarySaffron),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _loadingMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'कृपया प्रतीक्षा करें...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        );

      case AppView.analyzer:
        return DocumentAnalyzerView(
          analysis: _analysis!,
          selectedLang: _selectedLang,
          ttsService: widget.ttsService,
          onReset: _resetToScanner,
        );
    }
  }
}
