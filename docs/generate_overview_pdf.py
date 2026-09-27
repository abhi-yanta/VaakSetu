#!/usr/bin/env python3
"""Convert docs/VaakSetu_Overview.md -> HTML, then PDF via Edge (Unicode-safe)."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import markdown

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "docs" / "VaakSetu_Overview.md"
HTML_PATH = ROOT / "docs" / "VaakSetu_Overview.html"
PDF_PATH = ROOT / "docs" / "VaakSetu_Overview.pdf"

CSS = """
@page { size: A4; margin: 18mm 16mm 18mm 16mm; }
* { box-sizing: border-box; }
body {
  font-family: "Segoe UI", "Nirmala UI", "Noto Sans Devanagari", Arial, sans-serif;
  font-size: 11pt;
  line-height: 1.45;
  color: #1e293b;
  max-width: 820px;
  margin: 0 auto;
  padding: 12px 8px 32px;
}
h1 {
  font-size: 22pt;
  color: #0f172a;
  border-bottom: 3px solid #e65100;
  padding-bottom: 8px;
  margin-top: 0;
}
h2 {
  font-size: 14pt;
  color: #00695c;
  margin-top: 1.6em;
  border-bottom: 1px solid #d4cec4;
  padding-bottom: 4px;
  page-break-after: avoid;
}
h3 {
  font-size: 12pt;
  color: #334155;
  margin-top: 1.2em;
  page-break-after: avoid;
}
p, li { orphans: 3; widows: 3; }
table {
  border-collapse: collapse;
  width: 100%;
  margin: 0.8em 0 1.2em;
  font-size: 10pt;
  page-break-inside: avoid;
}
th, td {
  border: 1px solid #d4cec4;
  padding: 6px 8px;
  text-align: left;
  vertical-align: top;
}
th { background: #efeae2; }
code, pre {
  font-family: Consolas, "Courier New", monospace;
  font-size: 9.5pt;
  background: #f7f3eb;
}
pre {
  padding: 10px 12px;
  border: 1px solid #d4cec4;
  border-radius: 6px;
  overflow-x: auto;
  white-space: pre-wrap;
  page-break-inside: avoid;
}
code { padding: 1px 4px; border-radius: 3px; }
blockquote {
  border-left: 4px solid #e65100;
  margin: 1em 0;
  padding: 4px 12px;
  color: #475569;
  background: #fff8f3;
}
hr { border: none; border-top: 1px solid #d4cec4; margin: 1.5em 0; }
a { color: #00695c; }
.meta {
  background: #f7f3eb;
  border: 1px solid #d4cec4;
  border-radius: 8px;
  padding: 10px 14px;
  margin-bottom: 1.2em;
}
"""


def md_to_html(md_text: str) -> str:
    body = markdown.markdown(
        md_text,
        extensions=["tables", "fenced_code", "toc", "sane_lists"],
        output_format="html5",
    )
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<title>VaakSetu — Complete Project Explainer</title>
<style>{CSS}</style>
</head>
<body>
{body}
</body>
</html>
"""


def find_edge() -> Path | None:
    candidates = [
        Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"),
        Path(r"C:\Program Files\Microsoft\Edge\Application\msedge.exe"),
    ]
    for p in candidates:
        if p.exists():
            return p
    return None


def html_to_pdf_edge(html_path: Path, pdf_path: Path) -> None:
    edge = find_edge()
    if edge is None:
        raise RuntimeError("Microsoft Edge not found; cannot print HTML to PDF.")

    # file:/// URL with forward slashes
    url = html_path.resolve().as_uri()
    pdf_path.parent.mkdir(parents=True, exist_ok=True)
    if pdf_path.exists():
        pdf_path.unlink()

    cmd = [
        str(edge),
        "--headless=new",
        "--disable-gpu",
        "--no-pdf-header-footer",
        f"--print-to-pdf={pdf_path.resolve()}",
        url,
    ]
    print("Running:", " ".join(cmd[:4]), "...", url)
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    if result.returncode != 0:
        print(result.stdout)
        print(result.stderr, file=sys.stderr)
        raise RuntimeError(f"Edge print failed with code {result.returncode}")
    if not pdf_path.exists() or pdf_path.stat().st_size < 1000:
        raise RuntimeError("PDF was not created or is too small.")
    print(f"Wrote {pdf_path} ({pdf_path.stat().st_size} bytes)")


def main() -> int:
    if not MD_PATH.exists():
        print(f"Missing {MD_PATH}", file=sys.stderr)
        return 1
    md_text = MD_PATH.read_text(encoding="utf-8")
    HTML_PATH.write_text(md_to_html(md_text), encoding="utf-8")
    print(f"Wrote {HTML_PATH}")
    html_to_pdf_edge(HTML_PATH, PDF_PATH)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
