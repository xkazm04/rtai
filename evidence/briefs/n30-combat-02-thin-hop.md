# n30 combat call 02: the chain hop and daze stun back to the thin look; bold current only for the bolt

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. You start ~11:20. **Commit the code by 11:50,
evidence by 12:15, hard stop 12:25 (report and END).** Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot at a time in this worktree (another builder here only runs node tests). Every Godot launch goes through the
shipped tools (`tools/dev/run.mjs`, `tools/film/*.mjs`, `tools/lib/godot.mjs` `runGodot`), never raw `$GODOT_BIN`.
Windowed runs: `--position 0,1440`.

## The owner's verdict (2026-11-25, verbatim in docs/decisions.md:1598)
"the chain hop and stun go back to the thin look, bold current only for the bolt". `fx_amber_ink` stays on.

## What you need to know
- `project/features/combat/weapons/art/weapon_fx_electro.gd` (199 lines, at its soft cap: the debt ratchet counts lines;
  keep it <= 200 or move code into `weapon_fx_bolt.gd`): `BODY_PX` 10 / `CORE_PX` 4 / `INK_EXTRA_PX` 3 in `add_path` are
  shared by the bolt (`WeaponFxBolt`, `weapon_fx_bolt.gd`), the chain hop (`chain_plan`) and the daze stun (`stun_plan`,
  stars without ink). n29 commit `a33cfc186` made them one width; `87a5688c0` made `chain_plan` also call
  `WeaponFxBolt.amplify` (`JAG_K` 3.0). Read `evidence/n29/electric/bolt.md` and `git show a33cfc186 87a5688c0`.
- The thin look the owner wants back = `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/electro_hop_pair_64_thin.png`
  (right half = the hop at that time; the n28 hop, before any JAG_K: n28 commit `2d2f12f69`). In n28 the hop's translucent
  halo printed cream with a faint amber glow (the print dissolves translucent strokes). **Target:** the same thin weight
  (measure the stroke's across-path width in that still and match it within +-1 px at 64 px/m), its n28 kink (no JAG_K on
  the hop), but **amber**: give the hop and the stun an opaque amber body (ElectricArc.HALO, opaque) + cream core at the
  thin width, no ink outline (if amber at that width vanishes on the floor, a 1 px ink rim is allowed: say so and show it).
- Implement as separate constants for the thin path (e.g. `THIN_BODY_PX`, `THIN_CORE_PX`, a `thin` arg to `add_path` or a
  `HOP_JAG_K` 1.0), so going back to bold for hop/stun is one value. The bolt (`WeaponFxBolt`) stays exactly as it is
  (bold 10/4/ink 13, JAG_K 3.0): its pixels must not change (prove it: the bolt-in-flight still at tick 114 is identical
  before/after, 0 px diff in the bolt box).
- Hop take: `node tools/film/owner_takes.mjs <dir> 64 electro_gun_hop` (and `32`), hop at tick ~119-121, two robot thugs.
  For the stun you need a stunned human: find a shot that stuns one (`FightAreasArt` draws it via `StunCrowd.electric`
  in `project/features/combat/weapons/fight_areas_art.gd:36`; look at `tools/film/electric_stills.gd`/`.tscn`,
  `project/dev/weapon_art/electro_cells_view.gd`, `tools/film/film.mjs` shots, owner_takes items `electro_baton`/
  `claw_shock`). Use the first one that shows daze stars at 64 px/m; name it in the evidence.
- Before = HEAD `5114a4441` (render it first, before your edit, or from a temp worktree; never write `git show` PNGs into the tree).

## Acceptance (numeric)
1. Hop and stun: across-path stroke width at 64 px/m within +-1 px of the thin still's; amber present (count px near
   #edab42 in the hop box > 0); red 0 (R>170 G<110 B<90) and teal 0 in the hop and stun boxes (list the counter you use).
2. Bolt in flight (tick 114 of the hop take, 64 px/m): 0 px diff in the bolt box before/after.
3. Tests: update `project/tests/unit/test_weapon_fx_electro*.gd` pins that fix the hop/stun widths; add a test that the
   bolt keeps BODY_PX and the hop uses the thin width. `node tools/tests/run_unit.mjs --select=test_weapon_fx_electro,test_weapon_fx_electro_hash` green.
4. `node tools/lint/lint.mjs` green (fix lint and format findings in your own edit and go on); `node tools/debt/debt.mjs --check` green.
5. Mutate after the commit: `node tools/mutate/mutate.mjs --file=features/combat/weapons/art/weapon_fx_electro.gd --lines=<changed> --max=12 --tests=test_weapon_fx_electro,test_weapon_fx_electro_hash`, budget 15 min; quote killed/(killed+survived).
6. Evidence (masters `C:/Users/kazda/kiro/gtai-masters/n30/combat/`): `stills/hop_thin_pair_64.png` (before | after,
   same tick, labelled), `stills/stun_thin_pair_64.png` (same), `films/hop_thin_32.mp4` (the two-thug hop take at 32 px/m,
   1920x1080, 60 fps, 15-40 s; ffprobe it and quote the line). Add entries to `frames.json` there (create it as a JSON
   array of `{ "file", "title", "ppm", "before", "note" }`, paths relative to that dir). Write `evidence/n30/electric/thin.md`
   with the commands, ticks, widths and counts. **Look at each still yourself before committing** and say what you see.

## Commits (stage per path; never `git add -A/./-u`, no stash, no amend, no rebase, no reset --hard)
A: code + tests (by 11:50). B: evidence md (masters are outside the repo). End each message with
`Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. The pre-commit hook can take ~12 min on this machine; never skip it.
Do not touch `docs/decisions.md` (the director writes it).

## Allowlist (any other path: stop and report a NEED)
`project/features/combat/weapons/art/weapon_fx_electro.gd`, `.../weapon_fx_bolt.gd`, `project/tests/unit/test_weapon_fx_electro*.gd`,
`evidence/n30/electric/**`, `build/**`, the masters dir above. Forbidden: `tools/film/kill_reel*` (another builder), keys/cast/yard
files, `project/boot/collect_call/**` (CurrentLook is a different path; do not change it), `docs/decisions.md`, JOURNAL.md, REPORT.md.

## Report and END
Files, commits, commands with result lines, widths/counts, what you saw in the stills, what you could not do.
