# n30 combat call 04: the explosion light's rim amber through a new palette token

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Check `date +%H:%M` at start.
**Commit A (data + tests) by minute 25, evidence by minute 50, report and END at minute 60.** Never end uncommitted.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: another builder may run Godot here too. Before each Godot launch (unit tests
included) wait until no file in `$LOCALAPPDATA/gtai/runs/*.json` names `n23-street`
(`grep -l n23-street "$LOCALAPPDATA"/gtai/runs/*.json`), re-check every 30 s. Every launch through the shipped tools
(`tools/tests/run_unit.mjs`, `tools/film/*.mjs`, `tools/dev/run.mjs`, `runGodot`), never raw `$GODOT_BIN`. Windowed: `--position 0,1440`.

## Owner's verdict (docs/decisions.md:1598)
"the explosion light rim amber through a new palette token". Colour law: amber for fire, heat, current; vermilion only for
danger, objectives, Rivet's collar. This lane owns `lights.json` and the light palette entry this run.

## What is known
- `project/data/tables/lights.json` `kinds` row `explosion`: `token` paper, `alt_token` vermilion ("paper core, the outer band
  on the vermilion plate (danger)"), steps 3, radius 6 m, life 36 ticks. `project/core/render/light_layer.gd:160-170` reads
  `token`/`alt_token` as `palette.json` token ids through `PaletteTokens` (`pal.color(...)`). Read how the outer band uses
  `alt_token` (a strobe alternates token/alt on `flicker_hz`; with flicker 0 the rim takes alt?) and confirm on screen
  which pixels are the "rim".
- `project/data/tables/palette.json` has no amber token. The game's amber is `#EDAB42` (`Ink.AMBER`,
  `project/boot/collect_call/view/ink.gd:13`; `ElectricArc.HALO`). Add a token `amber` `#EDAB42` (doc: "fire, heat, electric
  current and overload; the explosion light's rim"). Decide `role`: if an `accent` token needs an `accents` row with
  uses/layers and gates (`PaletteTokens.classify` order), and adding one moves the accent audit or a test, prefer the smallest
  change that lets `lights.json` name it (check `palette.schema.json`, `PaletteTokens`, `dev/selftest/accent_audit.gd`, and
  every test that counts tokens). Say which you chose and why.
- Change only the explosion row's `alt_token` to `amber` (and its `doc`). `fire` stays vermilion (not asked; list it in your
  report as a call). Cost: one light per blast before and after (no new light).
- Where explosions are lit: `combat_lights` (arena and city block fight, `blast: true`). The grade: day = identity; check the
  arena look prints the rim amber (n29 lesson: a print can snap a non-ink colour to the nearest ink: amber went vermilion until
  `fx_amber_ink`). If the light layer prints amber as vermilion or cream, stop and report what prints it (no print code change).

## Do
1. Token + lights row + schema if needed; tests: a unit test that `lights.json` explosion's alt token resolves to `#EDAB42`
   and that no other kind changed (`project/tests/unit/test_light_explosion_amber.gd` or extend the existing lights test;
   find it with grep `lights.json` in `project/tests`). `node tools/tests/run_unit.mjs --changed` green (or `--select=` the
   lights/palette tests), `node tools/lint/lint.mjs` green, `node tools/debt/debt.mjs --check` green. Commit A.
2. Before | after at 64 px/m on the same tick: a rocket or nuke blast in the arena. Lead (n29 muzzle work): the arena reel
   director cut fires the rocket at tick 826 and the nuke at 1193:
   `node evidence/n29/red/take.mjs <out dir> <ticks> --rigs --bot=reel --reel=director --loadout=pistol --chapter=rocket_launcher,mini_nuke --ppm=64 --clean --silent`
   (check `evidence/n29/red/muzzle.md` and `fire.md` for blast ticks; pick 2-3 ticks across the light's 36-tick life). Before =
   HEAD's lights.json (render it first, before your edit, or check out the old row for one take and restore).
   Measure in the light's ring: vermilion px (`PaletteTokens` verm gate r - max(g,b) >= 0.31) and amber px (near #EDAB42)
   before/after; whole-frame diff outside the light's 6 m disc 0 (or explained). Frame cost: one light per blast in both arms
   (count lights from the LightLayer if a probe exists; else state it from code).
3. Evidence to `C:/Users/kazda/kiro/gtai-masters/n30/combat/`: `stills/explosion_rim_pair_64.png` (before | after, labelled,
   same tick, plus a crop of the ring), `films/explosion_rim_32.mp4` (rocket + nuke chapters at 32 px/m, 1920x1080, 60 fps,
   15-40 s; ffprobe and quote). Append entries to `frames.json` there (`{ "file", "title", "ppm", "before", "note" }`;
   re-read it just before writing, another builder appends too). `evidence/n30/lights/explosion_rim.md` (commands, ticks,
   counts, what you saw). **Look at each still yourself** and say what you see. Commit B.

## Commits (stage per path; never `git add -A/./-u`, no stash, no amend, no rebase, no reset --hard)
End each message with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. The pre-commit hook can take ~12 min;
never skip it. If it fails on a stale class cache run
`node -e "import('./tools/lib/godot.mjs').then(m=>m.runGodot(['--import'],{name:'import'}))"` and commit again.
Fix lint and format findings in your own edit and go on. Do not touch `docs/decisions.md`, JOURNAL.md, REPORT.md.

## Allowlist (any other path: stop and report a NEED)
`project/data/tables/lights.json`, `project/data/tables/palette.json`, `project/data/schemas/palette.schema.json`,
`project/data/schemas/lights.schema.json`, new or existing light/palette unit tests under `project/tests/unit/` (name them),
`evidence/n30/lights/**`, `build/**`, the masters dir. Forbidden: `project/core/render/*.gd` (report a NEED if code must change),
print/look profiles, weapon art PNGs, `project/features/combat/kills/**`, other lanes' worktrees.

## Report and END
Files, commits, commands with result lines, counts, what you saw, what you could not do, the `fire` light as a call.
