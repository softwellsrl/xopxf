# XOPXF — eXtended Open Production eXchange Format

**An open, validatable interchange format for film and television production
financial documents — budgets, cost reports and their underlying detail —
exchanged between producers and commissioning parties (broadcasters,
co-producers, financiers).**

XOPXF is a *document format*, not a software product. Anyone may emit it, read
it, and adapt their tools to it. It is published openly so that production
financial data can travel between heterogeneous systems the way electronic
invoices already do — once, in a documented and verifiable shape.

---

## The problem

A film or TV production is governed by two financial documents that move
constantly between the people who make it and the people who pay for it: the
**budget** (the approved plan, which defines the chart of accounts) and the
periodic **cost report** (where the money has actually gone, measured against
that budget). Behind them sits a third layer — the **detail**: the individual
invoices, purchase orders and payroll entries that justify every figure.

Today these documents are exchanged almost entirely as **hand-made
spreadsheets**. Each producer has their own layout. A broadcaster financing ten
productions receives ten different shapes of the same information: fragile,
unversioned, impossible to validate, and impossible to compare or consolidate
without re-keying everything by hand. A single renamed column breaks a
downstream macro. There is no way for a machine to know whether a received cost
report is even internally consistent, let alone whether it lines up with the
budget it claims to measure.

## The gap

One would expect an open standard to already exist for this. It does not.

- **Movie Magic Budgeting** (`.mbb` / `.mmbx`) is the dominant budgeting tool,
  but its format is **proprietary and closed** — an export target, not an
  interchange standard you can read and validate independently.
- **AICP** and similar industry templates standardise a **spreadsheet layout**,
  not a data schema: they say where numbers go on a page, not what a machine
  should expect to parse.
- At the European level, the **EBU CCDM** (Tech 3351, the *Class Conceptual Data
  Model*) models `Contract` and `ContractCost` as a high-level **conceptual**
  ontology (RDF/OWL). It describes *what the concepts mean* but deliberately
  leaves the concrete financial **document** abstract — there is a conceptual
  model, but no actual file that travels between two parties and can be checked.

So the industry has a closed tool format, a page layout, and a high-level
ontology — but **no open, validatable data format for the actual interchange**
of production budgets and cost reports. That is the gap XOPXF fills.

## Why a common interchange format is the foundation

A shared, validatable document format is not a convenience — it is the
*precondition* for everything a commissioning party actually wants to do with
the numbers:

- **Analysis.** Once budgets and cost reports arrive in one documented shape,
  they become comparable across productions: cost ratios, above/below-the-line
  splits, variance trends — computed, not retyped.
- **Consolidation.** A broadcaster receiving weekly cost reports from many
  productions can aggregate them automatically into a single financial picture,
  instead of merging spreadsheets by hand and hoping the columns matched.
- **Co-productions.** When several partners — often in different countries,
  languages and accounting conventions — contribute to one production, they need
  to reconcile budgets whose charts of accounts and terminologies differ. Because
  XOPXF carries every classification *as declared data* (not as hard-wired
  national codes) and renders human-readable views in any language, each partner
  can keep their own coding and still exchange a document the others can read and
  validate.
- **Interoperability with existing models.** A concrete, validatable document is
  also the missing piece that makes a conceptual model like CCDM usable in
  practice: XOPXF is intended to be **mappable onto CCDM concepts**, giving the
  ontology a real file to point at.

None of this is possible while the data lives in ad-hoc spreadsheets. The format
comes first; the analysis, consolidation and reconciliation follow from it.

## What XOPXF is

XOPXF is a family of three related XML document types, each defined by an XML
Schema and rendered to readable HTML by an XSLT stylesheet:

| Document | Purpose |
|----------|---------|
| **[Budget](documents/budget.md)** | The approved estimate; defines the chart of accounts for a production. Versioned and immutable once confirmed. |
| **[Cost Report](documents/cost-report.md)** | Periodic statement of progress against a referenced budget revision — spent, committed, estimate to complete, variance. |
| **[Details](documents/details.md)** | The underlying analytic movements (invoices, purchase orders, payroll, variations) that justify a cost report. Provided on request, with built-in personal-data minimisation. |

The three are linked by reference: a cost report cites the budget revision it
measures against; details cite the cost report they explain.

Every document is **self-contained** (it carries its own vocabularies, so no
external lookup table is needed to read it), enforces **referential integrity**
in-schema (a dangling reference fails validation), and is **versioned** so
figures stay reproducible across reporting periods. See the
[Specification](specification.md) for the design in full.

!!! warning "Status: 0.1.0 (alpha draft)"
    XOPXF is an early draft. The three schemas are complete and validated, with
    worked examples and localized HTML views, but the format may still change
    within the `0.x` series. It is published now to invite review and adoption,
    not as a frozen standard.

## License

- **Schemas, stylesheets and example code** (`schema/`, `examples/`):
  Apache-2.0.
- **Documentation** (this site, `docs/`, the README): Creative Commons
  Attribution 4.0 International (CC-BY-4.0).

Proposed and maintained by **Softwell S.r.l.** See `NOTICE` for attribution.
