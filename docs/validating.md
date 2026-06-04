# Validating & rendering

XOPXF documents are plain XML: validate them with any standard XSD validator and
render them with any XSLT 1.0 processor. The repository uses Python with `lxml`.

## Validating

```python
from lxml import etree

schema = etree.XMLSchema(etree.parse("schema/budget/budget.xsd"))
doc = etree.parse("examples/budget/analytic-example.xml")
assert schema.validate(doc), schema.error_log   # structural + referential integrity
```

The XSD enforces both **structure** and **referential integrity**: any code used
in the body (a group, role, type, tax rate…) must be declared in the header, so a
document with a dangling reference is rejected. The one deliberate exception is
Details' `payeeRef`, which is a soft reference so the personal-data-minimised form
stays valid — see [Details](documents/details.md).

To validate every shipped example:

```python
from lxml import etree

CHECKS = [
    ("schema/budget/budget.xsd",
     ["examples/budget/analytic-example.xml", "examples/budget/synthetic-example.xml"]),
    ("schema/cost-report/cost-report.xsd",
     ["examples/cost-report/analytic-example.xml", "examples/cost-report/synthetic-example.xml"]),
    ("schema/details/details.xsd",
     ["examples/details/full-example.xml", "examples/details/minimized-example.xml"]),
]
for xsd, files in CHECKS:
    s = etree.XMLSchema(etree.parse(xsd))
    for f in files:
        assert s.validate(etree.parse(f)), f"{f}: {s.error_log}"
```

## Rendering

A single document renders to a readable HTML view through its (localized)
stylesheet:

```python
from lxml import etree

xslt = etree.XSLT(etree.parse("schema/budget/generated/budget-html-en.xslt"))
doc  = etree.parse("examples/budget/analytic-example.xml")
open("budget.html", "w").write(str(xslt(doc)))
```

## The pipeline

Two scripts cover the full toolchain; both are idempotent and safe to re-run:

```console
$ python regen.py            # templates + dictionaries  -> localized XSLT
Generated 24 localized stylesheets (4 templates x 6 languages).

$ python render_examples.py  # examples + XSLT           -> localized HTML + indexes
Rendered 35 HTML files (7 views x 5 languages) and 3 indexes.
```

Run `regen.py` after changing a template or a dictionary; run
`render_examples.py` after changing an example or regenerating the stylesheets.
See [Localization](localization.md) for how the two stages fit together.
