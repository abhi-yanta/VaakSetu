export const LANGUAGES = [
  { code: 'hi', name: 'हिन्दी', label: 'Hindi', flag: '🇮🇳' },
  { code: 'ta', name: 'தமிழ்', label: 'Tamil', flag: '🇮🇳' },
  { code: 'te', name: 'తెలుగు', label: 'Telugu', flag: '🇮🇳' },
  { code: 'mr', name: 'मराठी', label: 'Marathi', flag: '🇮🇳' },
  { code: 'bn', name: 'বাংলা', label: 'Bengali', flag: '🇮🇳' },
  { code: 'gu', name: 'ગુજરાતી', label: 'Gujarati', flag: '🇮🇳' },
  { code: 'kn', name: 'ಕನ್ನಡ', label: 'Kannada', flag: '🇮🇳' },
  { code: 'ml', name: 'മലയാളം', label: 'Malayalam', flag: '🇮🇳' },
  { code: 'or', name: 'ଓଡ଼ିଆ', label: 'Odia', flag: '🇮🇳' },
  { code: 'pa', name: 'ਪੰਜਾਬੀ', label: 'Punjabi', flag: '🇮🇳' },
  { code: 'as', name: 'অসমীয়া', label: 'Assamese', flag: '🇮🇳' },
  { code: 'ur', name: 'اردو', label: 'Urdu', flag: '🇮🇳' }
];

export const VOICE_PROMPTS = {
  hi: {
    welcome: "वाक् सेतु में आपका स्वागत है। दस्तावेज़ पढ़ने और धोखाधड़ी से बचने के लिए, नीचे दी गई भाषा चुनें।",
    scan_prompt: "अब अपने फोन के कैमरे को कागज़ के सामने लाएं और नीचे दिए गए बड़े हरे बटन को दबाकर फोटो खींचें।",
    processing: "दस्तावेज़ को पढ़ा जा रहा है, कृपया थोड़ी देर प्रतीक्षा करें।",
    result_ready: "दस्तावेज़ पढ़ लिया गया है। जानकारी सुनने के लिए पीले बटन को दबाएं। खतरे की चेतावनी सुनने के लिए लाल बटन दबाएं।"
  },
  ta: {
    welcome: "வாக் சேதுவிற்கு உங்களை வரவேற்கிறோம். ஆவணங்களைப் படிக்கவும் மோசடிகளைத் தவிர்க்கவும், கீழே உள்ள மொழியைத் தேர்ந்தெடுக்கவும்.",
    scan_prompt: "இப்போது உங்கள் தொலைபேசி கேமராவை காகிதத்திற்கு முன்னால் கொண்டு வந்து, கீழே உள்ள பெரிய பச்சை பொத்தானை அழுத்தி புகைப்படம் எடுக்கவும்.",
    processing: "ஆவணம் வாசிக்கப்படுகிறது, தயவுசெய்து சிறிது நேரம் காத்திருக்கவும்.",
    result_ready: "ஆவணம் வாசிக்கப்பட்டது. தகவலைக் கேட்க மஞ்சள் பொத்தானையும், எச்சரிக்கையைக் கேட்க சிவப்பு பொத்தானையும் அழுத்தவும்."
  },
  te: {
    welcome: "వాక్ సేతుకి స్వాగతం. పత్రాలు చదవడానికి మరియు మోసాలను నివారించడానికి, క్రింది భాషను ఎంచుకోండి.",
    scan_prompt: "ఇప్పుడు మీ ఫోన్ కెమెరాను కాగితం ముందుకు తీసుకువచ్చి, క్రింద ఉన్న పెద్ద ఆకుపచ్చ బటన్‌ను నొక్కి ఫోటో తీయండి.",
    processing: "పత్రం చదవబడుతోంది, దయచేసి కాసేపు వేచి ఉండండి.",
    result_ready: "పత్రం చదవడం పూర్తయింది. సమాచారం వినడానికి పసుపు బటన్‌ను, హెచ్చరికలు వినడానికి ఎరుపు బటన్‌ను నొక్కండి."
  },
  mr: {
    welcome: "वाक् सेतूमध्ये आपले स्वागत आहे. दस्तऐवज वाचण्यासाठी आणि फसवणूक टाळण्यासाठी, खालील भाषा निवडा.",
    scan_prompt: "आता तुमचा फोन कॅमेरा कागदासमोर आणा आणि खाली दिलेले मोठे हिरवे बटण दाबून फोटो काढा.",
    processing: "दस्तऐवज वाचला जात आहे, कृपया थोडा वेळ थांबा.",
    result_ready: "दस्तऐवज वाचून झाला आहे. माहिती ऐकण्यासाठी पिवळे बटण दाबा. धोक्याची चेतावणी ऐकण्यासाठी लाल बटण दाबा."
  },
  bn: {
    welcome: "বাক সেতুতে আপনাকে স্বাগত। দলিল পড়তে এবং জালিয়াতি এড়াতে, নিচের ভাষাটি নির্বাচন করুন।",
    scan_prompt: "এখন আপনার ফোন ক্যামেরাটি কাগজের সামনে আনুন এবং নিচের বড় সবুজ বোতামটি টিপে ছবি তুলুন।",
    processing: "দলিলটি পড়া হচ্ছে, দয়া করে কিছুক্ষণ অপেক্ষা করুন।",
    result_ready: "দলিল পড়া শেষ হয়েছে। তথ্য শোনার জন্য হলুদ বোতাম এবং বিপদ সংকেত শোনার জন্য লাল বোতাম টিপুন।"
  },
  gu: {
    welcome: "વાક્ સેતુમાં આપનું સ્વાગત છે. દસ્તાવેજો વાંચવા અને છેતરપિંડીથી બચવા માટે, નીચે આપેલ ભાષા પસંદ કરો.",
    scan_prompt: "હવે તમારા ફોનના કેમેરાને કાગળની સામે લાવો અને નીચે આપેલ મોટું લીલું બટન દબાવીને ફોટો પાડો.",
    processing: "દસ્તાવેજ વંચાઈ રહ્યો છે, કૃપા કરીને થોડીવાર રાહ જુઓ.",
    result_ready: "દસ્તાવેજ વંચાઈ ગયો છે. માહિતી સાંભળવા માટે પીળું બટન દબાવો. જોખમની ચેતવણી માટે લાલ બટન દબાવો."
  },
  kn: {
    welcome: "ವಾಕ್ ಸೇತುಗೆ ಸ್ವಾಗತ. ಪತ್ರಗಳನ್ನು ಓದಲು ಮತ್ತು ವಂಚನೆ ತಡೆಯಲು, ಕೆಳಗಿನ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಿ.",
    scan_prompt: "ಈಗ ನಿಮ್ಮ ಫೋನ್ ಕ್ಯಾಮೆರಾವನ್ನು ಕಾಗದದ ಮುಂದೆ ತந்து, ಕೆಳಗಿನ ದೊಡ್ಡ ಹಸಿರು ಬಟನ್ ಒತ್ತಿ ಫೋಟೋ ತೆಗೆಯಿರಿ.",
    processing: "ಪತ್ರವನ್ನು ಓದಲಾಗುತ್ತಿದೆ, ದಯವಿಟ್ಟು ಸ್ವಲ್ಪ ಸಮಯ ಕಾಯಿರಿ.",
    result_ready: "ಪತ್ರ ಓದುವುದು ಮುಗಿದಿದೆ. ಮಾಹಿತಿ ಕೇಳಲು ಹಳದಿ ಬಟನ್, ಎಚ್ಚರಿಕೆ ಕೇಳಲು ಕೆಂಪು ಬಟನ್ ಒತ್ತಿ."
  },
  ml: {
    welcome: "வாക് സേതുവിലേക്ക് സ്വാഗതം. രേഖകൾ വായിക്കുന്നതിനും തട്ടിപ്പുകൾ ഒഴിവാക്കുന്നതിനും താഴെയുള്ള ഭാഷ തിരഞ്ഞെടുക്കുക.",
    scan_prompt: "ഇപ്പോൾ നിങ്ങളുടെ ഫോൺ ക്യാമറ പേപ്പറിന് മുന്നിൽ കൊണ്ടുവന്ന് താഴെയുള്ള വലിയ പച്ച ബട്ടൺ അമർത്തി ഫോട്ടോ എടുക്കുക.",
    processing: "രേഖ വായിച്ചുകൊണ്ടിരിക്കുകയാണ്, ദയവായി കുറച്ചു സമയം കാത്തിരിക്കൂ.",
    result_ready: "രേഖ വായിച്ചു കഴിഞ്ഞു. വിവരങ്ങൾ കേൾക്കാൻ മഞ്ഞ ബട്ടണും, മുന്നറിയിപ്പുകൾ കേൾക്കാൻ ചുവപ്പ് ബട്ടണും അമർത്തുക."
  },
  or: {
    welcome: "ବାକ୍ ସେତୁକୁ ଆପଣଙ୍କୁ ସ୍ୱାଗତ । ଦଲିଲ୍ ପଢିବା ଏବଂ ଜାଲିଆତିରୁ ବଞ୍ଚିବା ପାଇଁ, ତଳେ ଥିବା ଭାଷା ବାଛନ୍ତୁ ।",
    scan_prompt: "ଏବେ ଆପଣଙ୍କ ଫୋନ୍ କ୍ୟାମེରାକୁ କାଗଜ ସାମ୍ନାକୁ ଆଣନ୍ତୁ ଏବଂ ତଳେ ଥିବା ବଡ ସବୁଜ ବଟନ୍ ଦବାଇ ଫଟୋ ଉଠାନ୍ତୁ ।",
    processing: "ଦଲିଲ୍ ପଢାଯାଉଛି, ଦୟାକରି କିଛି ସମୟ ଅପେକ୍ଷା କରନ୍ତୁ ।",
    result_ready: "ଦଲିଲ୍ ପଢା ସରିଛି । ସୂଚନା ଶୁଣିବା ପାଇଁ ହଳଦିଆ ବଟନ୍ ଏବଂ ବିପଦ ଚେତାବନୀ ଶୁଣିବା ପାଇଁ ନାଲି ବଟନ୍ ଦବାନ୍ତୁ ।"
  },
  pa: {
    welcome: "ਵਾਕ ਸੇਤੂ ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ। ਦਸਤਾਵੇਜ਼ ਪੜ੍ਹਨ ਅਤੇ ਧੋਖਾਧੜੀ ਤੋਂ ਬਚਣ ਲਈ, ਹੇਠਾਂ ਦਿੱਤੀ ਭਾਸ਼ਾ ਚੁਣੋ।",
    scan_prompt: "ਹੁਣ ਆਪਣੇ ਫ਼ੋਨ ਦੇ ਕੈਮਰੇ ਨੂੰ ਕਾਗਜ਼ ਦੇ ਸਾਹਮਣੇ ਲਿਆਓ ਅਤੇ ਹੇਠਾਂ ਦਿੱਤੇ ਵੱਡੇ ਹਰੇ ਬਟਨ ਨੂੰ ਦਬਾ ਕੇ ਫੋਟੋ ਖਿੱਚੋ।",
    processing: "ਦਸਤਾਵੇਜ਼ ਪੜ੍ਹਿਆ ਜਾ ਰਿਹਾ ਹੈ, ਕਿਰਪਾ ਕਰਕੇ ਥੋੜ੍ਹੀ ਦੇਰ ਉਡੀਕ ਕਰੋ।",
    result_ready: "ਦਸਤਾਵੇਜ਼ ਪੜ੍ਹ ਲਿਆ ਗਿਆ ਹੈ। ਜਾਣਕਾਰੀ ਸੁਣਨ ਲਈ ਪੀਲਾ ਬਟਨ ਦਬਾਓ। ਖਤਰੇ ਦੀ ਚੇਤਾਵਨੀ ਸੁਣਨ ਲਈ ਲਾਲ ਬਟਨ ਦਬਾਓ।"
  },
  as: {
    welcome: "বাক সেতু লৈ আপোনাক স্বাগতম। নথি পঢ়িবলৈ আৰু জালিয়াতিৰ পৰা বাচিবলৈ, তলৰ ভাষা বাছনি কৰক।",
    scan_prompt: "এতিয়া আপোনাৰ ফোনৰ কেমেৰাটো কাগজখনৰ সন্মুখলৈ আনক আৰু তলৰ ডাঙৰ সেউজীয়া বুটামটো টিপি ফটো তোলক।",
    processing: "নথিখন পঢ়ি থকা হৈছে, অনুগ্ৰহ কৰি অলপ সময় অপেক্ষা কৰক।",
    result_ready: "নথি পঢ়া সম্পূৰ্ণ হৈছে। তথ্য শুনিবলৈ হালধীয়া বুটাম আৰু বিপদৰ জাননী শুনিবলৈ ৰঙা বুটাম টিপক।"
  },
  ur: {
    welcome: "واک سیتو میں خوش آمدید۔ دستاویز پڑھنے اور دھوکہ دہی سے بچنے کے لیے، نیچے دی گئی زبان منتخب کریں۔",
    scan_prompt: "اب اپنے فون کے کیمرے کو کاغذ کے سامنے لائیں اور نیچے دیے گئے بڑے ہرے بٹن کو دبا کر تصویر کھینچیں۔",
    processing: "دستاویز پڑھی جا رہی ہے، براہِ کرم تھوڑی دیر انتظار کریں۔",
    result_ready: "دستاویز پڑھ لی گئی ہے۔ معلومات سننے کے لیے پیلا بٹن اور خطرے کی وارننگ سننے کے لیے سرخ بٹن دبائیں۔"
  }
};

class VoiceGuider {
  constructor() {
    this.synth = window.speechSynthesis;
    this.currentUtterance = null;
    this.voices = [];
    
    if (this.synth) {
      this.loadVoices();
      if (this.synth.onvoiceschanged !== undefined) {
        this.synth.onvoiceschanged = () => this.loadVoices();
      }
    }
  }

  loadVoices() {
    this.voices = this.synth.getVoices();
  }

  findVoiceForLanguage(langCode) {
    const langMap = {
      hi: ['hi-IN', 'hi'],
      ta: ['ta-IN', 'ta'],
      te: ['te-IN', 'te'],
      mr: ['mr-IN', 'mr'],
      bn: ['bn-IN', 'bn-BD', 'bn'],
      gu: ['gu-IN', 'gu'],
      kn: ['kn-IN', 'kn'],
      ml: ['ml-IN', 'ml'],
      or: ['or-IN', 'or'],
      pa: ['pa-IN', 'pa'],
      as: ['as-IN', 'as'],
      ur: ['ur-PK', 'ur-IN', 'ur']
    };

    const targetLocales = langMap[langCode] || ['hi-IN'];
    
    for (const locale of targetLocales) {
      const match = this.voices.find(v => v.lang.toLowerCase() === locale.toLowerCase() || v.lang.toLowerCase().startsWith(locale.toLowerCase()));
      if (match) return match;
    }
    
    const fallback = this.voices.find(v => v.lang.toLowerCase().includes(langCode));
    if (fallback) return fallback;

    return null;
  }

  speak(text, langCode, callbacks = {}) {
    if (!this.synth) {
      console.warn("Speech synthesis not supported on this browser.");
      if (callbacks.onError) callbacks.onError(new Error("Not supported"));
      return;
    }

    this.stop();

    const utterance = new SpeechSynthesisUtterance(text);
    this.currentUtterance = utterance;

    const voice = this.findVoiceForLanguage(langCode);
    if (voice) {
      utterance.voice = voice;
    } else {
      utterance.lang = langCode === 'hi' ? 'hi-IN' : langCode;
    }

    utterance.rate = 0.85;
    utterance.pitch = 1.0;

    if (callbacks.onStart) utterance.onstart = callbacks.onStart;
    if (callbacks.onEnd) utterance.onend = callbacks.onEnd;
    if (callbacks.onError) utterance.onerror = callbacks.onError;

    this.synth.speak(utterance);
  }

  stop() {
    if (this.synth) {
      this.synth.cancel();
    }
  }

  speakPrompt(promptKey, langCode, callbacks = {}) {
    const translation = VOICE_PROMPTS[langCode] || VOICE_PROMPTS.hi;
    const text = translation[promptKey] || "";
    if (text) {
      this.speak(text, langCode, callbacks);
    }
  }
}

export const guider = new VoiceGuider();
