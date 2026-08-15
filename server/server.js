const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Tesseract = require('tesseract.js');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

const upload = multer({
  dest: 'uploads/',
  limits: { fileSize: 10 * 1024 * 1024 }
});

if (!fs.existsSync('uploads')) {
  fs.mkdirSync('uploads');
}

const TRANSLATIONS = {
  hi: {
    title_loan: "ऋण दस्तावेज़ (लोन पेपर)",
    title_deed: "ज़मीन के कागज़ात (भूमि डीड)",
    title_job: "काम का अनुबंध (नौकरी का ठेका)",
    title_medical: "अस्पताल का पर्चा (मेडिकल फॉर्म)",
    alert_high_interest: "चेतावनी: ब्याज दर बहुत ज़्यादा है! (24% से अधिक)",
    alert_collateral: "चेतावनी: आपकी ज़मीन या संपत्ति गिरवी रखी जा रही है!",
    alert_hidden_fee: "सावधान: फाइलिंग या प्रोसेसिंग के नाम पर छिपे हुए पैसे मांगे जा रहे हैं!",
    alert_unpaid_labor: "चेतावनी: बिना अतिरिक्त पैसे दिए ज़्यादा काम कराने की शर्त है!",
    alert_no_exit: "चेतावनी: आप इस नौकरी को आसानी से छोड़ नहीं सकते, जुर्माना लिखा है!",
    alert_medical_liability: "सावधान: अस्पताल किसी भी गलती की ज़िम्मेदारी नहीं ले रहा है!",
    summary_safe: "यह दस्तावेज़ सुरक्षित लग रहा है। आप आगे बढ़ सकते हैं।",
    summary_warning: "ध्यान दें! इस दस्तावेज़ में कुछ ऐसी बातें हैं जो आपको संकट में डाल सकती हैं। कृपया किसी भरोसेमंद व्यक्ति से दोबारा जाँच करवाएं।",
    category: "श्रेणी",
    status_danger: "खतरा! हस्ताक्षर न करें",
    status_warning: "सावधान! पहले समझें",
    status_safe: "सुरक्षित"
  },
  ta: {
    title_loan: "கடன் ஆவணம் (லோன் பேப்பர்)",
    title_deed: "நிலப் பத்திரம் (பத்திர ஆவணம்)",
    title_job: "வேலை ஒப்பந்தம் (வேலைக்கான பத்திரம்)",
    title_medical: "மருத்துவமனை படிவம் (மெடிக்கல் ஃபார்ம்)",
    alert_high_interest: "எச்சரிக்கை: வட்டி விகிதம் மிக அதிகமாக உள்ளது! (24% மேல்)",
    alert_collateral: "எச்சரிக்கை: உங்கள் நிலம் அல்லது சொத்து அடமானம் வைக்கப்படுகிறது!",
    alert_hidden_fee: "கவனம்: மறைமுக கட்டணங்கள் கேட்கப்படுகின்றன!",
    alert_unpaid_labor: "எச்சரிக்கை: கூடுதல் சம்பளம் இல்லாமல் அதிக நேரம் வேலை செய்ய சொல்கிறார்கள்!",
    alert_no_exit: "எச்சரிக்கை: இந்த வேலையிலிருந்து நீங்கள் எளிதாக விலக முடியாது, அபராதம் உள்ளது!",
    alert_medical_liability: "கவனம்: மருத்துவமனை எந்த தவறுக்கும் பொறுப்பேற்க மறுக்கிறது!",
    summary_safe: "இந்த ஆவணம் பாதுகாப்பானது போல தோன்றுக்கிறது. நீங்கள் தொடரலாம்.",
    summary_warning: "கவனம்! இந்த ஆவணத்தில் உங்களை ஆபத்தில் தள்ளக்கூடிய சில விஷயங்கள் உள்ளன. தயவுசெய்து தெரிந்தவர்களிடம் சரிபார்க்கவும்.",
    category: "வகை",
    status_danger: "ஆபத்து! கையெழுத்திட வேண்டாம்",
    status_warning: "கவனம்! முதலில் புரிந்து கொள்ளுங்கள்",
    status_safe: "பாதுகாப்பானது"
  },
  te: {
    title_loan: "రుణ పత్రాలు (లోన్ పేపర్స్)",
    title_deed: "భూమి పత్రాలు (లాండ్ డీడ్)",
    title_job: "ఉద్యోగ ఒప్పందం (జాబ్ కాంట్రాక్ట్)",
    title_medical: "ఆసుపత్రి పత్రాలు (మెడికల్ ఫారమ్)",
    alert_high_interest: "హెచ్చరిక: వడ్డీ రేటు చాలా ఎక్కువగా ఉంది! (24% కంటే ఎక్కువ)",
    alert_collateral: "హెచ్చరిక: మీ భూమి లేదా ఆస్తి కుదవ పెట్టబడుతోంది!",
    alert_hidden_fee: "జాగ్రత్త: రహస్య రుసుములు వసూలు చేస్తున్నారు!",
    alert_unpaid_labor: "హెచ్చరిక: అదనపు వేతనం లేకుండా ఎక్కువ గంటలు పనిచేయించుకునే నిబంధన ఉంది!",
    alert_no_exit: "హెచ్చరిక: మీరు ఈ ఉద్యోగాన్ని సులభంగా వదలలేరు, జరిమానా ఉంది!",
    alert_medical_liability: "జాగ్రత్త: ఆసుపత్రి ఎటువంటి తప్పులకూ బాధ్యత వహించడం లేదు!",
    summary_safe: "ఈ పత్రం సురక్షితంగానే కనిపిస్తోంది. మీరు ముందుకు వెళ్ళవచ్చు.",
    summary_warning: "జాగ్రత్త! ఈ పత్రంలో మిమ్మల్ని ఇబ్బందుల్లో నెట్టే కొన్ని అంశాలు ఉన్నాయి. నమ్మకస్తుల చేత ఒకసారి తనిఖీ చేయించండి.",
    category: "రకం",
    status_danger: "ప్రమాదం! సంతకం చేయవద్దు",
    status_warning: "జాగ్రత్త! ముందుగా అర్థం చేసుకోండి",
    status_safe: "సురక్షితం"
  },
  mr: {
    title_loan: "कर्ज दस्तऐवज (लोन पेपर)",
    title_deed: "जमिनीचे कागदपत्र (लँड डीड)",
    title_job: "नोकरीचा करार (जॉब कॉन्ट्रॅक्ट)",
    title_medical: "दवाखान्याचा फॉर्म (मेडिकल फॉर्म)",
    alert_high_interest: "धोका: व्याजदर खूप जास्त आहे! (२४% पेक्षा जास्त)",
    alert_collateral: "धोका: तुमची जमीन किंवा मालमत्ता गहाण ठेवली जात आहे!",
    alert_hidden_fee: "सावधान: छुपे शुल्क किंवा प्रक्रिया फी मागितली जात आहे!",
    alert_unpaid_labor: "धोका: विना मोबदला जादा कामाची अट आहे!",
    alert_no_exit: "धोका: नोकरी सोडल्यास मोठ्या दंडाची तरतूद आहे!",
    alert_medical_liability: "सावधान: रुग्णालय कोणत्याही चुकीची जबाबदारी घेत नाही आहे!",
    summary_safe: "हा दस्तऐवज सुरक्षित वाटत आहे. आपण पुढे जाऊ शकता.",
    summary_warning: "सावधान! या दस्तऐवजात काही गोष्टी अशा आहेत ज्यामुळे तुम्हाला त्रास होऊ शकतो. कृपया कोणा विश्वासू व्यक्तीकडून खात्री करून घ्या.",
    category: "वर्ग",
    status_danger: "धोका! सही करू नका",
    status_warning: "सावधान! आधी समजून घ्या",
    status_safe: "सुरक्षित"
  },
  bn: {
    title_loan: "ঋণের দলিল (লোন পেপার)",
    title_deed: "জমির দলিল (ল্যান্ড ডিড)",
    title_job: "কাজের চুক্তিপত্র (চাকরির চুক্তি)",
    title_medical: "হাসপাতালের ফর্ম (মেডিকেল ফর্ম)",
    alert_high_interest: "সতর্কতা: সুদের হার অনেক বেশি! (২৪% এর বেশি)",
    alert_collateral: "সতর্কতা: আপনার জমি বা সম্পত্তি বন্ধক রাখা হচ্ছে!",
    alert_hidden_fee: "সাবধান: অতিরিক্ত লুকানো চার্জ দাবি করা হচ্ছে!",
    alert_unpaid_labor: "সতর্কতা: অতিরিক্ত পারিশ্রমিক ছাড়া বেশি কাজ করার শর্ত রয়েছে!",
    alert_no_exit: "সতর্কতা: আপনি সহজেই চাকরি ছাড়তে পারবেন না, জরিমানার বিধান আছে!",
    alert_medical_liability: "সাবধান: হাসপাতাল কোনো ভুলের দায় নিতে অস্বীকার করছে!",
    summary_safe: "এই দলিলটি নিরাপদ বলে মনে হচ্ছে। আপনি এগোতে পারেন।",
    summary_warning: "সাবধান! এই দলিলের কিছু শর্ত আপনার জন্য বিপদ ডেকে আনতে পারে। কোনো বিশ্বস্ত লোককে দিয়ে আরেকবার যাচাই করুন।",
    category: "বিভাগ",
    status_danger: "বিপদ! স্বাক্ষর করবেন না",
    status_warning: "সাবধান! আগে বুঝুন",
    status_safe: "নিরাপদ"
  },
  gu: {
    title_loan: "લોનના કાગળો (લોન પેપર)",
    title_deed: "જમીનના દસ્તાવેજ (લેન્ડ ડીડ)",
    title_job: "નોકરીનો કરાર (જોબ કોન્ટ્રાક્ટ)",
    title_medical: "હોસ્પિટલનું ફોર્મ (મેડિકલ ફોર્મ)",
    alert_high_interest: "ચેતવણી: વ્યાજ દર ઘણો વધારે છે! (24% થી વધુ)",
    alert_collateral: "ચેતવણી: તમારી જમીન કે મિલકત ગીરો મુકાઈ રહી છે!",
    alert_hidden_fee: "સાવધાન: છુપી ફી અથવા પ્રોસેસિંગ ચાર્જ માંગવામાં આવી રહ્યો છે!",
    alert_unpaid_labor: "ચેતવણી: વધારાના પૈસા વગર વધારે કામ કરાવવાની શરત છે!",
    alert_no_exit: "ચેતવણી: તમે આ નોકરી સરળતાથી છોડી શકશો નહીં, દંડ લખેલો છે!",
    alert_medical_liability: "સાવધાન: હોસ્પિટલ કોઈપણ ભૂલની જવાબદારી લેવા તૈયાર નથી!",
    summary_safe: "આ દસ્તાવેજ સુરક્ષિત લાગે છે. તમે આગળ વધી શકો છો.",
    summary_warning: "સાવધાન! આ દસ્તાવેજમાં કેટલીક બાબતો એવી છે જે તમને મુશ્કેલીમાં મૂકી શકે છે. કૃપા કરીને કોઈ વિશ્વાસુ વ્યક્તિ પાસે ચકાસણી કરાવો.",
    category: "શ્રેણી",
    status_danger: "ખતરો! સહી કરશો નહીં",
    status_warning: "સાવધાન! પહેલા સમજો",
    status_safe: "સુરક્ષિત"
  },
  kn: {
    title_loan: "ಸಾಲದ ಪತ್ರಗಳು (ಲೋನ್ ಪೇಪರ್)",
    title_deed: "ಭೂಮಿ ದಸ್ತಾವೇಜು (ಲ್ಯಾಂಡ್ ಡೀಡ್)",
    title_job: "ಕೆಲಸದ ಒಪ್ಪಂದ (ಜಾಬ್ ಕಾಂಟ್ರಾಕ್ಟ್)",
    title_medical: "ಆಸ್ಪತ್ರೆ ಫಾರ್ಮ್ (ಮೆಡಿಕಲ್ ಫಾರ್ಮ್)",
    alert_high_interest: "ಎಚ್ಚರಿಕೆ: ಬಡ್ಡಿ ದರ ತುಂಬಾ ಹೆಚ್ಚಾಗಿದೆ! (24% ಕ್ಕಿಂತ ಹೆಚ್ಚು)",
    alert_collateral: "ಎಚ್ಚರಿಕೆ: ನಿಮ್ಮ ಜಮೀನು ಅಥವಾ ಆಸ್ತಿಯನ್ನು ಅಡಮಾನ ಇಡಲಾಗುತ್ತಿದೆ!",
    alert_hidden_fee: "ಎಚ್ಚರ: ಹಿಡನ್ चಾರ್ಜ್ ಅಥವಾ ಹೆಚ್ಚುವರಿ ಹಣ ಕೇಳಲಾಗುತ್ತಿದೆ!",
    alert_unpaid_labor: "ಎಚ್ಚరిಕೆ: ಹೆಚು ಕೆಲಸಕ್ಕೆ ಹೆಚ್ಚಿನ ವೇತನವಿಲ್ಲದ ನಿಯಮವಿದೆ!",
    alert_no_exit: "ಎಚ್ಚరిಕೆ: ಈ ಕೆಲಸವನ್ನು ನೀವು ಸುಲಭವಾಗಿ ಬಿಡುವಂತಿಲ್ಲ, ದಂಡ ವಿಧಿಸಲಾಗುತ್ತದೆ!",
    alert_medical_liability: "ಎಚ್ಚರ: ಆಸ್ಪತ್ರೆಯು ಯಾವುದೇ ತಪ್ಪುಗಳಿಗೆ ಜವಾಬ್ದಾರರಾಗಿರುವುದಿಲ್ಲ!",
    summary_safe: "ಈ ಪತ್ರವು ಸುರಕ್ಷಿತವಾಗಿರುವಂತೆ ತೋರುತ್ತಿದೆ. ನೀವು ಮುಂದುವರಿಯಬಹುದು.",
    summary_warning: "ಎಚ್ಚರ! ಈ ಪತ್ರದಲ್ಲಿ ನಿಮ್ಮನ್ನು ತೊಂದರೆಗೆ ಸಿಲುಕಿಸುವ ಕೆಲವು ಅಂಶಗಳಿವೆ. ದಯವಿಟ್ಟು ಯಾರಾದರೂ ನಂಬಿಕಸ್ಥರಿಂದ ಮತ್ತೊಮ್ಮೆ ಪರಿಶೀಲಿಸಿ.",
    category: "ವರ್ಗ",
    status_danger: "ಅಪಾಯ! ಸಹಿ ಮಾಡಬೇಡಿ",
    status_warning: "ಎಚ್ಚರ! ಮೊದಲು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಿ",
    status_safe: "ಸುರಕ್ಷಿತ"
  },
  ml: {
    title_loan: "വായ്പാ രേഖ (ലോൺ പേപ്പർ)",
    title_deed: "ആധാരം (ലാൻഡ് ഡീഡ്)",
    title_job: "തൊഴിൽ കരാർ (ജോബ് കോൺട്രാക്ട്)",
    title_medical: "ആശുപത്രി ഫോം (മെഡിക്കൽ ഫോം)",
    alert_high_interest: "മുന്നറിയിപ്പ്: പലിശ നിരക്ക് വളരെ കൂടുതലാണ്! (24%-ൽ കൂടുതൽ)",
    alert_collateral: "മുന്നറിയിപ്പ്: നിങ്ങളുടെ ഭൂമിയോ സ്വത്തോ പണയപ്പെടുത്തുന്നു!",
    alert_hidden_fee: "ശ്രദ്ധിക്കുക: ഒളിഞ്ഞിരിക്കുന്ന ഫീസുകൾ ഈടാക്കുന്നു!",
    alert_unpaid_labor: "മുന്നറിയിപ്പ്: അധിക വേതനം നൽകാതെ കൂടുതൽ സമയം ജോലി ചെയ്യിക്കാൻ വ്യവസ്ഥയുണ്ട്!",
    alert_no_exit: "മുന്നറിയിപ്പ്: ഈ ജോലി എളുപ്പത്തിൽ ഉപേക്ഷിക്കാൻ കഴിയില്ല, പിഴയുണ്ട്!",
    alert_medical_liability: "ശ്രദ്ധിക്കുക: ആശുപത്രി യാതൊരു തെറ്റുകൾക്കും ഉത്തരവാദിത്തം ഏൽക്കുന്നില്ല!",
    summary_safe: "ഈ രേഖ സുരക്ഷിതമാണെന്ന് തോന്നുന്നു. നിങ്ങൾക്ക് മുന്നോട്ട് പോകാം.",
    summary_warning: "ശ്രദ്ധിക്കുക! ഈ രേഖയിൽ നിങ്ങളെ അപകടത്തിലാക്കിയേക്കാവുന്ന ചില കാര്യങ്ങളുണ്ട്. ദയവായി വിശ്വസ്തനായ ഒരാളെക്കൊണ്ട് വീണ്ടും പരിശോധിപ്പിക്കുക.",
    category: "വിഭാഗം",
    status_danger: "അപകടം! ഒപ്പിടരുത്",
    status_warning: "ശ്രദ്ധിക്കുക! ആദ്യം മനസ്സിലാക്കൂ",
    status_safe: "സുരക്ഷിതം"
  },
  or: {
    title_loan: "ଋଣ ଦଲିଲ୍ (ଲୋନ୍ ପେପର)",
    title_deed: "ଜମି ପଟ୍ଟା (ଲ୍ୟାଣ୍ଡ୍ ଡିଡ୍)",
    title_job: "କାର୍ଯ୍ୟ ଚୁକ୍ତିପତ୍ର (ଚାକିରି ଚୁକ୍ତି)",
    title_medical: "ଡାକ୍ତରଖାନା ଫର୍મ (ମେଡିକାଲ୍ ଫର୍ମ)",
    alert_high_interest: "ଚେତାବନୀ: ସୁଧ ହାର ବହୁତ ଅଧିକ ଅଛି! (୨୪% ରୁ ଅଧିକ)",
    alert_collateral: "ଚେତାବନୀ: ଆପଣଙ୍କ ଜମି କିମ୍ବା ସମ୍ପତ୍ତି ବନ୍ଧକ ରଖାଯାଉଛି!",
    alert_hidden_fee: "ସାବଧାନ: ଲୁଚି ରହିଥିବା ଅତିରିକ୍ତ ଦେୟ ମାଗାଯାଉଛି!",
    alert_unpaid_labor: "ଚେତାବନୀ: ଅଧିକ କାମ ପାଇଁ ଅତିରିକ୍ତ ଟଙ୍କਾ ନ ଦେବାର ସର୍ତ୍ତ ଅଛି!",
    alert_no_exit: "ଚେତାବନୀ: ଆପଣ ସହଜରେ ଚାକିରି ଛାଡିପାରିବେ ନାହିଁ, ଜରିମାନା ଲେଖାଯାଇଛି!",
    alert_medical_liability: "ସାବଧାନ: ଡାକ୍ତରଖାନା କୌଣସି ଭୁଲ୍ ପାଇଁ ଦାୟୀ ରହିବ ନାହିଁ!",
    summary_safe: "ଏହି ଦଲିଲ୍ ସୁରକ୍ષିତ ମନେହେଉଛି । ଆପଣ ଆଗକୁ ବଢିପାରିବେ ।",
    summary_warning: "ସାବଧାନ! ଏହି ଦଲିଲରେ ଏମିତି କିଛି ସର୍ତ୍ତ ଅଛି ଯାହା ଆପଣଙ୍କୁ ଅସୁବिଧାରେ ପକାଇପାରେ । ଦୟାକରି କୌଣସି ବିଶ୍ୱସ୍ତ ବ୍ୟକ୍ତିଙ୍କ ଦ୍ୱାରା ଯାଞ୍ચ କରାନ୍ତୁ ।",
    category: "ଶ୍ରେଣୀ",
    status_danger: "ବିପଦ! ଦସ୍ତଖତ କରନ୍ତୁ ନାହିଁ",
    status_warning: "ସାବଧାନ! ପ୍ରଥମେ ବୁଝନ୍ତୁ",
    status_safe: "ସୁରକ୍ષିତ"
  },
  pa: {
    title_loan: "ਕਰਜ਼ਾ ਦਸਤਾਵੇਜ਼ (ਲੋਨ ਪੇਪਰ)",
    title_deed: "ਜ਼ਮੀਨ ਦੀ ਰਜਿਸਟਰੀ (ਲੈਂਡ ਡੀਡ)",
    title_job: "ਨੌਕਰੀ ਦਾ ਇਕਰਾਰਨਾਮਾ (ਜੌਬ ਕੰਟਰੈਕਟ)",
    title_medical: "ਹਸਪਤਾਲ ਦਾ ਫਾਰਮ (ਮੈਡੀਕਲ ਫਾਰਮ)",
    alert_high_interest: "ਚੇਤਾਵਨੀ: ਵਿਆਜ ਦਰ ਬਹੁਤ ਜ਼ਿਆਦਾ ਹੈ! (24% ਤੋਂ ਵੱਧ)",
    alert_collateral: "ਚੇਤਾਵਨੀ: ਤੁਹਾਡੀ ਜ਼ਮੀਨ ਜਾਂ ਜਾਇਦਾਦ ਗਿਰਵੀ ਰੱਖੀ ਜਾ ਰਹੀ ਹੈ!",
    alert_hidden_fee: "ਸਾਵਧਾਨ: ਫਾਈਲਿੰਗ ਦੇ ਨਾਮ 'ਤੇ ਲੁਕੇ ਹੋਏ ਪੈਸੇ ਮੰਗੇ ਜਾ ਰਹੇ ਹਨ!",
    alert_unpaid_labor: "ਚੇਤਾਵਨੀ: ਬਿਨਾਂ ਵਾਧੂ ਪੈਸੇ ਦਿੱਤੇ ਜ਼ਿਆਦਾ ਕੰਮ ਕਰਵਾਉਣ ਦੀ ਸ਼ਰਤ ਹੈ!",
    alert_no_exit: "ਚੇਤਾਵਨੀ: ਤੁਸੀਂ ਇਹ ਨੌਕਰੀ ਆਸਾਨੀ ਨਾਲ ਛੱਡ ਨਹੀਂ ਸਕਦੇ, ਜੁਰਮਾਨਾ ਲਿਖਿਆ ਹੈ!",
    alert_medical_liability: "ਸਾਵਧਾਨ: ਹਸਪਤਾਲ ਕਿਸੇ ਵੀ ਗਲਤੀ ਦੀ ਜ਼ਿੰਮੇਵਾਰੀ ਨਹੀਂ ਲੈਂਦਾ!",
    summary_safe: "ਇਹ ਦਸਤਾਵੇਜ਼ ਸੁਰੱਖਿਅਤ ਲੱਗਦਾ ਹੈ। ਤੁਸੀਂ ਅੱਗੇ ਵਧ ਸਕਦੇ ਹੋ।",
    summary_warning: "ਸਾਵਧਾਨ! ਇਸ ਦਸਤਾਵੇਜ਼ ਵਿੱਚ ਕੁਝ ਅਜਿਹੀਆਂ ਗੱਲਾਂ ਹਨ ਜੋ ਤੁਹਾਨੂੰ ਮੁਸੀਬਤ ਵਿੱਚ ਪਾ ਸਕਦੀਆਂ ਹਨ। ਕਿਰਪา ਕਰਕੇ ਕਿਸੇ ਭਰੋਸੇਮੰਦ ਵਿਅਕਤੀ ਤੋਂ ਦੁਬਾਰਾ ਜਾਂਚ ਕਰਵਾਓ।",
    category: "ਸ਼੍ਰੇਣੀ",
    status_danger: "ਖਤਰਾ! ਦਸਤਖਤ ਨਾ ਕਰੋ",
    status_warning: "ਸਾਵਧਾਨ! ਪਹਿਲਾਂ ਸਮਝੋ",
    status_safe: "ਸੁਰੱਖਿਅਤ"
  },
  as: {
    title_loan: "ঋণৰ নথি-পত্ৰ (লোন পেপাৰ)",
    title_deed: "মাটিৰ দলিল (লেণ্ড ডীড)",
    title_job: "চাকৰিৰ চুক্তিপত্ৰ (জব কন্ট্ৰেক্ট)",
    title_medical: "চিকিৎসালয়ৰ ফৰ্ম (মেডিকেল ফৰ্ম)",
    alert_high_interest: "সাৱধান: সূতৰ হাৰ বহুত বেছি! (২৪% তকৈ অধিক)",
    alert_collateral: "সাৱধান: আপোনাৰ মাটি বা সম্পত্তি বন্ধকত ৰখা হৈছে!",
    alert_hidden_fee: "সাৱধান: গোপন চাৰ্জ বা অতিৰিক্ত পইচা দাবী কৰা হৈছে!",
    alert_unpaid_labor: "সাৱধান: অতিৰিক্ত মজুৰি নোহোৱাকৈ বেছি সময় কাম কৰাৰ নিয়ম আছে!",
    alert_no_exit: "সাৱধান: আপুনি এই চাকৰি সহজে এৰিব নোৱাৰে, জৰিমনা লিখা আছে!",
    alert_medical_liability: "সাৱধান: চিকিৎসালয়ে কোনো ভুলৰ বাবে দায় ল'বলৈ অস্বীকাर কৰিছে!",
    summary_safe: "এই নথিখন সুৰক্ষিত যেন লাগিছে। আপুনি আগবাঢ়িব পাৰে।",
    summary_warning: "সাৱধান! এই নথিত কিছুমান কথা আছে যিয়ে আপোনাক বিপদত পেলাব পাৰে। অনুগ্ৰহ কৰি কোনো বিশ্বাসী লোকৰ দ্বাৰা পুনৰ পৰীক্ষা কৰাওক।",
    category: "শ্ৰেণী",
    status_danger: "বিপদ! চহী নকৰিব",
    status_warning: "সাৱধান! প্ৰথমে বুজি লওক",
    status_safe: "সুৰক্ষিত"
  },
  ur: {
    title_loan: "قرض کا معاہدہ (لون پیپر)",
    title_deed: "زمین کے کاغذات (لینڈ ڈیڈ)",
    title_job: "ملازمت کا معاہدہ (جاب کانٹریکٹ)",
    title_medical: "ہسپتال کا فارم (میڈیکل فارم)",
    alert_high_interest: "وارننگ: سود کی شرح بہت زیادہ ہے! (24 فیصد سے زائد)",
    alert_collateral: "وارننگ: آپ کی زمین یا جائیداد گروی رکھی جا رہی ہے!",
    alert_hidden_fee: "خبردار: فائلنگ کے نام پر چھپے ہوئے پیسے مانگے جا رہے ہیں!",
    alert_unpaid_labor: "وارننگ: بغیر قانونی فوائد کے کام کرانے کی شرط ہے!",
    alert_no_exit: "وارننگ: آپ یہ ملازمت آسانی سے چھوڑ نہیں سکتے، جرمانہ درج ہے!",
    alert_medical_liability: "خبردار: ہسپتال غلطیوں کی ذمہ داری لینے سے انکاری ہے!",
    summary_safe: "یہ دستاویز محفوظ معلوم ہوتی ہے۔ آپ آگے بڑھ سکتے ہیں۔",
    summary_warning: "خبردار! اس دستاویز میں کچھ باتیں ایسی ہیں جو آپ کو مشکل میں ڈال سکتی ہیں۔ کسی قابلِ بھروسہ شخص سے چیک کروائیں۔",
    category: "زمرہ",
    status_danger: "خطرہ! دستخط نہ کریں",
    status_warning: "خبردار! پہلے سمجھیں",
    status_safe: "محفوظ"
  }
};

function analyzeText(text = "") {
  const normalizedText = text.toLowerCase();
  let category = "loan";
  let warnings = [];
  let severity = "safe";

  if (normalizedText.includes("land") || normalizedText.includes("deed") || normalizedText.includes("property") || normalizedText.includes("survey number") || normalizedText.includes("sale") || normalizedText.includes("registra") || normalizedText.includes("खसरा") || normalizedText.includes("पट्टा") || normalizedText.includes("पंजीकरण")) {
    category = "deed";
  } else if (normalizedText.includes("employment") || normalizedText.includes("labor") || normalizedText.includes("job") || normalizedText.includes("salary") || normalizedText.includes("work hours") || normalizedText.includes("employer") || normalizedText.includes("नौकरी") || normalizedText.includes("काम") || normalizedText.includes("वेतन")) {
    category = "job";
  } else if (normalizedText.includes("medical") || normalizedText.includes("hospital") || normalizedText.includes("consent") || normalizedText.includes("patient") || normalizedText.includes("treatment") || normalizedText.includes("surgery") || normalizedText.includes("मरीज") || normalizedText.includes("अस्पताल")) {
    category = "medical";
  }

  if (category === "loan") {
    const interestRegex = /(\d+)%\s*(?:per annum|annual|interest|yearly|interest rate|ब्याज|प्रति वर्ष)/i;
    const match = normalizedText.match(interestRegex);
    let interestRate = 0;
    if (match) {
      interestRate = parseInt(match[1]);
    } else {
      const monthlyMatch = normalizedText.match(/(\d+)%\s*(?:per month|monthly|प्रति माह)/i);
      if (monthlyMatch) {
        interestRate = parseInt(monthlyMatch[1]) * 12;
      }
    }

    if (interestRate >= 24 || normalizedText.includes("30%") || normalizedText.includes("36%") || normalizedText.includes("40%") || normalizedText.includes("compound interest") || normalizedText.includes("चक्रवृद्धि ब्याज")) {
      warnings.push("alert_high_interest");
      severity = "danger";
    }

    if (normalizedText.includes("seize") || normalizedText.includes("collateral") || normalizedText.includes("forfeit") || normalizedText.includes("mortgage") || normalizedText.includes("guarantee land") || normalizedText.includes("गिरवी") || normalizedText.includes("जब्त")) {
      warnings.push("alert_collateral");
      severity = "danger";
    }

    if (normalizedText.includes("processing fee") || normalizedText.includes("admin fee") || normalizedText.includes("hidden cost") || normalizedText.includes("commission") || normalizedText.includes("कमीशन")) {
      warnings.push("alert_hidden_fee");
      if (severity !== "danger") severity = "warning";
    }
  }

  if (category === "deed") {
    if (normalizedText.includes("transfer all rights") || normalizedText.includes("irrevocable") || normalizedText.includes("forever") || normalizedText.includes("relinquish") || normalizedText.includes("अधिकार हस्तांतरण")) {
      warnings.push("alert_collateral");
      severity = "danger";
    }
    if (normalizedText.includes("without consent") || normalizedText.includes("spouse signature") || normalizedText.includes("बिना सहमति")) {
      warnings.push("alert_collateral");
      if (severity !== "danger") severity = "warning";
    }
  }

  if (category === "job") {
    if (normalizedText.includes("overtime without pay") || normalizedText.includes("no overtime") || normalizedText.includes("additional hours") || normalizedText.includes("बिना अतिरिक्त भुगतान")) {
      warnings.push("alert_unpaid_labor");
      severity = "danger";
    }
    if (normalizedText.includes("cannot resign") || normalizedText.includes("bond period") || normalizedText.includes("penalty fee") || normalizedText.includes("notice period 6 months") || normalizedText.includes("जुर्माना")) {
      warnings.push("alert_no_exit");
      if (severity !== "danger") severity = "warning";
    }
  }

  if (category === "medical") {
    if (normalizedText.includes("not responsible") || normalizedText.includes("waive liability") || normalizedText.includes("at own risk") || normalizedText.includes("no claims") || normalizedText.includes("जिम्मेदार नहीं")) {
      warnings.push("alert_medical_liability");
      severity = "warning";
    }
  }

  return {
    category,
    warnings,
    severity,
    textLength: text.length
  };
}

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'VaakSetu Local Hotspot Kiosk API online.' });
});

app.post('/api/analyze', upload.single('document'), async (req, res) => {
  const lang = req.body.lang || 'hi';
  const translations = TRANSLATIONS[lang] || TRANSLATIONS.hi;

  try {
    let textContent = "";

    if (req.file) {
      const filePath = path.join(__dirname, req.file.path);
      const ocrResult = await Tesseract.recognize(filePath, 'eng+hin');
      textContent = ocrResult.data.text;
      fs.unlinkSync(filePath);
    } else if (req.body.text) {
      textContent = req.body.text;
    } else {
      return res.status(400).json({ error: "Please upload an image file or provide text content." });
    }

    const analysis = analyzeText(textContent);
    
    const localizedWarnings = analysis.warnings.map(key => ({
      key,
      text: translations[key] || key
    }));

    let categoryTitle = translations[`title_${analysis.category}`] || analysis.category;
    let summaryText = analysis.severity === "safe" ? translations.summary_safe : translations.summary_warning;

    res.json({
      success: true,
      rawText: textContent,
      category: analysis.category,
      categoryTitle,
      severity: analysis.severity,
      severityTitle: translations[`status_${analysis.severity}`],
      warnings: localizedWarnings,
      summary: summaryText,
      language: lang
    });

  } catch (error) {
    console.error("Backend processing error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/presets', (req, res) => {
  res.json([
    {
      id: "loan_fraud",
      name: "36% Interest Private Loan (High Risk)",
      text: "Loan Agreement. The borrower agrees to borrow Rs. 50,000. The interest rate is 3% per month (compound interest). In case of default, the lender has complete rights to seize the borrower's agriculture land survey number 405. Processing fee of Rs. 5,000 will be deducted in advance."
    },
    {
      id: "land_deed_safe",
      name: "Standard Land Registration (Safe)",
      text: "Sale Deed. This document confirms the sale of plot 42 from seller Ramesh to buyer Suresh for Rs. 3,00,000. All taxes have been paid. Both parties sign with mutual consent in front of witnesses."
    },
    {
      id: "labor_bond",
      name: "Exploitative Brick Kiln Job Contract (High Risk)",
      text: "Labor Contract. Employee agrees to work 12 hours daily. Overtime without pay is mandatory during harvest season. Employee cannot resign or leave the work site before 12 months. Any early resignation incurs a penalty of Rs. 25,000."
    },
    {
      id: "medical_waiver",
      name: "Hospital Surgery Release Form (Warning)",
      text: "Patient Consent Form. Patient agrees to undergo gall bladder surgery. The hospital is not responsible for any post-surgery infections, medical negligence, or accidental errors. Patient waives all rights to file legal claims against doctors."
    }
  ]);
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`===========================================================`);
  console.log(`VaakSetu Local Hotspot Server running on port ${PORT}`);
  console.log(`===========================================================`);
});
