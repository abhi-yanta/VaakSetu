import React, { useState, useRef, useEffect } from 'react';
import { Camera, Upload, AlertCircle, FileText } from 'lucide-react';
import { guider } from '../utils/voiceGuider';

export default function CameraScanner({ selectedLang, onScanCompleted, onBack }) {
  const [stream, setStream] = useState(null);
  const [useCamera, setUseCamera] = useState(false);
  const [cameraError, setCameraError] = useState(null);
  const [presets, setPresets] = useState([]);
  const [loadingPresets, setLoadingPresets] = useState(true);
  
  const videoRef = useRef(null);
  const canvasRef = useRef(null);

  useEffect(() => {
    guider.speakPrompt('scan_prompt', selectedLang);
    fetchPresets();
    return () => {
      stopCamera();
    };
  }, [selectedLang]);

  const fetchPresets = async () => {
    try {
      setLoadingPresets(true);
      const res = await fetch('http://localhost:5000/api/presets');
      if (res.ok) {
        const data = await res.json();
        setPresets(data);
      } else {
        throw new Error("Local server not running");
      }
    } catch (e) {
      console.log("Could not load presets from kiosk server. Using local offline backups.");
      setPresets([
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
    } finally {
      setLoadingPresets(false);
    }
  };

  const startCamera = async () => {
    try {
      setCameraError(null);
      const mediaStream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'environment', width: { ideal: 1280 }, height: { ideal: 720 } }
      });
      setStream(mediaStream);
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
      }
      setUseCamera(true);
    } catch (err) {
      console.error("Camera access error:", err);
      setCameraError("Camera not available. Please upload a file or choose a preset below.");
      setUseCamera(false);
    }
  };

  const stopCamera = () => {
    if (stream) {
      stream.getTracks().forEach(track => track.stop());
      setStream(null);
    }
    setUseCamera(false);
  };

  const capturePhoto = () => {
    if (!videoRef.current || !canvasRef.current) return;
    const video = videoRef.current;
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
    
    canvas.toBlob((blob) => {
      stopCamera();
      const url = URL.createObjectURL(blob);
      onScanCompleted({ type: 'image', file: blob, previewUrl: url });
    }, 'image/jpeg');
  };

  const handleFileUpload = (event) => {
    const file = event.target.files[0];
    if (file) {
      const url = URL.createObjectURL(file);
      onScanCompleted({ type: 'image', file: file, previewUrl: url });
    }
  };

  const selectPreset = (preset) => {
    guider.speak(`Loading preset ${preset.name}`, selectedLang);
    onScanCompleted({ type: 'text', text: preset.text, name: preset.name });
  };

  return (
    <div style={{ width: '100%' }}>
      <div className="scanner-header">
        <button
          onClick={() => { guider.stop(); onBack(); }}
          className="btn-back"
        >
          ← Back
        </button>
        <span className="badge-mode">Scanner Mode</span>
      </div>

      <div className="camera-viewport">
        {useCamera ? (
          <>
            <video
              ref={videoRef}
              autoPlay
              playsInline
              className="camera-stream"
            />
            <div className="camera-overlay">
              <span className="camera-overlay-label">Place Document Here</span>
            </div>
            <div className="scanline" />
          </>
        ) : (
          <div className="camera-fallback-msg">
            <AlertCircle size={40} style={{ color: '#F59E0B' }} />
            <p>{cameraError || "Press button below to activate phone camera."}</p>
            <button
              onClick={startCamera}
              className="btn-camera-trigger tap-target"
            >
              <Camera size={18} />
              Open Camera
            </button>
          </div>
        )}
        <canvas ref={canvasRef} style={{ display: 'none' }} />
      </div>

      {useCamera && (
        <div className="capture-controls">
          <button
            onClick={capturePhoto}
            className="btn-shutter tap-target pulse-button"
            title="Capture Document"
          >
            <Camera size={32} />
          </button>
        </div>
      )}

      <div className="upload-fallback-row">
        <label className="btn-upload-box tap-target">
          <Upload size={18} style={{ color: 'var(--color-teal)' }} />
          Upload Document Photo
          <input
            type="file"
            accept="image/*"
            style={{ display: 'none' }}
            onChange={handleFileUpload}
          />
        </label>
      </div>

      <div className="presets-section">
        <h3>
          <FileText size={16} />
          Test with Demo Documents:
        </h3>
        <div className="presets-grid">
          {presets.map((preset) => (
            <button
              key={preset.id}
              onClick={() => selectPreset(preset)}
              className="btn-preset tap-target"
            >
              <span>{preset.name}</span>
              <span className="preset-tag">Tap to Load</span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
