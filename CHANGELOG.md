# Changelog

All notable changes to the XOPXF format are documented here. The format follows
semantic versioning; backward compatibility is intended within a major version.

## [Unreleased]

### Added

- **Budget** document, version `1.0` (draft):
  - XML Schema `schema/budget/budget.xsd` with self-contained `<Header>`
    (vocabularies) and `<Header>`/`<Body>` separation.
  - Synthetic and analytic profiles (the analytic profile adds the optional
    `<Item>` level between `<Account>` and `<Detail>`).
  - Multi-axis chapter grouping via `<GroupRef>` referencing `<Group>` entries
    that carry a `scheme`.
  - Referential integrity enforced in-schema (key/keyref) between body
    references and header vocabularies.
  - XSLT stylesheets: `budget-html.xslt` (budget body) and `header-html.xslt`
    (header / data dictionary).
  - Worked examples: analytic and synthetic samples (same total), with rendered
    HTML.
- Namespace: `urn:xopxf:budget:1.0`.
- **Cost Report** document, version `1.0` (draft):
  - XML Schema `schema/cost-report/cost-report.xsd`, same Header/Body design and
    synthetic/analytic profiles as Budget (the analytic profile breaks figures
    down per `<Line>`; synthetic carries them on the `<Account>`).
  - `<BudgetReference>` linking the report to a specific confirmed budget
    revision (production code + revision number).
  - Per-line metrics: budget, spentToDate, committed, costToDate, reserve, efc,
    variance, estToComplete; optional `<Benchmark>` (pastEfc, pastVariance,
    movement) against a referenced previous report.
  - XSLT `cost-report-html.xslt` rendering the report with overrun highlighting.
  - Worked analytic and synthetic examples (same budget total), with HTML.
  - Namespace: `urn:xopxf:costreport:1.0`.

### Planned

- **Details** document and schema (analytic movements, provided on request).
- Specification prose under `docs/`.
- Mapping notes to EBU CCDM (`Contract` / `ContractCost`).
