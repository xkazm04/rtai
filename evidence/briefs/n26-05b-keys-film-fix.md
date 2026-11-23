# Brief n26-05b (resume of keys-film): three faults the director saw in keys_overlay_64.png, then the re-take

Same lane, worktree, environment, repo law and allowlist as `evidence/briefs/n26-05-keys-film.md`, PLUS the two souls HUD
files named in item 3 (the keys lane owns the deploy chips this run) and their unit test.
**Hard stop: HARDSTOP wall clock. Commit deadline: COMMITBY.** Check `date` first. No amend, rebase, stash, `add -A/./-u`,
`commit -a`, `reset --hard`, push. Fix lint and format findings in your own edit and go on. mutate `--max=20`, changed lines.
If your keys_film commit is not in yet, commit it first (scene + caps + uid + md), then do these.

1. **The overlay prints a raw loc key**: the 1 cap reads `GAUNTLET__GHOST__DENT`. Resolve it through the translation the
   game uses for that msgid (`project/data/loc/en.po` has it: find why `Loc.t()`/`tr()` returns the id here, e.g. the
   locale not loaded in a dev scene, or the wrong call) so the cap reads the player-facing name (Dent, Kerf, Ohm, Tonnage;
   Sprint, Dash, Quick claw, Car for the others, from the same strings the prompts use). No literal English in the file.
2. **The overlay covers the deploy HUD**: its panel sits on the ghost strip (it hides the "Tonnage" name label). Move it
   where it covers no HUD element (e.g. bottom-centre or above the strip with a clear gap); check every frame of the take.
3. **The deploy chips are in the wrong order for number keys** (product fix, keys lane owns it): the strip draws
   `4 1 2 3` (Tonnage first, the chevron/▼ under the selected ghost, and the cycle hint). With 1 to 4 each deploying its own
   ghost, the strip must read **1 Dent, 2 Kerf, 3 Ohm, 4 Tonnage** left to right, always, and the cycle hint/chevron for the
   freed G key must not be drawn (nothing selects by cycling any more; `power_gearbox` has no key). Find where the order or
   rotation comes from (`project/features/souls/ghost_form_hud.gd` `order`/`_shown`/`selected`, `GhostHudHints.cycle`) and
   fix it there; keep the compact (folded) layout working. Unit test in `project/tests/unit/test_ghost_form_hud.gd`: shown
   order is the slot order whatever the selected ghost; no cycle hint is drawn; each chip shows its number. Allowed files
   for this item: `ghost_form_hud.gd`, `ghost_hud_hints.gd` (or wherever the hint lives in `project/features/souls/`),
   that test. If the order comes from a file outside them (a table, melee's souls code), stop and write `NEED`.
   `node tools/tests/run_unit.mjs --changed` green, `node tools/gate/quick.mjs`, scenarios
   (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`) 68/68 if the HUD is read by any scenario
   or replay hash (check; quote the line). One commit for item 3.
4. **Re-take** the 32 px/m film and the 64 px/m still after 1-3 (the film is the owner's; it must show the fixed strip),
   ffprobe it, LOOK at six frames, update `evidence/n26-keys/keys_film.md` and frames.json. Then the Gloria vs pistol still
   of the first brief if not done. Final message: commits, ffprobe line, what you saw in the frames, NEED lines.
