# Source 5 — CLAUDETTE Dataset

**Project**: CLAUDETTE (CLAUse DEtection in Terms and conditions of onlinE services)  
**Website**: http://claudette.eui.eu/  
**Paper**: "Automated Detection of Potentially Unfair Clauses in Online Terms of Service" (Lippi et al., 2019)  
**Type**: Consumer contracts annotated for unfair & potentially unfair clauses  
**Language**: English  
**License**: Research/Academic use  

---

## 📌 Why This Dataset Matters for VaakSetu

CLAUDETTE specifically identifies **unfair and predatory clauses** in consumer contracts — which maps directly to VaakSetu's use case of protecting rural users from abusive legal terms.

### CLAUDETTE Clause Categories → VaakSetu Mapping

| CLAUDETTE Category | Description | VaakSetu Warning |
|-------------------|-------------|-----------------|
| Limitation of liability | Provider limits own liability entirely | alert_medical_liability |
| Unilateral change | Provider can change terms without notice | alert_no_exit |
| Content removal | Provider can remove content without notice | — |
| Jurisdiction | Unfair forum for dispute resolution | alert_collateral |
| Arbitration | Mandatory arbitration waiving court rights | alert_no_exit |
| Unilateral termination | Provider can terminate without cause | alert_no_exit |
| Contract by using | Agreeing just by using = hidden consent | alert_hidden_fee |
| Privacy-related | Broad data collection without consent | — |

---

## 📥 How to Access

1. **Email the CLAUDETTE team**: Contact via http://claudette.eui.eu for academic dataset access
2. **GitHub**: Some annotated samples available at https://github.com/claudette
3. **Hugging Face**: Search `claudette` for community uploads

---

## 📁 Files in This Folder

| File | Description |
|------|-------------|
| `README.md` | This file |
| `unfair_clause_patterns.json` | Patterns extracted from CLAUDETTE research for VaakSetu |
| `sample_annotated_clauses.json` | Sample clauses showing annotation format |
