# REPORT - lane cast, run n24 (2026-11-22), branch `n24-cast`

DRAFT (session 3, 20:50): sections marked TODO are filled at the report pass after the freeze.

Owner's note 5: "Design of new characters when added to waves should be always finetuned from start to have cop-level
quality (animations, clean cut and shape), assume we will use all characters in some form in the game". This lane
redraws the four new wave enemies from the owner's concept picks (`gtai-art/foes-n22/out/`, picks at the end of
`foes-n22/notes.md`) to the patrol cop's standard, near Rivet's size, and wires each finished one into the game behind
`project/data/tables/cast_cards.json` (one row per enemy, `enabled`). No enemy number changed (`enemies.json` is not in
this branch's diff from `b3f4727c0`).

Final commit: TODO. Gate: TODO (`node tools/gate/run.mjs --rev=HEAD`, quote line and `gate.json` path).

## 1. Audit (brief item 1)
Full table with every checklist item per archetype: `docs/art/cast-audit.md`; the checklist: `docs/art/cast-checklist.md`
(commit da91b9083). Contact sheets: `C:\Users\kazda\kiro\gtai-masters\n24\cast\audit_lineup_{32,64}ppm_tilt{70,55}.png`.

At the start of the run, at 32 px/m tilt 70 (Rivet 77 px, patrol cop 43 px):

| Archetype | Drawn with on main | Height px 70/55 | Fails (of 15 items) |
|---|---|---|---|
| patrol_cop | own sheets (the standard) | 43 / 45 | 3: attack tell, feet, provenance |
| riot_cop | own sheets | 53 / 55 | 3: cut, feet, provenance |
| swat | own sheets, pistol drawn | 52 / 54 | 4: identity, attack tell, feet, provenance |
| robot_thug | own articulated rig | 60 / 62 | 6: grid, pitches, ink, cut, shadow, provenance |
| robot_gunner | thug rig, aim feed | 65 / 61 | 10 |
| contractor | patrol look 5 (borrowed) | 57 / 59 | 8 (identity, walk, tell, hit, fall, palette, feet, provenance) |
| rocket_trooper | borrowed SWAT body + vector tube | 60 / 64 | 11 |
| sentry_turret | vector mount over a hidden thug rig | 88 / 78 | 10 (incl. scale) |
| shield_robot | thug rig x1.888 + vector slab | 121 / 119 | 12 (incl. scale) |
| war_machine | thug rig x2.838 + vector add-ons | 178 / 168 | 13 (incl. scale) |
| sergeant_mulroney | squad look + coat overlay | 51 / 48 | 11 |
| appliance_warden | cop body + overall dress | 72 / 69 | 11 |

## 2. What works
| Item | Evidence | Number |
|---|---|---|
| The lancer (rocket trooper) drawn from the owner's pick: walk, attack with kneel tell and backblast, hit, fall, 5 facings, both pitches | commits 0c7c09e39, f61bf1e09, 0228d57fe; `gtai-masters/n24/cast/lancer_{32,64}ppm_tilt{70,55}.png`, `lancer_close_64.mp4` | 1920x1080, 60 fps, 16.0 s; attack 3 takes, fall 2, walk 1, hit 1 |
| The door carrier (shield robot), bare slab with striped edges, slab as wide as the shove hit | commit f87537d4b; `gtai-masters/n24/cast/door_{32,64}ppm_tilt{70,55}.png` | slab 41 px (p55) / 46 px (p70) vs the shove's 40.96 px at 64 px/m; body 1.98 / 2.04 m |
| TODO clamshell, pile-driver, films, standing rule | | |

## 3. What does not
TODO

## 4. What blocked or slowed me (minutes)
- Image generation mixes up the diagonal and rear facings of machines: the pile-driver's front column came out as a plan
  view copied from the concept's inset (TODO minutes).
- A pre-commit tooling test (`tools/merge/morning_run.break.test.mjs`) timed out under five-lane load (TODO minutes).

## 5. Calls for the owner
TODO

## 6. Merge notes
- Shared render files touched by one-line call sites only: `project/features/arena/arena_robot_rigs.gd` (door card),
  TODO the rest from the briefs' reports.
- `cast_cards.json` `enabled` per row: false = everything as on main.

## 7. Next steps
TODO

## 8. Astra ledger
| Call | Minutes | Result | Brief differently |
|---|---|---|---|
| audit | 54 | accepted | - |
| lancer | 72 | accepted (attack cols 4-5 bounced to round 03) | ask for a per-column facing check against the cop, not only the cut |
| film-door | 66 | accepted, the 32 px/m film bounced (1280x800) | name the window resolution flag and a survival condition for the filmed enemy |
| clamshell | TODO | TODO | |
