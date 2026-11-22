# Brief n24-melee P4: the kills must read as brutal on screen (quality package)

Lane `melee`, branch `n24-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**Hard stop HARDSTOP wall clock** (check `date`). **Commit deadline COMMITBY**. Commit each item as it lands.

## The owner's words (verbatim)
"we need on unique swing per weapon, with unique brutal animation per human enemies as it should one-shot them.
For robot enemies we will need electric weapons to have similar effect"

P1 to P3 on this branch built the rule (one swing per click, `MeleeLethal`, per-victim variants in
`signature_kills.json`, the electric shut-down on robots). This package is about what the owner SEES. The director
looked at the P2 and P3 sheets and found these weak (in priority order):

1. **Electro baton on a human shows no shock.** `n24/melee/kills/variants/review_electro_baton_32.png` (contractor):
   at the kill tick and +4 nothing shows the shock (no arcs, no seizure, no flash); the man just stands, then at
   +16..+36 he is thrown back and lies charred. Wanted: from the kill tick, white-blue-white and amber arcs crawl over
   the victim (reuse `features/combat/react/shock_arcs_view.gd`, `kill_shock_fx.gd`, whatever P3 used for the
   robot shut-down), a tick-locked seizure (jerks of the card/rig, about 20 ticks, no RNG outside the registry),
   a flash at the contact, then the throw and the charred body. Each human type (patrol, riot, SWAT, contractor,
   rocket trooper) through the same path.
2. **Plasma sword on a human has no blood and a cartoon star.** `variants/review_plasma_sword_32.png`: a white
   comic-star burst at the kill tick, halves fly, not one drop of red. Wanted: a hot sweep streak along the cut line
   instead of the star (the blade's own colour from its existing look; never teal, never vermilion), white-hot /
   amber glowing cut edges on the halves fading over ~40 ticks, and a blood spray and pool (red is for blood: use
   it), so it reads as at least as brutal as the katana (`kills/katana_64.png`).
3. **Chainsaw grind draws a white zigzag** between Rivet's chest and the victim (`n24/melee/compare/chainsaw/64/t46.png`,
   ticks 42 to 57, also on main). It reads as an electric arc on a saw. Find which mark draws it (`melee_feel*`,
   `melee_marks.json`, `kills/**`, `react/**`) and make the grind throw warm sparks (yellow/amber) and blood chunks
   only. If the zigzag is drawn by a file outside the allowlist, stop that item and report a NEED with the file.
4. **The right-facing baton contact frame** (the deferred issue in your P2 report): fix it if it is in our art or
   code (Rivet's `*_strike*` / `*_windup*` art is ours; generated art only via the repo's Codex pipeline and with a
   provenance line, never script-drawn shapes). If it needs new generated frames and time is short, report it with
   a still instead.

5. **Three director decisions need their `docs/decisions.md` lines** (append, one line each, own commit, date
   2026-11-22, format `- [2026-11-22] DECISION n24 melee: ...`):
   - cursor: with hands or a melee weapon selected the weapon-shaped cursor is replaced by the system arrow (keeps a
     pointer for aim); a plain dot is one const away (`WeaponCursor.PLAIN_DOT`); rejected: no cursor at all (the
     player loses where Rivet faces).
   - hands: the claw is not a one-shot on humans (the owner said "melee weapons"; hands are the quick claw, normal
     damage); one value away (`rivet_melee.json` `kills_human`, false).
   - `combat.json` `robo_tazer.damage` 46 is not doubled: it is Quartermaster Mertz's boss weapon, not a wave enemy;
     boss designs do not change tonight; one value away.

## Acceptance
- For each item, a before/after pair at the same tick and zoom (32 px/m sheet + 64 px/m close-up), rendered with
  the kill-reel / variant tooling you used in P2 (`tools/film/kill_reel.mjs`, the variant sheets), to
  `C:/Users/kazda/kiro/gtai-masters/n24/melee/kills/p4/`. Look at every frame yourself and say per item in one line
  what reads and what does not.
- No teal, no vermilion anywhere in these marks; red only in blood. Robots do not bleed.
- Determinism: everything tick-locked; RNG through the registry only. No sim, parity, bake or tape digest moves
  (combat marks are visual: if a replay digest moves, stop and report why).
- Unit tests for any new rule-bearing code (a variant lookup, a tick schedule); `node tools/tests/run_unit.mjs --changed`
  and `node tools/gate/quick.mjs` before each commit (its PagedAllocator shutdown lines are pre-existing on
  b3f4727c0; anything else red is yours). One `--import` after new scripts or art.
- After the last commit: `node tools/mutate/mutate.mjs --file=<the main changed .gd> --max=20` on changed lines; quote
  killed/(killed+survived).

## Setup
- `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/melee` before EVERY Godot or gate run;
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- One Godot process at a time in this lane. Windowed: `--position 0,1440`. Rendering `--rendering-driver d3d12`.
  Free your own processes by PID, never by name.

## Files you may edit (allowlist; any other path: stop that item and report a NEED)
`project/features/player/melee_*.gd`, `player_melee.gd`, `player_shock.gd`, `rivet_swipe_view.gd`,
`project/data/tables/melee_weapons.json`, `rivet_melee.json`, `melee_marks.json`, `signature_kills.json`,
`human_reactions.json`, their schemas, `project/features/combat/kills/**`, `project/features/combat/react/**`,
`project/features/combat/robo_tazer.gd`, Rivet's strike/windup art (`rivet_eq_*_windup*`, `*_strike*`,
`rivet_strike.png`) with its `.import`, `steam/ai-provenance/2026-11.jsonl` (append only), `tools/film/**` (only
new files or your own P1/P2 tools), new files under `project/dev/melee/`, tests named for these files, existing
tests that break because of this change (name them).
**Forbidden**: `combat_arena.gd` (already at its 2-line budget: no further change), `enemies.json`, `weapons.json`,
`combat.json`, `input_actions.json`, `player_motion*.gd`, `rivet_walk*.gd`, `player_deflect.gd`, `player_guard*.gd`,
`features/gauntlet/**`, `features/souls/**`, `features/characters/art/**` (except Rivet's strike/windup files above),
`features/combat/squad/**`, `features/bosses/**`.

## Repo law
Typed GDScript, warnings are errors; files about 200 lines (hard 300), functions 40 lines or fewer, 5 params max;
`Log` not `print`; sim steps on `SimClock.TICK_DT`. Stage per path, one commit per change; no `git add -A/./-u`, no
`commit -a`, no stash, no amend, no rebase, no reset --hard, never push. Fix lint and format findings in your own
edit and go on. Do not invent story or characters.

## Report (final message)
Per item: commit sha + files, the before/after paths, one line on what reads and what does not; tests / quick gate /
mutate score; any NEED.
