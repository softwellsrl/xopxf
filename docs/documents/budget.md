# Budget

The approved estimate for a production. The budget **defines the chart of
accounts** (chapters and accounts) that the cost report and details later
reference, and it travels as a **confirmed, immutable revision**.

- Namespace: `urn:xopxf:budget:1.0`
- Schema: `schema/budget/budget.xsd`
- Examples: `examples/budget/analytic-example.xml`, `synthetic-example.xml`

## Structure

```text
Budget (@version @profile @language)
  Header
    Transmission        sender / recipient / documentId / issueDate
    Production           code / title / episodes / dates / currency
    Revision             @number @status(draft|confirmed) @date …
    Groups*              grouping axes (e.g. above/below-the-line) with @scheme
    Phases* Departments* Producers* Roles* UnitsOfMeasure*
    DetailTypes*         nature of a line; @contingency marks a reserve
    VatRates* WithholdingRates*
  Body
    Chapter (@code @name)
      GroupRef*          chapter membership in one or more groups
      Account (@code @name @externalCode)
        Detail+          (synthetic) — or —
        Item+            (analytic: @ref @department @producer)
          Detail+
```

## The two profiles

- **Synthetic** — `Detail` lines sit directly under `Account`.
- **Analytic** — an `Item` level (by department / producer) sits between
  `Account` and `Detail`; the account total is the sum of its items.

Both validate against the same schema; the analytic form sums to the synthetic
one. The two shipped examples carry the **same total** (2,819,200 net), which
demonstrates the equivalence.

## Detail line

A `Detail` carries the figures (`netAmount` required; `socialCharges`,
`grossAmount`, `quantity`, `unitPrice`, `resources` optional) and references the
header vocabularies by code: `type` → `DetailType`, `phase` → `Phase`,
`role` → `Role`, `unitOfMeasure`, `vatRate`, `withholdingRate`. Every such
reference is validated against the header.

## Grouping

A `Chapter` can belong to several grouping axes at once via multiple `GroupRef`
elements, each pointing at a `Group` that carries a `scheme` (e.g. `line` for
above/below-the-line, `financier`, …). Multi-axis grouping keeps the format open
to new classifications without structural change.

## Tags

Beyond the chart of accounts and the grouping axes, a budget line can carry
**tags** — free, cross-cutting labels orthogonal to the account structure (e.g.
*tax-credit-eligible*, *eco*, *reshoot*). Tags are declared once in the header:

```xml
<Tags>
  <Tag scheme="incentive" code="TAXCRED" name="Tax-credit eligible"/>
  <Tag scheme="event"     code="RESHOOT" name="Reshoot"/>
</Tags>
```

and applied to a `Detail` (or `Item`) with one or more `<TagRef tag="…"/>`:

```xml
<Detail type="PUR" description="Option and rights" netAmount="80000">
  <TagRef tag="TAXCRED"/>
</Detail>
```

The reference is validated against the header like every other code. Tags enable
cross-cutting analysis the chart of accounts cannot express — e.g. the total of
everything tax-credit-eligible across chapters.

**The Budget is the authority for tags.** A Cost Report or Details document that
uses tags redeclares the subset it needs in its own header (to stay
self-contained) and MUST keep it consistent with the referenced budget revision.
See the [Specification](../specification.md#tags-and-cross-document-consistency).

## Mapping note

Domain term naming is provisional: *Item* (budget line), *Role* (job),
*Contingency* (reserve) may be revised within the `0.x` series.
