# Brief n29-combat-03b-bolt-bold: the electro bolt and its chain hop read as strong current at 32 px/m

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" at the end (binding). At the hard stop write your report and END, even
mid-task, committed.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on.
Fix lint and format findings in your own edit and go on. No amend, no rebase, no push. Read `AGENTS.md` (repo law) briefly.

## Why
Owner (2026-11-25): "the in-flight electro bolt in the halo look", live current like the chain hop. The last call
(commits 3e2fde824, 3ba4b1fdd, 25fb82801, 8b356974f; notes `evidence/n29/electric/bolt.md`, read it first) shipped
`WeaponFxBolt` (`project/features/combat/weapons/art/weapon_fx_bolt.gd`, a 5 px opaque amber body + 2 px cream core) and a
take `electro_gun_hop`. The director LOOKED at `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/electro_hop_pair_64.png`
(top = `--electro-cells`, bottom = current): the new bolt is a thin hairline next to the old bold ink-rimmed zigzag, and
the **shipped chain hop between the two thugs is a faint, almost invisible line** (its translucent amber halo dissolves in
the arena print: only the 2 px cream core survives, cream on a pale floor). Colour law is met; boldness is not.

## What
A. **One width value, applied to the bolt, the chain hop and the stun.** In `WeaponFxElectro` (the shared `add_path`, used
   by `chain_plan`, `star_plan`, `stun_plan` and `WeaponFxBolt.plan`) add an **opaque amber body stroke** (`ElectricArc.HALO`
   colour, alpha 1.0) between the translucent halo and the cream core, width from ONE const (e.g. `BODY_PX`) that both the
   bolt and the chain use (remove the bolt-only body so there is one value). Start at **body 8 px, core 3 px** (screen px
   at k = 1) and tune by looking. Keep a thin dark outline under the body only if the stills show amber on the pale floor
   does not separate (an ink stroke 1-1.5 px wider than the body, `Ink.INK` or the ink the cells use; it is allowed on the
   new path if it is what makes it read, say so). Give the head star the same body. Do NOT change `ElectricArc.strokes()`
   or its consts (the kill/wreck arcs use them and the owner accepted those). `--electro-cells` keeps the old draws exactly.
   Presentation only: no sim state, replay and parity unchanged, no RNG.
   Tests in `project/tests/unit/test_weapon_fx_electro.gd`: the chain plan and the bolt plan both carry an opaque amber
   stroke of exactly `BODY_PX * k` width; core narrower than body narrower than outer halo; same inputs -> same plan.
B. **Look before commit (binding).** Re-render the owner take at 64 px/m, both arms, at the tick of the old stills
   (`bolt.md` has the commands: `TAKE_FLAGS=--electro-cells node tools/film/owner_takes.mjs <dir> 64 electro_gun_hop`, and
   without the flag), and a 32 px/m still of the hop. The bar: at 32 px/m the bolt and the chain hop are each **at least
   6 screen px wide of opaque amber/cream** (measure the stroke width in the PNG across the path, quote it), and read at
   least as strong as the cells zigzag. Colour check on the crop: count pixels with hue <= 20 or >= 340, s > 0.5, v > 0.4
   (red/vermilion) and hue 160-200 s > 0.3 (teal) inside the effect box: both must be ~0 (quote them). Commit A
   (code + tests + one appended `docs/decisions.md` line saying the width and that the chain hop and stun now share it).
C. **Films.** Re-render `electro_bolt_{cells,current}_32.mp4` and the labelled side-by-side `electro_bolt_pair_32.mp4`
   (cells left) at 32 px/m, 1920x1080 for the singles, 60 fps, 15-40 s (ffprobe each), stills
   `stills/electro_bolt_{cells,current,pair}_64.png` + `stills/electro_hop_pair_64.png` overwritten with the new look (keep
   the old current still as `stills/electro_hop_pair_64_thin.png` = the "before" of this call). Update
   `C:/Users/kazda/kiro/gtai-masters/n29/combat/frames.json` (re-read it first, keep other entries, one entry per file).
   Update `evidence/n29/electric/bolt.md` (width, measured px, colour counts, film ffprobe). Commit B.
D. **Mutate** (budget 12 min each, if time remains):
   `node tools/mutate/mutate.mjs --file=project/features/combat/weapons/art/weapon_fx_bolt.gd --max=20 --tests=test_weapon_fx_electro`
   then the same on `weapon_fx_electro.gd` with `--lines=<your changed lines>`. Quote killed/(killed+survived) in bolt.md,
   commit.

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe GTAI_GODOT_EST_MB=1000`.
  `--rendering-driver d3d12` for renders; windowed only at `--position 0,1440`. Godot only through `tools/dev/run.mjs` /
  `runGodot` / film tools. **One Godot at a time for the whole lane**: another builder (kill scale, test runs) works beside
  you; before each Godot run check `tasklist //FI "IMAGENAME eq Godot*"` and wait if one runs that you did not start.
  Never kill a process you did not start, never by name. `mem-budget: waiting` = the 16 GB cap: wait.
- `node tools/gate/quick.mjs` before every commit (its standalone parse of `weapon_fx_electro.gd` / `weapon_fx_art.gd`
  fails even unchanged, Log autoload chain: compare against the base commit, do not chase it). The pre-commit hook takes
  up to ~12 min; if it fails on `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again. Never
  skip the hook. `run_unit.mjs --select=test_weapon_fx_electro,test_electric_arc` green before commit A.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with new `.gd`.
  Stage per path. Banned: `git stash`, `git add -A/./-u`, `git commit -a`, `reset --hard`, amend, rebase, push.
  `docs/decisions.md`: append your one line and stage only that file right before committing (another builder may append
  too: if the diff shows a line that is not yours, commit anyway, both lines are legitimate). Commit trailer:
  `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.
- Never delete anything in Temp you did not create; report it.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/features/combat/weapons/art/weapon_fx_electro.gd`, `weapon_fx_bolt.gd`, `weapon_fx_art.gd` (the BOLT branch only),
`project/tests/unit/test_weapon_fx_electro.gd`, `tools/film/owner_take*.gd`, `tools/film/owner_takes.mjs`,
`docs/decisions.md` (one line), `evidence/n29/electric/**`, `build/**`, `C:/Users/kazda/kiro/gtai-masters/n29/combat/`.
Forbidden: `electric_arc.gd`, every PNG in the repo, every table, `project/boot/**`, `project/features/combat/kills/**`,
the HUD files, the sim, other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; body/core px; measured on-screen widths at 32 and 64 px/m; red/teal counts; still + film paths with ffprobe;
how it reads (one honest sentence); units; mutate scores; what was left.

## Wall clock (binding)
Started 03:50. Commit A (code + tests + decisions line, after the 64 px/m look) by **04:30**. Commit B (films, stills,
frames.json, bolt.md) by **04:50**. HARD STOP **05:00**: report and END, committed. Mutate only if B is in.
