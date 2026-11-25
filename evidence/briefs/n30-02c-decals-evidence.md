# Brief n30-02c `decals-evidence`: item 2's evidence (decal contrast, readability bars, pilots, film, decisions, mutate) (lane yard, run n30)

HARD STOP: see the time in the prompt that launched you (report and END). FIRST COMMIT (pilots + contrast table) started no later than 25 minutes after launch; LAST COMMIT started no later than 12 minutes before the hard stop. Check `date` often. Never amend, never rebase. No product code change in this call (evidence only; a fault you find goes in the report).

## Setup
Same as `evidence/briefs/n30-02a-decals-over.md` (env exports, runGodot-only tools incl. `node tools/art/prologue_yard_film.mjs` for stills and 1080p movies, the lane's Godot lock `build/yard-godot.lock` with your tag `decals-evidence`). Never stage files you did not write.

## What landed
`5950ceb34` + `ed6b97278` (read both diffs): in `arched_line` the stain layer (`floor_stains.png`, `over_impression`), the non-ochre `torn_line` decal stamps (`decals_over_impression`: tyre marks, scorch, oil, cracks) and the ochre bay lines (`ochre_over_impression`) print above the i55 impression; wrecks and spans stay above them. Floor L* 51.6 -> 50.8. Before = `6c32defe4` (shade 0.5, decals under the impression). i20 = `c649a15d6`.

## Work
1. Pilots seeds 7, 3, 11, 21, 42 in ONE Godot process (`project/dev/prologue_yard/yard_pilot_rows.gd`) to `evidence/yard30/prologue-yard-pilots-decals.json`: identical to `evidence/yard30/prologue-yard-pilots-shade05.json`. If not: STOP and report.
2. Decal contrast: renders at the mid and gate cameras, tick 300, 32 px/m, of before (`6c32defe4`: render it from a temp worktree `git worktree add <tmp> 6c32defe4`, and remove it after; or swap the table + code at HEAD back temporarily and restore byte for byte) and HEAD. Pick 4 to 6 decal boxes by hand from the frames (two tyre-mark sweeps, two bay-line runs, two stains; boxes away from actors) and measure mean |decal - floor ring| luminance (Rec.709 linear, the method of `evidence/yard29/prop_contrast.py`, decal pixels = the darkest 30 % (or for bay lines the most ochre 30 %) in the box). Table i20 / before / after with after/before %. Bar: every decal class after >= before.
3. Readability bars at HEAD with the n29 scripts (`evidence/yard29/floor_i55_bars.md` names them and the method: `readability.py`, `rivet_delta.py`, `dusk_contrast.py`, `bars.sh`): patrol blue outside/inside >= 65 %, rifle >= 95 %, pellet >= 90 %, Rivet luminance delta (report against 0.147; a drop of more than 0.01 is a FAIL to report). Write `evidence/yard30/decals_over.md` (both tables, method lines, what you saw). COMMIT 1.
4. Film: 32 px/m mid yard, 1080p60, `--place=mid --tick=1757 --frames=1380`, before | after hstack of two 960x1080 crops keeping tyre marks, bay lines and the forklift in view, labelled correctly (before = 6c32defe4), to `C:/Users/kazda/kiro/gtai-masters/n30/yard/decals_over_before_after_mid_32ppm.mp4` (ffprobe: h264, 1920x1080, 60 fps, 15..40 s). Copy `evidence/yard30/decals_over_64ppm.png` to masters. Two entries in `C:/Users/kazda/kiro/gtai-masters/n30/yard/frames.json` (keep valid). Re-label the left half of `evidence/yard30/decals_over_before_after_mid_32ppm.png` as `before: 6c32defe4` (it was rendered there) or re-render it.
5. One line appended to `docs/decisions.md`: `- [2026-11-25] DECISION yard n30 decals over the impression: ...` (the three keys, floor L*, decal contrast, bars, pilots; rejected: a lower impression tint (owner: draw order)).
6. Mutate: `node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_yard_overprint.gd --max=20 --tests=test_prologue_yard_decals_over,test_prologue_yard_overprint` (hold the Godot lock across it); save its summary to `evidence/yard30/decals_mutate.txt`. COMMIT 2 (evidence, decisions, mutate txt).

## Owned files (allowlist)
`evidence/yard30/**`, `docs/decisions.md` (one appended line), `C:/Users/kazda/kiro/gtai-masters/n30/yard/**`, `build/**`, a temp worktree under `build/` or the OS temp you create and remove; TEMPORARY table/code swaps restored byte for byte (`git diff --stat project` empty at the end).

## Forbidden
Product edits (code, table, schema, tests, tools), `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, other worktrees (`n23-controls`, `n23-street`, `n23-prologue`), `C:/Users/kazda/kiro/gtai-art/**`. No image generation. No `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push, never `--no-verify`.

## Report (final message, then END)
Commit shas; pilots identical yes/no; the decal contrast table; the bars; ffprobe line; mutate score (killed/(killed+survived)) and survivors; what you saw; `git diff --stat project` (empty); what was not done.
