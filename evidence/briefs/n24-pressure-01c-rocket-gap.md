# Brief n24-pressure-01c (resume): the rocket trooper fires from where it stands, and two small fixes

You are resuming your brief-01b session for lane `pressure`. "Machine rules", "Git law" and the forbidden list of
`evidence/briefs/n24-pressure-01-numbers-gaps.md` still bind. You are the only Godot user of this lane.

**Wall clock: hard stop 20:45. Last commit by 20:40.** Commit each task as it lands.

Your report was read. The director committed your staged task C through the hook as the commit right after
`4e516c297` (`git log --oneline -3`): do not re-commit it. Start with `git status`; if the commit is missing, the hook
failed: run `node tools/gate/quick.mjs`, fix what it names, and commit it yourself first (message
`pressure: shorter enemy fire gaps ...`).

## Allowlist additions (only these)

- `project/features/combat/squad/foe_rocket.gd`: the rocket trooper's trigger and reposition rule (logic; the
  `foe_*view*.gd` files stay lane cast's). Granted: no other lane has touched it since main.
- `project/data/tables/enemies.json` + `project/data/schemas/enemies.schema.json`: a new numeric/boolean key on the
  rocket trooper row or the `rocket` weapon row, if the rule needs one.
- `project/tests/unit/test_dock_waves.gd`, tests named for `foe_rocket.gd`.

## Task D - the rocket trooper (one commit: code + table + `evidence/n24-pressure/fire-gaps/after.{json,md}` re-run)

Your measurement: the mandatory 3 m relocation in `foe_rocket.gd` eats about 19 s of 30 when Rivet circles; rocket
rounds/s 0.33 before and after, 0 circling hits. Change the rule so that a trooper with line of sight, its cooldown up
and a shooter slot fires from where it stands; it relocates only when it has no line of sight or has fired N rockets
from the same spot (a table value, e.g. `relocate_after_shots` 2; 0 = today's "relocate before every shot", so the old
behaviour is one value away). Lead the rocket at a moving Rivet by a share you can tune (reuse `EnemyBrain.led_offset`;
a table value, 0 = today). Its tell stays readable: keep the visible tell at or above 0.6 s (a rocket is a large round,
the player must be able to read it and step or dash aside; say which number you kept). Targets: rocket rounds/s at
least 1.5x the before (0.33 -> >= 0.5) standing and circling, circling hits > 0 in 30 s, standing still hit more than
circling. Re-run the fire-gap tool, commit `after.{json,md}` with the change. If Quest 1 or another scenario digest
moves, list it with a reason and a decisions line (quest 1 has no rocket trooper as far as I know: if it moves, say why).

## Task E - two fixes (one commit)

- `test_dock_waves.gd` `test_guards_die_to_one_nail_and_their_rounds_are_weak`: you pinned `36.0`; that drops the
  test's claim. Keep a bound that still says the dock guards are weaker than Rivet:
  `assert_lt(rifle.damage_vs_rivet * rifle.magazine, arena.rivet.max_hp * 0.5, "a full magazine takes less than half of Rivet")`
  (check `max_hp`; if 0.5 is not true, pick the smallest honest share and say so).
- Mutate the gap commit: `node tools/mutate/mutate.mjs --file=project/features/combat/guard_brain.gd --max=20 --lines=<the street_aim lines>`
  and the same for `foe_rocket.gd` after task D. Quote killed/(killed+survived); add a test if a survivor shows a
  real hole (cheap only).

Run unit (`--changed`) and the full scenarios once at the end (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`),
quote the result lines.

## Report

Per task: sha, files, checks with result lines, rocket rounds/s and circling hits before -> after, the tell you kept,
moved digests, mutate scores, NEEDs.
