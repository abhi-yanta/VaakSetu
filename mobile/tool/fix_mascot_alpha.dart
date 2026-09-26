/// Repair mascot PNG alpha: fill interior holes, close small edge bites,
/// and despill leftover pink/magenta chroma fringe.
///
/// Inpainting prefers nearby, color-similar opaque neighbors so cream shirt
/// pixels are not painted onto skin holes.
///
/// Usage (from mobile/):
///   dart run tool/fix_mascot_alpha.dart [mascotDir]
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _alphaOpaque = 200;
const _alphaHole = 160;
const _closeRadius = 2;
const _searchRadii = [1, 2, 3, 5, 8, 12, 20, 40];

void main(List<String> args) {
  final mascotDir = Directory(
    args.isNotEmpty
        ? args.first
        : '${Directory.current.path}${Platform.pathSeparator}assets'
            '${Platform.pathSeparator}mascot',
  );
  if (!mascotDir.existsSync()) {
    stderr.writeln('Mascot dir not found: ${mascotDir.path}');
    exit(1);
  }

  final files = mascotDir
      .listSync()
      .whereType<File>()
      .where((f) {
        final name = f.uri.pathSegments.last.toLowerCase();
        return name.endsWith('_final.png');
      })
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final before = file.readAsBytesSync();
    final decoded = img.decodePng(before);
    if (decoded == null) {
      stderr.writeln('Failed to decode ${file.path}');
      continue;
    }

    final rgba = decoded.convert(numChannels: 4);
    final result = repairMascot(rgba);
    final after = img.encodePng(result.image, level: 6);
    file.writeAsBytesSync(after);

    stdout.writeln(
      '${file.uri.pathSegments.last}: '
      'holes=${result.holesFilled} closed=${result.edgeClosed} '
      'despill=${result.despilled} '
      '(${before.length} -> ${after.length} bytes)',
    );
  }
}

class _RepairStats {
  final img.Image image;
  final int holesFilled;
  final int edgeClosed;
  final int despilled;
  _RepairStats(this.image, this.holesFilled, this.edgeClosed, this.despilled);
}

_RepairStats repairMascot(img.Image src) {
  final exterior = _markExterior(src);
  var holesFilled = _fillInteriorHoles(src, exterior);
  final edgeClosed = _morphologicalCloseAndInpaint(src);
  final exterior2 = _markExterior(src);
  holesFilled += _fillInteriorHoles(src, exterior2);
  final exterior3 = _markExterior(src);
  final despilled = _despillPinkFringe(src, exterior3);
  // Fix any cream/white blotches left inside skin from bad sampling.
  final cleaned = _recolorAnomalousLightBlotches(src, exterior3);
  _softenBoundary(src, exterior3);
  return _RepairStats(src, holesFilled, edgeClosed, despilled + cleaned);
}

List<bool> _markExterior(img.Image src) {
  final w = src.width;
  final h = src.height;
  final exterior = List<bool>.filled(w * h, false);
  final queue = <int>[];

  bool isLowAlpha(int i) {
    final x = i % w;
    final y = i ~/ w;
    return src.getPixel(x, y).a < _alphaHole;
  }

  void enqueue(int i) {
    if (i < 0 || i >= w * h) return;
    if (exterior[i]) return;
    if (!isLowAlpha(i)) return;
    exterior[i] = true;
    queue.add(i);
  }

  for (var x = 0; x < w; x++) {
    enqueue(x);
    enqueue((h - 1) * w + x);
  }
  for (var y = 0; y < h; y++) {
    enqueue(y * w);
    enqueue(y * w + (w - 1));
  }

  var qi = 0;
  while (qi < queue.length) {
    final i = queue[qi++];
    final x = i % w;
    if (x > 0) enqueue(i - 1);
    if (x + 1 < w) enqueue(i + 1);
    if (i >= w) enqueue(i - w);
    if (i + w < w * h) enqueue(i + w);
  }
  return exterior;
}

int _fillInteriorHoles(img.Image src, List<bool> exterior) {
  final w = src.width;
  final remaining = <int>{};
  for (var i = 0; i < exterior.length; i++) {
    if (!exterior[i] && src.getPixel(i % w, i ~/ w).a < _alphaHole) {
      remaining.add(i);
    }
  }
  if (remaining.isEmpty) return 0;

  var filled = 0;
  for (var guard = 0; guard < 60 && remaining.isNotEmpty; guard++) {
    final newly = <int>[];
    final force = guard > 12;
    for (final i in remaining) {
      final sample = _sampleOpaqueNeighbors(
        src,
        i % w,
        i ~/ w,
        remaining,
        forceLarge: force,
      );
      if (sample == null) continue;
      src.setPixelRgba(i % w, i ~/ w, sample.$1, sample.$2, sample.$3, 255);
      newly.add(i);
      filled++;
    }
    if (newly.isEmpty) break;
    for (final i in newly) {
      remaining.remove(i);
    }
  }
  return filled;
}

int _morphologicalCloseAndInpaint(img.Image src) {
  final w = src.width;
  final h = src.height;
  final n = w * h;
  final opaque = List<bool>.filled(n, false);
  for (var i = 0; i < n; i++) {
    opaque[i] = src.getPixel(i % w, i ~/ w).a >= _alphaOpaque;
  }

  List<bool> dilate(List<bool> mask, int radius) {
    final out = List<bool>.from(mask);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (mask[y * w + x]) continue;
        var hit = false;
        for (var dy = -radius; dy <= radius && !hit; dy++) {
          for (var dx = -radius; dx <= radius; dx++) {
            final nx = x + dx;
            final ny = y + dy;
            if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
            if (dx * dx + dy * dy > radius * radius) continue;
            if (mask[ny * w + nx]) {
              hit = true;
              break;
            }
          }
        }
        if (hit) out[y * w + x] = true;
      }
    }
    return out;
  }

  List<bool> erode(List<bool> mask, int radius) {
    final out = List<bool>.from(mask);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (!mask[y * w + x]) continue;
        var keep = true;
        for (var dy = -radius; dy <= radius && keep; dy++) {
          for (var dx = -radius; dx <= radius; dx++) {
            final nx = x + dx;
            final ny = y + dy;
            if (nx < 0 || ny < 0 || nx >= w || ny >= h) {
              keep = false;
              break;
            }
            if (dx * dx + dy * dy > radius * radius) continue;
            if (!mask[ny * w + nx]) {
              keep = false;
              break;
            }
          }
        }
        if (!keep) out[y * w + x] = false;
      }
    }
    return out;
  }

  final closed = erode(dilate(opaque, _closeRadius), _closeRadius);
  final remaining = <int>{};
  for (var i = 0; i < n; i++) {
    if (closed[i] && !opaque[i]) remaining.add(i);
  }
  if (remaining.isEmpty) return 0;

  var filled = 0;
  for (var guard = 0; guard < 40 && remaining.isNotEmpty; guard++) {
    final newly = <int>[];
    for (final i in remaining) {
      final sample = _sampleOpaqueNeighbors(
        src,
        i % w,
        i ~/ w,
        remaining,
        forceLarge: guard > 8,
      );
      if (sample == null) continue;
      src.setPixelRgba(i % w, i ~/ w, sample.$1, sample.$2, sample.$3, 255);
      newly.add(i);
      filled++;
    }
    if (newly.isEmpty) break;
    for (final i in newly) {
      remaining.remove(i);
    }
  }
  return filled;
}

bool _isPinkish(int r, int g, int b) {
  if (r < 140 || b < 100) return false;
  if (g >= r * 0.82) return false;
  if ((r - g) < 35) return false;
  if (b > g + 25 && r > g + 35) return true;
  if (r > 200 && b > 160 && g < 150) return true;
  return false;
}

bool _isCreamShirtLike(int r, int g, int b) {
  // Off-white / cream clothing — must not be used to fill skin holes.
  return r > 220 && g > 210 && b > 190 && (r - b) < 50 && (g - b) < 45;
}

bool _isSkinLike(int r, int g, int b) {
  // Broad tan/brown skin range for this mascot.
  if (r < 90 || r > 230) return false;
  if (g < 55 || g > 190) return false;
  if (b < 40 || b > 160) return false;
  if (r <= g) return false;
  if (g < b - 10) return false;
  return true;
}

int _despillPinkFringe(img.Image src, List<bool> exterior) {
  final w = src.width;
  final h = src.height;
  final updates = <int, (int, int, int, int)>{};

  for (var y = 1; y < h - 1; y++) {
    for (var x = 1; x < w - 1; x++) {
      final i = y * w + x;
      final p = src.getPixel(x, y);
      final a = p.a.toInt();
      if (a < 40) continue;
      final r = p.r.toInt(), g = p.g.toInt(), b = p.b.toInt();
      if (!_isPinkish(r, g, b)) continue;

      var nearExterior = exterior[i];
      if (!nearExterior) {
        for (final d in [-1, 1, -w, w, -w - 1, -w + 1, w - 1, w + 1]) {
          final ni = i + d;
          if (ni >= 0 && ni < w * h && exterior[ni]) {
            nearExterior = true;
            break;
          }
        }
      }
      final nearEdge = a < 250 || nearExterior;
      if (!nearEdge && !(r > 210 && b > 170 && g < 140)) continue;

      var rSum = 0.0, gSum = 0.0, bSum = 0.0, wSum = 0.0;
      for (var dy = -2; dy <= 2; dy++) {
        for (var dx = -2; dx <= 2; dx++) {
          if (dx == 0 && dy == 0) continue;
          final nx = x + dx, ny = y + dy;
          if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
          final np = src.getPixel(nx, ny);
          if (np.a < _alphaOpaque) continue;
          final nr = np.r.toInt(), ng = np.g.toInt(), nb = np.b.toInt();
          if (_isPinkish(nr, ng, nb)) continue;
          final weight = 1.0 / (math.sqrt(dx * dx + dy * dy) + 0.25);
          rSum += nr * weight;
          gSum += ng * weight;
          bSum += nb * weight;
          wSum += weight;
        }
      }

      if (wSum > 0) {
        updates[i] = (
          (rSum / wSum).round().clamp(0, 255),
          (gSum / wSum).round().clamp(0, 255),
          (bSum / wSum).round().clamp(0, 255),
          a < 180 ? 255 : a,
        );
      } else {
        final ng = math.max(g, ((r + b) / 2 * 0.85).round());
        final nr = (r * 0.75 + ng * 0.25).round().clamp(0, 255);
        final nb = (b * 0.65 + ng * 0.35).round().clamp(0, 255);
        updates[i] = (nr, ng.clamp(0, 255), nb, a < 180 ? 255 : a);
      }
    }
  }

  for (final e in updates.entries) {
    final i = e.key;
    src.setPixelRgba(i % w, i ~/ w, e.value.$1, e.value.$2, e.value.$3, e.value.$4);
  }
  return updates.length;
}

/// Replace cream/white blotches that sit inside otherwise skin-colored regions.
int _recolorAnomalousLightBlotches(img.Image src, List<bool> exterior) {
  final w = src.width;
  final h = src.height;
  final updates = <int, (int, int, int)>{};

  for (var y = 2; y < h - 2; y++) {
    for (var x = 2; x < w - 2; x++) {
      final i = y * w + x;
      if (exterior[i]) continue;
      final p = src.getPixel(x, y);
      if (p.a < _alphaOpaque) continue;
      final r = p.r.toInt(), g = p.g.toInt(), b = p.b.toInt();
      if (!_isCreamShirtLike(r, g, b) && !(r > 235 && g > 230 && b > 220)) {
        continue;
      }

      // Local neighborhood vote: mostly skin => this cream pixel is a blotch.
      var skin = 0, cream = 0, other = 0;
      var sr = 0.0, sg = 0.0, sb = 0.0;
      for (var dy = -3; dy <= 3; dy++) {
        for (var dx = -3; dx <= 3; dx++) {
          if (dx == 0 && dy == 0) continue;
          final nx = x + dx, ny = y + dy;
          final ni = ny * w + nx;
          if (exterior[ni]) continue;
          final np = src.getPixel(nx, ny);
          if (np.a < _alphaOpaque) continue;
          final nr = np.r.toInt(), ng = np.g.toInt(), nb = np.b.toInt();
          if (_isCreamShirtLike(nr, ng, nb) || (nr > 235 && ng > 230 && nb > 220)) {
            cream++;
            continue;
          }
          if (_isSkinLike(nr, ng, nb)) {
            skin++;
            sr += nr;
            sg += ng;
            sb += nb;
          } else {
            other++;
          }
        }
      }

      // Only rewrite when clearly surrounded by skin (not actual shirt).
      if (skin < 8) continue;
      if (skin <= cream + other) continue;

      updates[i] = (
        (sr / skin).round().clamp(0, 255),
        (sg / skin).round().clamp(0, 255),
        (sb / skin).round().clamp(0, 255),
      );
    }
  }

  for (final e in updates.entries) {
    final i = e.key;
    final a = src.getPixel(i % w, i ~/ w).a.toInt();
    src.setPixelRgba(i % w, i ~/ w, e.value.$1, e.value.$2, e.value.$3, a);
  }
  return updates.length;
}

(int, int, int)? _sampleOpaqueNeighbors(
  img.Image src,
  int x,
  int y,
  Set<int> stillHoles, {
  bool forceLarge = false,
}) {
  final w = src.width;
  final h = src.height;

  // Estimate local context color from the closest opaque ring.
  final context = _localContextColor(src, x, y, stillHoles);
  final preferSkin = context == null || _isSkinLike(context.$1, context.$2, context.$3);
  final radii = forceLarge ? _searchRadii : _searchRadii.take(6).toList();

  for (final radius in radii) {
    var rSum = 0.0, gSum = 0.0, bSum = 0.0, wSum = 0.0;
    var count = 0;

    for (var dy = -radius; dy <= radius; dy++) {
      for (var dx = -radius; dx <= radius; dx++) {
        if (dx == 0 && dy == 0) continue;
        final nx = x + dx;
        final ny = y + dy;
        if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
        final ni = ny * w + nx;
        if (stillHoles.contains(ni)) continue;
        final p = src.getPixel(nx, ny);
        if (p.a < _alphaOpaque) continue;
        final pr = p.r.toInt(), pg = p.g.toInt(), pb = p.b.toInt();
        if (_isPinkish(pr, pg, pb)) continue;

        // When filling into a skin neighborhood, skip cream/shirt samples.
        if (preferSkin && _isCreamShirtLike(pr, pg, pb)) continue;
        if (preferSkin && pr > 235 && pg > 230 && pb > 220) continue;

        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist > radius) continue;

        var weight = 1.0 / (dist + 0.25);
        if (context != null) {
          final cd = (pr - context.$1).abs() +
              (pg - context.$2).abs() +
              (pb - context.$3).abs();
          // Strongly prefer similar colors.
          weight *= 1.0 / (1.0 + cd / 18.0);
          if (cd > 90 && !forceLarge) continue;
        }
        if (preferSkin && _isSkinLike(pr, pg, pb)) {
          weight *= 2.5;
        }

        rSum += pr * weight;
        gSum += pg * weight;
        bSum += pb * weight;
        wSum += weight;
        count++;
      }
    }

    final minCount = forceLarge ? 1 : (radius <= 2 ? 1 : 2);
    if (count >= minCount && wSum > 0) {
      return (
        (rSum / wSum).round().clamp(0, 255),
        (gSum / wSum).round().clamp(0, 255),
        (bSum / wSum).round().clamp(0, 255),
      );
    }
  }
  return null;
}

(int, int, int)? _localContextColor(
  img.Image src,
  int x,
  int y,
  Set<int> stillHoles,
) {
  final w = src.width;
  final h = src.height;
  for (final radius in [2, 4, 6, 10]) {
    var rSum = 0.0, gSum = 0.0, bSum = 0.0, n = 0;
    for (var dy = -radius; dy <= radius; dy++) {
      for (var dx = -radius; dx <= radius; dx++) {
        final nx = x + dx, ny = y + dy;
        if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
        final ni = ny * w + nx;
        if (stillHoles.contains(ni)) continue;
        final p = src.getPixel(nx, ny);
        if (p.a < _alphaOpaque) continue;
        final pr = p.r.toInt(), pg = p.g.toInt(), pb = p.b.toInt();
        if (_isPinkish(pr, pg, pb)) continue;
        if (_isCreamShirtLike(pr, pg, pb)) continue;
        rSum += pr;
        gSum += pg;
        bSum += pb;
        n++;
      }
    }
    if (n >= 3) {
      return (
        (rSum / n).round(),
        (gSum / n).round(),
        (bSum / n).round(),
      );
    }
  }
  return null;
}

void _softenBoundary(img.Image src, List<bool> exterior) {
  final w = src.width;
  final h = src.height;
  final updates = <int, (int, int, int)>{};
  for (var y = 1; y < h - 1; y++) {
    for (var x = 1; x < w - 1; x++) {
      final i = y * w + x;
      if (exterior[i]) continue;
      final p = src.getPixel(x, y);
      if (p.a < _alphaOpaque) continue;

      var touchesExt = false;
      for (final d in [-1, 1, -w, w]) {
        if (exterior[i + d]) {
          touchesExt = true;
          break;
        }
      }
      if (!touchesExt) continue;

      var rSum = 0.0, gSum = 0.0, bSum = 0.0, n = 0;
      for (var dy = -1; dy <= 1; dy++) {
        for (var dx = -1; dx <= 1; dx++) {
          final nx = x + dx, ny = y + dy;
          final ni = ny * w + nx;
          if (exterior[ni]) continue;
          final np = src.getPixel(nx, ny);
          if (np.a < _alphaOpaque) continue;
          final nr = np.r.toInt(), ng = np.g.toInt(), nb = np.b.toInt();
          if (_isPinkish(nr, ng, nb)) continue;
          rSum += nr;
          gSum += ng;
          bSum += nb;
          n++;
        }
      }
      if (n < 3) continue;
      updates[i] = (
        (rSum / n).round().clamp(0, 255),
        (gSum / n).round().clamp(0, 255),
        (bSum / n).round().clamp(0, 255),
      );
    }
  }
  for (final e in updates.entries) {
    final i = e.key;
    final a = src.getPixel(i % w, i ~/ w).a.toInt();
    src.setPixelRgba(i % w, i ~/ w, e.value.$1, e.value.$2, e.value.$3, a);
  }
}
