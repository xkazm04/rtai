# Follow-up to brief 02 `dash`: the schema edit is authorised

Authorised: edit `project/data/schemas/input_actions.schema.json`: set the row `bit` maximum to **19** and the
`wire_bit` maximum to **32** (not 18 / 31). The ghost lane already committed exactly these two maxima for its
`ghost_deploy` row (bit 19, wire bit 32), so identical numbers merge clean. Change nothing else in that schema.
Also widen the TickInput mask as brief 02 says (`& 0xFFFFFFFFFFFF`), the identical line the ghost lane wrote.

Everything else in brief 02 stands: work it now, top to bottom. Hard stop 19:44, commit deadline 19:35,
commit 1 (the MILESTONE dash) as early as you can. In general: a one-line or two-number edit in a schema that
your own new row needs is allowed; name it in the report and go on, do not stop for it.
