# Cost Report

A periodic statement of financial progress for a production, measured against a
specific confirmed budget revision — the producer's "state of work" delivered to
the commissioning party.

- Namespace: `urn:xopxf:costreport:1.0`
- Schema: `schema/cost-report/cost-report.xsd`
- Examples: `examples/cost-report/analytic-example.xml`, `synthetic-example.xml`

## Relationship to the budget

A cost report does **not** redefine the chart of accounts. It references a budget
revision via `BudgetReference` (production code + revision number) and reports
figures against the chapters and accounts that revision declared. The codes used
are expected to exist in that budget revision.

## Structure

```text
CostReport (@version @profile @language)
  Header
    Transmission
    Production
    BudgetReference   @productionCode @revision   (the immutable revision)
    Reporting         @number @asOf @fromDate @toDate
    PreviousReport?   the prior report, for benchmark figures
    Groups* Departments* Producers*
  Body
    Chapter (@code @name)
      GroupRef*
      Account (@code @name @externalCode)
        Figures           (synthetic) — or —
        Line+             (analytic: @ref @department @producer)
          Figures
```

## Metrics

`Figures` carries the cost report metrics:

| Attribute | Meaning |
|-----------|---------|
| `budget` | approved budget for the line (required) |
| `spentToDate` | actual cost incurred to date |
| `committed` | open commitments (e.g. POs not yet invoiced) |
| `costToDate` | `spentToDate` + `committed` |
| `reserve` | contingency/reserve carried on the line |
| `efc` | estimate of final cost |
| `variance` | `budget − efc` (negative = overrun) |
| `estToComplete` | `efc − costToDate` |

An optional `Benchmark` sub-element compares against the previous report
(`pastEfc`, `pastVariance`, `movement`).

## The two profiles

- **Synthetic** — `Figures` sits directly on the `Account`.
- **Analytic** — one or more `Line` breakdowns (by department / producer), each
  with its own `Figures`; the account total is the sum of its lines.

The HTML view highlights negative variance (overrun) and resolves group,
department and producer references to their declared names.
