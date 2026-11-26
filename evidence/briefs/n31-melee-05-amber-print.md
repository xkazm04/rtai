# Builder n31-melee-05 (sonnet, 25 min, Godot only for one still pair): the amber print rule, as a patch

Read `evidence/briefs/n31-common.md`. Tag `05`. Item 5 of the lane: the FX item print
(`project/assets/shaders/look_d4_item.gdshader:72-86`, the `else` branch) snaps every opaque colour to the nearest of
CREAM / STEEL / INK / VERM / AMBER (when `amber_ink`) / TEAL. A fire or ember blend between AMBER and INK (a dark
orange-brown) is nearer VERM than either end, so it prints vermilion (n30 combat's finding; 04d hit it on the plasma
sear: `git show 43676e245`). Vermilion is danger and Rivet's collar only.
Rule to write: when `amber_ink` is on, let `seg` = distance from `col` to the segment AMBER-INK (project, clamp
t in 0..1); keep VERM only when `dv < seg`; otherwise print the nearer of AMBER / INK (t < 0.5 -> AMBER). This
file is core render, not the lane's: do NOT edit it in the tree. Deliver:
1. `evidence/n31-melee/05-amber/look_d4_item.patch` (git diff format against HEAD) + `rule.md`: the rule, and a table
   of 12 sample colours (the plasma sear's old ember->char ramp from 43676e245's parent, the flamethrower/fire
   palette ramps you find in `features/**/fire*` or `gun_fx.json`, pure VERM, Rivet's collar orange from
   `rivet` art if a value is named in code) -> ink before -> ink after, computed by a small Node or Python mirror
   of the branch (`tools/melee/amber_rule.mjs` with a `node --test` test: VERM stays VERM, the collar stays VERM,
   a 50 % amber/ink blend goes AMBER or INK, never VERM).
2. One still pair at 64 px/m of a fire/plasma effect with the patch applied ONLY in a temp copy
   (`git worktree add` at HEAD in Temp, apply the patch there, `--import`, run `project/dev/melee_n31/marks_still`
   with the plasma sword; delete the worktree) - only if the lane lock is free within 5 min; otherwise skip and say so.
3. JOURNAL-ready line: `NEED director: apply evidence/n31-melee/05-amber/look_d4_item.patch (core render)`.
Owned: `evidence/n31-melee/05-amber/**`, `tools/melee/amber_rule.mjs` + its test. Commit by 20 min; END at 25.
