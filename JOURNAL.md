# JOURNAL lane polish (n21, 2026-11-20)

- 11:41 START iteration 1, session 1. Read n20 reports (flight/tonnage/dent/ohm "What does not"/"Next steps"). No Astra lock, no `NEED polish` in kerf's journal.
- 11:43 ASTRA RUNNING reel-encode since 11:43 (brief `evidence/briefs/01-reel-encode-flight.md`: encode range fix, all-ghosts reel, ghost_flight.gd mutants; hard stop 12:55). Out: `evidence/briefs/01.out.txt`.
- 11:47 Briefs written ahead: 02 Ohm eight facings (6 image jobs: 2 tilts x 3 pose pairs, 4x4 grid, mirrored-pair columns so left and right are drawn together; prompt verbatim in the brief), 03 Tonnage (smoke root under hump, slam ring weight, chip visor), 04 Dent (hit reaction in 3 views, seized car top tint).
- 11:47 DECISION ohm sheet layout: per tilt three 1536x1024 images by pose pair (idle+drift, charged+thrust, recovery+struck), 4x4 cells; each column holds a facing and its left twin (toward-right/toward-left, right/left, away-right/away-left, toward/away), so the model draws each left cell directly under its right partner. Rejected: 8x6 in one image (cells ~190 px, below n20's 229), one pose per image (12 images, more drift between poses).
- 11:47 DECISION ownership: the Tonnage HUD chip (`hud/art/ghost_chips/tonnage_spectral.png`) is not on either list but the lane brief assigns the fix to polish; kerf owns only `kerf_*` chips. Polish takes it.
