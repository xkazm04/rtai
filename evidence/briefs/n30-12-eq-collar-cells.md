# n30-12 eq-collar-cells: rigid collar in the p70 `_left` aim strips (rocket launcher, mini-nuke, gatling), per-cell 2x edits

Launched ~12:56. **Commit each finished strip as soon as its proof and your look pass (first commit by 13:25); last commit by
13:42. Report and END by 13:48 (hard: the session that runs you ends at 13:54 and an uncommitted call loses its work).**
`date +%H:%M` first and often; write the deadlines in your first STATE line. Work in `C:/Users/kazda/kiro/gtai-wt/n23-controls`
(branch `n30-keys`). Never amend, rebase, push, stash, `git add -A/./-u`, `commit -a`, `reset --hard`. Stage per path
(`git commit -- <paths>`: another builder, n30-11 collar film, works in this worktree and may temporarily swap
`p55/rivet_run8.png`: never stage that file). Fix lint and format findings in your own edit and go on.

## Why
Rivet's striped neck band is a rigid hazard collar, never cloth (standing law). Audit `evidence/n30-keys/eq_collar_audit.md`
(`57c72c41a`; read it, and look at `C:/Users/kazda/kiro/gtai-masters/n30/keys/eq_collar/p70_left_suspects.png`): in the p70 `_left`
aim strips of the rocket launcher, mini-nuke and gatling the band is broken, knitted stripes with jagged edges; Gloria's,
chainsaw's and the assault rifle's `_left` cells are the clean read (flat ring, straight parallel vermilion / near-black stripes,
dark outline top and bottom). p70 is the default in play; `_left` shows whenever Rivet aims left standing.

## The route (proven on 33 p55 cells this run: reuse it)
Round `C:/Users/kazda/kiro/gtai-art/rivet-n30/collar_cells/` (`STATE.md`, `scripts/cell_job.py`, `cell_comp.py`, `protect_restore.py`,
`run_comp.sh`, `accept.py`). Make a sub-round `C:/Users/kazda/kiro/gtai-art/rivet-n30/eq_collar/` (own `STATE.md`, copies of the
scripts adapted to a strip: the cell grid of a `_left` strip is 3 equal cells across, e.g. 780x170 -> 260x170; check the code
that cuts it if unsure). Per cell: crop, 2x NEAREST on the key canvas, image edit with `C:/Users/kazda/kiro/gtai-art/gen.mjs`
(image one = the target cell at 2x, image two = the reference cell at 2x: `p70/rivet_eq_gloria_left.png` same cell index, or the
chainsaw's / assault rifle's when its pose fits better; the prompt: change ONLY the neck band into the reference's rigid ring,
keep the helmet, visor, weapon, arms, body, outline, pose exactly). Scale back, register (alpha IoU >= 0.97), composite neck-only:
0 px changed outside the band mask, alpha identical, the other cells bit-identical, teal 0, the visor protected (yellow AND
orange glow: use `CELL_PROTECT` boxes from the start, n30-06/n30-08 found orange visors slip the yellow guard). **The weapon must
not change by one pixel** (protect it: its px are outside the band mask; prove 0 changed in the weapon's bbox).
Known fault of gen.mjs: a job can stall on the copy to `./out` after the image exists under `~/.codex/generated_images/`: copy it by
hand at once (compare the dir listing before/after the job) instead of waiting for the 900 s timeout. Two jobs in flight at most.
If the image tool answers with a usage limit: stop generating, write `BLOCKED images`, commit what passed.

## Order and cap: **at most 8 images this call** (the lane's last 8; count them in STATE)
1. `rocket_launcher_left` cell 1, 2. `mini_nuke_left` cell 1, 3. `gatling_left` cell 1, 4. `rocket_launcher_left` cell 2,
5. `mini_nuke_left` cell 2, 6. `gatling_left` cell 2, 7. `rocket_launcher_left` cell 0, 8. `mini_nuke_left` cell 0
(cells are 0-based as in the audit). No retries unless an image is left over at the end; a failed cell keeps the shipped cell.

## Per cell bar (before acceptance)
The proof numbers above, and YOUR look at a 4x judge still (shipped | candidate | reference): flat ring, straight parallel
stripes, dark outline, no knit/twist/fray, visor, helmet, weapon, claws untouched, no seam, no new teal/red/yellow. One STATE
line per cell.

## Per strip, before its commit
Install, Godot `--import` (check the `.import` is unchanged and **verify the imported texture follows the new png**: the n30-08
builder found a stale import; copy the check from `build/n30-08/chain.sh`), an in-game 64 px/m still: the arsenal turn recorder
`node tools/dev/run.mjs` or runGodot with `-s res://dev/rivet_arsenal/arsenal_turn.gd -- --weapon=<rocket_launcher|mini_nuke|gatling> --pitch=p70 --ppm=64 --out=<abs dir under build/n30-12/>`
(see `evidence/n30-keys/arsenal_turn.md`; it writes `octN_rest` stills; the left octants show the `_left` cells), before (HEAD,
one run per weapon before you install) | after, cropped to Rivet, to `C:/Users/kazda/kiro/gtai-masters/n30/keys/eq_collar/<weapon>_left_64_ingame.png`;
look at it. A provenance line per commit in `steam/ai-provenance/2026-11.jsonl` (format of the n30-01 line). `node tools/gate/quick.mjs`.
Commit `art(keys n30): p70 <weapon> aim-left collar rigid (per-cell 2x edits, cells ...)`. Then the table rows (cell, ref, IoU,
mask px, changed, weapon px changed 0, verdict) in `evidence/n30-keys/eq_collar_audit.md` under a new section "Edits (n30-12)".

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Lane lock
`build/n30-godot.lock` (create exclusively with tag `n30-12` + your pid; n30-11 may hold it for its film runs (it swaps the p55 run
sheet under the lock): wait and do image work meanwhile; take it per run and delete it after). Only through runGodot. d3d12,
`--position 0,1440`. `mem-budget: waiting` = machine full, not a hang. Free only your own processes, by PID. No mutate.
If Godot never frees in time: commit the art with the proof numbers and the 4x stills, and write the in-game still as owed.

## Allowlist (anything else: stop and report a NEED)
`project/features/characters/art/view/p70/rivet_eq_{rocket_launcher,mini_nuke,gatling}_left.png` (+ `.import` only if Godot changes
it), `steam/ai-provenance/2026-11.jsonl` (append), `evidence/n30-keys/eq_collar_audit.md`, `C:/Users/kazda/kiro/gtai-art/rivet-n30/eq_collar/**`,
`C:/Users/kazda/kiro/gtai-masters/n30/keys/eq_collar/**`, `build/n30-12/**`. Read only: everything else (the collar_cells round's
scripts: copy, do not edit). Forbidden: `p55/rivet_run8.png`, other strips, code, data, `JOURNAL.md`, `REPORT.md`,
`docs/decisions.md`, other worktrees. Never delete anything in Temp or `~/.codex` you did not create.

## Report (short), then END
IMAGES n, the per-cell table, commit shas, stills, what is owed, STATE Next.
