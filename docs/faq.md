# FAQ

### Is XOPXF a piece of software?

No. XOPXF is a **document format** — a set of XML Schemas, XSLT stylesheets and
worked examples. There is nothing to install and no service to run. Any tool can
emit XOPXF documents, and any tool can read and validate them.

### How does it relate to Movie Magic (`.mbb`)?

Movie Magic Budgeting is a proprietary, closed budgeting *tool* format. XOPXF is
an open *interchange* layer that sits **alongside** such tools, not a replacement
for them. A budgeting tool can keep its own internal format and add an XOPXF
export so its budgets travel in a documented, validatable shape.

### How does it relate to EBU CCDM?

EBU CCDM (Tech 3351) is a high-level **conceptual** model (RDF/OWL) with classes
like `Contract` and `ContractCost`. It says what the concepts mean but leaves the
concrete financial document abstract. XOPXF is complementary: it is the actual,
validatable **document** for the financial domain CCDM leaves at the conceptual
level, and it is intended to be **mappable onto CCDM concepts**.

### Does it hard-wire national account codes (ANICA, broadcaster codes…)?

No. There are no country-specific codes baked into the schema. Issuers declare
their own chapters, accounts, groups, types and tax rates in the document's
header, as data. Classifications such as above/below-the-line are carried as
declared `Group` entries, not assumed by the format. This is what lets partners
with different charts of accounts exchange documents they can each read.

### How is payroll personal data handled (GDPR)?

The **Details** document never carries a counterparty name in the body — only a
code (`payeeRef`). Names live in an **optional** `Parties` registry in the header.
If you transmit the header with the registry, a reader can resolve codes to names;
if you omit it, only the codes travel and personal data never leaves the issuer.
The same body is valid either way, so minimisation is a transmission choice. See
[Details](documents/details.md).

### What is the difference between the synthetic and analytic profiles?

The **synthetic** profile carries figures at the account level; the **analytic**
profile adds one breakdown level (by department/producer). They are two
granularities of the *same* totals — an analytic document always sums to the
equivalent synthetic one. Budget and Cost Report support both; Details is
analytic only.

### Can a tool keep its own format and still emit XOPXF?

Yes — that is the intended use. XOPXF is an export/import layer. A system keeps
its internal data model and adds a converter that produces (and ideally consumes)
XOPXF documents, validating them against the schemas.

### Why XML and XSD rather than JSON?

The format is built around **referential integrity** (a code in the body must be
declared in the header) and **human-readable views**, which XML Schema `key`/
`keyref` and XSLT provide directly and portably. XML is also the established
shape for validatable *document* interchange (electronic invoicing being the
closest analogue). A JSON projection is not precluded for a future revision.

### Is XOPXF stable? Can I rely on it?

The current release is **0.1.0 (alpha draft)**. The three schemas are complete
and validated, with worked examples and localized HTML views, but the format may
still change within the `0.x` series. It is published now to invite review and
early adoption, not as a frozen standard. Within a major version, backward
compatibility is intended.
