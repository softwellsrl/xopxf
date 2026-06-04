# Specification

This page describes the design shared by all three XOPXF documents. For the
field-level detail of each, see the [Budget](documents/budget.md),
[Cost Report](documents/cost-report.md) and [Details](documents/details.md)
pages; the XSD files under `schema/` are the normative reference.

## Design principles

1. **Self-contained.** Every code a document references (cost groups, phases,
   departments, roles, detail/movement types, tax rates, counterparties…) is
   declared in the document's own `<Header>`. No external lookup table or shared
   database is required to read it. The vocabulary is frozen together with the
   revision it describes.
2. **No national taxonomy hard-wired.** There are no country-specific account
   codes baked into the schema. Issuers declare their own codes; classifications
   such as above/below-the-line are carried as *data*, not assumed by the format.
3. **Profiles, not separate formats.** Budget and Cost Report each come in a
   *synthetic* and an *analytic* form; the analytic form adds one optional level
   of detail. One schema validates both, and analytic always degrades to
   synthetic by summation. (Details is analytic only — see below.)
4. **Versioned and immutable.** A budget travels as a confirmed revision. Cost
   reports reference a budget by *(production, revision number)*, so figures are
   reproducible and comparable across reporting periods.

## Common structure: Header + Body

Every document has the same top-level shape:

```xml
<Document version="0.1.0" language="en">
  <Header> … metadata + vocabularies … </Header>
  <Body>   … data that references the header by code … </Body>
</Document>
```

- The **Header** carries transmission metadata (sender, recipient, document id,
  issue date), the production identity, the inter-document references, and the
  **vocabularies** the body uses — groups, departments, producers, roles, type
  lists, tax rates, and so on. Vocabulary containers are optional: a minimal
  document declares only the few it needs.
- The **Body** carries the figures, organised as `Chapter > Account > …`, and
  references the header vocabularies by `code`.

## Referential integrity

The XSD enforces not only structure but **referential integrity** via XML Schema
`key` / `keyref`: every code used in the body (a group, role, type, tax rate…)
must be declared in the header, so a document with a dangling reference is
**rejected** by the validator.

!!! note "XPath namespace prefixes"
    Identity-constraint XPaths (`xs:selector` / `xs:field`) do not use the
    default namespace: an unprefixed name matches elements in *no* namespace.
    Because XOPXF elements live in a target namespace, every selector is written
    with an explicit prefix (e.g. `b:Header/b:Groups/b:Group`). Without the
    prefix the keys would match nothing and the constraints would be inert.

## Profiles: synthetic vs analytic

- **Synthetic** — figures sit directly on the `Account` (Budget: `Detail` lines
  under the account; Cost Report: a `Figures` block on the account).
- **Analytic** — an extra level breaks the account down (Budget: `Item` by
  department/producer; Cost Report: `Line`). The account total is the sum of its
  breakdown.

An analytic document always reduces to the equivalent synthetic one by summing
the breakdown level, so the two profiles describe the *same* totals at different
granularity. **Details** has no synthetic/analytic distinction, but carries its
own pair of interchangeable shapes — `hierarchical` (the `Chapter > Account`
tree) and `flat` (a single list of movements, each carrying its own
`chapterCode`/`accountCode`). Both sum to the same totals; the flat form is the
tabular, CSV-friendly projection.

## Tags and cross-document consistency

Beyond chapters, accounts and grouping axes, a line can carry **tags** — free,
cross-cutting labels orthogonal to the chart of accounts (e.g. tax-credit
eligibility, reshoot). Tags are declared in a header `<Tags>` vocabulary and
applied with repeatable `<TagRef tag="…"/>` elements on a budget `Detail`/`Item`
or a details `Movement`; the reference is enforced against the header like any
other code.

The **Budget is the authority** for the tag vocabulary. A Cost Report or Details
document that uses tags **redeclares** the subset it needs in its own header — so
it remains self-contained — and that redeclaration **MUST** be consistent (same
`code`, `name`, `scheme`) with the budget revision it references.

Consistency *across* documents is beyond what XML Schema can check (an XSD
validates one document against one schema, not two documents against each other).
It is therefore a **normative rule verified by importers**: a system ingesting a
Details document checks its tag declarations — and its chapter/account codes —
against the referenced budget and reports any mismatch. The same applies to other
redeclared vocabularies.

## Inter-document references

- A **Cost Report** carries a `BudgetReference` (`productionCode` + `revision`)
  pointing at the immutable confirmed budget revision it measures against, and an
  optional `PreviousReport` for week-over-week benchmark figures.
- A **Details** document carries both a `BudgetReference` and a
  `CostReportReference` (`documentId` + `number` + `asOf`) pointing at the cost
  report whose figures its movements justify.

## Localization

Element and attribute names are **English** (the language of the standard). The
*data* (descriptions, names) stays in the issuer's language, declared by the
`language` attribute on the root. Human-readable HTML views are localized
independently: see [Localization](localization.md). Number formatting (decimal
and grouping separators) is per-language, so the same figures render as
`2,819,200.00`, `2.819.200,00` or `2 819 200,00` according to locale.

## Versioning

The format follows semantic versioning; backward compatibility is intended
within a major version. The current release is **0.1.0 (alpha draft)** — the
schemas are complete and validated, but the shape may still change within the
`0.x` series. Namespaces carry the major version (`urn:xopxf:budget:1.0`,
`urn:xopxf:costreport:1.0`, `urn:xopxf:details:1.0`).
