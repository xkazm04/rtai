# Brief n23-prologue-05 - make it read and make it last: the yard, the cast at a glance, wave pacing

Lane `prologue`, night run n23. Same worktree and branch. The prologue is playable end to end after calls 01-04. This call raises the weakest parts the director saw in the stills and the pilot numbers.
**Hard stop: <HH:MM>. Last commit by <HH:MM>.** Check `date` as you go.

## Environment (every Godot run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/prologue` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`.
- One Godot process at a time; kill by PID only; never rebuild native; windowed runs `--rendering-driver d3d12 --position 0,1440`. Headless `--import` after new scripts or art; commit `.uid`/`.import` files.

## What the director saw (stills `C:\Users\kazda\kiro\gtai-masters\n23\prologue\scratch\yard-t0300.png`, `dale-first-kill-t2061.png`, and the later ones)
1. **The yard reads as a road**, not a burnt factory yard: the `dock_floor` tile carries long painted lane lines across the whole yard. Use a floor that reads as factory concrete (an existing tile without lane lines, or the same tile with the lines hidden under scorch, oil, rubble and debris decals from `project/features/city/art/decals/` and props); a factory wall edge on the north side (the destroyed plant: broken wall segments / roof debris from existing roof or wall art); more machine carcasses. **`press_carcass` uses King's torso art** (`res://features/characters/art/king/torso.png`): replace it with machinery that does not read as a boss character. Keep every footprint solid cover, keep the gate and the street with the payphone. No wall on a zebra crossing.
2. **Dale is not told apart at a glance**: give him the megaphone (existing prop art or a small drawn shape in his view, no generated art) and keep him the lead of the file. **The wardens** are blue cops with poles: give them the overalls read (a tint/overlay on the existing rig: a utility colour that is not red, not teal, not vermilion, e.g. a drab olive or grey-green overall), the pole kept. **Mulroney** (call 03): coat and hat read; check his still. Cast plates for the look: `C:\Users\kazda\kiro\gtai-n23\prologue\cast\*.png` (look only; do not copy them in as art).
3. **Wave 1 stands in a 2x3 grid** and falls in 6.5 s after Dale (pilot, seed 7). The owner wants two to five minutes for the whole prologue for a player who does not die. Make wave 1 a fight of roughly 40-70 s for the pilot: the frightened cops back off to keep distance, regroup in a loose bunch (not a grid), fire wild in panic bursts, and the catchers pin Rivet at pole reach so the claw/roll lessons happen. Do it with prologue-side behaviour and `prologue_stage.json` numbers (spawn timing: e.g. the six patrol cops in two groups through the gate; retreat distance; burst timing), **never by more health or bigger enemies** (owner: harder by what they do to a moving player, not by size or health alone; humans are always weaker than Rivet). Do not change `enemies.json` rows.
5. **Mulroney is not found at a glance** (stills `mulroney-order-t3410.png`, `mulroney-hit-t3468.png`): in both I cannot tell which figure is Mulroney: every man in the line is a blue helmeted cop. Give him the coat and the hat (a long dark coat tint/overlay and a peaked cap or hat drawn in his view; his plate is `C:\Users\kazda\kiro\gtai-n23\prologue\cast\` Mulroney), stand him visibly BEHIND his line, and draw his order tell above HIM (an order mark + a short wind-up ring that fills over the 1.5 s tell, vermilion = danger is allowed) so the order reads before the volley/flank. The "exposed" 1.6 s window needs its own read (e.g. the line's shields drop/part and a small open-mark over him). The owner's film clip "Mulroney giving an order and being punished after it" depends on this.
6. **Prompt overlap**: the pistol lesson prompt ("Select pistol [Mouse Wheel Down] · Aim [mouse] and fire [LMB]") runs under the wheel's Hands/Pistol popup and the pistol card (still `mulroney-hit-t3468.png`). Keep the prompt card clear of the wheel popup and the weapon card (shorter text per prompt step, or move the card).
4. Same check for wave 2 and Mulroney: the pilot's wave-2 fight should be 40-90 s with at least two orders visible.

## Acceptance
- Stills at 32 px/m tilt 70 of: the yard at tick 300, Dale with the megaphone, a warden with pole and overalls next to a patrol cop, Mulroney among his line -> `C:\Users\kazda\kiro\gtai-masters\n23\prologue\scratch\`. Before/after pair of the yard at the same tick and zoom. Never fake a frame.
- Pilot full run: seconds per beat (beat 1 talk, wave 1, beat 2 talk, wave 2, beat 3) and total; total between 120 and 300 s; deaths. Two seeded runs byte-identical (`cmp`). `scenario_prologue_pilot` still passes (update its tick budget if needed).
- Unit tests for the new pacing rules (retreat keeps distance, groups enter in order).

## Tests
`node tools/tests/run_unit.mjs --select=<basenames>`; `node tools/lint/lint.mjs`; `node tools/gate/quick.mjs` before each commit; the scenario suite once at the end (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`, quote the summary line).

## Owned files (allowlist). Any other path: stop and write `NEED <lane>: <file> <why>` in your report
- `project/boot/prologue/**`, `project/dev/prologue/**`, `project/dev/bots/prologue_*`
- `project/data/tables/prologue_*.json`, `project/data/schemas/prologue_*.schema.json`
- `project/tests/unit/test_prologue_*.gd`, `project/tests/golden/prologue/**`, `project/tests/scenarios/scenario_prologue_*.gd`
- append-only, one line each: `project/boot/launch_args.gd` KNOWN_FLAGS (then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n23 prologue"`), `docs/decisions.md`
- Forbidden (other lanes, read-only): `enemies.json`, `bosses.json` (except the `mulroney` entry), `project/boot/collect_call/**`, `project/boot/quest1*`, `project/features/**` (all of it, including art there: reuse it, never edit it), `combat.json`, `gauntlet*.json`, `input_actions.json`, `test_player.json`, `quest_rules.json`, `tools/gauntlet/**`, every existing tape and golden.

## Law
- AGENTS.md and STANDARDS.md bind. Typed GDScript; files about 200 lines (hard 300; split into new `prologue_*.gd` files before you hit it); functions of 40 lines or fewer; at most 5 parameters. `Log`, not print. UI text through `tr()`. No global RNG; sim on `SimClock.TICK_DT`.
- Colour law: red is blood only; cops blue; vermilion only for danger, objectives and Rivet's collar; teal only for souls; amber for heat/overload.
- No generated art; placeholders from existing rigs, props and decals, tints and small drawn shapes only.
- Fix lint and format findings in your own edits and go on.
- Stage per path. No `git add -A/./-u`, no `commit -a`, no stash, no amend, no rebase, no reset --hard, never push. One commit per working piece. Do not commit `JOURNAL.md`, `REPORT.md` or `evidence/briefs/**`.
- Shipped scenes, quest 1, the 60 s replay and every existing tape stay byte-identical. Do not invent story or lines.
- When you are done, make sure no Godot or shell you started is still running (kill by PID).

## Report at the end
Commits (sha + subject), files, commands with result lines, seconds per beat and total, deaths, still paths (before/after), what is left, any NEED.
