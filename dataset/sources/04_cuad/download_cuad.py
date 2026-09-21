"""
Download CUAD (Contract Understanding Atticus Dataset) from HuggingFace.

Requirements:
    pip install datasets huggingface_hub

Usage:
    python download_cuad.py

Output:
    cuad_raw/         - Raw downloaded files from HuggingFace
    cuad_converted/   - Converted to VaakSetu JSON format
"""

import json
import os

def download_cuad():
    try:
        from datasets import load_dataset
    except ImportError:
        print("ERROR: Please install the 'datasets' library first:")
        print("  pip install datasets")
        return

    print("Downloading CUAD from HuggingFace...")
    dataset = load_dataset("cuad")

    os.makedirs("cuad_raw", exist_ok=True)
    os.makedirs("cuad_converted", exist_ok=True)

    # Save raw train split
    train_data = [dict(item) for item in dataset["train"]]
    with open("cuad_raw/train.json", "w", encoding="utf-8") as f:
        json.dump(train_data, f, indent=2, ensure_ascii=False)
    print(f"  Saved {len(train_data)} training contracts to cuad_raw/train.json")

    # Save raw test split
    test_data = [dict(item) for item in dataset["test"]]
    with open("cuad_raw/test.json", "w", encoding="utf-8") as f:
        json.dump(test_data, f, indent=2, ensure_ascii=False)
    print(f"  Saved {len(test_data)} test contracts to cuad_raw/test.json")

    # Convert to VaakSetu format
    # Map CUAD clause types to VaakSetu warning keys
    clause_mapping = {
        "Liquidated Damages": ("alert_no_exit", "danger"),
        "Uncapped Liability": ("alert_collateral", "danger"),
        "Termination For Convenience": ("alert_no_exit", "warning"),
        "Indemnification": ("alert_medical_liability", "warning"),
        "Limitation Of Liability": ("alert_medical_liability", "warning"),
        "Non-Compete": ("alert_no_exit", "warning"),
        "Non-Solicitation": ("alert_no_exit", "warning"),
        "Automatic Renewal": ("alert_hidden_fee", "warning"),
        "Price Restrictions": ("alert_high_interest", "warning"),
    }

    converted = []
    for i, item in enumerate(train_data[:50]):  # Convert first 50 as sample
        warnings = []
        severity = "safe"

        # Check annotations for relevant clauses
        annotations = item.get("answers", {})
        for clause_name, (warning_key, risk) in clause_mapping.items():
            if clause_name in str(annotations):
                warnings.append(warning_key)
                if risk == "danger":
                    severity = "danger"
                elif risk == "warning" and severity == "safe":
                    severity = "warning"

        converted.append({
            "id": f"cuad_{i+1:04d}",
            "source": "CUAD_v1",
            "category": "loan",
            "is_legal_document": True,
            "risk_level": severity,
            "language": "en",
            "text": item.get("context", "")[:500] + "...",  # First 500 chars
            "expected_warnings": warnings,
        })

    with open("cuad_converted/vaaksetu_cuad_sample.json", "w", encoding="utf-8") as f:
        json.dump(converted, f, indent=2, ensure_ascii=False)
    print(f"  Converted 50 contracts to cuad_converted/vaaksetu_cuad_sample.json")
    print("\nDone! CUAD dataset downloaded and converted.")

if __name__ == "__main__":
    download_cuad()
