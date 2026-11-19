# Brief 10 `calls-polish` (lane move, n19): fix the shared-file slip, finish car doors, stills for the owner's Calls

Before ANY Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Rendering runs: `--rendering-driver d3d12`; windowed runs `--position 0,1440`. One Godot process at a time.
Never kill processes by name. Commit each step as it lands: this session is stopped at 75 minutes.
The freeze is 07:30; nothing after it.

## 1. Restore the shared line in `project/boot/launch_args.gd` (do this first, one commit)
`KNOWN_FLAGS` is shared and append-only. f8e7c9d8f rewrote the existing d9-rivet lines
```
	# d9-rivet: --rivet-height=<m> sets Rivet's drawn standing height under a card view (Call 1)
	"--rivet-height",
```
into one line `"--rivet-height",  # d9-rivet: ...`. Put those two lines back exactly as at `28302bd3c`.
Check: `git diff 28302bd3c HEAD -- project/boot/launch_args.gd` shows ONLY added lines (our 5 commented flags).
If a line-count debt or file-size check then fails, do NOT reword other lanes' lines: shorten OUR appended
comments (they may share one comment line above them) or record it with `--accept-regression="n19 move flags"`.

## 2. Car doors: one visual fix (brief 08 is otherwise accepted)
In `gtai-masters/n19/move/car/on-64/131-seat.png` the entering Rivet is drawn as a translucent ghost ON TOP of
the sedan's roof (helmet and collar visible through the roof). That reads as a ghost, not as getting in. Make
him disappear INTO the car instead: while the door motion is past the door point, draw him under the car body
(the car card occludes him: depth/z order, or clip his figure at the car's door edge), with the fade kept short;
the exit mirrors it (he emerges from under the door edge). Render only: no sim state, flag-off digests unchanged,
the door scenario still twice identical. Re-render the car INDEX frames at ticks 124, 131, 316, 319 (32 and 64
px/m, off and on) and the 32 px/m clip; look at them and say what you saw. If the car layer order makes this
impossible without touching `features/city/**` or `features/characters/**`, use the clip (a mask from the car
quad) instead, and say which you did.

## 3. Side-by-side stills for the owner's Calls (dev scripts and frames only, no product change)
Each pair: same tick, same zoom, tilt 70 at 64 px/m plus 32 px/m, written to
`C:/Users/kazda/kiro/gtai-masters/n19/move/calls/` with an INDEX.md line per file (what, tick, the value).
Both alternatives must be ONE data value or flag already; if one is not, make it one (data + schema), default
unchanged.
- **Cover peek distance**: `peek_m` 0.8 (shipped) vs 0.45, Rivet peeking and firing past a station's end in the
  pit arena, the guard visible. Also say whether his own diagonal shot at 0.45 is stopped by the box he covers
  behind (measure it: the shot-stop rule's answer for that shot at both values).
- **Vault into a guard**: the shipped tackle (vaulting into a standing guard: peak about 12.2 m/s, guard shoved
  about 1.74 m) vs the alternative where the vault refuses (or stops) when a body stands in the landing.
  If the alternative does not exist as a data value, add `vault.bodies_block_landing` (bool, default false =
  today's behaviour) with a red-before unit test, and film both.
- **Car doors**: flag off (cosmetic view only) vs `--car-doors` (sim phase), same tick of an enter, 64 px/m.

## 4. Update `C:/Users/kazda/kiro/gtai-masters/n19/move/frames.json`
8 to 15 entries, best first, `{file, title, ppm, before, note}`: add the best car-door before/after and the
fuzz evidence if it has a picture; drop weaker entries to stay within 15. Delete scratch renders frames.json and
the INDEX files do not reference.

## 5. Mutation scores (after steps 1-4 are committed)
Run and save each JSON to `build/mutate/<name>.json` (`--json`), quote killed/(killed+survived):
`node tools/mutate/mutate.mjs --file=features/player/player_vault.gd --max=20 --json` (last measured 50 % at
22:41, before the gap tests), `--file=features/player/stride_match.gd --max=15`, and
`--file=features/vehicles/vehicle_door_view.gd --max=15`. For each survivor, say in one line whether it is an
equivalent mutant or a test gap; close real gaps with a test if time allows (commit), and re-run that file.

## Not yours
`features/arena/**`, `features/combat/**` (ai), `features/characters/**` (anim), city/police/native (gfx), any
golden or digest file, `project/boot/**` beyond an existing call site.

## Repo law
AGENTS.md + STANDARDS.md; typed; functions <= 40 lines; files ~200 (hard 300); `Log`, never `print`; no global
RNG; commit `.uid` files. Stage per path; no stash, add -A, reset --hard; never push; never stage JOURNAL.md,
REPORT.md or evidence/. Keep doc comments. Commits `move: ...` with
`Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Acceptance (I check after you)
launch_args diff vs base = added lines only; quick gate (`node tools/gate/quick.mjs`) + lint clean;
`run_unit.mjs --changed` green; stills exist and you looked at each (say what you saw); frames.json valid JSON
with 8-15 entries; `git status` clean. End with a table: step, commits, checks run, result.
