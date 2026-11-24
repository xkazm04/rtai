# Brief n26-02 `dusk`: fire light, the broken front, the new pieces (lane yard, run n26)

HARD STOP: 13:55 local (stop work, report). LAST COMMIT: 13:50. Check `date` now and then.

## Before anything
- `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/yard` and `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe` in every shell that runs Godot or a gate. One Godot at a time in this worktree; windowed runs `--position 0,1440`; kill only PIDs you started.
- You (the previous call `cover`) built the `line_fire` dressing row and its cover layout. Re-read your own commits (`git log --oneline -10`).

## Goal (owner, verbatim: "add fire light and the broken front")
The approved plate `C:\Users\kazda\kiro\gtai-art\factory-n25\out\a-torn-line.png` is dusk: dark sky, the hall's loading doors burst open with fire roaring inside, an amber glow spilling onto the yard, a yard lamp pool by the gate, wall lamps over the doors, long shadows. Today's game yard is flat pale daylight. Give the `line_fire` row that mood, within the colour law, while Rivet, the cops and every round stay as readable as in daylight.

## Colour law (binding)
Red is blood only. Cops blue. Vermilion only for danger, objectives and Rivet's collar. Teal only for souls. **Amber for fire and heat.** Note: the shared `lights.json` kind `fire` prints on the vermilion plate: do NOT use it for this yard. Do not edit `lights.json` or `palette.json` (not ours).

## Item 0 (10 min, first, its own commit): a NEED from the melee lane
The melee lane makes the quick claw lethal to ordinary humans but exempts named ones by a fighter meta. Lieutenant Dale Winnick spawns as a plain `patrol_cop`; only `project/boot/prologue/prologue_patrol.gd` (around line 83, `id == "winnick"`) knows him. Where his fighter is spawned, set `fighter.set_meta(&"melee_named_human", true)` (the literal is `MeleeLethal.NAMED` on branch `n26-melee`, not merged here: use the StringName literal in a yard-owned const with a comment naming `MeleeLethal.NAMED`). Add a unit assertion that Winnick's fighter carries it. The seed-7 pilot result must stay byte-identical (a meta only).

## Order and the cap
This call is stopped at 75 minutes. Do items 0, 1, 2, 3, 5, 7 and commit each as it lands. Items 4 (smoke/embers) and 6 (frame cost under the bench lock) come in a resume call: skip them now unless everything else is committed before 13:35. The keys lane's milestone is merged here (e98906eac): Space sprints, F is the claw, 1-4 deploy ghosts; tests that touch input are theirs, do not edit them.

## What to build (all as data in the `line_fire` row of `prologue_yard_dressings.json`, so `plain`/`torn_line` stay daylight and unchanged)
1. **The grade.** Use the existing `LightLayer` (`project/core/render/light_layer.gd`) the print stage already owns. Its `grades` and `kinds` are public dictionaries loaded from `lights.json`; from the prologue's own code (in `project/boot/prologue/`) register a yard grade `dusk` and yard light kinds (`yard_fire`, `yard_lamp`) at setup from the dressing row (kind rows carry a `color` hex the yard owns: amber for fire, a warm pale for lamps; same keys as `lights.json` kinds plus `color`/`alt_color` as `light_layer.gd` builds them). Start from `night` (`paper_level 0.58, gamma 1.5, accent_keep 0.85`) and tune lighter for dusk (suggest paper_level about 0.7). If `LightLayer` cannot take an injected grade or kind without a core change, stop and report a NEED (exact change), and fall back to a yard-owned additive layer in `project/boot/prologue/`.
2. **Fire and lamp lights** (held, on the 60 Hz tick, no frame delta): fire pools at each burst doorway of the hall front (flicker <= 2.5 Hz, the photosensitivity cap holds), one pool at the robot arm's sparking cable, the yard lamp by the gate (lamp pool), wall lamps over the doors. Lights must not change the sim: render only; the seed-7 pilot result must stay byte-identical to your call-01 pin with the lights on.
3. **The broken front.** The hall front along the top edge becomes torn open: the burst doorways with fire inside, rubble spilled forward, the conveyor's first segment coming out through a doorway. New piece sheets are being drawn now under `C:\Users\kazda\kiro\gtai-art\factory-n26\out\` (`conveyor-run.png`, `front-broken-b.png` = the hall front, four strips at the game camera: USE THIS one, `front-broken.png` is a facade-on reject; `yard-props.png`: lamp post and payphone are drawn side-on, squash them to about 0.5 height; `fence-gate.png` is for a later call). All four sheets exist; their notes: `C:/Users/kazda/kiro/gtai-art/factory-n26/notes.md`. Cut them with the repo tool `tools/art/prologue_yard_cut.py` (extend its spec, keep its pytest green) into `project/boot/prologue/art/line_fire/`, and use them in the `line_fire` row: conveyor segments for the S-run, pallet stacks, the toppled arm, fallen fridges, the lamp post, the payphone, and the front pieces. Sheets not yet in `out/` when you start: use the torn_line pieces for those and say so. Cover art must still fill its footprint (the footprint test, >= 85 %).
4. **Smoke or embers**: only if it costs under 0.5 ms a frame (measure, see 6); else skip and say so. Deterministic or purely render-side (no global RNG; `ctx.rng.stream(...)` or a hash of the tick).
5. **Readability check.** Stills at 32 px/m of the seed-7 pilot at ticks 2858 (wave 1) and 6000 (squad) with `line_fire` beside `torn_line` (same tick, same camera): `evidence/yard26/dusk_t2858_32ppm.png`, `dusk_t6000_32ppm.png`, and 64 px/m close-ups at the gate and the hall front: `dusk_gate_64ppm.png`, `dusk_front_64ppm.png`. Report the mean luminance contrast of the patrol cop's blue, the rifle round and the shotgun pellet against the ground beneath them, day vs dusk (sample pixels from the stills; a small Python script under `evidence/yard26/`). If a cop or a round loses more than a third of its contrast, lift the grade until it does not.
6. **Frame cost.** `torn_line` vs `line_fire`, uncapped, release-ish, with the existing frame probe (`project/dev/prologue_yard/yard_frame_probe.gd`), 3 rounds A B, 60 s each, ONLY under the bench lock `C:\Users\kazda\kiro\gtai-n26\bench.lock` (create it exclusively with your pid and time; younger than 20 min held by someone else = skip and report CONTENDED numbers instead; older is stale, delete it; delete yours afterwards). Write `evidence/yard26/frame-cost.md` with p50 / p99 per round and the mean delta with a CI.
7. **Tests**: the dressing row's light block parses (kinds, grade, light positions inside the yard or its front); `plain`/`torn_line` register no grade (stay day). Re-run the pilot seed 7 and `cmp` with your call-01 pin.

## Owned files (allowlist). Any other path: stop and write the NEED in your final report.
- `project/boot/prologue/**`, `project/data/tables/prologue_stage.json`, `project/data/tables/prologue_yard_dressings.json`, their schemas
- `project/dev/prologue/**`, `project/dev/prologue_yard/**`
- `tools/art/prologue_yard_*.py` and their tests
- `project/tests/unit/test_prologue_*.gd`, `project/tests/scenarios/scenario_prologue_*.gd` and their goldens
- `evidence/yard26/**`, `docs/decisions.md` (append one line if a pin moves), `tools/debt/baseline.json` (only through `node tools/debt/debt.mjs --update --accept-regression="<reason> for n26 yard"`), `steam/ai-provenance/2026-11.jsonl` (append one line per generated sheet you ship, same format as the n25 yard lines)
- `.uid` and `.import` files of new scripts and art (run one `"$GODOT_BIN" --headless --path project --import` after adding art, before committing).

## Forbidden
`lights.json`, `palette.json`, `project/core/**`, `project/features/**`, `input_actions.json`, `combat.json`, `enemies.json`, `weapons.json`, `ghost_*.json`, `cast_cards.json`, `native/**`, quest 1 files and tapes. No balance change.

## Repo law
Typed GDScript, files <= 200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`, data JSON with schema, sorted keys. Stage per path; one commit per change; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push. Fix lint and format findings in your own edit and go on. Before each commit `node tools/gate/quick.mjs`. After the main code commit: `node tools/mutate/mutate.mjs --file=<the new light/front file> --max=20`, quote killed/(killed+survived).

## Report (final message)
Commits, which pieces came from which sheet, the light list, the grade values, the contrast table, frame cost, pilot cmp, mutate score, NEEDs, what was not done.
