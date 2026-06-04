# Details

The underlying analytic movements — invoices, purchase orders, payroll, variations
— that justify a cost report. Provided **on request**, because this document can
carry personal data (payroll), and with personal-data minimisation built into the
format.

- Namespace: `urn:xopxf:details:1.0`
- Schema: `schema/details/details.xsd`
- Examples: `examples/details/full-example.xml` (with the counterparty
  registry), `minimized-example.xml` (same body, registry omitted)

## Analytic only

Unlike Budget and Cost Report, Details has **no synthetic/analytic profile**: it
is by nature the list of individual movements. Summing the movements reconstructs
the cost report figures, so a "synthetic details" would have no meaning.

## Structure

```
Details (@version @language)
  Header
    Transmission
    Production
    BudgetReference         @productionCode @revision
    CostReportReference     @documentId @number @asOf   (what these movements explain)
    Groups* Departments* Producers* Roles*
    MovementTypes*          e.g. INV / PO / PAY / VAR; @payroll flags personal-data lines
    Parties*                the counterparty registry — OPTIONAL (see below)
  Body
    Chapter (@code @name)
      GroupRef*
      Account (@code @name @externalCode)
        Movement+
```

A `Movement` carries `type` (→ `MovementType`), `date`, amounts (`spent`,
`ordered`, and an optional `net`/`charges`/`gross`/`vat`/`withholding`
breakdown), references (`role`, `department`, `producer`, `itemRef`), source
document coordinates (`documentNumber`, `documentDate`), and an optional
`<Document url="…">` link to the source PDF (invoice, payslip, PO).

## Counterparties and data minimisation

This is the design pivot of the Details document.

**The body never carries a counterparty name inline.** Each movement carries at
most a `payeeRef` — an opaque code (a registry / payroll number, a *matricola*).
Identifying data lives in the optional `Parties` vocabulary in the header: one
entry per code, **person or company**, with the identifying fields all optional
(`legalName`, `personName`, `taxId`, `vatId`, `city`, and a `role` for a person).

Minimisation is therefore a **transmission choice**, not a rewrite of the data:

| Sent | Result |
|------|--------|
| Header **with** `Parties` + Body | the reader resolves each code to a name (and city) |
| Body only (`Parties` omitted) | only the codes travel; names never leave the issuer |

The **same body** is valid in both cases. The two shipped examples are identical
except for the presence of `Parties` — the full one shows `Eleanor Vance`,
`Apex Camera Rental Ltd`, …; the minimised one shows only `P0101`, `C2001`, …
and a note explaining that the registry was withheld.

!!! note "Soft reference by design"
    Because `Parties` is optional, `payeeRef` is intentionally **not** enforced
    by `keyref` — enforcing it would forbid the minimised form. The reference is
    "soft": it can be checked by external tools when the registry is present.
    Every *other* reference in the document (movement type, role, department,
    producer, group) is fully enforced by the schema.

This maps directly onto the way a production accounting system already unifies
the underlying movement: one record with a type, spent/ordered amounts, an
optional payee identified by code, and a link to the source document — with the
name resolved (or not) at presentation time.

## Mapping note

`MovementType` codes are free and declared by the issuer; the `@payroll` flag
lets a reader apply stricter handling to personal-data movements regardless of
the code chosen.
