import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/haptic_service.dart';
import '../../../data/services/preset_service.dart';
import '../../../domain/models/localized_content.dart';
import '../../core/app_colors.dart';
import '../../core/tactile_button.dart';

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
        // Prefer rear camera
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
      ResolutionPreset.high,
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
      await _cameraController!.setFlashMode(nextFlash ? FlashMode.torch : FlashMode.off);
      setState(() => _isFlashOn = nextFlash);
    } catch (e) {
      debugPrint("Flash toggle: $e");
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
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
        imageQuality: 90,
      );
      if (image != null) {
        widget.onImageCaptured(image.path);
      }
    } catch (e) {
      debugPrint("Gallery pick error: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ui = LocalizedContent.uiTexts[widget.selectedLang] ?? LocalizedContent.uiTexts['hi']!;
    final allPresets = PresetService.getPresets();
    final presets = widget.forFormGuide
        ? allPresets.where((p) => p.isForm).toList()
        : allPresets;
    final scanTitle = widget.forFormGuide
        ? LocalizedContent.get(widget.selectedLang, 'mode_form_title')
        : (ui['take_photo'] ?? 'Scan Document');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                onPressed: () {
                  HapticService.lightTap();
                  widget.onBack();
                },
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.forFormGuide
                            ? Icons.edit_note_rounded
                            : Icons.document_scanner_rounded,
                        color: AppColors.primarySaffronLight,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          scanTitle,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isCameraReady)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        color: _isFlashOn ? AppColors.warningYellow : Colors.white70,
                      ),
                      onPressed: _toggleFlash,
                    ),
                    if (_cameras.length > 1)
                      IconButton(
                        icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white70),
                        onPressed: _toggleCamera,
                      ),
                  ],
                )
              else
                const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),

          // Camera Viewport or Fallback
          // Fixed, comfortable height (340px) with BoxFit.cover:
          // 1. Zero squishing/stretching (maintains native camera aspect ratio)
          // 2. Fits on screen with shutter button clearly visible without scrolling!
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 340,
              width: double.infinity,
              color: Colors.black,
              child: _isCameraReady && _cameraController != null
                  ? Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: 100,
                            height: 100 * _cameraController!.value.aspectRatio,
                            child: CameraPreview(_cameraController!),
                          ),
                        ),
                        // Framing Overlay Guide
                        Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primarySaffronLight.withOpacity(0.75),
                              width: 2.5,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                LocalizedContent.getFrameGuide(widget.selectedLang),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      height: 340,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 56),
                            const SizedBox(height: 14),
                            Text(
                              ui['camera_preparing'] ?? LocalizedContent.get(widget.selectedLang, 'camera_preparing'),
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primarySaffron,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                              label: Text(
                                ui['upload_photo'] ?? LocalizedContent.get(widget.selectedLang, 'upload_photo'),
                                style: const TextStyle(color: Colors.white),
                              ),
                              onPressed: _pickFromGallery,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // Shutter & Gallery Controls
          if (_isCameraReady) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: _capturePhoto,
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primarySaffron,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primarySaffron.withOpacity(0.5),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 34),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Upload File Alternative
          TactileButton(
            label: ui['upload_photo'] ?? LocalizedContent.get(widget.selectedLang, 'upload_photo'),
            icon: const Icon(Icons.file_upload_rounded, color: Colors.white, size: 22),
            style: TactileButtonStyle.secondary,
            height: 52,
            fontSize: 15,
            onPressed: _pickFromGallery,
          ),
          const SizedBox(height: 18),

          // Built-in Demo Documents Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySaffron.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primarySaffron.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📝 ${LocalizedContent.get(widget.selectedLang, 'try_form_guide')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LocalizedContent.get(widget.selectedLang, 'try_form_guide_hint'),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.description_rounded, color: AppColors.primarySaffronLight, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.forFormGuide
                    ? LocalizedContent.get(widget.selectedLang, 'try_form_guide')
                    : (ui['demo_docs'] ?? LocalizedContent.get(widget.selectedLang, 'demo_docs')),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: presets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final preset = presets[index];
              final isForm = preset.isForm;
              return Material(
                color: isForm
                    ? AppColors.primarySaffron.withValues(alpha: 0.14)
                    : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    HapticService.lightTap();
                    widget.onPresetSelected(preset);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isForm ? AppColors.primarySaffron : AppColors.borderDark,
                        width: isForm ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isForm ? Icons.edit_note_rounded : Icons.article_rounded,
                          color: AppColors.primarySaffronLight,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                preset.title,
                                style: const TextStyle(
                                  color: Colors.white,
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
                        if (isForm)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primarySaffron,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'GUIDE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
