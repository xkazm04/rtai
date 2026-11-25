# n30 combat call 23: the nuke round's last vermilion px, by the c18 soot seam (model first, then in game)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Check `date +%H:%M` at start.
**Hard clock: start the commit (hook ~12 min) by 16:50, commit by 17:05, report and END by 17:12.** Never end with an
uncommitted product edit: commit it with its evidence or `git checkout -- project/features/combat/weapons/art/fx/nuke_shell.png`.
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot at a time in this worktree (you are the only builder running Godot). Godot only through shipped tools (runGodot).

## Why / read first
- `evidence/n30/rounds/band.md`: the nuke shell's nose band was recoloured amber (`recolour_band.py`); at 64 px/m, tick 1212,
  39 vermilion px remain along the two black stripes' edges. c07b darkened the band's edge px (`--stripe-edge`, value caps
  0.30/0.14/0.09) and the count ROSE (71/60/55).
- `evidence/n30/floor/specks.md` (c18) explains why: the FX item print (`look_d4_item`) snaps every sampled colour to its
  NEAREST ink among CREAM, STEEL, INK, VERM, AMBER, TEAL. Amber->ink blends between ~25 % and ~70 % ink are nearest VERM;
  a dark amber-brown edge is itself in the VERM cell (that is why c07b got worse). The blast cells were fixed by turning the
  amber->ink fringe into a soot grey (128,118,118) (alpha 128 there): amber->soot blends snap AMBER/STEEL, soot->ink snap INK.
  Model tools: `evidence/n30/floor/snap.py <png>` (texels + neighbour blends that snap VERM) and `sim.py <png>` (bilinear x k).
- So: put a soot seam (opaque or not: you measure which reads better) between the amber band and each ink stripe of
  `project/features/combat/weapons/art/fx/nuke_shell.png`, only texels inside or touching the band mask (recolour_band.py's
  mask). Find the on-screen scale k of the sprite at 64 px/m (box 395,328,440,401 at t1212 vs the PNG size) and model at that
  k (the downscale averages several texels: a 1-texel seam may vanish; widen to 2 if the model says so).

## Do
1. Model: `snap.py` + `sim.py` (add the k you found) on HEAD nuke_shell.png and on your candidate(s). Write the candidate with a
   small script `evidence/n30/rounds/seam.py <in> <out> [width]` (reproducible; HEAD PNG via `git show HEAD:<path>`; if LFS,
   smudge as recolour_band.py does). Pick the candidate with the fewest modelled VERM px.
2. In game: write it into the PNG, run an import FIRST (`node tools/tests/run_unit.mjs --select=<a test from step 4>` imports;
   a windowed take does NOT reimport a changed PNG), then
   `node evidence/n29/red/take.mjs build/n30seam/after 1206,1212,1218 --rigs --bot=reel --reel=director --loadout=pistol --chapter=pistol,machine_pistol,rocket_launcher,mini_nuke --ppm=64 --clean --silent`
   and the same ticks at HEAD into `build/n30seam/before` (restore the PNG + import before it, or take before first).
   Count with `evidence/n30/rounds/band_stills.py` logic (round box 395,328,440,401 at t1212; find the box at 1206/1218 from
   the diff bbox + 6 px): vermilion `r-max(g,b) >= 0.31`, amber, red, teal, px changed outside the box.
3. **Bars to commit**: t1212 vermilion 39 -> at most 10, and lower on 1206 and 1218 too; amber at least 850 (was 957); red 0
   added, teal 0, 0 px changed outside the round box; the stripes still read as two dark stripes on an amber band. LOOK at
   the before | after crop (6x nearest) yourself. If no candidate meets the bars by 16:45: restore the PNG, commit only the
   script + a `## c23 soot seam (not landed)` section with the model and in-game numbers (that negative is still evidence).
4. Unit tests that reach the PNG: `node tools/tests/test_map.mjs project/features/combat/weapons/art/fx/nuke_shell.png`, then
   `node tools/tests/run_unit.mjs --select=<those>`; quote the summary line. `node tools/lint/lint.mjs` (quote the line).
5. Still `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/nuke_round_seam_pair_64.png` (t1212, before | after, crop of the
   round at 6x nearest, labelled with the counts). Append `## c23 soot seam` to `evidence/n30/rounds/band.md` (commands,
   model numbers, table, what you saw). Do NOT edit frames.json, JOURNAL.md, REPORT.md, docs/decisions.md.
6. Commit: `n30 combat c23: nuke band stripe soot seam (t1212 vermilion 39 -> N)`.

## Commits
Stage per path, `git commit -m "..." -- <paths>`; never `git add -A/./-u`, no stash, no amend, no rebase, no reset --hard,
never skip the hook. End the message with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. If the hook fails on
`tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: import, commit again. Fix lint and format findings in your
own edit and go on. Another builder may commit `evidence/n30/floor/specks.md` meanwhile: never stage or restore it.

## Allowlist
Commit only `project/features/combat/weapons/art/fx/nuke_shell.png` (+ its `.import` only if it changed),
`evidence/n30/rounds/**`. Write freely `build/**` and the masters stills dir. Forbidden: every other path (print shaders,
`core/render/**`, other lanes' files). Anything else: stop and report a NEED.

## Report and END
Scale k, model numbers (HEAD vs candidates), in-game table, what you saw, test + lint lines, commit hash, what you could not do.
