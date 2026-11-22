# Brief n24-melee P6b (resume): keep the saw's hold exactly as it is, change only its look

**Hard stop 00:05 wall clock. Commit deadline 23:59 (no commit after 00:00).** Check `date` now.

Director's decision on your NEED (thank you for stopping at the allowlist): do NOT touch the hold mechanics. The
shipped `stun_ticks` 16 already holds the saw's victim (your probe: all 16 ticks), so the sim stays byte-identical.
Only the LOOK changes: a victim whose stun comes from a non-electric melee hit is not drawn with electric sparks.

## Wanted (view only, zero sim/replay change)
1. `project/features/combat/weapons/fighter_fx.gd`: add exactly ONE line, a view-only field, e.g.
   `var hold_look_until: int = -1  ## n24 melee: tick until which the stun is a physical hold (no electric look); view only, not in write_state`
   It must NOT be written by `write_state` (so no tape, replay, parity or digest moves) and must not be read by any
   sim decision. (If the doc comment needs its own line, two lines are fine.)
2. Our melee contact (`melee_contact.gd` or `player_shock.gd`, your choice) sets it when a hit whose row says the stun
   is not electric applies its stun: `fx.hold_look_until = <the same tick clock the renderer uses> + stun ticks`.
   Row value: `stun_look` in `melee_weapons.json` (`"electric"` default when absent, `"hold"` on `chainsaw_1` and
   `chainsaw_drive`); add it to the schema. Verify which tick the renderer's `tick` is and use that clock.
3. `project/features/combat/weapons/fight_areas_art.gd:36`: ONE-line call-site change, e.g.
   `if e.stun_ticks > 0 and tick > e.hold_look_until and not WeaponFxElectro.stun(...)`.
4. Our own react views that draw electric current on any stunned body: check `project/features/combat/react/shock_arcs_view.gd:91`,
   `stun_crowd.gd:26`, `react_link.gd:184`; where one DRAWS electric current, apply the same check (they are ours).
   Where one only drives a pose/react timing, leave it.
5. A unit test: a saw hit leaves `stun_ticks` exactly as before (16) AND sets `hold_look_until`; a baton hit leaves
   `hold_look_until` at -1. And one that `write_state` bytes are identical with and without `hold_look_until` set.

## Acceptance
- After frames at ticks 42, 46, 50, 57 at 32 and 64 px/m beside your before frames in
  `C:/Users/kazda/kiro/gtai-masters/n24/melee/kills/p6/` (`chainsaw-32-after.png`, `chainsaw-64-after.png`,
  `electro_baton-32-after.png`, `electro_baton-64-after.png`). LOOK at them: no white zigzag on the saw victim, saw
  sparks + blood stay; the baton still shows its flash and arcs. Say in one line each what reads.
- `node tools/tests/run_unit.mjs --changed` green; the chainsaw and baton scenarios pass; no digest moves.
- `node tools/gate/quick.mjs` before the commit.
- After the commit: `node tools/mutate/mutate.mjs --file=project/features/player/melee_contact.gd --max=20 --lines=<changed lines>`; quote it.
- One commit. In the message body name the two call-site lines in `fighter_fx.gd` and `fight_areas_art.gd`.
- Then (only if it is before 23:45) append ONE line to `docs/decisions.md`:
  `- [2026-11-22] DECISION n24 melee: a click that lands while a swing (or a chainsaw grind) still runs is dropped, not buffered; a one-press buffer after recovery is the alternative if the owner finds it sluggish. The saw's hold keeps its stun ticks and loses only the electric look (view-only hold_look_until, not hashed).`
  and commit it separately (`git commit -- docs/decisions.md`).
- Item 2 of the P6 brief (plasma blood) is CANCELLED tonight.

## Allowlist (this call)
`project/features/player/melee_*.gd`, `player_shock.gd`, `project/data/tables/melee_weapons.json` + its schema,
`project/features/combat/react/**`, ONE line (two with a doc comment) in `project/features/combat/weapons/fighter_fx.gd`,
ONE line at `project/features/combat/weapons/fight_areas_art.gd:36`, tests named for these, `docs/decisions.md`
(one appended line). Anything else: stop and report a NEED. Forbidden: `fight_areas.gd`, `combat_arena.gd`,
`enemies.json`, `weapons.json`, `combat.json`, `input_actions.json`, ai/**, gauntlet/**, souls/**, characters/**.

## Setup and law (unchanged)
`export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/melee` and `GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
before every Godot run; one Godot at a time; `--position 0,1440`, `--rendering-driver d3d12`; free your own
processes by PID. Typed GDScript, warnings are errors, files about 200 lines (hard 300), functions <= 40 lines,
5 params; `Log` not `print`. Stage per path; no `add -A/./-u`, no `commit -a`, no stash, no amend, no rebase, no
reset --hard, never push. Fix lint and format findings in your own edit and go on.

## Report
Commit shas + files, the two shared lines quoted, after-frame paths with one line each, tests, quick gate, mutate.
