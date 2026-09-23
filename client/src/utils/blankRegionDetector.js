/**
 * Blank Field Region Detection (MVP Heuristic Engine)
 * Modular architecture: Can be swapped with OpenCV.js contour detection in v2.
 * 
 * Classifies canvas regions immediately below and to the right of detected field labels.
 * Measures background uniformity, ink pixel density vs baseline label text density.
 */

/**
 * Extract pixel luminance (0 = black, 255 = white)
 */
function getPixelLuminance(r, g, b) {
  return 0.299 * r + 0.587 * g + 0.114 * b;
}

/**
 * Analyze an ImageData region for ink density and lightness uniformity
 */
function analyzeCanvasRegion(ctx, x, y, width, height) {
  // Clamp boundaries to canvas bounds
  const canvasW = ctx.canvas.width;
  const canvasH = ctx.canvas.height;

  const rx = Math.max(0, Math.min(Math.round(x), canvasW - 1));
  const ry = Math.max(0, Math.min(Math.round(y), canvasH - 1));
  const rw = Math.max(1, Math.min(Math.round(width), canvasW - rx));
  const rh = Math.max(1, Math.min(Math.round(height), canvasH - ry));

  if (rw <= 2 || rh <= 2) {
    return { valid: false, inkDensity: 1.0, avgLightness: 0, uniformity: 0 };
  }

  try {
    const imgData = ctx.getImageData(rx, ry, rw, rh);
    const data = imgData.data;
    const totalPixels = rw * rh;

    let totalLuminance = 0;
    let inkPixels = 0; // Dark / handwritten / printed marks

    // Two-pass: 1) mean luminance, 2) variance
    const luminances = new Float32Array(totalPixels);
    for (let i = 0; i < totalPixels; i++) {
      const idx = i * 4;
      const lum = getPixelLuminance(data[idx], data[idx + 1], data[idx + 2]);
      luminances[i] = lum;
      totalLuminance += lum;

      // Darker than 140 is typically ink/printed border/text
      if (lum < 140) {
        inkPixels++;
      }
    }

    const avgLum = totalLuminance / totalPixels;
    let varianceSum = 0;
    for (let i = 0; i < totalPixels; i++) {
      const diff = luminances[i] - avgLum;
      varianceSum += diff * diff;
    }
    const stdDev = Math.sqrt(varianceSum / totalPixels);

    return {
      valid: true,
      x: rx,
      y: ry,
      width: rw,
      height: rh,
      inkDensity: inkPixels / totalPixels,
      avgLightness: avgLum,
      uniformity: Math.max(0, 1 - (stdDev / 128)) // 1.0 = perfectly uniform
    };
  } catch (err) {
    // Canvas tainted or unavailable
    return { valid: false, inkDensity: 0.1, avgLightness: 240, uniformity: 0.8 };
  }
}

/**
 * Main Blank Region Detection Function
 * @param {HTMLImageElement|HTMLCanvasElement|Object} imageSource 
 * @param {Array} detectedFields - Fields detected by fuzzy matcher with bbox
 * @param {Object} options - Tuning parameters
 * @returns {Array} - Enriched fields with blankRegion and confidence ('green'|'yellow'|'red')
 */
export function detectBlankRegions(imageSource, detectedFields, options = {}) {
  if (!detectedFields || detectedFields.length === 0) return [];

  // Determine document dimensions
  const docWidth = imageSource?.naturalWidth || imageSource?.width || 800;
  const docHeight = imageSource?.naturalHeight || imageSource?.height || 1100;

  // Prepare offscreen canvas for pixel inspection
  let ctx = null;
  let hasPixelAccess = false;

  if (typeof document !== 'undefined' && imageSource) {
    try {
      const canvas = document.createElement('canvas');
      canvas.width = docWidth;
      canvas.height = docHeight;
      const context = canvas.getContext('2d', { willReadFrequently: true });
      if (context) {
        if (imageSource instanceof HTMLImageElement || imageSource instanceof HTMLCanvasElement) {
          context.drawImage(imageSource, 0, 0, docWidth, docHeight);
        } else {
          // Fill default white paper backdrop for preview
          context.fillStyle = '#FFFFFF';
          context.fillRect(0, 0, docWidth, docHeight);
        }
        ctx = context;
        hasPixelAccess = true;
      }
    } catch (e) {
      console.warn("Offscreen canvas pixel inspection unavailable; using geometric heuristic fallback:", e);
      hasPixelAccess = false;
    }
  }

  return detectedFields.map((field) => {
    const { bbox } = field;
    if (!bbox) {
      return {
        ...field,
        confidence: 'red',
        confidenceScore: 0.1,
        blankRegion: null,
        blankPosition: 'unclear_box'
      };
    }

    const labelW = bbox.width || (bbox.x1 - bbox.x0);
    const labelH = bbox.height || (bbox.y1 - bbox.y0);

    // 1. Establish baseline label text ink density
    let labelBaselineInk = 0.28; // Default typical printed text density
    if (hasPixelAccess && ctx) {
      const labelAnalysis = analyzeCanvasRegion(ctx, bbox.x0, bbox.y0, labelW, labelH);
      if (labelAnalysis.valid && labelAnalysis.inkDensity > 0.05) {
        labelBaselineInk = labelAnalysis.inkDensity;
      }
    }

    // 2. Candidate A: Region to the RIGHT of label
    // Common in forms like "Name: [                    ]" or "Date: [        ]"
    const marginX = 12;
    const rightX = bbox.x1 + marginX;
    const rightY = bbox.y0 - 2;
    const rightW = Math.min(Math.max(docWidth * 0.35, 140), docWidth - rightX - 16);
    const rightH = Math.max(labelH * 1.25, 28);

    // 3. Candidate B: Region BELOW the label
    // Common in forms with labels stacked above input boxes:
    // "Applicant Signature / Thumb Impression"
    // "[                   BOX                     ]"
    const marginY = 8;
    const belowX = bbox.x0;
    const belowY = bbox.y1 + marginY;
    const isSpecialBox = field.fieldKey === 'signature' || field.fieldKey === 'address';
    const belowW = Math.min(
      Math.max(labelW * 1.5, isSpecialBox ? docWidth * 0.42 : docWidth * 0.35),
      docWidth - belowX - 20
    );
    const belowH = isSpecialBox ? Math.max(labelH * 2.8, 64) : Math.max(labelH * 1.5, 34);

    let rightAnalysis = { valid: false };
    let belowAnalysis = { valid: false };

    if (hasPixelAccess && ctx) {
      rightAnalysis = analyzeCanvasRegion(ctx, rightX, rightY, rightW, rightH);
      belowAnalysis = analyzeCanvasRegion(ctx, belowX, belowY, belowW, belowH);
    }

    // Evaluate Right Candidate
    let rightScore = 0;
    const rightFeasible = rightX + 60 < docWidth && rightW >= 60;
    if (rightFeasible) {
      if (rightAnalysis.valid) {
        // High lightness, low ink compared to label
        const isLight = rightAnalysis.avgLightness > 180;
        const lowInk = rightAnalysis.inkDensity < labelBaselineInk * 0.45;
        if (isLight && lowInk) {
          rightScore = 0.85 + (rightAnalysis.uniformity * 0.1);
        } else if (isLight) {
          rightScore = 0.55;
        }
      } else {
        // Geometric heuristic: fields like phone, dob, date often have inputs to the right
        if (['phone', 'dob', 'date', 'gender'].includes(field.fieldKey)) {
          rightScore = 0.82;
        } else {
          rightScore = 0.65;
        }
      }
    }

    // Evaluate Below Candidate
    let belowScore = 0;
    const belowFeasible = belowY + 24 < docHeight && belowH >= 24;
    if (belowFeasible) {
      if (belowAnalysis.valid) {
        const isLight = belowAnalysis.avgLightness > 180;
        const lowInk = belowAnalysis.inkDensity < labelBaselineInk * 0.45;
        if (isLight && lowInk) {
          belowScore = 0.88 + (belowAnalysis.uniformity * 0.1);
        } else if (isLight) {
          belowScore = 0.58;
        }
      } else {
        // Geometric heuristic: signature, address, name often have inputs below
        if (['signature', 'address', 'name', 'occupation', 'id_number'].includes(field.fieldKey)) {
          belowScore = 0.86;
        } else {
          belowScore = 0.70;
        }
      }
    }

    // Selection & Classification
    let chosenCandidate = null;
    let confidence = 'red';
    let confidenceScore = 0;
    let position = 'unclear_box';

    if (belowScore >= rightScore && belowScore > 0.4) {
      chosenCandidate = {
        x: belowX,
        y: belowY,
        width: Math.round(belowW),
        height: Math.round(belowH),
        position: 'below'
      };
      confidenceScore = belowScore;
      position = 'below';
    } else if (rightScore > 0.4) {
      chosenCandidate = {
        x: rightX,
        y: rightY,
        width: Math.round(rightW),
        height: Math.round(rightH),
        position: 'right'
      };
      confidenceScore = rightScore;
      position = 'right';
    }

    // Map confidence score to visual hierarchy: Green / Yellow / Red
    if (chosenCandidate) {
      if (confidenceScore >= 0.78) {
        confidence = 'green';
      } else if (confidenceScore >= 0.50) {
        confidence = 'yellow';
      } else {
        confidence = 'red';
        position = 'unclear_box';
      }
    } else {
      confidence = 'red';
      position = 'unclear_box';
    }

    return {
      ...field,
      confidence,
      confidenceScore,
      blankRegion: chosenCandidate,
      blankPosition: position
    };
  });
}
