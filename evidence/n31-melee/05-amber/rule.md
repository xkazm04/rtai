# 05 amber print rule (patch for core render, not applied in this tree)

Problem: the FX item print (`look_d4_item.gdshader`, opaque `else` branch) snaps to the nearest of CREAM / STEEL / INK / VERM / AMBER (`amber_ink`) / TEAL. A fire blend between AMBER and INK is nearer VERM than either end, so it printed vermilion (danger and Rivet's collar only).

Rule (patch `look_d4_item.patch`, applies clean with `git apply`): when `amber_ink` is on and VERM won, let `seg` = distance from the colour to the AMBER-INK segment (project, t clamped 0..1). Keep VERM only when `dv < seg`; otherwise print AMBER (t < 0.5) or INK. TEAL still gets its later chance. Nothing changes with `amber_ink` off.

Mirror: `tools/melee/amber_rule.mjs` (test `tools/melee/amber_rule.test.mjs`). Printed ink before -> after, `amber_ink` on:

| sample | before | after |
|---|---|---|
| pure VERM | VERM | VERM |
| Rivet collar (VERM fill, no other value named in code) | VERM | VERM |
| plasma HOT core (kill_hole_fx HOT) | CREAM | CREAM |
| EMBER #E9A23B (kill_hole_fx) | AMBER | AMBER |
| sear ramp EMBER->CHAR 25% (43676e245^ blade_marks) | VERM | AMBER |
| sear ramp EMBER->CHAR 50% | VERM | AMBER |
| sear ramp EMBER->CHAR 75% | INK | INK |
| sear CHAR (plasma_scorch_view) | INK | INK |
| flame ember hot #FFD23A (flame_embers.json) | AMBER | AMBER |
| flame ember rim #EE6A1C | VERM | VERM (nearer VERM than the AMBER-INK line: a deliberate orange, kept) |
| 50% AMBER/INK blend | STEEL | STEEL |
| #EE6A1C half to INK | VERM | INK |

Findings: AMBER-INK blends at t 0.30 and 0.35 printed VERM before and print AMBER after. Blends at t 0.40-0.55 print STEEL (grey) before and after: the rule does not touch them (the brief's "50% goes AMBER or INK" is not what the branch does; STEEL wins first). Dark ember mixes are therefore best drawn unblended (as 04d did) or the STEEL gate widened by the director.
