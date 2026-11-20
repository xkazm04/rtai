# Brief n20-ohm-06b (resume): last red unit, hard stop 06:08

Same environment and rules as brief 06. Only item: `project/tests/unit/test_ghost_spectral_sheets.gd:183`
(`test_legacy_cell_cut_and_tail_socket_follow_the_displayed_belt`, flight's file) fails because its fixture is Ohm and
Ohm's `ghost_hover.json` row has `fade_from` 0 (ours, keep it). Make it green with the SMALLEST edit inside that test
only (flight accepts a minimal fixture edit there, like 6c9319597): e.g. make that one test build its GhostFlight
for a form whose row has a nonzero `fade_from` (tonnage 0.43 or kerf 0.39), or give its fixture a nonzero cut, so the
test still checks what it checked. Do not touch `ghost_hover.json`, ghost_*.gd, or any Ohm visual. Run
`--select=test_ghost_spectral_sheets`, then the full `node tools/tests/run_unit.mjs` must be 0 failed. One commit
("Give flight's legacy belt test a form with a leg cut"), by 06:05. Report: sha, full unit line. Then stop: no other work.
