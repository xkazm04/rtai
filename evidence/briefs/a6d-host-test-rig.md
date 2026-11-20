# Brief a6d (resume): the second null in the host test, then the flip. Commits by 05:55.

Your sprite guard stays. Line 118 reads `view._bodies.dent._rig.sides`; Dent's spectral body has no
legacy rig (no legs, which is the point). Guard it in the same test, same minimal way: take the rig
into a local once and iterate `sides` only when it is not null (a spectral Dent with no rig has no
foot to plant, so `planted` stays false and the existing `assert_eq(planted, grounded, ...)` still
checks the right thing). Do not change any assertion. If `_rig` is not a declared member of
DentBody, use `body.get(&"_rig")` typed as the rig class, or whatever the file does; keep it typed.

Then: `--select=test_ghost_flight_hosts` with Dent `legacy` (quote pass count), quick gate, commit the
test alone ("Let the flight host test pass a ghost that draws its own spectral body"). Then a6c item 2
(the flip with its checks and decision line) if the clock allows a full `--changed` run before 05:55;
if it does not, skip the flip and say so. Any new red: stop and report file:line + message.
