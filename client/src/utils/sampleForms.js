/**
 * Sample Form Presets with simulated document graphics and OCR bounding boxes.
 * Allows offline, instant testing of Form Field Guide without requiring physical scan.
 */

export const SAMPLE_FORMS = [
  {
    id: 'kisan_kalyan_form',
    title: 'Kisan Yojana Registration Form',
    nativeTitle: 'किसान कल्याण योजना आवेदन प्रपत्र',
    category: 'government_form',
    width: 680,
    height: 900,
    ocrData: {
      text: "Government of India\nKisan Kalyan Registration Form\n1. Full Name / पूरा नाम:\n2. Date of Birth / जन्म तिथि:\n3. Gender / लिंग:\n4. Mobile Number / मोबाइल नंबर:\n5. Aadhaar Number / आधार संख्या:\n6. Occupation / व्यवसाय:\n7. Residential Address / निवास का पता:\n8. Date / दिनांक:\n9. Applicant Signature / आवेदक के हस्ताक्षर:",
      lines: [
        {
          text: "Full Name / पूरा नाम",
          bbox: { x0: 48, y0: 160, x1: 220, y1: 188 }
        },
        {
          text: "Date of Birth / जन्म तिथि",
          bbox: { x0: 360, y0: 160, x1: 520, y1: 188 }
        },
        {
          text: "Gender / लिंग",
          bbox: { x0: 48, y0: 250, x1: 180, y1: 278 }
        },
        {
          text: "Mobile Number / मोबाइल नंबर",
          bbox: { x0: 360, y0: 250, x1: 540, y1: 278 }
        },
        {
          text: "Aadhaar Number / आधार संख्या",
          bbox: { x0: 48, y0: 340, x1: 260, y1: 368 }
        },
        {
          text: "Occupation / व्यवसाय",
          bbox: { x0: 360, y0: 340, x1: 510, y1: 368 }
        },
        {
          text: "Residential Address / निवास का पता",
          bbox: { x0: 48, y0: 430, x1: 300, y1: 458 }
        },
        {
          text: "Date / दिनांक",
          bbox: { x0: 48, y: 640, x1: 170, y1: 668 }
        },
        {
          text: "Applicant Signature / हस्ताक्षर / अंगूठे का निशान",
          bbox: { x0: 360, y0: 640, x1: 610, y1: 668 }
        }
      ]
    },
    // Renders visual SVG document image representation
    generateSvg: function() {
      return `
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 680 900" width="100%" height="100%" style="background:#FFFDF9; font-family: sans-serif;">
          <!-- Document Header -->
          <rect x="20" y="20" width="640" height="860" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2" rx="6" />
          <rect x="30" y="30" width="620" height="840" fill="none" stroke="#E2E8F0" stroke-width="1" />
          
          <circle cx="340" cy="65" r="22" fill="#FF6D1F" opacity="0.1" />
          <text x="340" y="72" font-size="20" text-anchor="middle" fill="#FF6D1F" font-weight="bold">🏛️</text>
          
          <text x="340" y="105" font-size="17" text-anchor="middle" fill="#0F1E36" font-weight="bold">GOVERNMENT WELFARE REGISTRATION FORM</text>
          <text x="340" y="126" font-size="13" text-anchor="middle" fill="#64748B">कल्याणकारी योजना लाभार्थी पंजीकरण प्रपत्र</text>
          
          <line x1="45" y1="142" x2="635" y2="142" stroke="#E2E8F0" stroke-width="1.5" />

          <!-- Row 1: Full Name & DOB -->
          <text x="48" y="180" font-size="13" font-weight="bold" fill="#1E293B">1. Full Name / पूरा नाम:</text>
          <rect x="48" y="196" width="270" height="34" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="3,3" rx="4" />

          <text x="360" y="180" font-size="13" font-weight="bold" fill="#1E293B">2. Date of Birth / जन्म तिथि:</text>
          <rect x="360" y="196" width="260" height="34" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="3,3" rx="4" />

          <!-- Row 2: Gender & Mobile -->
          <text x="48" y="270" font-size="13" font-weight="bold" fill="#1E293B">3. Gender / लिंग:</text>
          <rect x="48" y="286" width="270" height="34" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="3,3" rx="4" />

          <text x="360" y="270" font-size="13" font-weight="bold" fill="#1E293B">4. Mobile Number / मोबाइल नंबर:</text>
          <rect x="360" y="286" width="260" height="34" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="3,3" rx="4" />

          <!-- Row 3: Aadhaar & Occupation -->
          <text x="48" y="360" font-size="13" font-weight="bold" fill="#1E293B">5. Aadhaar Number / आधार संख्या:</text>
          <rect x="48" y="376" width="270" height="34" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="3,3" rx="4" />

          <text x="360" y="360" font-size="13" font-weight="bold" fill="#1E293B">6. Occupation / व्यवसाय:</text>
          <rect x="360" y="376" width="260" height="34" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="3,3" rx="4" />

          <!-- Row 4: Address -->
          <text x="48" y="450" font-size="13" font-weight="bold" fill="#1E293B">7. Residential Address / निवास का पता:</text>
          <rect x="48" y="468" width="572" height="130" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="3,3" rx="4" />

          <!-- Row 5: Date & Signature -->
          <text x="48" y="660" font-size="13" font-weight="bold" fill="#1E293B">8. Date / दिनांक:</text>
          <rect x="48" y="678" width="240" height="34" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="3,3" rx="4" />

          <text x="360" y="660" font-size="13" font-weight="bold" fill="#1E293B">9. Signature / हस्ताक्षर / अंगूठा:</text>
          <rect x="360" y="678" width="260" height="88" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" stroke-dasharray="3,3" rx="4" />
          <text x="490" y="730" font-size="11" fill="#94A3B8" text-anchor="middle">Sign or Thumb Impression inside this box</text>

          <!-- Footer seal -->
          <text x="340" y="840" font-size="10" text-anchor="middle" fill="#94A3B8">OFFICIAL DOCUMENT • DO NOT OVERWRITE BORDERS</text>
        </svg>
      `;
    }
  },

  {
    id: 'scholarship_application_form',
    title: 'Rural Youth Scholarship Form',
    nativeTitle: 'ग्रामीण छात्रवृत्ति आवेदन पत्र',
    category: 'government_form',
    width: 680,
    height: 840,
    ocrData: {
      text: "National Student Welfare Council\nScholarship Application Form\nApplicant Name:\nDate of Birth:\nMobile Number:\nAddress:\nIdentity Number:\nSignature:\nDate:",
      lines: [
        {
          text: "Applicant Name / विद्यार्थी का नाम",
          bbox: { x0: 50, y0: 170, x1: 270, y1: 198 }
        },
        {
          text: "Date of Birth / जन्म तिथि",
          bbox: { x0: 360, y0: 170, x1: 530, y1: 198 }
        },
        {
          text: "Mobile Number / मोबाइल नंबर",
          bbox: { x0: 50, y0: 270, x1: 250, y1: 298 }
        },
        {
          text: "Identity Number / आधार या पहचान पत्र",
          bbox: { x0: 360, y0: 270, x1: 590, y1: 298 }
        },
        {
          text: "Permanent Address / स्थायी पता",
          bbox: { x0: 50, y0: 370, x1: 280, y1: 398 }
        },
        {
          text: "Signature of Applicant / हस्ताक्षर",
          bbox: { x0: 360, y0: 540, x1: 580, y1: 568 }
        },
        {
          text: "Date / दिनांक",
          bbox: { x0: 50, y0: 540, x1: 160, y1: 568 }
        }
      ]
    },
    generateSvg: function() {
      return `
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 680 840" width="100%" height="100%" style="background:#FFFDF9; font-family: sans-serif;">
          <rect x="20" y="20" width="640" height="800" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2" rx="6" />
          <text x="340" y="80" font-size="18" text-anchor="middle" fill="#0F1E36" font-weight="bold">NATIONAL STUDENT WELFARE COUNCIL</text>
          <text x="340" y="105" font-size="13" text-anchor="middle" fill="#64748B">छात्रवृत्ति आवेदन प्रपत्र (Scholarship Form)</text>
          <line x1="45" y1="130" x2="635" y2="130" stroke="#E2E8F0" stroke-width="1.5" />

          <text x="50" y="190" font-size="13" font-weight="bold" fill="#1E293B">1. Applicant Name / नाम:</text>
          <rect x="50" y="206" width="270" height="34" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" rx="4" />

          <text x="360" y="190" font-size="13" font-weight="bold" fill="#1E293B">2. Date of Birth / जन्म तिथि:</text>
          <rect x="360" y="206" width="260" height="34" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" rx="4" />

          <text x="50" y="290" font-size="13" font-weight="bold" fill="#1E293B">3. Mobile Number / मोबाइल:</text>
          <rect x="50" y="306" width="270" height="34" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" rx="4" />

          <text x="360" y="290" font-size="13" font-weight="bold" fill="#1E293B">4. ID Number / पहचान पत्र:</text>
          <rect x="360" y="306" width="260" height="34" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" rx="4" />

          <text x="50" y="390" font-size="13" font-weight="bold" fill="#1E293B">5. Address / पता:</text>
          <rect x="50" y="408" width="570" height="90" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" rx="4" />

          <text x="50" y="560" font-size="13" font-weight="bold" fill="#1E293B">6. Date / दिनांक:</text>
          <rect x="50" y="578" width="240" height="34" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" rx="4" />

          <text x="360" y="560" font-size="13" font-weight="bold" fill="#1E293B">7. Signature / हस्ताक्षर:</text>
          <rect x="360" y="578" width="260" height="80" fill="#F8FAFC" stroke="#94A3B8" stroke-width="1.2" rx="4" />
        </svg>
      `;
    }
  }
];
