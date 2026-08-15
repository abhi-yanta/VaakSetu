import React, { useState, useEffect } from 'react';
import { createWorker } from 'tesseract.js';
import { analyzeDocumentText, SEVERITIES } from '../utils/ruleEngine';
import { guider } from '../utils/voiceGuider';
import WaveVisualizer from './WaveVisualizer';
import { AlertTriangle, ShieldCheck, HelpCircle, Volume2, Play, Square, Loader } from 'lucide-react';

export default function DocumentAnalyzer({ scanData, selectedLang, onReset }) {
  const [loading, setLoading] = useState(true);
  const [progress, setProgress] = useState("");
  const [analysis, setAnalysis] = useState(null);
  const [speakingSection, setSpeakingSection] = useState(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [showRawText, setShowRawText] = useState(false);

  const LOCALIZED_UI = {
    hi: {
      loading_ocr: "दस्तावेज़ को पढ़ा जा रहा है...",
      loading_rules: "सुरक्षा जांच की जा रही है...",
      category: "दस्तावेज़ प्रकार",
      summary: "दस्तावेज़ का सार (संक्षेप)",
      red_flags: "खतरे की चेतावनी (रेड फ्लैग)",
      safe_doc: "यह दस्तावेज़ सुरक्षित है",
      warning_doc: "सावधान! पहले पूरी बात समझें",
      danger_doc: "खतरा! इस दस्तावेज़ पर हस्ताक्षर न करें",
      listen_all: "पूरी जानकारी सुनें",
      stop: "आवाज बंद करें",
      view_raw: "मूल दस्तावेज़ का पाठ (टैक्स्ट)",
      deed: "ज़मीन के कागज़ात (भूमि डीड)",
      loan: "ऋण दस्तावेज़ (लोन पेपर)",
      job: "काम का अनुबंध (जाब कांट्रैक्ट)",
      medical: "अस्पताल का पर्चा (मेडिकल फॉर्म)"
    },
    ta: {
      loading_ocr: "ஆவணம் வாசிக்கப்படுகிறது...",
      loading_rules: "பாதுகாப்பு சோதனை செய்யப்படுகிறது...",
      category: "ஆவண வகை",
      summary: "ஆவணச் சுருக்கம்",
      red_flags: "ஆபத்து எச்சரிக்கைகள்",
      safe_doc: "இந்த ஆவணம் பாதுகாப்பானது",
      warning_doc: "கவனம்! முதலில் புரிந்து கொள்ளுங்கள்",
      danger_doc: "ஆபத்து! கையெழுத்திட வேண்டாம்",
      listen_all: "முழு விபரங்களையும் கேளுங்கள்",
      stop: "ஒலியை நிறுத்து",
      view_raw: "அசல் ஆவண உரை",
      deed: "நிலப் பத்திரம் (பத்திர ஆவணம்)",
      loan: "கடன் ஆவணம் (லோன் பேப்பர்)",
      job: "வேலை ஒப்பந்தம் (வேலைக்கான பத்திரம்)",
      medical: "மருத்துவமனை படிவம் (மெடிக்கல் ஃபார்ம்)"
    },
    te: {
      loading_ocr: "పత్రం చదవబడుతోంది...",
      loading_rules: "భద్రతా తనిఖీ జరుగుతోంది...",
      category: "పత్రం రకం",
      summary: "పత్రం సారాంశం",
      red_flags: "ప్రమాద హెచ్చరికలు",
      safe_doc: "ఈ పత్రం సురక్షితం",
      warning_doc: "జాగ్రత్త! ముందుగా అర్థం చేసుకోండి",
      danger_doc: "ప్రమాదం! సంతకం చేయవద్దు",
      listen_all: "పూర్తి సమాచారం వినండి",
      stop: "ఆపు",
      view_raw: "అసలు పత్రం యొక్క వచనం",
      deed: "భూమి పత్రాలు (లాండ్ డీడ్)",
      loan: "రుణ పత్రాలు (లోన్ పేపర్స్)",
      job: "ఉద్యోగ ఒప్పందం (జాబ్ కాంట్రాక్ట్)",
      medical: "ఆసుపత్రి పత్రాలు (మెడికల్ ఫారమ్)"
    },
    mr: {
      loading_ocr: "दस्तऐवज वाचला जात आहे...",
      loading_rules: "सुरक्षा तपासणी सुरू आहे...",
      category: "दस्तऐवज प्रकार",
      summary: "दस्तऐवजाचा गोषवारा",
      red_flags: "धोक्याच्या सूचना",
      safe_doc: "हा दस्तऐवज सुरक्षित आहे",
      warning_doc: "सावधान! आधी समजून घ्या",
      danger_doc: "धोका! सही करू नका",
      listen_all: "सर्व माहिती ऐका",
      stop: "आवाज बंद करा",
      view_raw: "मूळ दस्तऐवजाचा मजकूर",
      deed: "जमिनीचे कागदपत्र (लँड डीड)",
      loan: "कर्ज दस्तऐवज (लोन पेपर)",
      job: "नोकरीचा करार (जॉब कॉन्ट्रॅक्ट)",
      medical: "दवाखान्याचा फॉर्म (मेडिकल फॉर्म)"
    },
    bn: {
      loading_ocr: "দলিল পড়া হচ্ছে...",
      loading_rules: "নিরাপত্তা পরীক্ষা করা হচ্ছে...",
      category: "দলিলের প্রকার",
      summary: "দলিলের সারসংক্ষেপ",
      red_flags: "ঝুঁকি বা বিপদের শর্তাবলী",
      safe_doc: "এই দলিলটি নিরাপদ",
      warning_doc: "সাবধান! আগে বুঝুন",
      danger_doc: "বিপদ! স্বাক্ষর করবেন না",
      listen_all: "সম্পূর্ণ তথ্য শুনুন",
      stop: "থামুন",
      view_raw: "মূল দলিলের লেখা",
      deed: "জমির দলিল (ল্যান্ড ডিড)",
      loan: "ঋণের দলিল (লোন পেপার)",
      job: "কাজের চুক্তিপত্র (চাকরির চুক্তি)",
      medical: "হাসপাতালের ফর্ম (মেডিকেল ফর্ম)"
    },
    gu: {
      loading_ocr: "દસ્તાવેજ વંચાઈ રહ્યો છે...",
      loading_rules: "સુરક્ષા તપાસ થઈ રહી છે...",
      category: "દસ્તાવેજનો પ્રકાર",
      summary: "દસ્તાવેજનો સારાંશ",
      red_flags: "જોખમની ચેતવણીઓ",
      safe_doc: "આ દસ્તાવેજ સુરક્ષિત છે",
      warning_doc: "સાવધાન! પહેલા સમજો",
      danger_doc: "ખતરો! સહી કરશો નહીં",
      listen_all: "બધી માહિતી સાંભળો",
      stop: "અવાજ બંધ કરો",
      view_raw: "મૂળ દસ્તાવેજ લખાણ",
      deed: "જમીનના દસ્તાવેજ (લેન્ડ ડીડ)",
      loan: "લોનના કાગળો (લોન પેપર)",
      job: "નોકરીનો કરાર (જોબ કોન્ટ્રાક્ટ)",
      medical: "હોસ્પિટલનું ફોર્મ (મેડિકલ ફોર્મ)"
    },
    kn: {
      loading_ocr: "ಪತ್ರವನ್ನು ಓದಲಾಗುತ್ತಿದೆ...",
      loading_rules: "ಭದ್ರತಾ ಪರಿಶೀಲನೆ ನಡೆಯುತ್ತಿದೆ...",
      category: "ಪತ್ರದ ವಿಧ",
      summary: "ಪತ್ರದ ಸಾರಾಂಶ",
      red_flags: "ಅಪಾಯದ ಎಚ್ಚರಿಕೆಗಳು",
      safe_doc: "ಈ ಪತ್ರವು ಸುರಕ್ಷಿತವಾಗಿದೆ",
      warning_doc: "ಎಚ್ಚರ! ಮೊದಲು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಿ",
      danger_doc: "ಅಪಾಯ! ಸಹಿ ಮಾಡಬೇಡಿ",
      listen_all: "ಸಂಪೂರ್ಣ ಮಾಹಿತಿ ಕೇಳಿ",
      stop: "ನಿಲ್ಲಿಸು",
      view_raw: "ಮೂಲ ಪತ್ರದ ಬರಹ",
      deed: "ಭೂಮಿ ದಸ್ತಾವೇಜು (ಲ್ಯಾಂಡ್ ಡೀಡ್)",
      loan: "ಸಾಲದ ಪತ್ರಗಳು (ಲೋನ್ ಪೇಪರ್)",
      job: "ಕೆಲಸದ ಒಪ್ಪಂದ (ಜಾಬ್ ಕಾಂಟ್ರಾಕ್ಟ್)",
      medical: "ಆಸ್ಪತ್ರೆ ಫಾರ್ಮ್ (ಮೆಡಿಕಲ್ ಫಾರ್ಮ್)"
    },
    ml: {
      loading_ocr: "രേഖ വായിച്ചുകൊണ്ടിരിക്കുന്നു...",
      loading_rules: "സുരക്ഷാ പരിശോധന പുരോഗമിക്കുന്നു...",
      category: "രേഖയുടെ തരം",
      summary: "രേഖയുടെ ചുരുക്കം",
      red_flags: "അപകട മുന്നറിയിപ്പുകൾ",
      safe_doc: "ഈ രേഖ സുരക്ഷിതമാണ്",
      warning_doc: "ശ്രദ്ധിക്കുക! ആദ്യം മനസ്സിലാക്കൂ",
      danger_doc: "അപകടം! ഒപ്പിടരുത്",
      listen_all: "മുഴുവൻ വിവരങ്ങളും കേൾക്കുക",
      stop: "നിർത്തുക",
      view_raw: "യഥാർത്ഥ രേഖയിലെ വരികൾ",
      deed: "ആധാരം (ലാൻഡ് ഡീഡ്)",
      loan: "വായ്പാ രേഖ (ലോൺ പേപ്പർ)",
      job: "തൊഴിൽ കരാർ (ജോബ് കോൺട്രാക്ട്)",
      medical: "ആശുപത്രി ഫോം (മെഡിക്ൽ ഫോം)"
    },
    or: {
      loading_ocr: "ଦଲିଲ୍ ପଢାଯାଉଛି...",
      loading_rules: "ସୁରକ୍ଷା ଯାଞ୍ଚ ଚାଲିଛି...",
      category: "ଦଲିଲ୍ ର ପ୍ରକାର",
      summary: "ଦଲିଲ୍ ର ସାରାଂଶ",
      red_flags: "ବିପଦ ଚେତାବନୀ",
      safe_doc: "ଏହି ଦଲିଲ୍ ସୁରକ୍ଷିତ ଅଟେ",
      warning_doc: "ସାବଧାନ! ପ୍ରଥମେ ବୁଝନ୍ତು",
      danger_doc: "ବିପଦ! ଦସ୍ତଖତ କରନ୍ତು ନାହିଁ",
      listen_all: "ସମ୍ପୂର୍ଣ୍ଣ ସୂଚନା ଶୁଣନ୍ତୁ",
      stop: "ବନ୍ଦ କରନ୍ତು",
      view_raw: "ମୂଳ ଦଲିଲ୍ ର ଲେଖା",
      deed: "ଜମି ପଟ୍ଟା (ଲ୍ୟାଣ୍ଡ୍ ଡିଡ୍)",
      loan: "ଋଣ ଦଲିଲ୍ (ଲୋନ୍ ପେପର)",
      job: "କାର୍ଯ୍ୟ ଚୁକ୍ତିପਤ୍ର (ଚାକିରି ଚุକ୍ତି)",
      medical: "ଡାକ୍තରଖାନା ଫର୍ମ (ମେଡିକାଲ୍ ଫର୍ମ)"
    },
    pa: {
      loading_ocr: "ਦਸਤਾਵੇਜ਼ ਪੜ੍ਹਿਆ ਜਾ ਰਿਹਾ ਹੈ...",
      loading_rules: "ਸੁਰੱਖਿਆ ਜਾਂਚ ਚੱਲ ਰਹੀ ਹੈ...",
      category: "ਦਸਤਾਵੇਜ਼ ਦੀ ਕਿਸਮ",
      summary: "ਦਸਤਾਵੇਜ਼ ਦਾ ਸਾਰ",
      red_flags: "ਖਤਰੇ ਦੀਆਂ ਚੇਤਾਵਨੀਆਂ",
      safe_doc: "ਇਹ ਦਸਤਾਵੇਜ਼ ਸੁਰੱਖਿਅਤ ਹੈ",
      warning_doc: "ਸਾਵਧਾਨ! ਪਹਿਲਾਂ ਸਮਝੋ",
      danger_doc: "ਖਤਰਾ! ਦਸਤਖਤ ਨਾ ਕਰੋ",
      listen_all: "ਸਾਰੀ ਜਾਣਕਾਰੀ ਸੁਣੋ",
      stop: "ਆਵਾਜ਼ ਬੰਦ ਕਰੋ",
      view_raw: "ਮੂਲ ਦਸਤਾਵੇਜ਼ ਦਾ ਪਾਠ",
      deed: "ਜ਼ਮੀਨ ਦੀ ਰਜਿਸਟਰੀ (ਲੈਂਡ ਡੀਡ)",
      loan: "ਕਰਜ਼ਾ ਦਸਤਾਵੇਜ਼ (ਲੋਨ ਪੇਪਰ)",
      job: "ਨੌਕਰੀ ਦਾ ਇਕਰਾਰਨਾਮਾ (ਜੌਬ ਕੰਟਰੈਕਟ)",
      medical: "ਹਸਪਤਾਲ ਦਾ ਫਾਰਮ (ਮੈਡੀਕਲ ਫਾਰਮ)"
    },
    as: {
      loading_ocr: "নথি পঢ়া হৈ আছে...",
      loading_rules: "সুৰক্ষা পৰীক্ষা চলি আছে...",
      category: "নথিৰ প্ৰকাৰ",
      summary: "নথিখনৰ সাৰাংশ",
      red_flags: "বিপদৰ জাননী",
      safe_doc: "নথিখন সুৰক্ষিত হৈছে",
      warning_doc: "সাৱধান! প্ৰথমে বুজি লওক",
      danger_doc: "বিপদ! চহী নকৰিব",
      listen_all: "সম্পূৰ্ণ তথ্য শুনক",
      stop: "বন্ধ কৰক",
      view_raw: "মূল নথিৰ পাঠ",
      deed: "মাটিৰ দলিল (লেণ্ড ডীড)",
      loan: "ঋণৰ নথি-পত্ৰ (লোন পেপাৰ)",
      job: "চাকৰিৰ চুক্তিপত্ৰ (জব কন্ট্ৰেক্ট)",
      medical: "চিকিৎসালয়ৰ ফৰ্ম (মেডিকেল ফৰ্ম)"
    },
    ur: {
      loading_ocr: "دستاویز پڑھی جا رہی ہے...",
      loading_rules: "سیکیورٹی چیک کی جا رہی ہے...",
      category: "دستاویز کی قسم",
      summary: "خلاصہ",
      red_flags: "خطرناک شرائط",
      safe_doc: "یہ دستاویز محفوظ ہے",
      warning_doc: "خبردار! پہلے سمجھیں",
      danger_doc: "خطرہ! دستخط نہ کریں",
      listen_all: "مکمل تفصیلات سنیں",
      stop: "آواز روکیں",
      view_raw: "اصل دستاویز کا متن",
      deed: "زمین کے کاغذات (لینڈ ڈیڈ)",
      loan: "قرض کا معاہدہ (لون پیپر)",
      job: "ملازمت کا معاہدہ (جاب کانٹریکٹ)",
      medical: "ہسپتال کا فارم (میڈیکل فارم)"
    }
  };

  const uiText = LOCALIZED_UI[selectedLang] || LOCALIZED_UI.hi;

  const warningsTranslation = {
    hi: {
      alert_high_interest: "चेतावनी: ब्याज दर बहुत ज़्यादा है! यह सालाना चौबीस प्रतिशत से अधिक है। ब्याज चक्रवृद्धि हो सकता है, जिससे आपका कर्ज़ बहुत बढ़ जाएगा।",
      alert_collateral: "चेतावनी: इस कागज़ के अनुसार आपकी कृषि भूमि या मकान को गिरवी रखा जा रहा है। यदि आप समय पर पैसा नहीं चुका पाए, तो वे आपकी संपत्ति को जब्त कर लेंगे।",
      alert_hidden_fee: "सावधान: फाइलिंग या प्रोसेसिंग के नाम पर छुपे हुए पैसे लिए जा रहे हैं। आपको पूरा पैसा नहीं मिलेगा।",
      alert_unpaid_labor: "चेतावनी: बिना अतिरिक्त पैसे दिए आपसे ज़्यादा समय तक काम कराने की शर्त लिखी है। यह गैर-कानूनी है।",
      alert_no_exit: "चेतावनी: आप इस नौकरी को आसानी से छोड़ नहीं सकते। यदि आप समय से पहले छोड़ते हैं, तो आपको भारी जुर्माना देना पड़ेगा।",
      alert_medical_liability: "सावधान: अस्पताल किसी भी गलती या लापरवाही की जिम्मेदारी लेने से बच रहा है। वे कह रहे हैं कि कोई भी संकट आने पर आपकी खुद की जिम्मेदारी होगी।"
    },
    ta: {
      alert_high_interest: "எச்சரிக்கை: வட்டி விகிதம் மிக அதிகமாக உள்ளது! இது ஆண்டிற்கு இருபத்தி நான்கு சதவீதத்திற்கும் மேல். இதனால் உங்கள் கடன் சுமை பன்மடங்கு அதிகரிக்கும்.",
      alert_collateral: "எச்சரிக்கை: உங்கள் நிலம் அல்லது வீடு அடமானம் வைக்கப்படுகிறது. கடனைத் திருப்பிச் செலுத்தத் தவறினால் உங்கள் சொத்து பறிபோகும் அபாயம் உள்ளது.",
      alert_hidden_fee: "கவனம்: மறைமுகக் கட்டணங்கள் வசூலிக்கப்படுகின்றன. உங்களுக்கு முழுத் தொகையும் கிடைக்காது.",
      alert_unpaid_labor: "எச்சரிக்கை: கூடுதல் ஊதியம் இன்றி அதிக நேரம் வேலை வாங்க இந்த ஒப்பந்தம் வழிவகுக்கிறது.",
      alert_no_exit: "எச்சரிக்கை: இந்த வேலையிலிருந்து நீங்கள் எளிதாக விலக முடியாது. முன்கூட்டியே விலகினால் அதிக அபராதம் செலுத்த வேண்டும்.",
      alert_medical_liability: "கவனம்: மருத்துவமனையில் ஏதேனும் தவறு நடந்தால் நிர்வாகம் பொறுப்பேற்காது என்று குறிப்பிடப்பட்டுள்ளது."
    },
    te: {
      alert_high_interest: "హెచ్చరిక: వడ్డీ రేటు చాలా ఎక్కువగా ఉంది! ఇది సంవత్సరానికి ఇరవై నాలుగు శాతం కంటే ఎక్కువ. దీనివల్ల మీ అప్పు బాగా పెరిగిపోతుంది.",
      alert_collateral: "హెచ్చరిక: మీ భూమి లేదా ఇల్లు కుదవ పెట్టబడుతోంది. మీరు సకాలంలో డబ్బు చెల్లించకపోతే, వారు మీ ఆస్తిని స్వాధీనం చేసుకుంటారు.",
      alert_hidden_fee: "జాగ్రత్త: గుప్త రుసుములు వసూలు చేస్తున్నారు. మీకు పూర్తి రుణం అందకపోవచ్చు.",
      alert_unpaid_labor: "హెచ్చరిక: అదనపు జీతం లేకుండా ఎక్కువ గంటలు పనిచేయించుకునే నిబంధన ఉంది.",
      alert_no_exit: "హెచ్చరిక: ఈ ఉద్యోగాన్ని మీరు సులభంగా వదలలేరు. ముందే వదిలేస్తే పెద్ద మొత్తంలో జరిమానా కట్టాల్సి వస్తుంది.",
      alert_medical_liability: "జాగ్రత్త: ఆసుపత్రి ఎటువంటి తప్పులకూ బాధ్యత వహించదని రాసి ఉంది."
    },
    mr: {
      alert_high_interest: "धोका: व्याजदर खूप जास्त आहे! हा २४ टक्क्यांपेक्षा जास्त आहे. यामुळे तुमचे कर्ज खूप वाढू शकते.",
      alert_collateral: "धोका: तुमची जमीन किंवा घर गहाण ठेवले जात आहे. कर्ज न फेडल्यास मालमत्ता जप्त होण्याचा धोका आहे.",
      alert_hidden_fee: "सावधान: छुपे शुल्क आकारले जात आहे. आपल्याला संपूर्ण रक्कम मिळणार नाही.",
      alert_unpaid_labor: "धोका: अतिरिक्त पैशांशिवाय जास्त काम करून घेण्याची अट आहे.",
      alert_no_exit: "धोका: नोकरी लवकर सोडल्यास मोठा दंड आकारला जाईल अशी अट आहे.",
      alert_medical_liability: "सावधान: उपचारादरम्यान काही चूक झाल्यास रुग्णालय कोणतीही जबाबदारी घेणार नाही."
    },
    bn: {
      alert_high_interest: "সতর্কতা: সুদের হার অত্যন্ত বেশি! এটি বছরে ২৪ শতাংশের বেশি। এর ফলে ঋণের বোঝা দ্বিগুণ হতে পারে।",
      alert_collateral: "সতর্কতা: আপনার জমি বা ঘর বন্ধক রাখা হচ্ছে। ঋণ শোধ করতে না পারলে আপনার সম্পত্তি কেড়ে নেওয়া হতে পারে।",
      alert_hidden_fee: "সাবধান: লুকানো প্রসেসিং ফি বা চার্জ কাটা হচ্ছে। আপনি পুরো টাকা হাতে পাবেন না।",
      alert_unpaid_labor: "সতর্কতা: অতিরিক্ত পারিশ্রমিক ছাড়া বেশি কাজ করানোর অবৈধ শর্ত রয়েছে।",
      alert_no_exit: "সতর্কতা: আপনি চাইলেই চাকরি ছাড়তে পারবেন না। মাঝপথে ছাড়লে বড় জরিমানা হবে।",
      alert_medical_liability: "সাবধান: চিকিৎসার কোনো ভুলের জন্য হাসপাতাল কোনো দায়ভার নেবে না।"
    },
    gu: {
      alert_high_interest: "ચેતવણી: વ્યાજ દર ઘણો વધારે છે! આ વાર્ષિક ૨૪% થી વધુ છે. જેના કારણે તમારા પર દેવું વધી જશે.",
      alert_collateral: "ચેતવણી: તમારી જમીન કે મકાન ગીરો મુકાઈ રહ્યું છે. જો તમે પૈસા પાછા નહીં આપો તો મિલકત જપ્ત થઈ જશે.",
      alert_hidden_fee: "સાવધાન: છુપો ચાર્જ લેવામાં આવી રહ્યો છે. તમને લોનની પૂરી રકમ નહીં મળે.",
      alert_unpaid_labor: "ચેતવણી: વધારાના પૈસા આપ્યા વગર વધારે કામ કરાવવાની ખોટી શરત છે.",
      alert_no_exit: "ચેતવણી: તમે નોકરી વહેલી છોડી શકશો નહીં, છોડશો તો મોટો દંડ ભરવો પડશે.",
      alert_medical_liability: "સાવધાન: કોઈ પણ ભૂલ કે બેદરકારી માટે હોસ્પિટલ જવાબદારી સ્વીકારવાનો ઇનકાર કરે છે."
    },
    kn: {
      alert_high_interest: "ಎಚ್ಚರಿಕೆ: ಬಡ್ಡಿ ದರ ತುಂಬಾ ಹೆಚ್ಚಾಗಿದೆ! ಇದು ವರ್ಷಕ್ಕೆ ಶೇಕಡಾ 24 ಕ್ಕಿಂತ ಹೆಚ್ಚು. ಇದರಿಂದ ನಿಮ್ಮ ಸಾಲದ ಹೊರೆ ಹೆಚ್ಚಾಗುತ್ತದೆ.",
      alert_collateral: "ಎಚ್ಚರಿಕೆ: ನಿಮ್ಮ ಜಮೀನು ಅಥವಾ ಮನೆಯನ್ನು ಅಡಮಾನ ಇಡಲಾಗುತ್ತಿದೆ. ಸಾಲ ತೀರಿಸದಿದ್ದರೆ ಆಸ್ತಿ ಜಪ್ತಿಯಾಗುವ ಅಪಾಯವಿದೆ.",
      alert_hidden_fee: "ಎಚ್ಚರ: ಹಿಡನ್ ಚಾರ್ಜ್ ಕಡಿತಗೊಳಿಸಲಾಗುತ್ತಿದೆ. ನಿಮಗೆ ಪೂರ್ಣ ಹಣ ಸಿಗುವುದಿಲ್ಲ.",
      alert_unpaid_labor: "ಎಚ್ಚರಿಕೆ: ಹೆಚ್ಚುವರಿ ವೇತನವಿಲ್ಲದೆ ಹೆಚ್ಚು ಸಮಯ ಕೆಲಸ ಮಾಡಲು ಒಪ್ಪಂದ ಹೇಳುತ್ತದೆ.",
      alert_no_exit: "ಎಚ್ಚರಿಕೆ: ನೀವು ಕೆಲಸವನ್ನು ಬೇಗನೆ ಬಿಡುವಂತಿಲ್ಲ. ಬಿಟ್ಟರೆ ಭಾರಿ ದಂಡ ತೆರಬೇಕಾಗುತ್ತದೆ.",
      alert_medical_liability: "ಎಚ್ಚರ: ಚಿಕಿತ್ಸೆಯ ಯಾವುದೇ ತಪ್ಪುಗಳಿಗೆ ಆಸ್ಪತ್ರೆ ಹೊಣೆಗಾರಿಕೆ ವಹಿಸುವುದಿಲ್ಲ."
    },
    ml: {
      alert_high_interest: "മുന്നറിയിപ്പ്: പലിശ നിരക്ക് വളരെ കൂടുതലാണ്! ഇത് വർഷത്തിൽ 24 ശതമാനത്തിൽ കൂടുതലാണ്. കടക്കെണിയിലാകാൻ ഇത് കാരണമാകും.",
      alert_collateral: "മുന്നറിയിപ്പ്: നിങ്ങളുടെ ഭൂമിയോ വീടോ ഈടായി എഴുതി വാങ്ങുന്നു. പണം തിരിച്ചടച്ചില്ലെങ്കിൽ സ്വത്ത് നഷ്ടപ്പെടും.",
      alert_hidden_fee: "ശ്രദ്ധിക്കുക: പ്രോസസിങ് ഫീസ് എന്ന വ്യാജേന കമ്മീഷൻ തട്ടിയെടുക്കുന്നു.",
      alert_unpaid_labor: "മുന്നറിയിപ്പ്: അധിക വേതനം നൽകാതെ കൂടുതൽ സമയം പണിയെടുപ്പിക്കാൻ കരാർ വ്യവസ്ഥ ചെയ്യുന്നു.",
      alert_no_exit: "മുന്നറിയിപ്പ്: ജോലി പെട്ടെന്ന് ഉപേക്ഷിക്കാൻ കഴിയില്ല. ഉപേക്ഷിച്ചാൽ വലിയ പിഴ നൽകേണ്ടിവരും.",
      alert_medical_liability: "ശ്രദ്ധിക്കുക: ചികിത്സയിൽ ഉണ്ടാകുന്ന വീഴ്ചകൾക്ക് ആശുപത്രി ഉത്തരവാദിയല്ല എന്ന് വ്യക്തമാക്കുന്നു."
    },
    or: {
      alert_high_interest: "ଚେତାବନୀ: ସୁଧ ହାର ବହୁତ ଅଧିକ ଅଛି! ଏହା ବାର୍ଷିକ ୨୪ ପ୍ରତିଶତରୁ ଅଧିକ ଅଟେ ।",
      alert_collateral: "ଚେତାବନୀ: ଆପଣଙ୍କ ଜମି କିମ୍ବା ଘର ବନ୍ଧକ ରଖାଯାଉଛି । ଋଣ ନ ସୁଝିଲେ ଆପଣଙ୍କ ସମ୍ପତ୍ତି ଜବତ ହେବାର ଭୟ ଅଛି ।",
      alert_hidden_fee: "ସାବଧାନ: ଲୁଚାଛପା ପ୍ରୋସେସିଙ୍ଗ୍ ଫିସ୍ କଟାଯାଉଛି । ଆପଣଙ୍କୁ ପୂରା ଟଙ୍କା ମିଳିବ ନାହିଁ ।",
      alert_unpaid_labor: "ଚେତାବନୀ: ଅଧିକ ସମୟ କାମ ପାଇଁ କୌଣସି ଅତିରିକ୍ତ ମଜୁରୀ ନ ମିଳିବାର ସର୍ତ୍ତ ଅଛି ।",
      alert_no_exit: "ଚେତାବନୀ: ଆପଣ ଚାਕିରି ଶୀଘ୍ର ଛାଡିପାରିବେ ନାହିଁ । ଛାଡିଲେ ଜରିମାନା ଦେବାକୁ ପଡିବ ।",
      alert_medical_liability: "ସାବଧାନ: ଡାକ୍ତରଖାନା କୌଣସି ଭୁଲ୍ ପାଇଁ ଦାୟିତ୍ୱ ନେବ ନାହିଁ ବୋଲି ଲେଖାଅଛି ।"
    },
    pa: {
      alert_high_interest: "ਚੇਤਾਵਨੀ: ਵਿਆਜ ਦਰ ਬਹੁਤ ਜ਼ਿਆਦਾ ਹੈ! ਇਹ ਸਾਲਾਨਾ 24 ਪ੍ਰਤੀਸ਼ਤ ਤੋਂ ਵੱਧ ਹੈ, ਜਿਸ ਨਾਲ ਤੁਹਾਡਾ ਕਰਜ਼ਾ ਬਹੁਤ ਵਧ ਜਾਵੇਗਾ।",
      alert_collateral: "ਚੇਤਾਵਨੀ: ਤੁਹਾਡੀ ਜ਼ਮੀਨ ਜਾਂ ਘਰ ਗਿਰਵੀ ਰੱਖਿਆ ਜਾ ਰਹੀ ਹੈ। ਜੇ ਤੁਸੀਂ ਪੈਸੇ ਨਾ ਮੁੜ ਸਕੇ ਤਾਂ ਉਹ ਜਾਇਦਾਦ ਜ਼ਬਤ ਕਰ ਲੈਣਗੇ।",
      alert_hidden_fee: "ਸਾਵਧਾਨ: ਪ੍ਰੋਸੈਸਿੰਗ ਫੀਸ ਦੇ ਨਾਂ ਤੇ ਪੈਸੇ ਕੱਟੇ ਜਾ ਰਹੇ ਹਨ। ਤੁਹਾਨੂੰ ਪੂਰੇ ਪੈਸੇ ਨਹੀਂ ਮਿਲਣਗੇ।",
      alert_unpaid_labor: "ਚੇਤਾਵਨੀ: ਬਿਨਾਂ ਵਾਧੂ ਪੈਸੇ ਦਿੱਤੇ ਤੁਹਾਡੇ ਤੋਂ ਵੱਧ ਸਮਾਂ ਕੰਮ ਕਰਵਾਉਣ ਦੀ ਸ਼ਰਤ ਲਿਖੀ ਹੈ।",
      alert_no_exit: "ਚੇਤਾਵਨੀ: ਤੁਸੀਂ ਨੌਕਰੀ ਜਲਦੀ ਨਹੀਂ ਛੱਡ ਸਕਦੇ, ਛੱਡਣ 'ਤੇ ਭਾਰੀ ਜੁਰਮਾਨਾ ਦੇਣਾ ਪਵੇਗਾ।",
      alert_medical_liability: "ਸਾਵਧਾਨ: ਹਸਪਤਾਲ ਕਿਸੇ ਵੀ ਗਲਤੀ ਦੀ ਜ਼ਿੰਮੇਵารੀ ਨਹੀਂ ਲਵੇਗਾ।"
    },
    as: {
      alert_high_interest: "সাৱধান: সূতৰ হাৰ বহুত বেছি! এয়া বছৰি ২৪ শতাংশতকৈ বেছি। ইয়াৰ ফলত আপোনাৰ ঋণ বহুত বাঢ়ি যাব।",
      alert_collateral: "সাৱধান: আপোনাৰ মাটি বা ঘৰ বন্ধকত ৰখা হৈছে। ঋণ পৰিশোধ নকৰিলে সম্পত্তি বাজেয়াপ্ত কৰাৰ আশংকা আছে।",
      alert_hidden_fee: "সাৱধান: প্ৰক্ৰিয়াকৰণ মাচুলৰ নামত অতিৰিক্ত পইচা কটা হৈছে। আপুনি সম্পূৰ্ণ ঋণ লাভ নকৰে।",
      alert_unpaid_labor: "সাৱধান: অতিৰিক্ত মজুৰি নিদিয়াকৈ অধিক সময় কাম কৰাৰ ভুল নিয়মে চুক্তিখনত ঠাই পাইছে।",
      alert_no_exit: "সাৱধান: আপুনি চাকৰি সহজে এৰিব নোৱাৰে। চুক্তি ভংগ কৰিলে বৃহৎ জৰিমনা ভৰিব লাগিব।",
      alert_medical_liability: "সাৱধান: চিকিৎসালয়ে কোনো চিকিৎসাজনিত ভুলৰ বাবে নিজে দায়ী নহয় বুলি উল্লেখ কৰিছে।"
    },
    ur: {
      alert_high_interest: "وارننگ: سود کی شرح بہت زیادہ ہے! یہ سالانہ 24 فیصد سے زیادہ ہے۔ اس سے آپ کا قرض بہت بڑھ جائے گا۔",
      alert_collateral: "وارننگ: آپ کی زمین یا مکان گروی رکھا جا رہا ہے۔ پیسے نہ چکانے کی صورت میں وہ آپ کی جائیداد ضبط کر لیں گے۔",
      alert_hidden_fee: "خبردار: فائلنگ کے نام پر پوشیدہ چارجز لیے جا رہے ہیں، آپ کو پورا پیسہ نہیں ملے گا۔",
      alert_unpaid_labor: "وارننگ: بغیر اضافی پیسے دیے زیادہ کام کرنے کی غیر قانونی شرط لکھی گئی ہے۔",
      alert_no_exit: "وارننگ: آپ ملازمت جلد نہیں چھوڑ سکتے، ایسا کرنے پر بھاری جرمانہ دینا ہوگا۔",
      alert_medical_liability: "خبردار: ہسپتال علاج میں کسی بھی قسم کی غلطی کے لیے ذمہ داری لینے سے انکار کر رہا ہے۔"
    }
  };

  const currentLangWarnings = warningsTranslation[selectedLang] || warningsTranslation.hi;

  useEffect(() => {
    runOCRAndAnalysis();
    return () => {
      guider.stop();
    };
  }, [scanData]);

  const runOCRAndAnalysis = async () => {
    if (scanData.type === 'text') {
      setLoading(true);
      setProgress(uiText.loading_rules);
      
      setTimeout(() => {
        const results = analyzeDocumentText(scanData.text);
        setAnalysis({
          rawText: scanData.text,
          ...results
        });
        setLoading(false);
        triggerInitialAnnouncement(results);
      }, 800);
    } else {
      setLoading(true);
      setProgress(uiText.loading_ocr);

      try {
        let processedSuccessfully = false;
        try {
          const formData = new FormData();
          formData.append('document', scanData.file);
          formData.append('lang', selectedLang);

          const res = await fetch('http://localhost:5000/api/analyze', {
            method: 'POST',
            body: formData
          });

          if (res.ok) {
            const data = await res.json();
            setAnalysis({
              rawText: data.rawText,
              category: data.category,
              severity: data.severity,
              warnings: data.warnings.map(w => w.key)
            });
            processedSuccessfully = true;
            setLoading(false);
            triggerInitialAnnouncement(data);
          }
        } catch (e) {
          console.log("Kiosk server offline or failed. Running client-side Tesseract.js WebAssembly OCR...");
        }

        if (!processedSuccessfully) {
          const worker = await createWorker('eng+hin');
          setProgress("Initializing offline parser...");
          
          const ret = await worker.recognize(scanData.file);
          const text = ret.data.text;
          await worker.terminate();

          setProgress(uiText.loading_rules);
          const results = analyzeDocumentText(text);
          setAnalysis({
            rawText: text,
            ...results
          });
          setLoading(false);
          triggerInitialAnnouncement(results);
        }
      } catch (err) {
        console.error("OCR Failure:", err);
        setProgress("OCR Error occurred. Please try scanning again or load a demo document.");
      }
    }
  };

  const triggerInitialAnnouncement = (results) => {
    let textToSpeak = "";
    const categoryName = uiText[results.category] || results.category;
    
    if (results.severity === SEVERITIES.SAFE) {
      textToSpeak = `यह ${categoryName} दस्तावेज़ है। ${uiText.safe_doc}। आप इस पर हस्ताक्षर कर सकते हैं।`;
    } else if (results.severity === SEVERITIES.WARNING) {
      textToSpeak = `यह ${categoryName} दस्तावेज़ है। ${uiText.warning_doc}। ध्यान देने योग्य बातें नीचे पीली पट्टी में हैं।`;
    } else {
      textToSpeak = `यह ${categoryName} दस्तावेज़ है। ${uiText.danger_doc}। इसमें खतरे की लाल चेतावनी है। कृपया हस्ताक्षर न करें।`;
    }

    setIsPlaying(true);
    setSpeakingSection('summary');
    guider.speak(textToSpeak, selectedLang, {
      onEnd: () => {
        setIsPlaying(false);
        setSpeakingSection(null);
        guider.speakPrompt('result_ready', selectedLang);
      },
      onError: () => {
        setIsPlaying(false);
        setSpeakingSection(null);
      }
    });
  };

  const speakCompleteAnalysis = () => {
    if (!analysis) return;
    
    setIsPlaying(true);
    setSpeakingSection('all');
    
    const categoryName = uiText[analysis.category] || analysis.category;
    let textToSpeak = `यह ${categoryName} दस्तावेज़ है। `;
    
    if (analysis.severity === SEVERITIES.SAFE) {
      textToSpeak += `${uiText.safe_doc}। `;
    } else if (analysis.severity === SEVERITIES.WARNING) {
      textToSpeak += `${uiText.warning_doc}। `;
    } else {
      textToSpeak += `${uiText.danger_doc}। `;
    }

    if (analysis.warnings.length > 0) {
      textToSpeak += "खतरे की चेतावनियाँ इस प्रकार हैं: ";
      analysis.warnings.forEach((key, index) => {
        const warningDesc = currentLangWarnings[key] || key;
        textToSpeak += `नंबर ${index + 1}: ${warningDesc} `;
      });
    }

    guider.speak(textToSpeak, selectedLang, {
      onEnd: () => {
        setIsPlaying(false);
        setSpeakingSection(null);
      },
      onError: () => {
        setIsPlaying(false);
        setSpeakingSection(null);
      }
    });
  };

  const speakIndividualWarning = (key, index) => {
    const warningDesc = currentLangWarnings[key] || key;
    setIsPlaying(true);
    setSpeakingSection(`warning-${index}`);

    guider.speak(warningDesc, selectedLang, {
      onEnd: () => {
        setIsPlaying(false);
        setSpeakingSection(null);
      },
      onError: () => {
        setIsPlaying(false);
        setSpeakingSection(null);
      }
    });
  };

  const stopSpeaking = () => {
    guider.stop();
    setIsPlaying(false);
    setSpeakingSection(null);
  };

  if (loading) {
    return (
      <div className="loader-container">
        <div className="loader-spinner-box">
          <div className="loader-spinner" />
          <Loader className="loader-icon" size={24} />
        </div>
        <div className="loader-text">
          <h3>{progress}</h3>
          <p>कृपया फोन को हिलाएं नहीं</p>
        </div>
      </div>
    );
  }

  return (
    <div className="analyzer-container">
      
      <div className="scanner-header">
        <button
          onClick={() => { stopSpeaking(); onReset(); }}
          className="btn-back"
        >
          ← Scan Again
        </button>
        <span className="badge-mode">Analysis Result</span>
      </div>

      <div className={`security-indicator-card ${analysis.severity}`}>
        {analysis.severity === SEVERITIES.SAFE ? (
          <ShieldCheck size={40} style={{ color: 'var(--color-green)' }} />
        ) : (
          <AlertTriangle size={40} style={{ color: analysis.severity === SEVERITIES.DANGER ? 'var(--color-danger)' : 'var(--color-yellow)' }} />
        )}
        <div className="indicator-details">
          <span className="indicator-category">{uiText.category}: {uiText[analysis.category] || analysis.category}</span>
          <h2 className="indicator-title">
            {analysis.severity === SEVERITIES.SAFE ? uiText.safe_doc : analysis.severity === SEVERITIES.DANGER ? uiText.danger_doc : uiText.warning_doc}
          </h2>
        </div>
      </div>

      <WaveVisualizer isPlaying={isPlaying} />

      <div className="audio-controls-row">
        <button
          onClick={isPlaying ? stopSpeaking : speakCompleteAnalysis}
          className={`btn-audio-primary tap-target ${isPlaying ? 'playing' : ''}`}
        >
          {isPlaying ? (
            <>
              <Square size={16} fill="white" />
              {uiText.stop}
            </>
          ) : (
            <>
              <Play size={16} fill="white" />
              {uiText.listen_all}
            </>
          )}
        </button>

        <button
          onClick={() => guider.speakPrompt('welcome', selectedLang)}
          className="btn-audio-secondary tap-target"
        >
          <HelpCircle size={16} />
          Help / निर्देश
        </button>
      </div>

      {analysis.warnings.length > 0 && (
        <div style={{ marginTop: '16px' }}>
          <h3 className="warnings-header">
            <AlertTriangle size={18} />
            {uiText.red_flags} ({analysis.warnings.length})
          </h3>
          
          <div className="warnings-list">
            {analysis.warnings.map((key, idx) => (
              <div
                key={key}
                onClick={() => speakIndividualWarning(key, idx)}
                className={`warning-item-card tap-target ${speakingSection === `warning-${idx}` ? 'speaking' : ''}`}
              >
                <p className="warning-item-text">
                  {idx + 1}. {currentLangWarnings[key] || key}
                </p>
                <button className="warning-item-audio-btn">
                  <Volume2 size={14} />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="developer-inspector">
        <button
          onClick={() => setShowRawText(!showRawText)}
          className="developer-toggle"
        >
          <span>{uiText.view_raw}</span>
          <span>{showRawText ? '▲ Hide' : '▼ View'}</span>
        </button>
        {showRawText && (
          <div className="developer-text-box">
            {analysis.rawText || "No text parsed."}
          </div>
        )}
      </div>

    </div>
  );
}
