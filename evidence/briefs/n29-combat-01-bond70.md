# Brief n29-combat-01-bond70: Tonnage's mastery bar 85 -> 70, the ten-seed table, the film

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" at the end (binding). At the hard stop write your report and END, even
mid-task.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on. Fix lint
and format findings in your own edit and go on. No amend, no rebase, no push. Read `AGENTS.md` (repo law) first, briefly.

## Why (owner, 2026-11-25)
"Tonnage's bar 85 -> 70." Last run (n28) gave Tonnage a bar of his own, 85 (`project/data/tables/ghost_forms.json`
`bond.master_at_by_form.tonnage`); on ten seeds of the average test player he was never mastered: his bond reached 85 on
seeds 1 and 8 at waves 8/9 but both runs died before the next rest. The probe curves (`evidence/n28/bond/mastery.md`,
"Probe arm") predict that 70 gives wave 7-8 masteries on seeds 1, 2 and 8. This is the ONLY balance value that changes.

## What
A. **The value.** `ghost_forms.json` `bond.master_at_by_form.tonnage` 85 -> 70. Fix any doc string, schema example, test,
   scenario or golden that pins 85 for Tonnage (`grep -rn "85" project/tests project/data/tables/ghost_forms.json` and
   `node tools/tests/test_map.mjs project/data/tables/ghost_forms.json` to see which tests/scenarios read the table; run
   them). If a shipped replay/scenario digest moves because of the bar, re-pin it and say so in the decisions line.
   Append ONE line to `docs/decisions.md`:
   `- [2026-11-25] DECISION n29 combat: Tonnage's mastery bar 85 -> 70 (owner pick; ghost_forms.json bond.master_at_by_form.tonnage), measured on the ten seeds in evidence/n29/bond/mastery.md; one data value back to 85.`
   `node tools/tests/run_unit.mjs --changed` green, `node tools/gate/quick.mjs` green, then commit A (stage per path).
B. **Ten seeds, n28 beside n29.** The exact n28 measurement (read `evidence/n28/bond/mastery.md` bottom lines,
   `evidence/n28/bond/summarize.mjs`, `report.mjs`): for seed in 1..10:
   `node tools/dev/run.mjs res://dev/ghost-forms/bond_measure.tscn --fixed-fps=60 --bot=average --pick=greedy --seed=<n> --waves=15 --mastery-free=1 --result=<abs path under build/n29/bond/>`
   (~15 s a seed; run them one after the other, never two Godots). Then build `evidence/n29/bond/mastery.md` (+ `mastery.json`,
   copy and adapt the n28 scripts into `evidence/n29/bond/`) with the table:
   | Arm | Runs with a mastery | First-mastery waves | Median | Ghosts mastered | Tonnage mastered (seeds, wave) | Kerf mastered |
   rows: n27 free (from the n28 file), n28 (Tonnage 85), **n29 (Tonnage 70)**; plus the per-seed table of the n29 arm
   (Dent/Kerf/Ohm/Tonnage mastery wave, death wave, form entries) and an "expectation check" paragraph against the probe
   prediction (seeds 1, 2, 8 at wave 7-8). If Tonnage is still never mastered, say why from the data (died before the
   rest? bond short?). Commit B (evidence only) as soon as the table exists.
C. **Film for the owner.** `evidence/n28/bond/render_bond.mjs` made n28's `bond_mastery.mp4`; adapt a copy into
   `evidence/n29/bond/` that films a run where **Tonnage's bond fills and his mastery card is offered/taken** at 32 px/m,
   1920x1080, 60 fps, 15-40 s (pick the seed and tick window from your B results; the take may use `--bond-prefill` only if
   it is labelled so in the note). Output `C:/Users/kazda/kiro/gtai-masters/n29/combat/films/tonnage_mastery_70.mp4`,
   check with `ffprobe` (quote width, height, r_frame_rate, duration). Plus one 64 px/m still of the chip strip with
   Tonnage's ring full / mastered: `.../n29/combat/stills/tonnage_chip_70_64.png` (the 64 px/m scene is
   `res://dev/ghost-forms/bond_film_64.tscn`). LOOK at both yourself (open the still, extract 3 frames of the film with
   ffmpeg and look). Add entries to `C:/Users/kazda/kiro/gtai-masters/n29/combat/frames.json` (create it if missing; a JSON
   array of `{ "file", "title", "ppm", "before", "note" }`, `file` relative to that folder; keep other entries). The n28
   before film is `C:/Users/kazda/kiro/gtai-masters/n28/combat/films/bond_mastery.mp4`: name it in `before`.
   Commit the adapted script + a short `evidence/n29/bond/film.md` note.

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe GTAI_GODOT_EST_MB=600` (1000 for rendered runs).
  `--rendering-driver d3d12` for renders; any windowed run at `--position 0,1440`, never the main display. Only Godot
  through `tools/dev/run.mjs` / `runGodot`; one Godot process at a time; kill only your own PIDs, never by name.
  `mem-budget: waiting` is the 16 GB machine cap queueing you, not a hang: wait.
- Another builder of this lane works at the same time on fire art (PNGs under `project/features/combat/weapons/art/fx/`,
  `fx_atlas.png`): never touch those files; a Godot run may queue behind theirs.
- `node tools/gate/quick.mjs` before every commit; the pre-commit hook takes up to ~12 min on this shared machine. If it
  fails on `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` once and commit again. Never skip the hook.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not print. Stage per path.
  Banned: `git stash`, `git add -A/./-u`, `git commit -a`, `reset --hard`, amend, rebase, push.
- Commit message trailer: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/data/tables/ghost_forms.json` (the one value + its doc string), tests or scenario pins that read Tonnage's bar
(`project/tests/**`), `docs/decisions.md` (one appended line), `evidence/n29/bond/**`, `build/**` (scratch),
`C:/Users/kazda/kiro/gtai-masters/n29/combat/`.
Forbidden: every other table (`combat.json`, `enemies.json`, `rivet_motion.json`, `input_actions.json`, `cast_cards.json`),
the HUD files `project/features/souls/ghost_form_hud.gd`, `ghost_form_layout.gd`, `ghost_chip_number.gd` (keys' tonight),
art PNGs, `project/boot/prologue/**`, other worktrees, root `JOURNAL.md` / `REPORT.md`, `C:/Users/kazda/kiro/pof`.

## Report and END (short)
Commits (sha + subject); the table rows (n28 vs n29); what moved (tests/pins); film + still paths with ffprobe lines;
how they look; unit + quick gate lines; what was left.

## Wall clock (binding)
You die with the director's session at 02:35. **Commit A by 01:35.** Commit B by 01:55. **HARD STOP 02:20: report and END.**
