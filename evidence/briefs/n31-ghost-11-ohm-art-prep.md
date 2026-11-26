# n31 ghost 11 - Ohm deploy beats: art prep (no generation, no Godot, no repo edits)

Builder tag: `g11-ohm-prep`. **Hard stop 30 minutes after launch: write the state file, report, END.**
Read-only worktree: `C:\Users\kazda\kiro\gtai-wt\n25-yard` (branch `n31-ghost`). Do NOT edit or commit anything in the repo. Do NOT run Godot. Do NOT run `gen.mjs` (no images this call).

## Why
Owner: "The animation of ghost deployment and effect needs more detailed work - expecting the same issue will be for other ghosts". Ohm (key 4, the elder spot-welder, the mage) is the next ghost: builder g10 is turning its deploy into one press -> an 18-tick (0.3 s) charge -> a full-circle discharge at the aim spot (radius from a lab sweep, likely 4.5-6 m). Tonnage got the same pass already; copy its method: read `C:\Users\kazda\kiro\gtai-art\ghost-n31\tonnage-beats\state.md` (the prep for Tonnage) and `jobs.json` there, and the commit `b8e1739eb` (`git show --stat b8e1739eb`, then the souls files it added: `tonnage_drop_marks.gd`, `tonnage_drop_beats.gd`, `tools/ghost/drop_pack.py`).

## Do (write everything into `C:\Users\kazda\kiro\gtai-art\ghost-n31\ohm-beats\`)
1. The chain, by code reading only (file:line): which Ohm art the DEPLOYED Ohm shows in the gauntlet (`--pick-view` = tilt70, p70 art; `ghost_forms.json` ohm `look`; `ghost_deploy_body.gd`, `ohm_rig.gd`, `ohm_drawn.gd`, `ghost_drawn.gd`, `ghost_sheet.gd`); which cell it holds during the new charge and on the discharge; how the deploy's effect is drawn today (`ghost_deploy_effects.gd:77-116`: bolts from the spot to each target, `OhmBoltDraw`, `OhmFork`, `OhmVictimRims`).
2. The sheet warning `ghost_sheet: .../p70/ohm_spec_hover.png needs five rows of square pose cells`: `ghost_sheet.gd:28-40` infers 5 rows of SQUARE cells when cols == 0; `ohm_spec_hover.png` is 636x2184, `ohm_spec_cells.json` says cell 318x266, act sheets 1272x1330. Find the caller that loads the hover sheet with cols 0 (`grep -rn "ohm_spec_hover\|spec_hover" project/features --include=*.gd`), what the sheet's real layout is (measure alpha bounding boxes per 318-wide column and every 266/437-px row band with Python PIL), and write the smallest code fix (which line, what value) or the repack it needs. Do not apply it.
3. Beat plan for the Ohm deploy at 32 px/m (what a player must read), each beat with the drawing(s) it needs and whether an existing cell can serve: **arrival** (he appears hovering at the spot), **charge** (18 ticks: current gathers in the jars/electrode fingertips; the circle's edge announced on the ground BY THE EFFECT: e.g. electric creep or scorch sparks crawling outward to the radius, not a UI ring), **discharge** (bolts to every foe inside + a ground ring of scorch at the true radius), **aftermath** (scorch decal a few seconds, he fades). Colour law: teal only for souls (Ohm's body); electric current, heat and sparks are AMBER (the current) with ink and white; red is blood only; never teal on the ground effects. Facing: the discharge is a full circle, so lock the deployed body to the toward-camera row like Tonnage (DECISION there, 22:03) unless the chain shows that costs more.
4. Jobs for `gen.mjs` (read `C:\Users\kazda\kiro\gtai-art\gen.mjs` for the jobs.json format; copy the Tonnage round's style): at most 8 jobs, one cell or one effect texture each, each with a reference cropped from the shipped Ohm sheets into `refs/` (PIL crops are fine: they are references, not shipped art). Prefer edits of shipped cells. Write `jobs.json`.
5. `state.md`: status, the chain, the sheet-warning cause + fix, the beat plan, the jobs, open questions; resumable by the next builder.

## Rules
- Write only under `C:\Users\kazda\kiro\gtai-art\ghost-n31\ohm-beats\`. Python with PIL is fine for measuring and cropping. No Godot, no repo edits, no commits, no gen.mjs.

## Report
The chain in 5 lines, the sheet warning cause + proposed fix, the beat plan, the job list (names + one line each), open questions.
