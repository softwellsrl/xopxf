# XOPXF — eXtended Open Production eXchange Format

**An open, validatable interchange format for film/TV production financial
documents — budgets, cost reports and their underlying detail — exchanged
between producers and commissioning parties (broadcasters, co-producers,
financiers).**

XOPXF is a document format, not a software product. Anyone may emit it, read it,
and adapt their tools to it. It is published openly so that production financial
data can travel between heterogeneous systems the way electronic invoices already
do — once, in a documented and verifiable shape.

## Why this exists

Production budgets and weekly cost reports are exchanged today almost entirely as
**hand-made spreadsheets**: fragile, unversioned, unvalidated, and impossible to
compare or consolidate automatically. Each producer has its own layout, so a
broadcaster financing ten productions receives ten different shapes of the same
information.

One would expect an open standard to already exist. It does not:

- **Movie Magic** (`.mbb` / `.mmbx`) is the dominant budgeting tool, but its
  format is **proprietary and closed**.
- **AICP** and similar standardise a **spreadsheet layout**, not a data schema.
- **EBU CCDM** (Tech 3351) models `Contract` / `ContractCost` only at a
  high-level **conceptual** layer (RDF/OWL), leaving the concrete financial
  *document* abstract.

So there is a closed tool format, a page layout, and a high-level ontology — but
**no open, validatable data format for the actual interchange** of production
budgets and cost reports. XOPXF fills that gap.

A common interchange format is the precondition for what commissioning parties
actually want to do with the numbers: **analysis** comparable across productions,
automatic **consolidation** of many cost reports, and **co-productions** where
partners in different countries, languages and accounting conventions reconcile
budgets — each keeping their own codes (carried as data, not hard-wired) and
their own language (HTML views are localized). It is also the concrete document a
conceptual model like CCDM can be mapped onto.

→ The full rationale is in the [documentation](docs/index.md).

## The three documents

XOPXF is a family of three related document types, linked by reference: a cost
report cites the budget revision it measures against; details cite the cost
report they explain.

| Document | Purpose | Status |
|----------|---------|--------|
| **Budget** | The approved estimate; defines the chart of accounts for a production. Versioned. | ✅ draft schema + examples |
| **Cost Report** | Periodic statement of progress against a referenced budget revision (spent, committed, estimate to complete, variance). | ✅ draft schema + examples |
| **Details** | The underlying analytic movements (invoices, purchase orders, payroll, variations) that justify a cost report, with built-in personal-data minimisation. | ✅ draft schema + examples |

## Design principles

1. **Self-contained.** Every code a document references (groups, departments,
   roles, types, tax rates, counterparties…) is declared in the document's own
   `<Header>`. No external lookup table or shared database is required to read it.
2. **No national taxonomy hard-wired.** Issuers declare their own codes;
   classifications such as above/below-the-line are carried as data.
3. **Profiles, not separate formats.** Budget and Cost Report come in a
   *synthetic* and an *analytic* form; one schema validates both, and analytic
   degrades to synthetic by summation. (Details is analytic only.)
4. **Versioned and immutable.** A budget travels as a confirmed revision; cost
   reports reference it by *(production, revision number)*.
5. **Referentially validated.** The XSD enforces `key`/`keyref` integrity: a code
   used in the body but not declared in the header makes the document invalid.

## Repository layout

```text
schema/
  budget/        budget.xsd, *-html.template.xslt, generated/*-<lang>.xslt
  cost-report/   cost-report.xsd, template, generated/
  details/       details.xsd, template, generated/
examples/
  budget/        analytic / synthetic .xml + localized .html + index.html
  cost-report/   analytic / synthetic .xml + localized .html + index.html
  details/       full / minimized .xml + localized .html + index.html
l10n/            labels-<lang>.json dictionaries (en, it, fr, de, zh, ko)
docs/            documentation (MkDocs site; published prose under CC-BY-4.0)
regen.py         templates + dictionaries -> localized XSLT
render_examples.py   examples + XSLT      -> localized HTML + indexes
```

## Validating and rendering

```python
from lxml import etree
schema = etree.XMLSchema(etree.parse("schema/budget/budget.xsd"))
doc = etree.parse("examples/budget/analytic-example.xml")
assert schema.validate(doc)                       # structure + referential integrity

xslt = etree.XSLT(etree.parse("schema/budget/generated/budget-html-en.xslt"))
open("budget.html", "w").write(str(xslt(doc)))    # human-readable view
```

The toolchain:

```console
$ python regen.py            # -> 24 localized stylesheets (4 templates x 6 languages)
$ python render_examples.py  # -> 35 HTML files (7 views x 5 languages) + 3 indexes
```

See [Validating & rendering](docs/validating.md) and
[Localization](docs/localization.md) for detail.

## Documentation

Full documentation lives under [`docs/`](docs/index.md) (an MkDocs site):
the [specification](docs/specification.md), a page per document
([Budget](docs/documents/budget.md), [Cost Report](docs/documents/cost-report.md),
[Details](docs/documents/details.md)), [localization](docs/localization.md),
[validating & rendering](docs/validating.md), and the [FAQ](docs/faq.md).

## Status

Draft, version **0.1.0 (alpha)**. The three schemas are complete and validated,
with worked examples and localized HTML views in six languages. The format may
still change within the `0.x` series; backward compatibility is intended within a
major version once stable.

## License

- **Schemas, stylesheets and example code** (`schema/`, `examples/`): Apache-2.0
  — see [`LICENSE`](LICENSE).
- **Documentation** (`docs/`, this README): Creative Commons Attribution 4.0
  International (CC-BY-4.0) — see [`LICENSE-docs`](LICENSE-docs).

See [`NOTICE`](NOTICE) for attribution. Proposed and maintained by Softwell S.r.l.
