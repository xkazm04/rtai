# REPORT - lane cast, run n24 (2026-11-22), branch `n24-cast`

Written by the cast director, session 5 (2026-11-23 00:05); gate line updated in sessions 6 (01:32) and 8 (01:41).

Owner's note 5: "Design of new characters when added to waves should be always finetuned from start to have cop-level
quality (animations, clean cut and shape), assume we will use all characters in some form in the game". This lane
redraws the four new wave enemies from the owner's concept picks (`gtai-art/foes-n22/out/`, picks at the end of
`foes-n22/notes.md`) to the patrol cop's standard, near Rivet's size, and wires each finished one into the game behind
`project/data/tables/cast_cards.json` (one row per enemy, `enabled`). No enemy number changed (`enemies.json` is not in
this branch's diff from `b3f4727c0`).

Final code commit: `79c0c434b` (everything after it is JOURNAL/REPORT/briefs, inert). Gate: the 00:00 run of
`node tools/gate/run.mjs --rev=HEAD` on `6129b8f69` reached scenarios 67/67 ok, then died with the director's session 5
while waiting out a CONTENDED city_chase nav budget (log `build/gate/6129b8f69237/evidence.log`, git-ignored). Re-run
started 01:30 on `fc3b7b2bb`, detached (pid 29024), log `C:\Users\kazda\kiro\gtai-art\foes-n24\gate-final2.log`; it
takes about 20 min, so its verdict and `gate.json` path land after this report: the Director reads that log at merge.
At 01:41 (session 8) it was still in its lint stage inside the snapshot `%LOCALAPPDATA%\Temp\gtai-gate-fc3b7b2bbb75`
(pid 29024 alive; no evidence kind written yet). No green gate line is claimed here.

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
| The door carrier (shield robot), bare slab with striped edges, slab as wide as the shove hit; on by default | commits f87537d4b, 9c042d3e6, 9a8c74021; `gtai-masters/n24/cast/door_{32,64}ppm_tilt{70,55}.png`, `door_wave_32.mp4`, `door_close_64.mp4` | slab 41 px (p55) / 46 px (p70) vs the shove's 40.96 px at 64 px/m; body 1.98 / 2.04 m; films 1920x1080, 60 fps, 16.0 s |
| The lancer at 32 px/m in a street fight: tell, enemy rocket (ice blue, the owner's keep), hit, death | `gtai-masters/n24/cast/lancer_wave_32.mp4` | 1920x1080, 60 fps, 16.0 s |
| The clamshell (sentry turret): bolted plate, dome turns, tell glow, fire, hit, wreck, both pitches; on by default | commit b99a73a46; `gtai-masters/n24/cast/clamshell_{32,64}ppm_tilt{70,55}.png`, `clamshell_wave_32.mp4`, `clamshell_close_64.mp4` | plate 1.41 m wide, dome 1.16 / 1.19 m (70 / 55); films 1920x1080, 60 fps, 16.0 s; 2 takes per sheet |
| The standing rule: a character enters a wave only when it passes the checklist | commits 1343b32fe, 12edb6c2a; `docs/art/cast-checklist.md` section "Wave admission", `docs/decisions.md` line art/wave-admission | 15 items, patrol cop numbers per item |
| The pile-driver (war machine): walk, cannon tell + fire, stomp tell + slam, hit, wreck, both pitches; on by default | commit 718fee5b0; `gtai-masters/n24/cast/pile_{32,64}ppm_tilt{70,55}.png`, `pile_wave_32.mp4`, `pile_close_64.mp4`, `pile_before_after_64.png` | 2.42 m (70) / 2.47 m (55) beside Rivet 1.65 m; 78 px vs Rivet 77 px at 32 px/m; films 1920x1080, 60 fps, 16.0 s |
| Mutation-killing tests for the clamshell and pile-driver card views | commit 6f37fe7fc; `gtai-art/foes-n24/06-mutate-turret.log`, `06-mutate-war.log` | `foe_turret_card_view.gd` 20/(20+0) (was 3/(3+17)); `foe_war_card_view.gd` 20/(20+0) (was 4/(4+14)) |
| The door carrier's boot plants through each held walk cell | commit 79c0c434b; `gtai-art/foes-n24/06-door-sole.json`; `docs/art/cast-audit.md` Feet row | slide 11 px -> 0 px per held drawing at 32 px/m, at ink thresholds 100, 125 and 145 |
| `stomp` is an optional sheet key for any cast row (no id branch) | commit 6aeed9768 | - |
| Owner comparison clips at 64 px/m: each redrawn enemy beside the patrol cop and Rivet, walk, attack with tell, hit, death | `gtai-masters/n24/cast/{lancer,door,clamshell,pile}_beside_64.mp4` (+ the `_beside_32.mp4` set); `frames.json` (13 entries) | 1920x1080, 60 fps, 16.0 s each (ffprobe); Rivet 118 px wide in the 64 clip, 58 px in the 32 clip |
| After lineup: the redrawn four beside every archetype, Rivet and the cop | commit bf9a9f796 (ASCII header); `gtai-masters/n24/cast/audit_after_lineup_{32,64}ppm_tilt70.png` | at 64 px/m: Rivet 154 px, cop 85, lancer 98, clamshell 107, door carrier 109, pile-driver 155 |

## 3. What does not
- **Feet**: the lancer's boot slides 10 px per held drawing at 32 px/m (`docs/art/cast-audit.md`, after-table; the
  door carrier's hold trick did not plant it in a trial). That is the same 10.24 px the shipped patrol cop itself
  slides (audit, "Original rig ground-contact measurements"): the reference fails this item too. The door carrier and
  pile-driver hold at 0 px; the clamshell does not walk.
- **Contact shadow**: the door carrier and clamshell draw no separate ground shadow, 0 separate shadow px in both
  measured facings (visible in
  `gtai-masters/n24/cast/door_before_after_64.png` and `clamshell_before_after_64.png`).
- **Not redrawn**: the prologue's appliance warden and Sergeant Mulroney (audit: 11 fails each), and the other wave
  archetypes that fail the checklist on main (robot_gunner 10, contractor 8, robot_thug 6). They keep main's look.
- The door carrier's slab at tilt 70 is 46 px against the shove's 40.96 px at 64 px/m (12% wider; p55 41 px matches).
- The real gauntlet film (`gauntlet_wave_cast_32.mp4`, seed 8, waves 5-8) shows the redrawn enemies only as small
  shapes in a dense crowd at 32 px/m; the door carrier and pile-driver do not spawn in it.
- The standalone parse check and `tools/gate/quick.mjs` are red on an arena dependency cascade that reproduces on main
  `b3f4727c0` (`Identifier not found: Log` at `part_library.gd:60` in a standalone parse): not caused by this lane.

## 4. What blocked or slowed me (minutes)
- Image generation mixes up the diagonal and rear facings of machines: the pile-driver's front column came out as a plan
  view copied from the concept's inset (estimate, not timed: about 40 minutes over two rounds of regeneration).
- A pre-commit tooling test (`tools/merge/morning_run.break.test.mjs`) timed out under five-lane load (estimate, not timed: about 10 minutes).
- The clamshell commit lost a race with a director journal commit while the builder ran (estimate, not timed: about 15 minutes to
  re-stage and re-check in the next call).
- The final gate ran in session 5's own background shell and died with it at the CONTENDED-budget wait (00:23); the
  re-run could only start at 01:30, so no gate verdict is in this report (timed: about 70 minutes of gate lost).
- The quick gate's red cascade had to be reproduced on main before it could be called pre-existing (estimate, not timed: about 15 minutes).

## 5. Calls for the owner
- **Sizes beside Rivet** (`gtai-masters/n24/cast/audit_after_lineup_32ppm_tilt70.png`; Rivet 77 px, cop 43 px at 32 px/m):
  lancer 49, clamshell 53, door carrier 55, pile-driver 78 px (2.42 m drawn, Rivet 1.65 m). The door carrier now
  stands at about the cop's height, not taller than Rivet: keep it, or draw it up to about Rivet's height? Its slab
  already matches the shove width (`door_before_after_64.png`).
- **Planted feet are not in the cop standard yet**: the shipped patrol cop's boot slides 10 px per drawing, the same as
  the lancer. Should the checklist require planted feet (and the cop get re-cut), or should it match the cop as it is?
- **The clamshell's dome finish** (`clamshell_before_after_64.png`): navy plate with pale wear specks; read as
  "weathered blue steel" or as a pattern you do not want?
- **The appliance warden and Sergeant Mulroney** were not redrawn tonight: next in line under the same checklist.

## 6. Merge notes
- Shared render files touched by call sites only (`git diff b3f4727c0 HEAD`):
  `project/features/arena/arena_robot_rigs.gd` (3 lines: `rig.visible = Foe{Shield,Turret,War}CardView.show_rig(...)`),
  `project/features/arena/arena_rigs.gd` (the lancer: `_cast = FoeCastView.attach(...)` replaces `ReactLink.make` +
  `_squad_looks`; `_cast.feed(h, i)` replaces `FoeRocketPose.pose`), `project/features/arena/arena_wave_cards.gd`
  (1 line: `or FoeCastView.covers(_rigs, h)`), `foe_launcher_view.gd` (1 line: `FoeCastView.draws_launcher(h)`),
  `foe_shield_view.gd` / `foe_turret_view.gd` / `foe_walker_view.gd` (an early `return` when the card is on).
  `combat_arena.gd` untouched. A lane that edits `arena_rigs.gd` around `ReactLink` will conflict here: keep both.
- `cast_cards.json` `enabled` per row: false = everything as on main.

## 7. Next steps
1. Plant the lancer's feet (and the patrol cop's, if the owner wants the stricter standard): the door carrier's
   cell-hold did not carry over to the lancer's sheet in a trial; re-cut its contact frames.
2. Contact shadows for the door carrier and clamshell cards.
3. Redraw the appliance warden and Sergeant Mulroney, then robot_gunner and the contractor, worst first, under
   `docs/art/cast-checklist.md`.
4. A 64 px/m crop of a real gauntlet wave with the door carrier and the pile-driver in it (they did not spawn in the
   filmed seed 8 waves 5-8).

## 8. Astra ledger
| Call | Minutes | Result | Brief differently |
|---|---|---|---|
| audit | 54 | accepted | - |
| lancer | 72 | accepted (attack cols 4-5 bounced to round 03) | ask for a per-column facing check against the cop, not only the cut |
| film-door | 66 | accepted, the 32 px/m film bounced (1280x800) | name the window resolution flag and a survival condition for the filmed enemy |
| clamshell | 66 | accepted in part: art, stills, films, standing rule; the clamshell commit lost a race with my journal commit, quick red, door mutate 0/2 | never commit (even pathspec) while a builder runs; ask for the commit before the films |
| pile-driver | 66 | accepted (5 commits; mutate scores low on the new card views: clamshell 3/20, pile-driver 4/18) | ask for mutation-killing assertions in the same brief as the view, not after |
| polish | 60 | accepted (4 commits: tests to 20/20 on both card views, stomp key, ASCII header, door feet 0 px; 4 clips at 64 px/m) | ask for the 64 px/m owner clips in the same call as the 32 px/m ones |
