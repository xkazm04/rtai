# Follow-up n27-cast-01b: the warden's numbers and films (resume of your warden session)

Same worktree, branch `n27-cast`, same rules as your first brief (`evidence/briefs/n27-cast-01-warden.md`: APPDATA, GODOT_BIN,
one Godot at a time, d3d12, `--position 0,1440`, owned/forbidden lists, repo law, no image generation).
**Hard stop 04:55 local** (check `date`): commit what is green, report and END. **Commit the measured audit row by 04:25.**

Director's review of your first call: `dae51b291` and `7e86b3163` accepted. The quick gate's "FAIL res://..." is the
standalone `--check-only` load missing the autoloads (`Identifier not found: Log` / `LaunchArgs` in the chain): not yours, ignore
it; run `node tools/tests/run_unit.mjs --changed` instead (the full one, after your `CastCardKinds` refactor) and quote it.
The yard call you wrote is filed as a `NEED yard` by the director: do not edit prologue files.

## Do, in this order
1. `node tools/tests/run_unit.mjs --changed` green on HEAD; quote the line.
2. The lineup scene: `cast_warden_lineup` exited "Rivet empty or clipped" at 32/70. Find why (compare with
   `cast_mulroney_lineup`, which worked last night) and fix it in `project/dev/cast/**` only. 15 minutes max; if it still fails,
   render the lineup through `cast_mulroney_lineup` with her added, or say what blocks it.
3. Measure and quote every number (her card forced on in the dev scenes, `--cast-warden-trace` or whatever your row uses):
   - planted feet: sole / body jump, right and down-right, 70 and 55, walk 2.8 m/s and her arrival walk (`cast_feet.mjs`);
   - body jump on a stop, a turn AND a reversal (aim one way, step the other; extend `test_cast_walk_reversal.gd`);
   - drawings per second per gait;
   - 64 px/m edge measure (`tools/art/cast_mulroney_edge.py`) on all eight sheets (walk, attack, hit, fall x 70/55) + planted8;
   - size: px at 32 px/m 70 degrees for her (pole excluded), the patrol cop and Rivet; she must not be taller than Rivet;
   - wound contact: her boot on the shadow during a hit;
   - palette: no blue on her, no red outside blood.
   Fill her `docs/art/cast-audit.md` row with these numbers (replace "NOT MEASURED"), and replace the wrong "see JOURNAL" text
   with the exact yard call from your report (file, function, the three-line loop) and the three `prologue_props.gd` sites the
   yard must skip when `CastCards.current(&"appliance_warden") != null`. If every point passes, set `enabled: true` in
   `cast_cards.json` in the same commit; otherwise keep it false and list the fails. Commit by 04:25.
4. Films (after that commit, stills first), to `C:\Users\kazda\kiro\gtai-masters\n27\cast\`: `warden_beside_64ppm_tilt70.png`
   and `_tilt55.png` (her beside the patrol cop, Mulroney and Rivet, front three-quarter and back), `warden_swing_64.png` (the four
   attack columns down-right at 64 with the same at 32 beside), `warden_before_after_32.png` (same tick and zoom: the dyed rig
   + vector pole she has today / her card), then `warden_close_64.mp4` and `warden_fight_32.mp4` (1920x1080, 60 fps, 15 to 40 s;
   `ffprobe` both). Create `frames.json` there (`[{ "file", "title", "ppm", "before", "note" }]`, best first). Look at every frame.
5. If time: `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_warden_card_view.gd --max=20`; quote the score.

## Report (and END by 04:55)
Commits; every number above; enabled true/false and why; film paths + ffprobe lines; mutate score; what you could not do.
