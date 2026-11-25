# n30-cast-06: the warden's fall sheet drawn at his walk's size (NEED cast from combat) (tag `c06`, model opus)

Read `evidence/briefs/_common.md` first: it binds. Hard stop: launch + 45 min (report and END). Commit by launch + 35 min.

## The fault (combat lane's measurement, read, do not re-derive)
`C:\Users\kazda\kiro\gtai-wt\n23-street\evidence\n30\kills\card_fall.md` "Warden at the switch" (lines ~78-99) and its 2x
crop `C:\Users\kazda\kiro\gtai-wt\n23-street\build\n30\cardfall\probe_frames\switch_w.png` (READ ONLY: another lane's tree,
never write there): when Appliance Warden (Peg Dolan, `appliance_warden`) dies, the frame after the switch from his walk card
to his fall sheet shows the head ~1.4-1.5x bigger (cap ~22 px wide on the walk, ~33 px on the fall sheet's first drawing,
64 px/m), feet at the same y. Same in his living death (no kill style), which is cast's. Mulroney does not pop (cap 30 = 30).
Cause: his fall sheet (`project/features/characters/art/view/p{55,70}/appliance_warden_fall.png`, 5 rows x 3 drawings)
is drawn at the shared 192 px still scale while his walk is a padded 256 px cell; cut by `tools/art/cast_warden_pack.py`.

## Do (cast-owned fix: the art, not combat's code)
1. Find the cast tool that films his death (`tools/film/cast_warden_films.mjs` modes, or `project/dev/cast/**`): a living
   death at 64 px/m (pitch 70 and 55) with the last walk frame and the first fall frames. Measure in the DELIVERED frames:
   head (cap) width and figure height on the last walk frame vs the first fall drawing, per pitch. That is the before.
2. Give `cast_warden_pack.py` one fit factor per pitch for the fall sheet (`FALL_FIT = {70: k70, 55: k55}`, k from step 1 so
   the cap width matches the walk's), scaling each fall drawing about its boot / ground point inside the SAME canvas size
   (sheet size and 5x3 grid unchanged, so `KillCardFall` still splits it). Re-cut only the fall sheets (other sheets'
   bytes unchanged: compare). Check the `_hit` sheet the same way; fit it only if it pops too (measure first).
3. Re-measure in the delivered frames: cap width fall / walk within 0.9-1.1 at both pitches, feet y within 2 px. If not,
   adjust k once. 64 px/m before|after still `C:\Users\kazda\kiro\gtai-masters\n30\cast\warden_fall_fit_64.png`; LOOK at it.
4. Import, `node tools/tests/run_unit.mjs --changed` (or `--select=` the cast warden / card tests it names) green, lint, quick gate.
   Commit "cast: warden fall sheet drawn at his walk's size (cap 33 -> ~22 px at 64, NEED from combat)" with the sheets,
   `.import`s, the tool, and one provenance note line per changed sheet in `steam/ai-provenance/2026-11.jsonl` (append; copy
   the warden lines' format, human_edits = "rescaled by k about the boot" ; if `git diff` of that file shows lines that are not yours
   (another builder's uncommitted lines), skip the provenance lines, commit the rest, and write NEED director).
5. Do NOT edit `docs/art/cast-audit.md` (builder c05b appends to it right now): put the before/after table in the commit
   message body and your report; the director has it appended later. Append the still's
   entry to `C:\Users\kazda\kiro\gtai-masters\n30\cast\frames.json` (keep entries; valid JSON).

## Allowlist
`tools/art/cast_warden_pack.py`, `project/features/characters/art/view/p{55,70}/appliance_warden_{fall,hit}.png` (+ `.import`),
`tools/film/cast_warden_films.mjs` (a measure mode if needed), `project/dev/cast/**`, cast warden unit tests,
`steam/ai-provenance/2026-11.jsonl` (append), `build/look/n30-c06/**`, masters files.
Forbidden: `project/features/combat/kills/**` (combat's: `KillDeathCells.FIT_K` is theirs; do not add a key there). Anything else: NEED.

## Report
k per pitch, before/after cap width + height + feet per pitch (delivered frames), commits, test lines, still and what you saw.
