# Brief 03 (street lane, n23): enemy rounds not red, and the shove wedge at full reach

Hard stop: HARDSTOP wall clock (check `date`). Commit deadline: COMMITBY. Two parts, each committed before the next. If you are not done, commit what is green and report what is left.

## Setup for every Godot run
`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Anything that renders: `--rendering-driver d3d12`; any window `--position 0,1440` (secondary screen, never the main display). One Godot process at a time. Never kill processes by name; only a PID you started. Read `tools/README.md` for the film kit (`tools/film/film.mjs`, `compare.mjs --a=<commit> --b=<commit>` for same-tick before/after, `sheet.mjs`).

## Part A: enemy rounds are not red (owner: "recolour enemy rounds away from red")
Colour law: red is blood only; cops are blue; vermilion only for danger, objectives and Rivet's collar; **teal only for souls**; amber allowed for heat, overload and a cancelled cast. Rivet's own hits read red-ish on bodies. Enemy rounds must read as a threat against blood, asphalt and the pick screen.

Today `project/features/combat/weapons/gun_fx_art.gd` `tracer()` gives an enemy round `Ink.VERMILION` as core (line ~92). Find every place a HOSTILE round, its trail and its muzzle flash is drawn (grep `from_rivet`, `foe_ordnance_view.gd` for rockets/shells/war cannon, the hostile muzzle flash in `gun_fx_art.gd` / `gun_fx.gd`, large-round drawing). Do not touch Rivet's own rounds.
1. Put the new colours in one new file `project/features/combat/enemy_round_look.gd` (class `EnemyRoundLook`, consts only: small core, small glow/casing, large core, large rim, muzzle). Small rounds: a hot amber-white core (e.g. near `#FFE6A8` core on a deep amber `#E08A1E` rim). Large rounds (the ones to dodge): a cyan-white / ice core (e.g. `#E8FBFF` core, `#7FD8F0`-ish rim) that is clearly NOT soul teal: compare against the soul teal constant in the code (grep `TEAL` in `Ink` / ghost views) and keep the hue distance obvious (lean blue-white, high lightness, low saturation). So the two sizes also differ by colour.
2. Use `Shot.size` (`SMALL`/`LARGE`; `size_known`) to pick; an unknown size draws as small.
3. Colour only: no hitbox, speed, timing, spawn or RNG change. Prove it: the 60 s replay and the scenario suite stay green (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`), and no sim digest moves. If a pixel golden under `project/tests/golden/` or a reel compares these pixels and fails, do not re-pin it: report it.
4. Stills before and after at 32 px/m, tilt 70, 1080p, at the same tick: enemy small rounds and a large round (rocket trooper or war machine) in flight, (a) over a blood-covered floor, (b) on plain asphalt, (c) behind the gauntlet pick screen. Use the gauntlet (`project/dev/gauntlet/gauntlet.tscn`, `--pick-view` films the pick screen; `project/dev/gauntlet/gauntlet_stills.gd` exists, read it) or a `tools/film/film.mjs` shot, whichever gives the same tick before/after (`compare.mjs`). Plus one 64 px/m close-up of each size after. Output to `C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/` with names `rounds-<scene>-<before|after>-<ppm>.png`. Look at every still yourself and say in your report what you see (is the round visible on blood? on asphalt? does large differ from small?).
Commit A.

## Part B: the shove wedge at full reach (owner: "draw the wedge to the full reach")
`project/features/combat/squad/foe_shield_view.gd` `_shove_lane()` draws the shield robot's shove mark from the carrier's CURRENT position, `reach_m` long (1.8 m), 13 to 23 px wide. The real hit (`project/features/combat/squad/foe_shield.gd`, end of `_lunge`) is tested at the END of a lunge of `LUNGE_TICKS` (15) ticks at `arch.speed_mps` along the locked `e.aim`: Rivet is hit when `0 <= forward <= reach_m + rivet.radius_m` and `|lateral| <= rivet.radius_m + SLAB_HALF_M` (0.32), measured from the lunge's end position. So the drawn mark is shorter (no lunge distance) and slides with the carrier.
1. Add one pure static function (in `foe_shield.gd` or a new `project/features/combat/squad/foe_shove_zone.gd`, class `FoeShoveZone`) that returns the danger zone polygon in world metres for Rivet's BODY: from the tell's start position along `aim`, covering the lunge then the reach, `SLAB_HALF_M` half width, so that Rivet's body touching the zone == the hit test true (allowing that the hit test is on Rivet's centre; work out the exact shape, e.g. a strip from the lunge end back ... to lunge + reach, and say what you chose). Use the same numbers the hit uses (`reach_m`, `speed_mps`, `LUNGE_TICKS`, `SLAB_HALF_M`, `TICK_DT`): one source. If walls can stop the lunge early, use the full lunge (the mark may only ever be larger than the danger, never smaller).
2. The view draws exactly that zone (fill + vermilion rails; the vermilion is right here: danger), anchored at the world position where the tell started (not sliding during the lunge), shown from the tell through the lunge. Keep a wedge / arrow read at the far end if you can do it INSIDE the zone. Vermilion stays for danger.
3. Unit test `project/tests/unit/test_foe_shove_zone.gd`: for a few aims and speeds, sample Rivet centre positions whose body is just outside the zone (0.05 m clear of it on each side and past the far end) -> the real hit test says miss; positions just inside -> hit. Call the real hit predicate (factor it out of `_lunge` into a pure static, e.g. `FoeShield.connects(delta, aim, reach, rivet_r) -> bool`, so the sim path calls the same function; no behaviour change: prove with the scenario suite and the replay staying green).
4. Stills: shield robot telegraphing a shove, before and after, 32 px/m tilt 70 and a 64 px/m close-up, to `C:/Users/kazda/kiro/gtai-masters/n23/street/wedge/`. Look at them and report.
Commit B. Then `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_shield.gd --max=20 --lines=<changed lines>` and quote killed/(killed+survived).

## Acceptance checks (quote results in your report)
- `node tools/gate/quick.mjs` clean. Fix lint and format findings in your own edit and go on.
- `node tools/tests/run_unit.mjs --changed` green.
- scenario suite summary line, unchanged pass count.
- `node tools/debt/debt.mjs --check`; on `tighten:` run `--update` and commit the baseline.
- New `.gd` files: run `"$GODOT_BIN" --headless --path project --import` once and commit the `.uid`.

## Commit
Staged per path (`git add <path>`; never `-A`, `.`, `-u`, `commit -a`, stash, amend, rebase, reset --hard, push). End messages with
`Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Allowlist (edit only these)
Part A: `project/features/combat/weapons/gun_fx_art.gd` and the other files that DRAW hostile rounds / their trails / their muzzle flash (name each in your report; colour lines only), `project/features/combat/squad/foe_ordnance_view.gd` (colour only), new `project/features/combat/enemy_round_look.gd`, `project/features/combat/shot*.gd` (drawing only). Part B: `project/features/combat/squad/foe_shield_view.gd`, `project/features/combat/squad/foe_shield.gd` (only the pure hit predicate extraction; no behaviour change), new `foe_shove_zone.gd`, the new test. Both: `C:/Users/kazda/kiro/gtai-masters/n23/street/**`, `evidence/street/**`, `tools/debt/baseline.json` through the debt tool, `.uid` files of new scripts.
Forbidden: `project/features/player/**`, `project/features/gauntlet/bot/**`, `tools/gauntlet/**`, `project/data/tables/enemies.json`, `combat.json`, `gauntlet_bonuses.json`, `project/features/combat/combat_arena.gd`, `project/features/combat/ai/**`, `project/features/souls/**`, `project/boot/**`, tapes and goldens, JOURNAL.md, REPORT.md. Any other path: stop and report a NEED.
