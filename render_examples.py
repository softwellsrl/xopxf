#!/usr/bin/env python3
"""Render the example XML documents to localized HTML and build per-folder indexes.

The localized stylesheets are produced by regen.py (template + dictionaries).
This script applies them to the example documents and writes, for each example
and language, a standalone HTML file, plus an index.html per examples/ subfolder
linking the languages side by side.

    python render_examples.py            # render all
    python render_examples.py --check    # validate examples, render to a temp
                                          # dir and diff (no writes) [not yet]

Pipeline: regen.py  (templates -> schema/*/generated/*-<lang>.xslt)
          render_examples.py  (examples + generated XSLT -> examples/**/*.html)

The languages shown in the indexes are LANGS below (5, Chinese included). All
six generated stylesheets exist; the index simply links five of them.
"""
import sys
from pathlib import Path

try:
    from lxml import etree
except ImportError:
    sys.exit("render_examples.py requires lxml (pip install lxml).")

ROOT = Path(__file__).resolve().parent

# Languages linked from the indexes, in display order (Chinese included).
LANGS = ["en", "zh", "it", "fr", "ko"]
LANG_NAMES = {"en": "English", "zh": "中文", "it": "Italiano",
              "fr": "Français", "ko": "한국어", "de": "Deutsch"}

# One render = (source XML, stylesheet basename, output basename).
# stylesheet resolves to schema/<dir>/generated/<basename>-<lang>.xslt.
# A single XML can feed two views (e.g. budget body + header dictionary).
RENDERS = [
    # budget: body view + header/data-dictionary view, from the same documents
    ("examples/budget/analytic-example.xml",  "schema/budget/generated/budget-html",  "examples/budget/analytic-example"),
    ("examples/budget/synthetic-example.xml", "schema/budget/generated/budget-html",  "examples/budget/synthetic-example"),
    ("examples/budget/analytic-example.xml",  "schema/budget/generated/header-html",  "examples/budget/header-example"),
    # cost report
    ("examples/cost-report/analytic-example.xml",  "schema/cost-report/generated/cost-report-html",  "examples/cost-report/analytic-example"),
    ("examples/cost-report/synthetic-example.xml", "schema/cost-report/generated/cost-report-html",  "examples/cost-report/synthetic-example"),
    # details: full (with Parties) and minimized (without)
    ("examples/details/full-example.xml",      "schema/details/generated/details-html",  "examples/details/full-example"),
    ("examples/details/minimized-example.xml", "schema/details/generated/details-html",  "examples/details/minimized-example"),
    ("examples/details/flat-example.xml",      "schema/details/generated/details-html",  "examples/details/flat-example"),
]


def render_one(src, xslt_base, out_base):
    doc = etree.parse(str(ROOT / src))
    produced = []
    for lang in LANGS:
        xslt_path = ROOT / f"{xslt_base}-{lang}.xslt"
        transform = etree.XSLT(etree.parse(str(xslt_path)))
        html = transform(doc)
        out = ROOT / f"{out_base}-{lang}.html"
        out.write_bytes(etree.tostring(html, method="html",
                                       encoding="UTF-8", pretty_print=True))
        produced.append((lang, out))
    return produced


def write_index(folder, entries):
    """entries: list of (out_base_relative, set_of_langs). One block per example."""
    rows = []
    for base, langs in entries:
        title = Path(base).name
        links = " &middot; ".join(
            f'<a href="{Path(base).name}-{l}.html">{LANG_NAMES[l]}</a>'
            for l in LANGS if l in langs
        )
        rows.append(f"      <li><span class='ex'>{title}</span> {links}</li>")
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>XOPXF examples &ndash; {folder.name}</title>
  <style>
    body {{ font-family: -apple-system, Segoe UI, Roboto, sans-serif; margin: 32px; color: #222; }}
    h1 {{ font-size: 20px; }}
    ul {{ list-style: none; padding: 0; }}
    li {{ padding: 8px 0; border-bottom: 1px solid #eee; }}
    .ex {{ display: inline-block; min-width: 220px; font-weight: 600; font-family: ui-monospace, monospace; }}
    a {{ color: #2471a3; text-decoration: none; margin-right: 4px; }}
    a:hover {{ text-decoration: underline; }}
  </style>
</head>
<body>
  <h1>XOPXF examples &ndash; {folder.name}</h1>
  <ul>
{chr(10).join(rows)}
  </ul>
</body>
</html>
"""
    (folder / "index.html").write_text(html, encoding="UTF-8")


def main():
    # group produced outputs by folder for the indexes
    by_folder = {}
    total = 0
    for src, xslt_base, out_base in RENDERS:
        produced = render_one(src, xslt_base, out_base)
        total += len(produced)
        folder = (ROOT / out_base).parent
        by_folder.setdefault(folder, []).append(
            (out_base, {l for l, _ in produced})
        )

    for folder, entries in by_folder.items():
        write_index(folder, entries)

    print(f"Rendered {total} HTML files "
          f"({len(RENDERS)} views x {len(LANGS)} languages) "
          f"and {len(by_folder)} indexes.")


if __name__ == "__main__":
    main()
