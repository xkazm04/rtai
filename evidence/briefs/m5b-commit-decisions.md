# Brief m5b (lane moves, n23, follow-up of m5): commit the film scene, write the decision lines

Wall clock: start 06:39. **Commit deadline 07:20. Hard stop 07:30.** Setup as before: `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/moves`, `GODOT_BIN` as before, one Godot at a time, `--position 0,1440` windowed.

1. The `dev_loc` rise for `project/dev/moves` is authorised by the director: `node tools/debt/debt.mjs --update --accept-regression="move_film scene for n23 moves"`, stage `tools/debt/baseline.json`, lint green, `node tools/gate/quick.mjs`, then commit what you staged (film scene + scripts + `.uid`, `move_ttk_trial.gd`, `evidence/moves/capture.mjs`, `evidence/moves/film.md`) in one commit, staged per path.
2. Append these lines to `docs/decisions.md` (append-only, one line each, format `- [2026-11-22] DECISION <area>: ...`), one commit:
   - moves code home: new move logic in `project/features/combat/moves/` (prefix `move_`), ghost hooks in `project/features/souls/`, foe hooks in `combat/ai|squad`; every number in the `moves` block of `combat.json` with `enabled`, so loop can measure on/off.
   - Ohm short circuit adds to the ordinary electro stun (1.2 s on every body) and never replaces it: a replacing stun with 4 s immunity let a turret fire in the gaps (85 rounds over ten seeds vs 0); rejected: dropping the immunity (owner's spec).
   - the short circuit does not stop a turret's rounds already in flight; its cue is amber/white arcs (overload is amber; teal stays souls-only).
   - the armour crack helps every damage source while open (Tonnage opens it, guns cash it: the combo); once per stomp.
   - overkill carry starts only from Rivet's base form (guns, claw, shock, burn), never ghost forms; rank 1 never re-carries a carried kill; rank 2 = 4.5 m and two hops; only weapon effect in the pool, so the only one ranked.
   - no sim, parity, bake or replay digest moved: all four moves off = the same-roster baseline `c7f139b95` byte for byte (gauntlet seed 7 average SHA-256 2d60b987...555f; replay_60s final cbeb734ff9b97c41 on and off).
3. Report: both commit shas and the lint line.

Allowlist: `tools/debt/baseline.json` (through the debt tool), the files you staged in m5, `docs/decisions.md` (append only). Anything else: stop and report a NEED. No `add -A/./-u`, `commit -a`, stash, amend, rebase, reset --hard, push. Fix lint and format findings in your own edit and go on.
