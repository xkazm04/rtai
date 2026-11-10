# REPORT: lane n12-visual (visual quality of the engine and of combat), night 2026-11-09/10

Branch `n12-visual`, cut from main `812a0b061`, code head `bcf6d76b2` (the gates ran on it). One Opus
builder, five groups, reviewed group by group by the Director. Nothing is merged or pushed. The
detail, per group, with commands and figures, is in `JOURNAL.md` beside this file ("Group A report"
to "Group E report", then "Night summary"). Films and stills: `C:\Users\kazda\kiro\gtai-masters\n12\visual\`
(index `frames.json`).

## The ten ideas

| Idea | State | Reverse with |
|---|---|---|
| Ink line weight on impact | shipped ON (struck figure only; the world-print radius is not done) | `ink_edge_px` 0 per class in `hit_feel.json`, or `--feel=off` |
| Plate misregistration shock | built, shipped OFF (not visible at 32 px/m) | `plate_shock_px` 3 (blast, slam) / 2 (ram) turns it on |
| Per-weapon camera grammar | mostly existed; a `ray_gun` row ON; zoom punch not built | remove the `ray_gun` row |
| Victim sync | mostly existed; melee and heavy wounds react on the hit frame, ON | `--react-snap=off --wound-hold=off` |
| Light from combat | shipped ON (arena and city block fight) | `combat_lights.on` false in `lights.json` |
| Battle residue | shipped ON, partly (ground scuffs only, faint) | `on` false in `battle_residue.json` |
| Occlusion and depth | no hidden fighter found; the dropped pistol's depth fixed, ON | `GUN_ON_FLOOR` false |
| Melee holds, swings, plasma sword | not done (audit; three sword treatments as stills) | none |
| Crowd panic ripple | built, shipped OFF (the trial lost a reaction) | `crowd_ripple.mps` 12 turns it on |
| Headroom | first-use art loads warmed behind the load, ON; `node tools/perf/fight_gate.mjs` | `--strip-prefetch=off` |

## Gates at `bcf6d76b2`

Lint 15/15, unit 2251 passed / 0 failed, scenarios 55/55, parity bit-exact over 1200 steps, look
goldens 11/11 and block 5/5 at 0.00, debt ratchet ok (accepted rises are named in the JOURNAL).

## Read these figures with care

- Every timing of the night was taken with other processes on 3-16 of the 16 cores. No paired gate
  verdict was better than a WASH, and Group E's span figures are single runs with no A/A pair.
- The city fight read p99 8.6-12.2 ms under that load, against the 7 ms hard limit of section 20.
  It was not judged; it needs a quiet bench run.
- Inherited and not fixed: `test_quest_blade` fails when run alone; `tools/godot/check.mjs`
  false-fails on scripts that reach the `Log` autoload.

## Calls for the owner

1. Melee wound throw and the melee hit-stop's 2-tick delay (ON).
2. The ray gun's stream without per-round stops (ON).
3. Ink line widths per class (ON).
4. Plate shock (OFF): turn on, or drop.
5. Plasma sword treatment: as shipped, A (cream core), B (heavier ink rim) or C (both).
6. Drawn wind-up cells for the plasma sword, katana and baton (art).
7. The dropped pistol is a placeholder polygon: draw a cell, or drop the effect.
8. Combat lights (ON): keep or switch off; radius and muzzle/blast switches are data.
9. Battle residue (ON, faint): keep alpha 0.6, raise it, or switch off; scorch and casings not built.
10. Crowd ripple (OFF): leave off, try it, or commission the real wave (crowd flinch art, or a sim
    panic stagger, which would touch parity).
