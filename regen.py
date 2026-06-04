#!/usr/bin/env python3
"""Regenerate the localized XSLT stylesheets from the neutral templates.

Single source of truth: the *.template.xslt files (logic + @@key@@ placeholders)
and the per-language dictionaries in l10n/labels-<lang>.json. Running this script
rewrites every localized stylesheet under each schema's generated/ folder.

    python regen.py

Add a language: drop a new l10n/labels-<lang>.json (same keys as labels-en.json).
Change a template: edit the *.template.xslt and re-run; all languages realign.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
L10N = ROOT / "l10n"

# (template path, output basename) — one entry per stylesheet to localize.
TEMPLATES = [
    ("schema/budget/budget-html.template.xslt",            "budget-html"),
    ("schema/budget/header-html.template.xslt",            "header-html"),
    ("schema/cost-report/cost-report-html.template.xslt",  "cost-report-html"),
    ("schema/details/details-html.template.xslt",          "details-html"),
]

PLACEHOLDER = re.compile(r"@@([a-zA-Z0-9_]+)@@")


def load_labels():
    langs = {}
    for f in sorted(L10N.glob("labels-*.json")):
        data = json.loads(f.read_text(encoding="utf-8"))
        lang = data.get("_lang") or f.stem.split("-", 1)[1]
        langs[lang] = data
    if not langs:
        sys.exit("No l10n/labels-*.json dictionaries found.")
    return langs


def render(template_text, labels, where):
    missing = set()

    def sub(m):
        key = m.group(1)
        if key not in labels:
            missing.add(key)
            return m.group(0)
        return labels[key]

    out = PLACEHOLDER.sub(sub, template_text)
    if missing:
        sys.exit(f"{where}: missing label keys: {sorted(missing)}")
    return out


def main():
    langs = load_labels()
    # English is the reference key set; every dictionary must cover it.
    ref_keys = {k for k in langs.get("en", {}) if not k.startswith("_")}
    for lang, labels in langs.items():
        have = {k for k in labels if not k.startswith("_")}
        if ref_keys - have:
            sys.exit(f"labels-{lang}.json is missing keys: {sorted(ref_keys - have)}")

    count = 0
    for tpl_rel, base in TEMPLATES:
        tpl = ROOT / tpl_rel
        text = tpl.read_text(encoding="utf-8")
        outdir = tpl.parent / "generated"
        outdir.mkdir(exist_ok=True)
        for lang, labels in langs.items():
            rendered = render(text, labels, f"{base}/{lang}")
            leftover = PLACEHOLDER.findall(rendered)
            if leftover:
                sys.exit(f"{base}-{lang}: unresolved placeholders {leftover}")
            out = outdir / f"{base}-{lang}.xslt"
            out.write_text(rendered, encoding="utf-8")
            count += 1
    print(f"Generated {count} localized stylesheets "
          f"({len(TEMPLATES)} templates x {len(langs)} languages).")


if __name__ == "__main__":
    main()
