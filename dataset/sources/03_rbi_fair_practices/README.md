# Source 3 — RBI Fair Practices Code (FPC)

**Source**: Reserve Bank of India  
**URL**: https://www.rbi.org.in/Scripts/BS_CircularIndexDisplay.aspx  
**Type**: Regulatory guidelines on fair moneylending practices, illegal usury, and consumer protection  
**Language**: English  

---

## 📌 Why This Dataset Matters for VaakSetu

The **RBI Fair Practices Code** is the legal basis for VaakSetu's interest rate danger threshold (24% per annum). Any loan agreement exceeding these guidelines is flagged as predatory.

Key RBI guidelines that power VaakSetu's rule engine:
- Interest rate disclosure must be in simple annual percentage terms
- Compound interest without explicit borrower consent is prohibited
- Advance deduction of fees from disbursed principal is an unfair practice
- Lenders cannot seize collateral without following proper legal process

---

## ⚠️ Key Predatory Thresholds Derived from RBI FPC

| Metric | Safe Limit | Warning Zone | Danger Zone |
|--------|-----------|-------------|-------------|
| Annual Interest Rate | ≤ 18% | 18–24% | > 24% |
| Interest Type | Simple | Monthly compounding | Daily compounding |
| Advance Fee | 0% | < 2% of principal | ≥ 2% of principal |
| Collateral Seizure | Court order required | — | Without court order |
| Blank Cheques as Security | Prohibited | — | Any amount |

---

## 📄 Key Regulatory Circulars

| Circular | Date | Key Provision |
|---------|------|---------------|
| DBOD.Leg.BC.No.104/09.07.007/2003-04 | May 5, 2003 | Fair Practices Code for lenders |
| RPCD.CO.Plan.BC.66/04.09.001/2012-13 | May 28, 2013 | Fair practices for NBFCs & MFIs |
| RBI/2014-15/299 | Oct 10, 2014 | Revised FPC with interest rate transparency |
| RBI/2022-23/08 | Apr 8, 2022 | Digital lending regulations |

---

## 📄 Data Format

RBI guideline items are structured as:
```json
{
  "circular_id": "DBOD.Leg.BC.104_2003",
  "category": "loan",
  "guideline": "Lenders must disclose the Annual Percentage Rate (APR) in clear terms before sanctioning any loan.",
  "vaaksetu_rule": "alert_high_interest",
  "threshold": "APR > 24% triggers DANGER; APR 18-24% triggers WARNING",
  "penalty_for_violation": "Unfair practice; borrower can file complaint with RBI Ombudsman"
}
```

---

## 📁 Files in This Folder

| File | Description |
|------|-------------|
| `README.md` | This file |
| `rbi_fpc_rules.json` | Machine-readable RBI Fair Practices rules used in VaakSetu |
| `predatory_term_patterns.json` | Text patterns for detecting illegal moneylending language |
