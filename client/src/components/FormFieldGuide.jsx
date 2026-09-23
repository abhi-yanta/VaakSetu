import React, { useState, useEffect, useRef } from 'react';
import { guider } from '../utils/voiceGuider';
import { FIELD_DEFINITIONS, POSITION_PROMPTS } from '../utils/formFieldDictionary';
import { extractFormFieldsFromOCR } from '../utils/fieldMatcher';
import { detectBlankRegions } from '../utils/blankRegionDetector';
import { sortFieldsInReadingOrder } from '../utils/readingOrderSorter';
import { 
  ChevronLeft, 
  ChevronRight, 
  Volume2, 
  Square, 
  CheckCircle2, 
  AlertCircle, 
  HelpCircle, 
  Play, 
  RotateCcw,
  Sparkles,
  ListFilter,
  FileText
} from 'lucide-react';

const LOCALIZED_GUIDE_UI = {
  hi: {
    title: "फॉर्म फ़ील्ड गाइड",
    subtitle: "फॉर्म भरने में बोलकर सहायता",
    field_step: "फ़ील्ड",
    of: "कुल",
    prev: "पिछला",
    next: "अगला",
    repeat: "दोबारा सुनें",
    stop: "आवाज रोकें",
    auto_play: "लगातार सुनना",
    ready_to_fill: "यहाँ भरें (सुरक्षित स्थान)",
    verify_box: "जांचें (अनुमानित स्थान)",
    seek_help: "सहायता लें (डिब्बा नहीं मिला)",
    all_fields: "सभी फ़ील्ड सूची",
    no_fields_found: "इस कागज़ पर कोई फॉर्म फ़ील्ड नहीं पहचानी जा सकी।",
    back_to_scan: "वापस जाएं",
    view_document: "फॉर्म देखें",
    done_title: "फॉर्म समाप्त!",
    done_msg: "आपने फॉर्म के सभी फ़ील्ड सुन लिए हैं।"
  },
  ta: {
    title: "படிவ வழிகாட்டி",
    subtitle: "படிவத்தை நிரப்ப குரல் உதவி",
    field_step: "புலம்",
    of: "இல்",
    prev: "முந்தைய",
    next: "அடுத்தது",
    repeat: "மீண்டும் கேள்",
    stop: "நிறுத்து",
    auto_play: "தொடர் வாசிப்பு",
    ready_to_fill: "இங்கு நிரப்பவும்",
    verify_box: "சரிபார்க்கவும்",
    seek_help: "உதவி கேட்கவும்",
    all_fields: "அனைத்து புலங்கள்",
    no_fields_found: "படிவ புலங்கள் எதுவும் கண்டறியப்படவில்லை.",
    back_to_scan: "பின்செல்",
    view_document: "படிவத்தைக் காண்க",
    done_title: "படிவம் முடிந்தது!",
    done_msg: "அனைத்து புலங்களையும் கேட்டு முடித்துவிட்டீர்கள்."
  },
  te: {
    title: "ఫారమ్ ఫీల్డ్ గైడ్",
    subtitle: "ఫారమ్ నింపడానికి వాయిస్ సహాయం",
    field_step: "ఫీల్డ్",
    of: "మొత్తం",
    prev: "మునుపటి",
    next: "తదుపరి",
    repeat: "మళ్ళీ వినండి",
    stop: "ఆపు",
    auto_play: "ఆటో ప్లే",
    ready_to_fill: "ఇక్కడ పూరించండి",
    verify_box: "సరిచూసుకోండి",
    seek_help: "సహాయం కోరండి",
    all_fields: "అన్ని ఫీల్డ్‌లు",
    no_fields_found: "ఎటువంటి ఫీల్డ్‌లు గుర్తించబడలేదు.",
    back_to_scan: "వెనుకకు",
    view_document: "పత్రం చూడండి",
    done_title: "ఫారమ్ పూర్తయింది!",
    done_msg: "మీరు అన్ని ఫీల్డ్‌లను విన్నారు."
  },
  mr: {
    title: "फॉर्म मार्गदर्शक",
    subtitle: "फॉर्म भरण्यासाठी आवाज सहाय्य",
    field_step: "रकाना",
    of: "पैकी",
    prev: "मागील",
    next: "पुढील",
    repeat: "पुन्हा ऐका",
    stop: "आवाज थांबवा",
    auto_play: "सतत वाचन",
    ready_to_fill: "येथे भरा",
    verify_box: "तपासा",
    seek_help: "मदत घ्या",
    all_fields: "सर्व रकाने",
    no_fields_found: "फॉर्मचे रकाने सापडले नाहीत.",
    back_to_scan: "मागे जा",
    view_document: "फॉर्म पहा",
    done_title: "फॉर्म पूर्ण!",
    done_msg: "सर्व रकान्यांची माहिती ऐकून झाली आहे."
  },
  bn: {
    title: "ফর্ম ফিল্ড গাইড",
    subtitle: "ফর্ম পূরণের ভয়েস সহায়তা",
    field_step: "ঘর",
    of: "এর মধ্যে",
    prev: "পূর্ববর্তী",
    next: "পরবর্তী",
    repeat: "পুনরায় শুনুন",
    stop: "থামান",
    auto_play: "অটো-প্লে",
    ready_to_fill: "এখানে পূরণ করুন",
    verify_box: "যাচাই করুন",
    seek_help: "সাহায্য নিন",
    all_fields: "সকল ঘরের তালিকা",
    no_fields_found: "কোনো ফর্ম ফিল্ড চিহ্নিত করা যায়নি।",
    back_to_scan: "পিছনে যান",
    view_document: "ফর্ম দেখুন",
    done_title: "ফর্ম সমাপ্ত!",
    done_msg: "আপনি সকল তথ্য শুনে নিয়েছেন।"
  },
  gu: {
    title: "ફોર્મ માર્ગદર્શિકા",
    subtitle: "ફોર્મ ભરવા માટે ઓડિયો સહાય",
    field_step: "ખાનું",
    of: "માંથી",
    prev: "પાછળ",
    next: "આગળ",
    repeat: "ફરીથી સાંભળો",
    stop: "અવાજ બંધ",
    auto_play: "ઓટો-પ્લે",
    ready_to_fill: "અહીં ભરો",
    verify_box: "ચકાસો",
    seek_help: "મદદ લો",
    all_fields: "બધા ખાનાઓની યાદી",
    no_fields_found: "કોઈ ખાનું મળ્યું નથી.",
    back_to_scan: "પાછા જાઓ",
    view_document: "ફોર્મ જુઓ",
    done_title: "ફોર્મ પૂર્ણ!",
    done_msg: "તમે બધી વિગતો સાંભળી લીધી છે."
  },
  kn: {
    title: "ಫಾರ್ಮ್ ಫೀಲ್ಡ್ ಮಾರ್ಗದರ್ಶಿ",
    subtitle: "ಫಾರ್ಮ್ ತುಂಬಲು ಧ್ವನಿ ನೆರವು",
    field_step: "ವಿಭಾಗ",
    of: "ರಲ್ಲಿ",
    prev: "ಹಿಂದಿನ",
    next: "ಮುಂದಿನ",
    repeat: "ಮತ್ತೆ ಕೇಳಿ",
    stop: "ನಿಲ್ಲಿಸಿ",
    auto_play: "ಸ್ವಯಂಚಾಲಿತ",
    ready_to_fill: "ಇಲ್ಲಿ ಭರ್ತಿ ಮಾಡಿ",
    verify_box: "ಪರಿಶೀಲಿಸಿ",
    seek_help: "ಸಹಾಯ ಪಡೆಯಿರಿ",
    all_fields: "ಎಲ್ಲಾ ವಿಭಾಗಗಳು",
    no_fields_found: "ಯಾವುದೇ ಫೀಲ್ಡ್ ಕಂಡುಬಂದಿಲ್ಲ.",
    back_to_scan: "ಹಿಂದಕ್ಕೆ",
    view_document: "ದಾಖಲೆ ನೋಡಿ",
    done_title: "ಫಾರ್ಮ್ ಮುಗಿದಿದೆ!",
    done_msg: "ಎಲ್ಲಾ ವಿವರಗಳನ್ನು ಕೇಳಲಾಗಿದೆ."
  },
  ml: {
    title: "ഫോം ഫീൽഡ് ഗൈഡ്",
    subtitle: "ഫോം പൂരിപ്പിക്കാൻ ശബ്ദ സഹായം",
    field_step: "കോളം",
    of: "ൽ",
    prev: "മുമ്പത്തെ",
    next: "അടുത്തത്",
    repeat: "വീണ്ടും കേൾക്കുക",
    stop: "നിർത്തുക",
    auto_play: "തുടർച്ചയായി കേൾക്കുക",
    ready_to_fill: "ഇവിടെ പൂരിപ്പിക്കുക",
    verify_box: "പരിശോധിക്കുക",
    seek_help: "സഹായം തേടുക",
    all_fields: "എല്ലാ കോളങ്ങളും",
    no_fields_found: "ഫീൽഡുകൾ കണ്ടെത്താനായില്ല.",
    back_to_scan: "മടങ്ങുക",
    view_document: "രേഖ കാണുക",
    done_title: "പൂർത്തിയായി!",
    done_msg: "എല്ലാ വിവരങ്ങളും കേട്ടു കഴിഞ്ഞു."
  },
  or: {
    title: "ଫର୍ମ ଫିଲ୍ଡ ଗାଇଡ୍",
    subtitle: "ଫର୍ମ ପୂରଣ ପାଇଁ ଭଏସ୍ ସହାୟତା",
    field_step: "ଘର",
    of: "ରୁ",
    prev: "ପୂର୍ବ",
    next: "ପରବର୍ତ୍ତୀ",
    repeat: "ପୁଣି ଶୁଣନ୍ତୁ",
    stop: "ବନ୍ଦ କରନ୍ତୁ",
    auto_play: "ଅଟୋ ପ୍ଲେ",
    ready_to_fill: "ଏଠାରେ ପୂରଣ କରନ୍ତୁ",
    verify_box: "ଯାଞ୍ଚ କରନ୍ତୁ",
    seek_help: "ସହାୟତା ନିଅନ୍ତୁ",
    all_fields: "ସମସ୍ତ ତାଲିକା",
    no_fields_found: "କୌଣସି ଫିଲ୍ଡ ଚିହ୍ନଟ ହୋଇନାହିଁ ।",
    back_to_scan: "ପଛକୁ ଯାଆନ୍ତୁ",
    view_document: "ଦଲିଲ୍ ଦେଖନ୍ତୁ",
    done_title: "ସମାପ୍ତ!",
    done_msg: "ଆପଣ ସମସ୍ତ ତଥ୍ୟ ଶୁଣିସାରିଛନ୍ତି ।"
  },
  pa: {
    title: "ਫ਼ਾਰਮ ਫੀਲਡ ਗਾਈਡ",
    subtitle: "ਫ਼ਾਰਮ ਭਰਨ ਲਈ ਆਵਾਜ਼ ਸਹਾਇਤਾ",
    field_step: "ਖਾਨਾ",
    of: "ਵਿੱਚੋਂ",
    prev: "ਪਿਛਲਾ",
    next: "ਅਗਲਾ",
    repeat: "ਦੁਬਾਰਾ ਸੁਣੋ",
    stop: "ਆਵਾਜ਼ ਰੋਕੋ",
    auto_play: "ਲਗਾਤਾਰ ਸੁਣਨਾ",
    ready_to_fill: "ਇੱਥੇ ਭਰੋ",
    verify_box: "ਜਾਂਚ ਕਰੋ",
    seek_help: "ਮਦਦ ਲਵੋ",
    all_fields: "ਸਾਰੇ ਖਾਨੇ",
    no_fields_found: "ਕੋਈ ਫਾਰਮ ਖਾਨਾ ਨਹੀਂ ਮਿਲਿਆ।",
    back_to_scan: "ਵਾਪਸ ਜਾਓ",
    view_document: "ਦਸਤਾਵੇਜ਼ ਦੇਖੋ",
    done_title: "ਫ਼ਾਰਮ ਮੁਕੰਮਲ!",
    done_msg: "ਸਾਰੇ ਖਾਨਿਆਂ ਦੀ ਜਾਣਕਾਰੀ ਸੁਣ ਲਈ ਹੈ।"
  },
  as: {
    title: "ফৰ্ম ফিল্ড গাইড",
    subtitle: "ফৰ্ম পূৰণৰ মৌখিক সহায়",
    field_step: "বাকচ",
    of: "ৰ",
    prev: "পূৰ্বৱৰ্তী",
    next: "পৰৱৰ্তী",
    repeat: "পুনৰ শুনক",
    stop: "বন্ধ কৰক",
    auto_play: "অটো-প্লে",
    ready_to_fill: "ইয়াত পূৰণ কৰক",
    verify_box: "পৰীক্ষা কৰক",
    seek_help: "সহায় লওক",
    all_fields: "সকলো বাকচৰ তালিকা",
    no_fields_found: "কোনো ফৰ্ম ফিল্ড পোৱা নগ’ল।",
    back_to_scan: "উভতি যাওক",
    view_document: "নথি চাওক",
    done_title: "ফৰ্ম সম্পূৰ্ণ!",
    done_msg: "আপুনি সকলো ফিল্ডৰ তথ্য শুনিলে।"
  },
  ur: {
    title: "فارم فیلڈ گائیڈ",
    subtitle: "فارم بھرنے کے لیے صوتی رہنمائی",
    field_step: "خانہ",
    of: "از",
    prev: "پچھلا",
    next: "اگلا",
    repeat: "دوبارہ سنیں",
    stop: "آواز روکیں",
    auto_play: "آٹو پلے",
    ready_to_fill: "یہاں درج کریں",
    verify_box: "تصدیق کریں",
    seek_help: "مدد حاصل کریں",
    all_fields: "تمام خانوں کی فہرست",
    no_fields_found: "کوئی فارم فیلڈ نہیں ملی۔",
    back_to_scan: "واپس جائیں",
    view_document: "فارم دیکھیں",
    done_title: "فارم مکمل!",
    done_msg: "آپ تمام خانوں کی رہنمائی سن چکے ہیں۔"
  }
};

export default function FormFieldGuide({ 
  scanData, 
  selectedLang = 'hi', 
  onBack,
  initialOcrData = null 
}) {
  const [fields, setFields] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(false);
  const [autoAdvance, setAutoAdvance] = useState(false);
  const [showFieldList, setShowFieldList] = useState(false);
  const [imageSize, setImageSize] = useState({ width: 680, height: 900 });

  const activeFieldRef = useRef(null);
  const containerRef = useRef(null);

  const lang = selectedLang || 'hi';
  const ui = LOCALIZED_GUIDE_UI[lang] || LOCALIZED_GUIDE_UI.hi;

  // Process OCR data into ordered form fields with blank regions
  useEffect(() => {
    let ocrInput = initialOcrData;

    // If scanData already has OCR lines or text
    if (!ocrInput && scanData) {
      if (scanData.ocrData) {
        ocrInput = scanData.ocrData;
      } else if (scanData.lines) {
        ocrInput = { lines: scanData.lines, text: scanData.text || '' };
      } else if (scanData.text) {
        ocrInput = { lines: [], text: scanData.text };
      }
    }

    if (ocrInput) {
      // 1. Match and extract field labels
      const extracted = extractFormFieldsFromOCR(ocrInput, lang);

      // 2. Detect blank regions
      const withBlankRegions = detectBlankRegions(
        scanData?.imageElement || { width: imageSize.width, height: imageSize.height },
        extracted
      );

      // 3. Sort in natural reading order (top-to-bottom, left-to-right)
      const sorted = sortFieldsInReadingOrder(withBlankRegions);
      setFields(sorted);
      setCurrentIndex(0);
    }
  }, [scanData, initialOcrData, lang]);

  // Voice announcement whenever the current field changes
  useEffect(() => {
    if (fields.length > 0 && currentIndex >= 0 && currentIndex < fields.length) {
      speakCurrentField(currentIndex);
    }
    return () => {
      guider.stop();
    };
  }, [currentIndex, fields]);

  // Scroll active field into view on document canvas
  useEffect(() => {
    if (activeFieldRef.current && containerRef.current) {
      activeFieldRef.current.scrollIntoView({
        behavior: 'smooth',
        block: 'center',
        inline: 'center'
      });
    }
  }, [currentIndex]);

  const speakCurrentField = (index) => {
    if (!fields[index]) return;
    const field = fields[index];
    const fieldDef = FIELD_DEFINITIONS[field.fieldKey];

    const fieldNumStr = `${ui.field_step} ${field.readingOrder || index + 1}`;
    const fieldLabel = field.translatedLabel || fieldDef?.labels[lang] || field.label;
    
    // Construct spoken phrase
    let textToSpeak = `${fieldNumStr}: ${fieldLabel}। `;

    if (field.confidence === 'red' || field.blankPosition === 'unclear_box') {
      // Fallback for low confidence
      const unclearMsg = POSITION_PROMPTS.unclear_box[lang] || POSITION_PROMPTS.unclear_box.hi;
      textToSpeak += `${unclearMsg} `;
    } else {
      // Position prompt: below or right
      const posKey = field.blankPosition === 'right' ? 'right' : 'below';
      const posPhrase = POSITION_PROMPTS[posKey][lang] || POSITION_PROMPTS[posKey].hi;
      textToSpeak += `${posPhrase} `;

      // Help instruction on what to write
      const help = fieldDef?.spokenHelp[lang] || fieldDef?.spokenHelp.hi;
      if (help) {
        textToSpeak += `${help} `;
      }
    }

    setIsPlaying(true);
    guider.speak(textToSpeak, lang, {
      onEnd: () => {
        setIsPlaying(false);
        if (autoAdvance && index < fields.length - 1) {
          setTimeout(() => {
            setCurrentIndex(prev => prev + 1);
          }, 1200);
        }
      },
      onError: () => {
        setIsPlaying(false);
      }
    });
  };

  const handleNext = () => {
    guider.stop();
    setIsPlaying(false);
    if (currentIndex < fields.length - 1) {
      setCurrentIndex(prev => prev + 1);
    }
  };

  const handlePrev = () => {
    guider.stop();
    setIsPlaying(false);
    if (currentIndex > 0) {
      setCurrentIndex(prev => prev - 1);
    }
  };

  const handleRepeat = () => {
    if (isPlaying) {
      guider.stop();
      setIsPlaying(false);
    } else {
      speakCurrentField(currentIndex);
    }
  };

  const handleSelectField = (idx) => {
    guider.stop();
    setIsPlaying(false);
    setCurrentIndex(idx);
    setShowFieldList(false);
  };

  const currentField = fields[currentIndex];
  const currentDef = currentField ? FIELD_DEFINITIONS[currentField.fieldKey] : null;

  // Visual document renderer: SVG preview or image canvas
  const renderDocumentView = () => {
    // If a custom SVG generator is provided by sample preset
    if (scanData?.generateSvg) {
      return (
        <div 
          className="form-svg-wrapper"
          dangerouslySetInnerHTML={{ __html: scanData.generateSvg() }}
        />
      );
    }

    // If an image URL is available
    if (scanData?.previewUrl) {
      return (
        <img 
          src={scanData.previewUrl} 
          alt="Scanned Document" 
          className="scanned-doc-img"
          onLoad={(e) => {
            setImageSize({
              width: e.target.naturalWidth || 680,
              height: e.target.naturalHeight || 900
            });
          }}
        />
      );
    }

    // Default clean document canvas
    return (
      <div className="default-form-canvas" style={{ width: '100%', height: '700px' }}>
        <div className="canvas-header-decor">
          <div className="decor-line" />
          <p className="decor-title">OFFICIAL APPLICATION FORM</p>
          <div className="decor-line" />
        </div>
      </div>
    );
  };

  return (
    <div className="form-guide-container">
      {/* Top Header */}
      <div className="scanner-header">
        <button onClick={() => { guider.stop(); onBack(); }} className="btn-back">
          ← {ui.back_to_scan}
        </button>
        <div className="form-guide-mode-tag">
          <Sparkles size={14} />
          <span>{ui.title}</span>
        </div>
      </div>

      {/* Overview Progress Banner */}
      <div className="form-progress-bar-container">
        <div className="progress-info-row">
          <span className="step-counter">
            {ui.field_step} {fields.length > 0 ? currentIndex + 1 : 0} {ui.of} {fields.length}
          </span>
          <button 
            onClick={() => setShowFieldList(!showFieldList)}
            className="btn-list-toggle"
            title={ui.all_fields}
          >
            <ListFilter size={16} />
            <span>{ui.all_fields}</span>
          </button>
        </div>
        <div className="progress-track">
          <div 
            className="progress-fill" 
            style={{ width: `${fields.length ? ((currentIndex + 1) / fields.length) * 100 : 0}%` }}
          />
        </div>
      </div>

      {/* Field List Modal / Drawer */}
      {showFieldList && (
        <div className="field-list-modal">
          <div className="field-list-header">
            <h4>{ui.all_fields} ({fields.length})</h4>
            <button onClick={() => setShowFieldList(false)} className="btn-close-list">✕</button>
          </div>
          <div className="field-list-items">
            {fields.map((f, idx) => (
              <div
                key={f.id || idx}
                onClick={() => handleSelectField(idx)}
                className={`field-list-row tap-target ${idx === currentIndex ? 'active-row' : ''} status-${f.confidence}`}
              >
                <div className={`status-dot ${f.confidence}`} />
                <span className="field-row-order">{idx + 1}.</span>
                <span className="field-row-name">{f.translatedLabel || f.label}</span>
                <span className={`field-row-badge ${f.confidence}`}>
                  {f.confidence === 'green' ? '✓' : f.confidence === 'yellow' ? '⚠' : '✕'}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Interactive Document Viewport */}
      <div className="document-viewport-wrapper" ref={containerRef}>
        <div className="document-canvas-container" style={{ position: 'relative' }}>
          {renderDocumentView()}

          {/* Bounding Box Overlays */}
          {fields.map((field, idx) => {
            const isActive = idx === currentIndex;
            const bbox = field.bbox;
            const blank = field.blankRegion;
            const conf = field.confidence; // 'green', 'yellow', 'red'

            return (
              <React.Fragment key={field.id || idx}>
                {/* 1. Label Bounding Box */}
                {bbox && (
                  <div
                    ref={isActive ? activeFieldRef : null}
                    onClick={() => handleSelectField(idx)}
                    className={`label-bbox-overlay ${isActive ? 'active-label' : ''} conf-${conf}`}
                    style={{
                      position: 'absolute',
                      left: `${bbox.x0}px`,
                      top: `${bbox.y0}px`,
                      width: `${bbox.width}px`,
                      height: `${bbox.height}px`,
                      cursor: 'pointer'
                    }}
                  >
                    <span className="bbox-step-badge">{field.readingOrder || idx + 1}</span>
                  </div>
                )}

                {/* 2. Detected Blank Input Box Overlay */}
                {blank && conf !== 'red' && (
                  <div
                    onClick={() => handleSelectField(idx)}
                    className={`blank-region-overlay ${isActive ? 'active-blank pulse-glow' : ''} conf-${conf}`}
                    style={{
                      position: 'absolute',
                      left: `${blank.x}px`,
                      top: `${blank.y}px`,
                      width: `${blank.width}px`,
                      height: `${blank.height}px`,
                      cursor: 'pointer'
                    }}
                  >
                    {isActive && (
                      <span className="blank-here-tag">
                        {conf === 'green' ? ui.ready_to_fill : ui.verify_box}
                      </span>
                    )}
                  </div>
                )}

                {/* 3. Fallback Indicator for Red (Unclear / Missing Box) */}
                {isActive && conf === 'red' && bbox && (
                  <div
                    className="red-fallback-overlay"
                    style={{
                      position: 'absolute',
                      left: `${bbox.x0}px`,
                      top: `${bbox.y1 + 4}px`,
                      width: `${Math.max(bbox.width, 200)}px`
                    }}
                  >
                    <AlertCircle size={14} />
                    <span>{ui.seek_help}</span>
                  </div>
                )}
              </React.Fragment>
            );
          })}
        </div>
      </div>

      {/* Floating Active Step Guidance Card (Audio-First UI) */}
      {currentField && (
        <div className={`active-step-card status-card-${currentField.confidence}`}>
          {/* Card Top: Number & Confidence Badge */}
          <div className="step-card-header">
            <div className="step-badge-circle">
              {currentField.readingOrder || currentIndex + 1}
            </div>
            <div className="step-title-group">
              <h3 className="step-field-name">
                {currentField.translatedLabel || currentDef?.labels[lang] || currentField.label}
              </h3>
              <span className="step-canonical-name">({currentField.label})</span>
            </div>
            
            <div className={`step-confidence-pill ${currentField.confidence}`}>
              {currentField.confidence === 'green' ? (
                <>
                  <CheckCircle2 size={14} />
                  <span>{ui.ready_to_fill}</span>
                </>
              ) : currentField.confidence === 'yellow' ? (
                <>
                  <AlertCircle size={14} />
                  <span>{ui.verify_box}</span>
                </>
              ) : (
                <>
                  <HelpCircle size={14} />
                  <span>{ui.seek_help}</span>
                </>
              )}
            </div>
          </div>

          {/* Position & Action Instruction */}
          <div className="step-guidance-text">
            <p className="position-note">
              📍 {currentField.confidence === 'red' 
                ? (POSITION_PROMPTS.unclear_box[lang] || POSITION_PROMPTS.unclear_box.hi)
                : (currentField.blankPosition === 'right' 
                    ? (POSITION_PROMPTS.right[lang] || POSITION_PROMPTS.right.hi)
                    : (POSITION_PROMPTS.below[lang] || POSITION_PROMPTS.below.hi))}
            </p>
            {currentDef?.spokenHelp && currentField.confidence !== 'red' && (
              <p className="instruction-note">
                💡 {currentDef.spokenHelp[lang] || currentDef.spokenHelp.hi}
              </p>
            )}
          </div>

          {/* Audio & Navigation Controls Bar */}
          <div className="walkthrough-controls-row">
            <button
              onClick={handlePrev}
              disabled={currentIndex === 0}
              className="btn-nav-prev tap-target"
              title={ui.prev}
            >
              <ChevronLeft size={22} />
              <span>{ui.prev}</span>
            </button>

            <button
              onClick={handleRepeat}
              className={`btn-nav-audio tap-target ${isPlaying ? 'is-speaking' : ''}`}
            >
              {isPlaying ? (
                <>
                  <Square size={20} fill="white" />
                  <span>{ui.stop}</span>
                </>
              ) : (
                <>
                  <Volume2 size={20} />
                  <span>{ui.repeat}</span>
                </>
              )}
            </button>

            <button
              onClick={handleNext}
              disabled={currentIndex === fields.length - 1}
              className="btn-nav-next tap-target"
              title={ui.next}
            >
              <span>{ui.next}</span>
              <ChevronRight size={22} />
            </button>
          </div>
        </div>
      )}

      {fields.length === 0 && (
        <div className="empty-fields-alert">
          <AlertCircle size={28} style={{ color: 'var(--color-yellow)' }} />
          <p>{ui.no_fields_found}</p>
        </div>
      )}
    </div>
  );
}
