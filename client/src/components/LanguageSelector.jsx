import React from 'react';
import { LANGUAGES, guider } from '../utils/voiceGuider';
import { Volume2 } from 'lucide-react';

export default function LanguageSelector({ onLanguageSelected }) {
  const successPrompts = {
    hi: "हिन्दी चुनी गई है। आपका स्वागत है।",
    ta: "தமிழ் தேர்ந்தெடுக்கப்பட்டது. நல்வரவு.",
    te: "తెలుగు ఎంపిక చేయబడింది. సుస్వాగతం.",
    mr: "मराठी निवडली गेली आहे. आपले स्वागत आहे.",
    bn: "বাংলা নির্বাচন করা হয়েছে। আপনাকে স্বাগত।",
    gu: "ગુજરાતી પસંદ કરવામાં આવી છે. આપનું स्वागत છે.",
    kn: "ಕನ್ನಡ ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ. ಸುಸ್ವಾಗತ.",
    ml: "മലയാളം തിരഞ്ഞെടുത്തു. സ്വാഗതം.",
    or: "ଓଡ଼ିଆ ମନୋନୀତ ହୋଇଛି । ସ୍ୱାଗତ ।",
    pa: "ਪੰਜਾਬੀ ਚੁਣੀ ਗਈ ਹੈ। ਜੀ ਆਇਆਂ ਨੂੰ।",
    as: "অসমীয়া বাছনি কৰা হৈছে। আদৰণি জনাইছোঁ।",
    ur: "اردو منتخب کی گئی ہے۔ خوش آمدید۔"
  };

  const handleSelect = (lang) => {
    const text = successPrompts[lang.code] || `${lang.label} selected.`;
    guider.speak(text, lang.code, {
      onEnd: () => {
        onLanguageSelected(lang.code);
      }
    });
  };

  const speakName = (lang, e) => {
    e.stopPropagation();
    guider.speak(lang.name, lang.code);
  };

  return (
    <div style={{ width: '100%' }}>
      <div className="lang-header">
        <h2>भाषा चुनें / Choose Language</h2>
        <p>भाषा सुनने के लिए स्पीकर बटन दबाएं। चुनने के लिए बड़े बक्से पर दबाएं।</p>
      </div>

      <div className="lang-grid">
        {LANGUAGES.map((lang) => (
          <div
            key={lang.code}
            onClick={() => handleSelect(lang)}
            className="lang-card tap-target"
          >
            <div className="lang-card-badge">{lang.label}</div>

            <button
              onClick={(e) => speakName(lang, e)}
              className="lang-card-speaker"
              title="Listen pronunciation"
            >
              <Volume2 size={16} />
            </button>

            <span className="lang-card-title native-script">
              {lang.name}
            </span>
            <span className="lang-card-flag">
              {lang.flag} {lang.label}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
