# Brief n29-combat-02b-red-muzzle: every muzzle-flash core from vermilion to amber (red audit, muzzle group)

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" at the end (binding). At the hard stop write your report and END, even
mid-task.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on. Fix lint
and format findings in your own edit and go on. No amend, no rebase, no push. Read `AGENTS.md` (repo law) first, briefly.

## Why (owner, 2026-11-25)
"Fire and muzzle cores to amber." Audit `evidence/n28/red/audit.md` rows 5-10 (and 11: `rocket.png` / `nuke_shell.png`
are Rivet's own rounds: decide amber or keep, by the colour law: they are not danger to the player; say which). The fire
group (rows 1-4) was done by call c2a: read its commit, `evidence/n29/red/fire.md` and its script
`evidence/n29/red/recolour.py` (deterministic hue remap of the reddish band to the `#edab42` amber hue, keeping alpha and
value). **Reuse that script** (add file/cell arguments if needed; never change its result on the fire files: re-running
it on them must be a no-op, check that).

## What
A. **Before stills first** (current tree): 64 px/m in-game stills at fixed ticks of a pistol, an SMG, the rocket tube and
   the mini-nuke firing (the `flash_*` cells, `WeaponFxArt` muzzle), and the d4 `muzzle` kind (`fx.json` kind `muzzle`,
   `fx_atlas.png` cells 0-2) plus a small burst / ricochet star (cells 8, 13, 14). Use what c2a used (`evidence/n29/red/fire.md`
   lists its commands) and the take tools it names. Stills + crops to
   `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/red_muzzle_<gun>_before_64.png`; commands + ticks into
   `evidence/n29/red/muzzle.md`; reddish px per crop (c2a's crop counter).
B. **Repaint** with `recolour.py`: `project/features/combat/weapons/art/fx/flash_{nuke,tube,pistol,smg}_*.png` and their
   `colour/` variants, `fx_atlas.png` cells 0, 1, 2, 8, 13, 14 only (cells 9-12 were done by c2a: leave them, hash them
   before/after; every other cell byte-identical). The cream core must stay cream where it is cream: only the vermilion
   ring/core pixels move. Godot `--import`, `test_map.mjs` on each file + mapped tests, `run_unit.mjs --changed`, re-pin
   only pure consequences (list each). Commit B with ONE `docs/decisions.md` line
   `- [2026-11-25] DECISION n29 combat: muzzle-flash cores (flash_pistol/smg/tube/nuke + colour variants, fx_atlas muzzle cells 0-2, 8, 13, 14) repainted from vermilion to amber by the same hue remap (evidence/n29/red/recolour.py); red audit rows 5-10<, row 11 ...>.`
C. **After stills** at the same ticks, pairs `red_muzzle_<gun>_pair_64.png` (before left, labelled), px table in
   `evidence/n29/red/muzzle.md`. LOOK at each pair at full size: a flash must still read as a flash (cream core, amber
   star), never pink or brown. Commit C. Then a 32 px/m clip 1920x1080 60 fps 15-40 s of guns firing after
   (`films/red_muzzle_after_32.mp4`, ffprobe) and frames.json entries (re-read before writing; keep entries).

## Repo law, allowlist
As `evidence/briefs/n29-combat-02a-red-fire.md` "Repo law" (APPDATA `C:/Users/kazda/kiro/gtai-n29/appdata/combat`,
`GODOT_BIN`, `GTAI_GODOT_EST_MB`, d3d12, `--position 0,1440`, one Godot for the lane, quick gate + hook, ~12 min hook,
banned git verbs, trailer `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`). Allowlist: the `flash_*` PNGs
(+ `colour/`), `rocket.png`/`nuke_shell.png` (row 11 only), `fx_atlas.png` cells 0-2, 8, 13, 14, `evidence/n29/red/**`,
pure-consequence re-pins under `project/tests/**` / `art_src/*manifest*`, `docs/decisions.md` (one line), `build/**`,
`C:/Users/kazda/kiro/gtai-masters/n29/combat/`. Forbidden: every other PNG (held, pickup, icon art is keys'), tables,
code outside tests, `project/boot/prologue/**`, the HUD files, other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; px table; pair/film paths + ffprobe; how they read; gates; re-pins; row 11 call; what was left.
