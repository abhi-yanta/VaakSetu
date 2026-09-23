import React, { useState, useRef, useEffect, useCallback } from 'react';
import { Camera, Upload, AlertCircle, FileText, RefreshCw, X } from 'lucide-react';
import { guider } from '../utils/voiceGuider';

import { SAMPLE_FORMS } from '../utils/sampleForms';

export default function CameraScanner({ selectedLang, onScanCompleted, onBack }) {
  const [stream, setStream] = useState(null);
  const [useCamera, setUseCamera] = useState(false);
  const [cameraError, setCameraError] = useState(null);
  const [facingMode, setFacingMode] = useState('environment'); // 'environment' | 'user'
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

  // Ensure stream is bound to the video element whenever video element or stream updates
  useEffect(() => {
    if (videoRef.current && stream) {
      videoRef.current.srcObject = stream;
      videoRef.current.play().catch((err) => {
        console.warn("Autoplay was prevented or video stream play error:", err);
      });
    }
  }, [stream, useCamera]);

  const fetchPresets = async () => {
    try {
      setLoadingPresets(true);
      const apiBase = import.meta.env.VITE_API_BASE_URL || (window.location.hostname === 'localhost' ? 'http://localhost:5000' : '');
      const res = await fetch(`${apiBase}/api/presets`);
      if (res.ok) {
        const data = await res.json();
        setPresets([
          {
            id: "kisan_welfare_form",
            name: "📝 Kisan Yojana Registration Form (Form Guide)",
            isForm: true,
            ...SAMPLE_FORMS[0]
          },
          {
            id: "scholarship_form",
            name: "📝 Rural Youth Scholarship Form (Form Guide)",
            isForm: true,
            ...SAMPLE_FORMS[1]
          },
          ...data
        ]);
      } else {
        throw new Error("Local server not running");
      }
    } catch (e) {
      console.log("Using local offline backups with form guide presets.");
      setPresets([
        {
          id: "kisan_welfare_form",
          name: "📝 Kisan Yojana Registration Form (Form Guide)",
          isForm: true,
          ...SAMPLE_FORMS[0]
        },
        {
          id: "scholarship_form",
          name: "📝 Rural Youth Scholarship Form (Form Guide)",
          isForm: true,
          ...SAMPLE_FORMS[1]
        },
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

  const stopCamera = useCallback(() => {
    if (stream) {
      stream.getTracks().forEach((track) => {
        track.stop();
      });
      setStream(null);
    }
    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }
    setUseCamera(false);
  }, [stream]);

  const startCamera = async (mode = facingMode) => {
    setCameraError(null);

    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      setCameraError(
        "Camera access is not supported on this browser or requires a secure connection (HTTPS / localhost). Please upload a file instead."
      );
      setUseCamera(false);
      return;
    }

    // Stop any existing stream first
    if (stream) {
      stream.getTracks().forEach(track => track.stop());
      setStream(null);
    }

    let mediaStream = null;

    // Strategy 1: Attempt with ideal facingMode and high resolution
    try {
      mediaStream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: { ideal: mode },
          width: { ideal: 1920, min: 640 },
          height: { ideal: 1080, min: 480 }
        },
        audio: false
      });
    } catch (err1) {
      console.warn("HD camera constraint failed, trying basic facingMode:", err1);
      // Strategy 2: Attempt with basic facingMode
      try {
        mediaStream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: mode },
          audio: false
        });
      } catch (err2) {
        console.warn("facingMode constraint failed, falling back to any video device:", err2);
        // Strategy 3: Fallback to any default video device
        try {
          mediaStream = await navigator.mediaDevices.getUserMedia({
            video: true,
            audio: false
          });
        } catch (err3) {
          console.error("Camera access error:", err3);
          let errorMsg = "Could not activate camera. Please upload a photo or use a demo document below.";
          if (err3.name === 'NotAllowedError' || err3.name === 'PermissionDeniedError') {
            errorMsg = "Camera permission denied. Please allow camera access in your browser settings.";
          } else if (err3.name === 'NotFoundError' || err3.name === 'DevicesNotFoundError') {
            errorMsg = "No camera found on this device. Please upload a document photo.";
          } else if (err3.name === 'NotReadableError' || err3.name === 'TrackStartError') {
            errorMsg = "Camera is already in use by another app or tab. Please close other apps and retry.";
          }
          setCameraError(errorMsg);
          setUseCamera(false);
          return;
        }
      }
    }

    if (mediaStream) {
      setStream(mediaStream);
      setUseCamera(true);
    }
  };

  const toggleCameraFacing = async () => {
    const nextMode = facingMode === 'environment' ? 'user' : 'environment';
    setFacingMode(nextMode);
    await startCamera(nextMode);
  };

  const capturePhoto = () => {
    const video = videoRef.current;
    const canvas = canvasRef.current;
    if (!video || !canvas) return;

    const width = video.videoWidth || video.clientWidth || 1280;
    const height = video.videoHeight || video.clientHeight || 720;
    
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(video, 0, 0, width, height);

    const handleBlob = (blob) => {
      stopCamera();
      if (blob) {
        const url = URL.createObjectURL(blob);
        onScanCompleted({ type: 'image', file: blob, previewUrl: url });
      } else {
        // Fallback: convert dataURL
        const dataUrl = canvas.toDataURL('image/jpeg', 0.9);
        fetch(dataUrl)
          .then(res => res.blob())
          .then(b => {
            onScanCompleted({ type: 'image', file: b, previewUrl: dataUrl });
          });
      }
    };

    if (canvas.toBlob) {
      canvas.toBlob(handleBlob, 'image/jpeg', 0.92);
    } else {
      const dataUrl = canvas.toDataURL('image/jpeg', 0.92);
      fetch(dataUrl)
        .then(res => res.blob())
        .then(handleBlob);
    }
  };

  const handleFileUpload = (event) => {
    const file = event.target.files[0];
    if (file) {
      stopCamera();
      const url = URL.createObjectURL(file);
      onScanCompleted({ type: 'image', file: file, previewUrl: url });
    }
  };

  const selectPreset = (preset) => {
    stopCamera();
    guider.speak(`Loading preset ${preset.name}`, selectedLang);
    if (preset.isForm) {
      onScanCompleted({ 
        type: 'form', 
        name: preset.name, 
        text: preset.ocrData?.text || preset.text,
        ocrData: preset.ocrData,
        generateSvg: preset.generateSvg,
        isForm: true 
      });
    } else {
      onScanCompleted({ type: 'text', text: preset.text, name: preset.name });
    }
  };

  return (
    <div style={{ width: '100%' }}>
      <div className="scanner-header">
        <button
          onClick={() => { stopCamera(); guider.stop(); onBack(); }}
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
              muted
              className="camera-stream"
            />
            <div className="camera-overlay">
              <span className="camera-overlay-label">Align Document in Frame</span>
            </div>
            <div className="scanline" />
            
            <button
              onClick={stopCamera}
              className="btn-camera-close"
              title="Close Camera"
            >
              <X size={18} />
            </button>
          </>
        ) : (
          <div className="camera-fallback-msg">
            <AlertCircle size={40} style={{ color: '#F59E0B' }} />
            <p>{cameraError || "Press button below to activate camera."}</p>
            <button
              onClick={() => startCamera(facingMode)}
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
            onClick={toggleCameraFacing}
            className="btn-camera-flip tap-target"
            title="Flip Camera (Front / Back)"
          >
            <RefreshCw size={20} />
            <span>Flip</span>
          </button>

          <button
            onClick={capturePhoto}
            className="btn-shutter tap-target pulse-button"
            title="Capture Document"
          >
            <Camera size={32} />
          </button>

          <button
            onClick={stopCamera}
            className="btn-camera-cancel tap-target"
            title="Cancel"
          >
            <X size={20} />
            <span>Close</span>
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
