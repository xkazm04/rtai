# n30-cast-04: the patrol cop's build jitter +-8 % (tag `c04`, model sonnet)

Read `evidence/briefs/_common.md` first: it binds. Hard stop: launch time + 55 min (report and END). First commit by launch + 25 min.

## Goal (owner's pick)
Every whole-figure crowd card is scaled by `StreetCrowdCards.body_scale(actor_id)` = 1 + `SCALE_VAR` (0.16) x
`vary(actor_id, 3)` (`project/features/characters/street_crowd_cards.gd:22,68-69`). The patrol cop is drawn that way
(`street_walker_cards.gd` `place`, line ~168: `k = StreetCrowdCards.body_scale(rig.actor_id)` when the rig has no cast
pose) and so varies 0.84-1.16 beside card foes that no longer jitter (n29: `cast_cards.json` `build_jitter` 0). The owner
wants cops at +-8 %, the crowd keeps +-16 %. ONE value: e.g. `StreetCrowdCards.COP_SCALE_VAR: float = 0.08` and a
`body_scale_of(rig)` / `body_scale(actor_id, cop)` that picks it for cops. Visual only.

## Steps
1. Find every path that sizes a patrol cop by the crowd jitter: `grep -rn "body_scale\|SCALE_VAR" project --include=*.gd`
   (known: `street_walker_cards.gd` place, `street_crowd_cards.gd`, `arena_wave_cards.gd:78`; also the fall / corpse /
   hit paths that take the same k, e.g. `StreetWalkerFall.draw`). Find how a cop is told apart (the rig's variant tag,
   `CastCards`-less `patrol_cop` archetype, the plan's art dir...; the "patrol_cop" spawn in `ArenaSquad.spawn_member` and
   the street police in the city). Decide which cops count: every police officer drawn as a whole-figure card (patrol,
   street police); write the rule in the report. Riot/SWAT if they use the same path: same rule, say so.
   Do NOT touch `project/features/combat/kills/**` (combat's; `kill_fall_cells.gd` sizes a killed victim by
   `SCALE_VAR`: if a killed cop would jump size at death, write `NEED combat: kill_fall_cells uses SCALE_VAR for cops`).
2. Implement, with a unit test: a cop's scale lies in [0.92, 1.08] over actor ids 0..999, a non-cop pedestrian keeps
   [0.84, 1.16] and is byte-identical to before for the same id. `node tools/tests/run_unit.mjs --changed` green (fix
   tests that pin the old cop spread, e.g. `test_crowd_cell_layout.gd`, `test_street_ped_shock.gd`, only if they mean cops).
3. Determinism: `node tools/gate/quick.mjs` and the scenario suite through runGodot. If ANY replay, tape, pilot or
   scenario digest moves: revert with a new commit, STOP, report which digest and old/new. Commit only when unmoved.
4. Re-measure (n29 size table, `docs/art/cast-audit.md` "Card foes beside the rig patrol cop, n29", lines ~556-605;
   scene `project/dev/cast/cast_size_beside.gd`, measurer `tools/art/cast_size_measure.py`): at 64 px/m, tilt 70, the
   unjittered cop, the min-jitter cop and the max-jitter cop (pick actor ids whose `vary` is near -1 and +1; give the ids)
   beside the card foes and Rivet. Measure in the PNGs. Table: figure, px at 64, / unjittered cop, / Rivet; before
   (+-16 %: 0.84 / 1.16 x unjittered) and after (+-8 %). Still to `C:\Users\kazda\kiro\gtai-masters\n30\cast\cop_jitter_64.png`
   (min | unjittered | max cop beside the card foes); LOOK at it. Append the table as "Patrol cop build jitter, n30" to
   `docs/art/cast-audit.md`, and the still to `C:\Users\kazda\kiro\gtai-masters\n30\cast\frames.json` (append, keep entries).
5. Mutate `street_crowd_cards.gd` on the changed lines (`--max=20`), quote the score.

## Allowlist
`street_crowd_cards.gd`, `street_walker_cards.gd` (the k line only), `arena_wave_cards.gd` (the k line only), and their
unit tests; `project/dev/cast/**`; `docs/art/cast-audit.md` (append); `build/look/n30-c04/**`; the masters files above.
Anything else: NEED in the report. Do not touch `cast_cards.json`, `foe_*_view.gd` (other builders).

## Report
Commits, the cop rule, digest result line (quote), the size table, mutate score, NEEDs.
