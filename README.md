# XOPXF — eXtended Open Production eXchange Format

**An open, validatable interchange format for film/TV production financial
documents — budgets, cost reports and their underlying detail — exchanged
between producers and commissioning parties (broadcasters, co-producers,
financiers).**

XOPXF is a document format, not a software product. Anyone may emit it, read it,
and adapt their tools to it. It is published openly so that production financial
data can travel between heterogeneous systems the way electronic invoices already
do — once, in a documented and verifiable shape — instead of as fragile,
hand-made spreadsheets.

## Why

Production budgets and weekly cost reports are exchanged today mostly as Excel
files: fragile, unversioned, unvalidated, and impossible to compare or
consolidate automatically. A dominant budgeting tool format exists
(Movie Magic `.mbb`) but it is **proprietary and closed**, and layout standards
(e.g. AICP) are **spreadsheet templates, not data schemas**. At the European
level, EBU CCDM models contracts and costs only at a high conceptual level.

There is **no open, validatable data format** for the actual interchange of
production budgets and cost reports. XOPXF fills that gap.

## Design principles

1. **Self-contained.** Every code a document references (cost groups, phases,
   departments, detail types, tax rates…) is declared in the document's own
   `<Header>`. No external lookup tables or shared database are required to read
   it. The vocabulary is frozen together with the budget revision it describes.
2. **No national taxonomy hard-wired.** There are no country-specific account
   codes baked into the schema. Issuers declare their own codes; classifications
   such as above/below-the-line are carried as data, not assumed.
3. **Profiles, not separate formats.** A document is *synthetic* or *analytic*;
   the analytic form adds one extra level of detail. The same schema validates
   both, and analytic always degrades to synthetic by summation.
4. **Versioned and immutable.** A budget travels as a confirmed revision. Cost
   reports reference a budget by *(production, revision number)*, so figures are
   always reproducible and comparable across reporting periods.

## The three documents

XOPXF is a family of three related document types:

| Document | Purpose | Status |
|----------|---------|--------|
| **Budget** | The approved estimate; defines the chart of accounts for a production. Versioned. | ✅ draft schema + examples |
| **Cost Report** | Periodic statement of progress against a referenced budget revision (spent, committed, estimate to complete, variance). | 🚧 in progress |
| **Details** | The underlying analytic movements (invoices, purchase orders, payroll, variations) that justify a cost report. Provided on request. | ⏳ planned |

The three are linked by reference: a cost report cites the budget revision it
measures against; details cite the cost report they explain.

## Relationship to existing work

- **Movie Magic (`.mbb`/`.mmbx`)** — proprietary budgeting tool format. XOPXF is
  an open interchange layer *alongside* such tools, not a replacement for them; a
  tool can export to XOPXF.
- **EBU CCDM (Tech 3351)** — conceptual RDF/OWL model with high-level
  `Contract`/`ContractCost` classes. XOPXF is complementary: it is the concrete,
  validatable *document* format for the financial domain CCDM leaves abstract,
  and is intended to be mappable onto CCDM concepts.

## Repository layout

```
schema/
  budget/
    budget.xsd          XML Schema for the Budget document
    budget-html.xslt    XSLT: render a budget body as readable HTML
    header-html.xslt    XSLT: render the header / data dictionary as HTML
examples/
  budget/
    analytic-example.xml    full (analytic) sample budget
    synthetic-example.xml    same budget, synthetic profile (same total)
    *.html                   pre-rendered HTML of the above
docs/                    specification prose (to come)
```

## Validating and rendering

XOPXF documents are plain XML validated with any standard XSD validator and
rendered with any XSLT 1.0 processor. With Python and `lxml`:

```python
from lxml import etree
schema = etree.XMLSchema(etree.parse("schema/budget/budget.xsd"))
doc = etree.parse("examples/budget/analytic-example.xml")
assert schema.validate(doc)            # structural + referential integrity

xslt = etree.XSLT(etree.parse("schema/budget/budget-html.xslt"))
open("budget.html", "w").write(str(xslt(doc)))   # human-readable view
```

The XSD enforces not only structure but **referential integrity**: any code used
in the body (a group, phase, detail type, tax rate…) must be declared in the
header, so a document with a dangling reference is rejected.

## Status

Draft, version `1.0`. The Budget schema is complete and validated; Cost Report
and Details are in progress. The format is versioned; backward compatibility is
intended within a major version.

## License

- **Schemas, stylesheets and example code** (`schema/`, `examples/`): Apache-2.0
  — see [`LICENSE`](LICENSE).
- **Documentation prose** (`docs/`, this README): Creative Commons Attribution
  4.0 International (CC-BY-4.0) — see [`LICENSE-docs`](LICENSE-docs).

See [`NOTICE`](NOTICE) for attribution.
