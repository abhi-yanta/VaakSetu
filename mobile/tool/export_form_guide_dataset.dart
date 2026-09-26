// Regenerates Form Field Guide dataset JSON from Dart source of truth.
// Run from mobile/:  flutter test tool/export_form_guide_dataset.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vaaksetu_mobile/data/services/preset_service.dart';
import 'package:vaaksetu_mobile/domain/models/form_field_model.dart';

void main() {
  test('export form guide dataset JSON', () {
    final mobileDir = Directory.current;
    final repoRoot = mobileDir.parent;
    final destDirs = [
      Directory('${repoRoot.path}${Platform.pathSeparator}dataset${Platform.pathSeparator}form_guide'),
      Directory(
        '${mobileDir.path}${Platform.pathSeparator}assets${Platform.pathSeparator}dataset${Platform.pathSeparator}form_guide',
      ),
    ];

    final fields = FormFieldDictionary.definitions.values
        .map(
          (d) => {
            'key': d.key,
            'defaultLabel': d.defaultLabel,
            'keywords': d.keywords,
            'labels': d.labels,
            'spokenHelp': d.spokenHelp,
          },
        )
        .toList();

    final formPresets = PresetService.getFormPresets()
        .map(
          (p) => {
            'id': p.id,
            'title': p.title,
            'previewDescription': p.previewDescription,
            'fullText': p.fullText,
            'isForm': p.isForm,
          },
        )
        .toList();

    final languages = <String>{};
    for (final d in FormFieldDictionary.definitions.values) {
      languages.addAll(d.labels.keys);
      languages.addAll(d.spokenHelp.keys);
    }

    final encoder = const JsonEncoder.withIndent('  ');
    final fieldsJson = '${encoder.convert({'fields': fields})}\n';
    final presetsJson = '${encoder.convert({'presets': formPresets})}\n';

    for (final dir in destDirs) {
      dir.createSync(recursive: true);
      File('${dir.path}${Platform.pathSeparator}fields.json')
          .writeAsStringSync(fieldsJson);
      File('${dir.path}${Platform.pathSeparator}form_presets.json')
          .writeAsStringSync(presetsJson);
    }

    // ignore: avoid_print
    print('Exported ${fields.length} fields, ${formPresets.length} form presets');
    // ignore: avoid_print
    print('Languages (${languages.length}): ${languages.toList()..sort()}');
    for (final dir in destDirs) {
      // ignore: avoid_print
      print(' -> ${dir.path}');
    }

    expect(fields.length, greaterThan(0));
    expect(formPresets.length, greaterThan(0));
  });
}
