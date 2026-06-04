# Localization

XOPXF element and attribute names are English (the language of the standard).
The *data* stays in the issuer's language. What gets localized is the
**human-readable HTML view**: labels, column headings, and number formatting.

## How it works

The localized stylesheets are generated, not hand-maintained. The single source
of truth is:

1. a neutral **template** per view — `schema/*/<name>-html.template.xslt` —
   containing all the XSLT logic with `@@key@@` placeholders where text or a
   number separator should appear;
2. a **dictionary per language** — `l10n/labels-<lang>.json` — mapping each key
   to its translation.

`regen.py` substitutes the placeholders and writes one stylesheet per
(template × language) under each schema's `generated/` folder:

```console
$ python regen.py
Generated 24 localized stylesheets (4 templates x 6 languages).
```

Shipped languages: **English, Italian, French, German, Chinese, Korean**.

- **Add a language** — drop a new `l10n/labels-<lang>.json` with the same keys as
  `labels-en.json` and re-run `regen.py`.
- **Change a view** — edit the `*.template.xslt` and re-run; every language
  realigns. Never edit the generated copies.

`regen.py` enforces that every dictionary covers the English key set, and that no
placeholder is left unresolved — a missing key or a typo fails the build.

## Number formatting

Decimal and grouping separators are themselves localized, via three keys per
dictionary:

| Key | en | it | fr |
|-----|----|----|----|
| `num_decimal` | `.` | `,` | `,` |
| `num_grouping` | `,` | `.` | (non-breaking space) |
| `num_pattern` | `#,##0.00` | `#.##0,00` | `# ##0,00` |

So the same figure renders as `2,819,200.00` (en, zh, ko), `2.819.200,00`
(it, de) or `2 819 200,00` (fr). The pattern and the separators must agree,
because in XSLT `format-number` interprets the pattern's symbols according to the
active `decimal-format`; both are driven from the dictionary so they stay
consistent.

## From XML to HTML

`render_examples.py` applies the generated stylesheets to the example documents
and writes the localized HTML plus a per-folder `index.html` linking the
languages side by side:

```console
$ python render_examples.py
Rendered 35 HTML files (7 views x 5 languages) and 3 indexes.
```

The indexes link five languages (Chinese included); all six stylesheets are
generated regardless.
