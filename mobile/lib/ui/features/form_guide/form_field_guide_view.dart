import 'package:flutter/material.dart';
import '../../../data/services/haptic_service.dart';
import '../../../data/services/tts_service.dart';
import '../../../domain/models/form_field_model.dart';
import '../../../domain/models/localized_content.dart';
import '../../../domain/rules/form_field_engine.dart';
import '../../core/app_colors.dart';
import '../../core/tactile_button.dart';
import '../../core/wave_visualizer.dart';

class FormFieldGuideView extends StatefulWidget {
  final String rawText;
  final String selectedLang;
  final TtsService ttsService;
  final VoidCallback onBack;
  final VoidCallback? onSwitchToSafety;

  const FormFieldGuideView({
    super.key,
    required this.rawText,
    required this.selectedLang,
    required this.ttsService,
    required this.onBack,
    this.onSwitchToSafety,
  });

  @override
  State<FormFieldGuideView> createState() => _FormFieldGuideViewState();
}

class _FormFieldGuideViewState extends State<FormFieldGuideView> with SingleTickerProviderStateMixin {
  List<FormFieldItem> _fields = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.ttsService.addListener(_onTtsStateChanged);
    _isPlaying = widget.ttsService.isPlaying;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initFields();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_fields.isNotEmpty) {
        _speakField(_currentIndex);
      }
    });
  }

  void _onTtsStateChanged() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.ttsService.isPlaying;
      });
    }
  }

  void _initFields() {
    final parsed = FormFieldEngine.parseDocumentToFormFields(
      rawText: widget.rawText,
      langCode: widget.selectedLang,
      docWidth: 380.0,
      docHeight: 700.0,
    );

    setState(() {
      _fields = parsed;
      _currentIndex = 0;
    });
  }

  void _speakField(int index) {
    if (index < 0 || index >= _fields.length) return;
    final field = _fields[index];
    final def = FormFieldDictionary.definitions[field.fieldKey];

    final buffer = StringBuffer();
    // 1. Field number and title
    buffer.write("फ़ील्ड ${field.readingOrder}: ${field.translatedLabel}। ");

    // 2. Location prompt
    if (field.confidence == FieldConfidence.red || field.blankPosition == BlankPosition.unclear) {
      final unclear = FormFieldDictionary.positionUnclear[widget.selectedLang] ??
          FormFieldDictionary.positionUnclear['hi']!;
      buffer.write("$unclear ");
    } else if (field.blankPosition == BlankPosition.right) {
      final right = FormFieldDictionary.positionRight[widget.selectedLang] ??
          FormFieldDictionary.positionRight['hi']!;
      buffer.write("$right ");
    } else {
      final below = FormFieldDictionary.positionBelow[widget.selectedLang] ??
          FormFieldDictionary.positionBelow['hi']!;
      buffer.write("$below ");
    }

    // 3. Spoken instructions
    if (def != null && field.confidence != FieldConfidence.red) {
      final help = def.spokenHelp[widget.selectedLang] ?? def.spokenHelp['hi'];
      if (help != null) {
        buffer.write(help);
      }
    }

    HapticService.lightTap();
    widget.ttsService.speak(buffer.toString(), widget.selectedLang);
  }

  void _handleNext() {
    if (_currentIndex < _fields.length - 1) {
      widget.ttsService.stop();
      setState(() => _currentIndex++);
      _speakField(_currentIndex);
    }
  }

  void _handlePrev() {
    if (_currentIndex > 0) {
      widget.ttsService.stop();
      setState(() => _currentIndex--);
      _speakField(_currentIndex);
    }
  }

  void _handleToggleAudio() {
    if (_isPlaying) {
      widget.ttsService.stop();
    } else {
      _speakField(_currentIndex);
    }
  }

  void _selectField(int index) {
    widget.ttsService.stop();
    setState(() => _currentIndex = index);
    _speakField(index);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    widget.ttsService.removeListener(_onTtsStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentField = _fields.isNotEmpty ? _fields[_currentIndex] : null;
    final def = currentField != null ? FormFieldDictionary.definitions[currentField.fieldKey] : null;

    return Column(
      children: [
        // Mode Switcher Bar at top
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    widget.ttsService.stop();
                    widget.onSwitchToSafety?.call();
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: const Text(
                      '🛡️ सुरक्षा जांच (Safety)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primarySaffron.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primarySaffron),
                  ),
                  child: const Text(
                    '📝 फॉर्म गाइड (Form Guide)',
                    style: TextStyle(
                      color: AppColors.primarySaffron,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Progress Pill Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'फ़ील्ड ${_fields.isNotEmpty ? _currentIndex + 1 : 0} / ${_fields.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: _showFieldListSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.list, size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text('सूची (List)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Progress bar line
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _fields.isNotEmpty ? (_currentIndex + 1) / _fields.length : 0.0,
              backgroundColor: AppColors.surfaceDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primarySaffron),
              minHeight: 6,
            ),
          ),
        ),

        // Document Canvas Viewport
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDark),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document Header Banner
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Text(
                                'OFFICIAL REGISTRATION FORM',
                                style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Divider(color: Colors.black12, thickness: 1),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Form Fields Cards
                      if (_fields.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'कोई फॉर्म फ़ील्ड नहीं पहचानी जा सकी।',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        )
                      else
                        ..._fields.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final f = entry.value;
                          final isActive = idx == _currentIndex;

                          return _buildFormFieldCard(idx, f, isActive);
                        }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Bottom Step Walkthrough Card
        if (currentField != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(
                top: BorderSide(
                  color: currentField.confidence == FieldConfidence.green
                      ? AppColors.safeGreen
                      : currentField.confidence == FieldConfidence.yellow
                          ? AppColors.warningYellow
                          : AppColors.dangerRed,
                  width: 2.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Field Header: Circle Number + Title + Pill
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: currentField.confidence == FieldConfidence.green
                            ? AppColors.safeGreen
                            : currentField.confidence == FieldConfidence.yellow
                                ? AppColors.warningYellow
                                : AppColors.dangerRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${currentField.readingOrder}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentField.translatedLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '(${currentField.label})',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildConfidenceBadge(currentField.confidence),
                  ],
                ),
                const SizedBox(height: 10),

                // Spoken Guidance Text Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentField.confidence == FieldConfidence.red
                            ? '📍 ${FormFieldDictionary.positionUnclear[widget.selectedLang] ?? FormFieldDictionary.positionUnclear['hi']}'
                            : currentField.blankPosition == BlankPosition.right
                                ? '📍 ${FormFieldDictionary.positionRight[widget.selectedLang] ?? FormFieldDictionary.positionRight['hi']}'
                                : '📍 ${FormFieldDictionary.positionBelow[widget.selectedLang] ?? FormFieldDictionary.positionBelow['hi']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (def != null && currentField.confidence != FieldConfidence.red) ...[
                        const SizedBox(height: 4),
                        Text(
                          '💡 ${def.spokenHelp[widget.selectedLang] ?? def.spokenHelp['hi']}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Navigation Controls Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TactileButton(
                        label: '⬅️ पिछला',
                        style: TactileButtonStyle.secondary,
                        onPressed: _currentIndex > 0 ? _handlePrev : () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TactileButton(
                        label: _isPlaying ? '⏹️ आवाज रोकें' : '🔊 दोबारा सुनें',
                        style: _isPlaying ? TactileButtonStyle.danger : TactileButtonStyle.primary,
                        onPressed: _handleToggleAudio,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TactileButton(
                        label: 'अगला ➡️',
                        style: TactileButtonStyle.safe,
                        onPressed: _currentIndex < _fields.length - 1 ? _handleNext : () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFormFieldCard(int index, FormFieldItem f, bool isActive) {
    Color borderColor;
    Color bgColor;

    if (f.confidence == FieldConfidence.green) {
      borderColor = const Color(0xFF279B61);
      bgColor = const Color(0xFFF0FDF4);
    } else if (f.confidence == FieldConfidence.yellow) {
      borderColor = const Color(0xFFEAA100);
      bgColor = const Color(0xFFFEFCE8);
    } else {
      borderColor = const Color(0xFFDF2E2E);
      bgColor = const Color(0xFFFEF2F2);
    }

    return GestureDetector(
      onTap: () => _selectField(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? bgColor : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? borderColor : Colors.grey.shade300,
            width: isActive ? 2.5 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label Row
            Row(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: isActive ? borderColor : Colors.grey.shade400,
                  child: Text(
                    '${f.readingOrder}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${f.translatedLabel} (${f.label})',
                    style: TextStyle(
                      color: Colors.grey.shade900,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      f.confidence == FieldConfidence.green ? 'भरें' : 'जांचें',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Simulated Blank Box Input Area
            Container(
              width: double.infinity,
              height: f.fieldKey == 'signature' ? 52 : (f.fieldKey == 'address' ? 44 : 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive ? borderColor : Colors.grey.shade400,
                  width: isActive ? 1.5 : 1.0,
                  style: f.confidence == FieldConfidence.red ? BorderStyle.none : BorderStyle.solid,
                ),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                f.confidence == FieldConfidence.red
                    ? '⚠️ डिब्बा स्पष्ट नहीं है — कृपया सहायता लें'
                    : (f.fieldKey == 'signature' ? '✍️ हस्ताक्षर या अंगूठा यहाँ लगाएं' : 'खाली स्थान (Blank Box)'),
                style: TextStyle(
                  color: f.confidence == FieldConfidence.red ? Colors.red.shade700 : Colors.black38,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(FieldConfidence conf) {
    if (conf == FieldConfidence.green) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.safeGreen.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.safeGreen),
        ),
        child: const Text('✓ तैयार (Green)', style: TextStyle(color: AppColors.safeGreen, fontSize: 11, fontWeight: FontWeight.bold)),
      );
    } else if (conf == FieldConfidence.yellow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warningYellow.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warningYellow),
        ),
        child: const Text('⚠ जांचें (Yellow)', style: TextStyle(color: AppColors.warningYellow, fontSize: 11, fontWeight: FontWeight.bold)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.dangerRed.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dangerRed),
        ),
        child: const Text('✕ सहायता लें (Red)', style: TextStyle(color: AppColors.dangerRed, fontSize: 11, fontWeight: FontWeight.bold)),
      );
    }
  }

  void _showFieldListSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'सभी फ़ील्ड सूची (${_fields.length})',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: AppColors.borderDark),
              Expanded(
                child: ListView.builder(
                  itemCount: _fields.length,
                  itemBuilder: (context, i) {
                    final f = _fields[i];
                    final isSel = i == _currentIndex;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: f.confidence == FieldConfidence.green
                            ? AppColors.safeGreen
                            : (f.confidence == FieldConfidence.yellow ? AppColors.warningYellow : AppColors.dangerRed),
                        child: Text('${f.readingOrder}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                      title: Text(
                        f.translatedLabel,
                        style: TextStyle(
                          color: isSel ? AppColors.primarySaffron : Colors.white,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(f.label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _selectField(i);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
