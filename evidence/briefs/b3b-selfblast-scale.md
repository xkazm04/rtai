# Brief b3b (resume of b3-selfblast): commit, a hurt that reads, a film that shows it

**Hard stop: 05:35 wall clock (check `date`). Commit deadline: 05:30.** `n23-controls-common.md` still binds (APPDATA, GODOT_BIN, one Godot, repo law, forbidden files, mutate cap).

## 0. Commit what is staged (first, within 10 minutes)
`tools/debt/baseline.json` may be changed **only through the debt tool** (shared rule of the night): run
`node tools/debt/debt.mjs --update --accept-regression="RivetSelfBlast call site in fight_areas + dev/controls film for n23 controls"`, stage `tools/debt/baseline.json` with the staged files, commit through the hook (no `--no-verify`). Fix lint/format findings in your own edit and go on.

## 1. The hurt must read (DECISION by the director, 04:33)
A point-blank own rocket costs Rivet 2.2 of 100 HP (0.79 in the film). Enemy rockets do 10 to 24 to him (`enemies.json` splash_damage 10 / 24 / 18). "Let his own blasts hurt him" means a visible chunk. Change the conversion, not `self_k`:
- `combat.json` block `blast` gains `rivet_hp_per_table_hp` = 0.1 (schema: number, minimum 0, required; keys sorted). Self amount = weapon `splash_damage` (table HP) x `blast.rivet_hp_per_table_hp` x `blast.self_k` x falloff. `hp_scale` (0.01, the hostile conversion) no longer feeds the self-hit; drop the `hp_scale` parameter from `RivetSelfBlast.land` if unused (the call site in `fight_areas.gd` stays one line).
- Point blank then: rocket 22 (close to the lancer's 24), molotov 4, shard 3, mini-nuke 150 (kills at up to 4 m). Update `evidence/controls-flip/self-blast-radii.md` (the last column, plus the kill radius of the mini-nuke and the radius at which a rocket takes 10 HP).
- Update the unit tests to the new numbers; keep point blank / edge / wall / Tonnage / self_k 0 / guard / kill. Add one test that `rivet_hp_per_table_hp` = 0 gives 0.
- One `docs/decisions.md` line (append one line): `- [2026-11-22] DECISION combat: Rivet's own splash converts table HP at blast.rivet_hp_per_table_hp 0.1 (own rocket 22 at point blank, near an enemy rocket's 24), not the hostile 0.01 (2.2, invisible); self_k 1.0 stays the owner's knob; rejected: raising self_k to 10.`
- Re-run: targeted tests, `replay_60s`, the scenario suite in default and in `--controls=legacy` (quote counts), `brutality_kills` digests (it self-hits at ticks 66 and 396: say whether finals still match; if a final or golden moves, list scenario, old -> new and the reason in `self-blast-digests.md` and re-pin only then). One gauntlet `--seed=7 --bot=average --waves=5`: quote per-wave `self_damage` and whether the bot died.
- Mutate `project/features/combat/rivet_self_blast.gd` (`--max=20`), quote the score.

## 2. Refilm `self_blast.mp4` so the owner sees it
The current film shows no target, a dev text panel as the only HP read, and in the wall take the wall does not stand visibly between Rivet and the impact (it is a short post below the line of fire). Redo `project/dev/controls/self_blast_film.gd`:
- A visible target (a hostile or a dummy) about 2 m from Rivet; Rivet faces it and fires.
- Rivet's real HUD health bar on screen (the game's own HUD, not only a text panel); keep the panel as a caption if useful but it must show the drop too.
- Wall take: a long high wall segment perpendicular to the line of fire, clearly between Rivet and the target (Rivet behind cover, the rocket hits the wall face or the target beyond it). The still must make the geometry obvious at 32 px/m.
- 32 px/m, tilt 70, 1080p60, d3d12, `--position 0,1440`, 15 to 25 s, same paths (`self_blast.mp4`, `self_blast_hit.png`, `self_blast_wall.png`). Add one 64 px/m still of the open-floor hit (`self_blast_hit_64.png`). Look at every still yourself before you finish.
- Add/refresh entries in `C:/Users/kazda/kiro/gtai-masters/n23/controls/frames.json` (create if missing; `{file,title,ppm,before,note}`, best first).

## Allowlist
As in b3, plus `tools/debt/baseline.json` (through the debt tool only), one appended line in `docs/decisions.md`. Anything else: stop and report a NEED.

## Report
Commits, numbers (point blank per weapon, film HP before -> after), counts, digests, mutate score, the stills' paths.
