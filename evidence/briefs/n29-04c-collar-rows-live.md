# Brief n29-04-collar-rows: the p55 sprint collar, ONE ROW PER JOB (lane keys, run n29)

Art builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.
Read whole, in this order: `evidence/briefs/n28-05-collar-p55.md` (why, bars, evidence, allowlist: all hold, with `n28`
read as `n29` in every path below), `evidence/n28-keys/collar_p55.md` (the audit and the two failed rounds),
`C:/Users/kazda/kiro/gtai-art/rivet-n28/collar_p55/STATE.md` and its `scripts/` (`mkrefs.py`, `neck.py`, `comp.py`,
`comp2.py`: the neck-only composite that kept every pixel outside the masks identical).

## Wall clock (run `date +%H:%M` first and often)
02:59 launched. **Commit by 03:38 (rows that passed; partial is fine).** **Report and END by 03:50**, committed or not; never end with finished,
passing work uncommitted. Keep `STATE.md` current (every step, with the time): a later call resumes from it.

## What failed last time and what changes now
n28 tried a whole-sheet edit (poses moved, blur) and a five-row edit at 0.88 (still a twisted rope, yellow at the visor).
The owner's pick now: **one row per job, at full scale (1.0, no downscale), with the p70 bare run row of the same
facing as image 2**. Rows to fix: **3, 4, 6, 7, 8** of `project/features/characters/art/view/p55/rivet_run8.png`
(8 facing rows x 8 cells; rows 1, 2, 5 already draw the rigid collar and are the look to match). 5 jobs; at most 1 retry
per row; at most **9 images** this call.

- Round: `C:/Users/kazda/kiro/gtai-art/rivet-n29/collar_p55_rows/` (copy the n28 scripts). Image 1 = that row's 8 cells at
  1.0 on a flat green #00B140 key with gutters; image 2 = the p70 bare run row of the same facing
  (`p70/rivet_run8.png`); add as image 3 one rigid p55 cell (row 1 or 5) cropped to the neck at 4x, if the tool takes three.
- Prompt: only the neck band changes: one stiff flat ring, straight diagonal orange-and-black stripes (the shipped
  stripe colours; vermilion and black, no yellow, no red, no teal), the same width, the same position, following the neck's
  ellipse; no twist, no knot, no loose ends, no fabric folds; every other pixel exactly as image 1.
- Start the first job at once, write the per-row neck crops while it runs. Run the next row's job as soon as the previous
  png is in (hand-copy rule: the png lands under `~/.codex/generated_images/<new dir>/` after 4-6 min and is never copied
  to `out/`; copy by hand and stop that gen tree by PID). A usage-limit answer: stop, `BLOCKED images`.
- Composite each row neck-only (registered, feathered), prove 0 changed pixels outside the masks (script), and judge each
  row on a 4x nearest crop (shipped above, new below) **before** accepting it. A row that fails its bars after its retry
  stays shipped; commit the rows that pass (partial is fine; say which).

## Godot
One Godot per lane: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`, only through
`tools/dev/run.mjs`, `tools/godot/check.mjs`, the film tools or `tools/lib/godot.mjs`; d3d12 for renders; windowed
`--position 0,1440`. **No Godot until the file `build/n29-gloria.done` exists** (the Gloria builder holds the lane one Godot until then; the director creates the file); the image rounds and composites need no Godot. `mem-budget: waiting` = machine full, not a hang.

## Commit
`--import` after the png lands; provenance lines appended to `steam/ai-provenance/2026-11.jsonl` (hash of the new sheet);
`node tools/gate/quick.mjs`; `git add <paths>` and `git commit -m "keys n29: Rivet's p55 sprint rows <list> wear the rigid hazard collar" -- <paths>`
(incl. the `.png.import` if it changed). Banned: amend, rebase, `git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`.
Fix lint and format findings in your own edit and go on. If the hook fails only on
`tools/film/kill_reel_*.break.test.mjs` or `tools/merge/clash.test.mjs`: `--import`, commit again once. Never skip the hook;
it can take 12 min on this machine.

## Evidence (after the commit, separate commit; stop at 03:50 and leave the exact commands in STATE if not reached)
- `C:/Users/kazda/kiro/gtai-masters/n29/keys/collar/collar_p55_before_after_64.png`: in game, tilt 55, sprint 9.3 m/s,
  the fixed facings, before | after at the same tick ("before" from a temp worktree at the base sha, or the same capture
  with the shipped png swapped back in a scratch copy: the art is the only change; say which).
- Drift re-measured with the n27 setup (`evidence/n27-keys/p55_sprint_drift.md`, 3.83 cm at 64): must hold within 0.1 cm.
- `evidence/n29-keys/collar_p55.md`: rows fixed, identity proof, drift, IMAGES.

## Allowlist (anything else: stop and report a NEED)
`project/features/characters/art/view/p55/rivet_run8.png(.import)`, `steam/ai-provenance/2026-11.jsonl` (append),
`evidence/n29-keys/**`, `C:/Users/kazda/kiro/gtai-art/rivet-n29/**`, `C:/Users/kazda/kiro/gtai-masters/n29/keys/**`, `build/**`.
Forbidden: every other sheet, `rivet_motion.json`, code, every other table, the HUD files, `project/features/souls/**`,
`project/features/combat/**`, `project/boot/prologue/**`, cast art, `native/`, `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`.

## Report (short), then END
IMAGES n, rows fixed / failed (with what you saw), the identity proof, commit shas, drift, stills, STATE `Next`.

## This call (overrides above where they differ)
- Two other image jobs may run in this lane (Gloria builder): keep this builder at ONE job in flight, two only while
  the tool answers in under 6 min. Launch image jobs with the Bash tool's run_in_background (a foreground launch blocks).
- Commit each passing row group as soon as its checks pass (Godot rule above: `--import` only after `build/n29-gloria.done`).
  If Godot is still held at 03:30, leave the composited sheet in the round dir and STATE exact; do not commit without the
  import. Never delete anything in Temp or `~/.codex` you did not create; free only your own processes, by PID.
- Forbidden also: the sword and Gloria round dirs and files (other builders).
