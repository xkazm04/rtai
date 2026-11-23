# Brief 04b `films-cost` (resume) - lane yard, run n25

HARD STOP: wall clock 04:42. Last commit by 04:35. Check `date` after each step.

## NEED answered
You are authorized to raise the debt baseline for the yard film entry, through the debt tool only:
`node tools/debt/debt.mjs --update --accept-regression="yard film entry and frame probe for n25 yard"`, then stage `tools/debt/baseline.json` with your step 1 commit. Do not hand-edit `baseline.json`. Before that, keep the growth small: if `yard_film.gd` and `yard_stills.gd` duplicate camera placement, share it (a small helper in `project/dev/prologue_yard/`) so the accepted rise is as low as it can be. ObjectDB leaks at capture shutdown: note them, do not chase them.

## Then, in order (steps refer to `evidence/briefs/04-films-cost.md`; same law, allowlist and forbidden list, plus `tools/debt/baseline.json` through the tool)
1. Commit step 1 (staged files + baseline), with `node tools/gate/quick.mjs` green.
1b. **Mid film fix**: you saw the fighters leave the fixed crop by 12 s in `pair_mid_32ppm.mp4`. Re-pick the mid camera centre and tick range from the pilot's own position data so Rivet stays inside the 960 px crop for the whole clip (the camera stays fixed and identical in both halves); if no single 1600-tick window does that, use two 800-tick segments with their own fixed camera, joined by a 6-frame dip. Re-render, ffprobe, look at frames at 2, 13 and 25 s, update `films.json`.
2. Step 2 (full prologue on the default dressing + three excerpts). The end-card excerpt must show no void at the right edge of the street: look at its last frame and say so.
3. Step 3 (frame cost under the bench lock, A B x3). If the time left is under 25 min when you reach it, run 2 rounds instead of 3 and say so.
4. Step 4 (contact sheet) only if 10 min remain.

## Report
As in brief 04: per step done / not done, commit, every output with its ffprobe line, the frame-cost table and lock times, what each film shows and any fault in its frames, the accepted debt rise (metric, old -> new).
