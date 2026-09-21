import '../services/ocr_service.dart';
import '../services/preset_service.dart';
import '../../domain/models/document_analysis.dart';
import '../../domain/rules/rule_engine.dart';

class DocumentRepository {
  final OcrService _ocrService;

  DocumentRepository({OcrService? ocrService}) : _ocrService = ocrService ?? OcrService();

  Future<DocumentAnalysis> analyzeFromImagePath(String imagePath, {bool preferDevanagari = true}) async {
    final extractedText = await _ocrService.extractText(imagePath, preferDevanagari: preferDevanagari);
    return RuleEngine.analyze(extractedText);
  }

  DocumentAnalysis analyzeFromText(String rawText) {
    return RuleEngine.analyze(rawText);
  }

  List<DocumentPreset> getPresets() {
    return PresetService.getPresets();
  }

  void dispose() {
    _ocrService.dispose();
  }
}
