import React, { useState, useEffect } from 'react';
import LanguageSelector from './components/LanguageSelector';
import CameraScanner from './components/CameraScanner';
import DocumentAnalyzer from './components/DocumentAnalyzer';
import { guider } from './utils/voiceGuider';
import { Shield, Volume2, VolumeX, Eye } from 'lucide-react';

export default function App() {
  const [selectedLang, setSelectedLang] = useState(null);
  const [view, setView] = useState('language'); // 'language', 'scanner', 'analyzer'
  const [scanData, setScanData] = useState(null);
  const [voiceEnabled, setVoiceEnabled] = useState(true);
  const [hasInteracted, setHasInteracted] = useState(false);

  // Play welcome announcement on first interaction
  useEffect(() => {
    if (hasInteracted && view === 'language' && voiceEnabled) {
      guider.speakPrompt('welcome', 'hi'); // Default to Hindi welcome prompt
    }
  }, [hasInteracted, view, voiceEnabled]);

  const handleLanguageSelect = (langCode) => {
    setSelectedLang(langCode);
    setView('scanner');
  };

  const handleScanCompleted = (data) => {
    setScanData(data);
    setView('analyzer');
  };

  const handleBackToScanner = () => {
    setView('scanner');
    setScanData(null);
  };

  const handleReset = () => {
    setView('language');
    setSelectedLang(null);
    setScanData(null);
    guider.stop();
  };

  const toggleVoice = () => {
    if (voiceEnabled) {
      guider.stop();
      setVoiceEnabled(false);
    } else {
      setVoiceEnabled(true);
      if (view === 'language') {
        guider.speakPrompt('welcome', 'hi');
      } else if (view === 'scanner') {
        guider.speakPrompt('scan_prompt', selectedLang);
      }
    }
  };

  return (
    <>
      {/* Header Area */}
      <header className="app-header">
        <div onClick={handleReset} className="brand-logo tap-target">
          <div className="logo-icon-box">
            <Shield size={22} fill="white" />
          </div>
          <div className="brand-text-container">
            <h1 className="brand-title">VaakSetu</h1>
            <span className="brand-subtitle">वाक् सेतु</span>
          </div>
        </div>

        {/* Global Voice Toggle Button */}
        <button
          onClick={() => {
            if (!hasInteracted) setHasInteracted(true);
            toggleVoice();
          }}
          className={`btn-voice tap-target ${voiceEnabled ? 'active' : ''}`}
          title="Toggle audio guide"
        >
          {voiceEnabled ? <Volume2 size={20} /> : <VolumeX size={20} />}
        </button>
      </header>

      {/* Main Area */}
      <main className="app-main">
        {!hasInteracted ? (
          <div className="welcome-container">
            <div className="welcome-logo-large animate-bounce">
              <Shield size={52} fill="white" />
            </div>
            <div className="welcome-text-group">
              <h2>वाक् सेतु</h2>
              <h3>The Voice Bridge</h3>
              <p>सुरक्षित दस्तावेज़ पाठन सहायता। शुरू करने के लिए नीचे दबाएं।</p>
            </div>
            <button
              onClick={() => setHasInteracted(true)}
              className="btn-tap-start pulse-button tap-target"
            >
              यहाँ दबाएं / TAP HERE
            </button>
          </div>
        ) : (
          <>
            {view === 'language' && (
              <LanguageSelector onLanguageSelected={handleLanguageSelect} />
            )}

            {view === 'scanner' && (
              <CameraScanner
                selectedLang={selectedLang}
                onScanCompleted={handleScanCompleted}
                onBack={handleReset}
              />
            )}

            {view === 'analyzer' && (
              <DocumentAnalyzer
                scanData={scanData}
                selectedLang={selectedLang}
                onReset={handleBackToScanner}
              />
            )}
          </>
        )}
      </main>

      {/* Footer Area */}
      <footer className="app-footer">
        <p className="footer-badge">
          <Eye size={12} />
          100% Offline & Private • On-Device AI
        </p>
      </footer>
    </>
  );
}
