# n30 combat call 04b: why does the arena take draw no explosion light, and where would an amber rim come from

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Started ~13:15. **Evidence commit by 13:45, report and
END by 13:52 (hard: the session dies at 14:00).** Never end uncommitted. Diagnosis only: no committed product change.
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: another builder (c08: `project/boot/collect_call/view/current_look.gd`, its test,
`evidence/n30/mutate/**`, runs unit tests and mutate) shares it. Before each launch wait until no file in
`$LOCALAPPDATA/gtai/runs/*.json` names `n23-street` (re-check every 30 s). Only shipped tools / `runGodot` launch Godot.

## What is known (read `evidence/n30/lights/explosion_rim.md` first)
1. c04 put `lights.json` explosion `alt_token` on a new palette token `amber` (`d4b6aabcc`). Its arena takes
   (`node evidence/n29/red/take.mjs ... --chapter=rocket_launcher,mini_nuke --ppm=64 --clean ...`, scene `res://dev/arena/arena.tscn`)
   show 0 px difference before/after AND 0 px against a control with `combat_lights.on` false: no explosion light is drawn.
2. The director read `project/core/render/light_pool.gd:58-80`: `alt_color` is used only when `flicker_hz > 0` (a strobe);
   the explosion row has `flicker_hz` 0, so its `alt_token` is never drawn. There is no "rim" colour in the light model: the
   light is one colour (`token` paper) cut into `steps` bands by the shader. So the data change alone can never show.
3. Yet n29's still `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/red_fire_explosion_pair2_64.png` (same take tool, n29)
   shows a big pale hatched disc behind the explosion sprite: that looks like the light. Find out what it is.

## Do
A. Probe: with a TEMPORARY, uncommitted `Log.info` in `project/features/combat/weapons/arena_combat_lights.gd` `_light()` (or
   `step()`) and/or in `LightLayer.step` (count `active`), re-run the c04 take for ticks 60-110 and say: does ArenaCombatLights
   start an `explosion` light (started / refused by FlashBudget / outside radius / `on` false / reduced_motion)? Is the
   LightLayer stepped and its `active` > 0 on those ticks? Is the light canvas visible in the day grade? Restore every probed
   file with `git checkout -- <file>` before you commit anything (`git diff --stat` must show no product file).
B. Read the light shader (find it from `light_layer.gd`) and say exactly how the bands are drawn, and what the smallest code
   change would be to draw the outermost band (the "rim") in `alt_color` when `flicker_hz` is 0 (e.g. a `rim` flag per kind
   packed into the instance custom data `.b`, the shader mixing to an `alt` colour passed... say how the second colour gets to
   the shader: instance custom data `.a`/a packed int, or a per-kind uniform). Write it as a ready patch text in
   `evidence/n30/lights/rim_patch.md` (files, lines, the diff, the test that would pin it). Do NOT apply it: those files are
   not this lane's (`project/core/render/**`): it becomes a NEED for the Director.
C. If A finds the light IS drawn at some tick or in a different take (n29's), take one 64 px/m still where it shows
   (`C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/explosion_light_seen_64.png`) and say at which tick/flags.
Append the findings to `evidence/n30/lights/explosion_rim.md` under `## Probe (c04b)`; commit it and `rim_patch.md`
(`n30 combat: explosion light probe (why 0 px) and the rim patch for the Director`).

## Commits
Stage per path, commit with a pathspec (`git commit -m "..." -- <paths>`); never `git add -A/./-u`, no stash, no amend, no
rebase, no reset --hard. End messages with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Never skip the hook
(it can take ~12 min: start your commit by 13:40). Do not touch docs/decisions.md, JOURNAL.md, REPORT.md.

## Allowlist
Commit only `evidence/n30/lights/**`; scratch in `build/**`; stills in the masters dir. Temporary probes in
`project/features/combat/weapons/arena_combat_lights.gd` and `project/core/render/light_layer.gd` are allowed only uncommitted
and must be restored. Any other path: stop and report.

## Report and END
Probe lines (counts per tick), the answer to "why 0 px", the patch summary, what you could not do.
