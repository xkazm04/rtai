# n30 combat call 03: Rivet's rocket and nuke nose band amber (masked recolour)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. **Commit A (PNGs) by minute 30, evidence by minute 50,
report and END at minute 60.** Check `date +%H:%M` at start and write your deadlines down.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: another builder (c02, electro hop) films here. Before each Godot launch wait
until no file in `$LOCALAPPDATA/gtai/runs/*.json` names `n23-street` (`grep -l n23-street "$LOCALAPPDATA"/gtai/runs/*.json`),
check every 30 s. Every Godot launch goes through `runGodot` (`tools/lib/godot.mjs`; `evidence/n29/red/take.mjs` is an example),
never raw `$GODOT_BIN`. Windowed runs `--position 0,1440`.

## Owner's verdict (docs/decisions.md:1598)
"Rivet's rocket and nuke nose band amber". Colour law: amber for fire/heat/current; vermilion only for danger, objectives,
Rivet's collar. Owner-accepted mock: `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/call_rocket_band_pair_8x.png`
made by `evidence/n29/red/call_stills.py` `amber_mock` (reddish px -> amber #EDAB42 hue/sat, value and alpha kept).

## Do
1. Files: `project/features/combat/weapons/art/fx/rocket.png` (200x70, 336 reddish px), `fx/nuke_shell.png` (200x96, 968).
   Find every other copy the game draws for these rounds in flight (grep `rocket`/`nuke_shell` in
   `project/features/combat/weapons/**` incl. atlases, `fx_cells`, `colour/` variants; `weapon_fx_shell.gd` lobs `nuke_shell`;
   find what the rocket launcher's straight shot draws). Recolour only the nose band: a mask of the reddish px (the n29
   `is_red` gate) plus their anti-aliased edge if needed; value and alpha kept; **0 px changed outside the mask** (prove by diff).
   Put the script in `evidence/n30/rounds/recolour_band.py` (Pillow, `python -I`), with a `--dry` mode that prints counts.
2. **Before any commit, prove it reaches the screen.** Render in flight at 64 px/m, same tick, before and after.
   Lead: n29 muzzle work fired the rocket at tick 826 and the nuke at 1193 in the arena reel director cut:
   `node evidence/n29/red/take.mjs <out dir> <ticks> --rigs --bot=reel --reel=director --loadout=pistol --chapter=pistol,machine_pistol,rocket_launcher,mini_nuke --ppm=64 --clean --silent`
   (see `evidence/n29/red/muzzle.md`); pick ticks with the round mid-flight (e.g. 832-845, 1200-1230; check frames).
   Before = render with the HEAD PNGs first, then swap in the recoloured PNGs (the film tools re-import changed assets;
   if a plain take does not, run the import via `node -e "import('./tools/lib/godot.mjs').then(m=>m.runGodot(['--import'],{name:'import'}))"`).
   Never write `git show HEAD:<png>` into the tree (LFS pointer). n29 lesson: the item print snapped amber to vermilion until
   the FX view got an amber ink (`fx_amber_ink`, look_profiles.json): check the round really prints amber, not vermilion or cream.
   If it does not print amber, stop and report exactly which view/print draws the round (do not change print code).
3. Numbers: reddish px per PNG before/after (target 0); in-game round box at 64 px/m: reddish px (R>170 G<110 B<90 and the
   `is_red` gate) before/after, amber px (near #EDAB42) before/after, whole-frame diff px outside the round box (target 0 or
   explained).
4. Evidence to `C:/Users/kazda/kiro/gtai-masters/n30/combat/`: `stills/round_band_rocket_pair_64.png`,
   `stills/round_band_nuke_pair_64.png` (before | after, labelled, same tick, plus an 4x crop of the round),
   `films/round_band_32.mp4` (the rocket and nuke chapters at 32 px/m, 1920x1080, 60 fps, 15-40 s; ffprobe it and quote the line;
   use the shipped film tools, e.g. `tools/film/film.mjs` or the reel director take with `--ppm=32` and ffmpeg over the frames).
   Append entries to `frames.json` there (a JSON array of `{ "file", "title", "ppm", "before", "note" }`; another builder may
   also append: re-read it just before writing). Write `evidence/n30/rounds/band.md` (commands, ticks, counts, what you saw).
   **Look at each still yourself** and say what you see.

## Commits (stage per path; never `git add -A/./-u`, no stash, no amend, no rebase, no reset --hard)
A: the PNGs (+ their `.import` if changed) + the script. B: `evidence/n30/rounds/band.md`. End each message with
`Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. The pre-commit hook can take ~12 min; never skip it; if it fails on a
stale class cache run the import (above) and commit again. Fix lint and format findings in your own edit and go on.
Do not touch `docs/decisions.md`, JOURNAL.md, REPORT.md.

## Allowlist (any other path: stop and report a NEED)
`project/features/combat/weapons/art/fx/rocket.png`, `fx/nuke_shell.png` and other in-flight copies of these two rounds under
`project/features/combat/weapons/art/**` (name them in the report), `evidence/n30/rounds/**`, `build/**`, the masters dir.
Forbidden: weapon held/item/pickup art (keys' files: `held*`, `pickup*`, `showcase/**`, icons), print/look code, `weapon_fx_electro.gd`,
`weapon_fx_bolt.gd`, `tools/film/kill_reel*`, other lanes' worktrees.

## Report and END
Files, commits, commands with result lines, counts, what you saw in the stills, what you could not do.

## Clock (this call, started ~11:37)
Commit A by 12:05, commit B by 12:22, report and END by 12:28 whatever is left (the session that runs you stops at 12:33:
uncommitted work is lost). Another builder (c05, kill card fall) runs Godot here: serialize as above.
