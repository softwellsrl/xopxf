# The Excel on-ramp: converting non-conforming sources

This page frames a real adoption problem and the model XOPXF proposes to solve
it. It is design rationale, not normative specification.

## The problem

XOPXF assumes the issuer can produce a conformant XML document — natively from
their management software, or via an export. In practice, **not every producer
will adapt on day one.** Today production budgets and cost reports travel as
hand-made spreadsheets, each producer with its own layout. Telling them all
"emit XOPXF or you are out" is unrealistic as a starting condition.

So there is a transition gap: the standard exists, but some participants still
only have an Excel file.

If that gap is left unmanaged, one of two bad things happens:

1. **Adoption stalls** — producers keep sending spreadsheets and the standard is
   never used in practice; or
2. **The fragility comes back** — someone hand-copies the spreadsheet into the
   system, reintroducing exactly the manual, error-prone, unvalidated step the
   standard was meant to remove.

## Why a generic "Excel → XML" converter is not the answer

It is tempting to imagine one universal converter that turns "any Excel" into
XOPXF. That recreates the original fragility:

- every producer's spreadsheet has different sheets, columns, header rows,
  conventions;
- a converter that tries to accept all of them is guessing, and guessing on
  financial data is unacceptable;
- the spreadsheet is *precisely* the thing the standard exists to eliminate, so a
  permanent, blessed Excel channel undermines the goal.

A converter is therefore only acceptable under three constraints:

1. **Per-source, not universal.** Conversion is configured against *one*
   producer's specific, known layout — not "whatever arrives".
2. **Explicitly transitional.** It is an *on-ramp*: a bridge while a participant
   moves toward native XOPXF, not a permanent parallel channel. Converted output
   should be marked as originating from a conversion.
3. **Conversion = validation.** The converter does not merely translate; it
   **validates the result against the XSD and runs diagnostics**. If the source
   has an unknown account code, a total that does not add up, a missing VAT id or
   a broken reference, conversion **fails with a precise message** instead of
   emitting wrong XML. The undisciplined spreadsheet is disciplined at the gate.

## The proposed model: a paid, bespoke conversion service

The clean separation:

- **The standard stays open and free** — the XSDs, stylesheets and docs are the
  public good that drives adoption and credibility.
- **A bespoke Excel→XML converter is a paid service.** For each producer that
  will not (yet) adapt, an adapter is built/configured from *their* specific Excel
  to XOPXF, with error diagnostics. This is legitimate, billable adaptation work,
  and it is what makes clean data reach the commissioning party.

This is the well-established pattern of open standards: **open format, paid
tooling and services.** The format creates the market; conversion is one of the
services around it (alongside reading/consolidation tools).

### Architecture that keeps each bespoke converter cheap to produce

The cost of "bespoke" is controlled by separating two layers:

- **One reusable engine** (written once): reads the workbook, applies a mapping,
  validates against the XSD, and produces *(XML, diagnostic report)*. This is not
  rewritten per customer.
- **A per-producer mapping** (the bespoke part, quick to author): a configuration
  describing *this* producer's layout — e.g. "sheet `Costs`, account code in
  column C, net amount in column F, data starts at row 4, this column is the cost
  group". A new producer means writing only the mapping, not a new program.

So the service is sold as a "dedicated adapter" while internally it is mostly
configuration over a shared engine — exactly how electronic-invoicing converters
handle heterogeneous accounting packages.

### Diagnostics: the part the buyer actually values

The converter's diagnostic report is a **data-quality** instrument for the
commissioning party, not just a translation log. It should surface, at two
severities:

- **Blocking errors** (no XML is produced until fixed):
  - account/chapter code not present in the referenced budget revision;
  - detail totals that do not reconcile to the account/chapter total — the very
    check that is impossible on a free spreadsheet today;
  - missing mandatory fields (amounts, VAT id, dates);
  - references that do not resolve (a cost report line citing a budget item that
    does not exist).
- **Warnings** (XML is produced, but flagged):
  - duplicate rows, out-of-range values, unusual concentrations, format anomalies.

The converter thus doubles as the **admissibility gate** for incoming data: the
commissioning party receives clean, validated XOPXF without manual checking.

## What lives where

Because the bespoke converter is a commercial product, it is **not** part of the
public XOPXF repository:

- **Public repo (this standard):** at most the *specification of the mapping
  format* and a minimal **reference converter** as an open example. The standard
  documents how conversion should behave (per-source, transitional,
  validate-and-diagnose) without shipping the production-grade tool.
- **Private / commercial:** the robust engine, the advanced diagnostics, and the
  per-producer mappings — offered as a paid service by the standard's proposer.

## Relationship to the rest of XOPXF

- A converted document is an ordinary XOPXF document: once produced and validated,
  it is indistinguishable downstream from one emitted natively (save for an
  optional origin marker).
- The on-ramp applies to **Budget** and **Cost Report**. The **Details** document
  carries personal data (counterparties, payroll) and already supports
  minimisation; converting a spreadsheet of details inherits those concerns and
  should be approached only with the data-minimisation rules in mind.
- A real starting template exists for the cost report (the multi-sheet
  "Master Cost Report" spreadsheet observed in the field), which is a natural
  first *known layout* to support — strictly as a controlled, per-source mapping.

## Status

Design note. No converter is implemented in this repository. This page records
the intended model so the boundary between the open standard and the paid
conversion service stays explicit.
