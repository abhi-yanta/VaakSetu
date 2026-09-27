import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/haptic_service.dart';
import '../../../data/services/preset_service.dart';
import '../../../domain/models/localized_content.dart';
import '../../core/app_colors.dart';

/// Full-screen legal document scanner (live camera + gallery + shutter).
class CameraScannerView extends StatefulWidget {
  final String selectedLang;
  final Function(String imagePath) onImageCaptured;
  final Function(DocumentPreset preset) onPresetSelected;
  final VoidCallback onBack;
  /// When true, prioritizes form demos and titles the screen for form scanning.
  final bool forFormGuide;

  const CameraScannerView({
    super.key,
    required this.selectedLang,
    required this.onImageCaptured,
    required this.onPresetSelected,
    required this.onBack,
    this.forFormGuide = false,
  });

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraReady = false;
  bool _isFlashOn = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _selectedCameraIndex = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
        );
        if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;
        await _startCamera(_cameras[_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint("Camera initialization fallback: $e");
    }
  }

  Future<void> _startCamera(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      // Higher capture quality for document OCR readability.
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraReady = true;
        });
      }
    } catch (e) {
      debugPrint("Failed to start camera controller: $e");
      // Fallback if veryHigh is unsupported on device.
      try {
        final fallback = CameraController(
          camera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await fallback.initialize();
        if (mounted) {
          setState(() {
            _cameraController = fallback;
            _isCameraReady = true;
          });
        }
      } catch (e2) {
        debugPrint("Camera fallback also failed: $e2");
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    HapticService.selectionClick();
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _cameraController?.dispose();
    setState(() => _isCameraReady = false);
    await _startCamera(_cameras[_selectedCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    HapticService.lightTap();
    try {
      final nextFlash = !_isFlashOn;
      await _cameraController!
          .setFlashMode(nextFlash ? FlashMode.torch : FlashMode.off);
      setState(() => _isFlashOn = nextFlash);
    } catch (e) {
      debugPrint("Flash toggle: $e");
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    HapticService.dangerFeedback();
    try {
      final XFile photo = await _cameraController!.takePicture();
      widget.onImageCaptured(photo.path);
    } catch (e) {
      debugPrint("Photo capture error: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    HapticService.lightTap();
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );
      if (image != null) {
        widget.onImageCaptured(image.path);
      }
    } catch (e) {
      debugPrint("Gallery pick error: $e");
    }
  }

  void _showDemoSheet() {
    HapticService.lightTap();
    final allPresets = PresetService.getPresets();
    final presets = widget.forFormGuide
        ? allPresets.where((p) => p.isForm).toList()
        : allPresets.where((p) => !p.isForm).toList();
    final ui =
        LocalizedContent.uiTexts[widget.selectedLang] ?? LocalizedContent.uiTexts['hi']!;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  ui['demo_docs'] ??
                      LocalizedContent.get(widget.selectedLang, 'demo_docs'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: presets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final preset = presets[index];
                      return Material(
                        color: AppColors.bgDark,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            HapticService.lightTap();
                            widget.onPresetSelected(preset);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.article_rounded,
                                  color: AppColors.primarySaffronLight,
                                  size: 28,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        preset.title,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        preset.previewDescription,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview() {
    if (!_isCameraReady || _cameraController == null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primarySaffron),
              const SizedBox(height: 16),
              Text(
                LocalizedContent.get(widget.selectedLang, 'camera_preparing'),
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    final previewSize = _cameraController!.value.previewSize;
    // previewSize is landscape-oriented from the plugin; swap for portrait UI.
    final previewW = previewSize?.height ?? 3.0;
    final previewH = previewSize?.width ?? 4.0;

    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: previewW,
        height: previewH,
        child: CameraPreview(_cameraController!),
      ),
    );
  }

  Widget _buildBottomControl({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool highlight = false,
  }) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: !enabled
                  ? Colors.white24
                  : highlight
                      ? AppColors.warningYellow
                      : Colors.white,
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: enabled ? Colors.white70 : Colors.white24,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.selectedLang;
    final scanTitle = widget.forFormGuide
        ? LocalizedContent.get(lang, 'mode_form_title')
        : LocalizedContent.get(lang, 'take_photo');
    final galleryLabel = LocalizedContent.getGalleryShortLabel(lang);
    final flashLabel = LocalizedContent.getFlashLabel(lang);
    final flipLabel = LocalizedContent.getFlipLabel(lang);
    final demoLabel = LocalizedContent.get(lang, 'demo_docs');

    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Thin header: back + title (outside camera frame)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {
                      HapticService.lightTap();
                      widget.onBack();
                    },
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.forFormGuide
                              ? Icons.edit_note_rounded
                              : Icons.description_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            scanTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Camera frame — preview + overlay controls INSIDE the frame
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildCameraPreview(),

                      // Saffron border
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primarySaffronLight
                                  .withValues(alpha: 0.9),
                              width: 2.5,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),

                      // Frame guide text (top, inside frame)
                      Positioned(
                        top: 14,
                        left: 16,
                        right: 16,
                        child: IgnorePointer(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                LocalizedContent.getFrameGuide(lang),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Controls INSIDE frame — capture stays large & centered;
                      // gallery / flash / flip are smaller side icons.
                      Positioned(
                        left: 6,
                        right: 6,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left half — keeps shutter geometrically centered
                              Expanded(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: _buildBottomControl(
                                    icon: Icons.photo_library_outlined,
                                    label: galleryLabel,
                                    onTap: _pickFromGallery,
                                  ),
                                ),
                              ),
                              // Center — large capture button
                              GestureDetector(
                                onTap: _isCameraReady ? _capturePhoto : null,
                                child: Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isCameraReady
                                        ? AppColors.primarySaffron
                                        : Colors.white24,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: _isCameraReady
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primarySaffron
                                                  .withValues(alpha: 0.45),
                                              blurRadius: 14,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                                ),
                              ),
                              // Right half — flash + flip (smaller icons)
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                      child: _buildBottomControl(
                                        icon: _isFlashOn
                                            ? Icons.flash_on_rounded
                                            : Icons.flash_off_rounded,
                                        label: flashLabel,
                                        highlight: _isFlashOn,
                                        onTap: _isCameraReady
                                            ? _toggleFlash
                                            : null,
                                      ),
                                    ),
                                    Flexible(
                                      child: _buildBottomControl(
                                        icon: Icons.cameraswitch_rounded,
                                        label: flipLabel,
                                        onTap: _cameras.length > 1
                                            ? _toggleCamera
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Demo docs — OUTSIDE the camera frame; extra bottom space so
            // speaking captions don't cover this button.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _showDemoSheet,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primarySaffron,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.description_rounded, size: 22),
                  label: Text(
                    demoLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
