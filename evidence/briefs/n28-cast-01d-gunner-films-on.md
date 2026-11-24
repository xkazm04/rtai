# Brief n28-cast-01d: robot gunner A, the two films, then switch him on

Lane `cast`, branch `n28-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
**Read `evidence/briefs/n28-cast-01-gunner-on.md` first: the four points with their exact bars, the film specs, owned and
forbidden files and repo law hold unchanged.** No image generation in this call.

**Hard stop 19:15 local** (check `date` often): commit what is green, report and END. Start your first commit by 18:45;
start your last commit no later than 19:00 (the pre-commit hook takes up to 12 minutes). Never amend, never rebase.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**Never run `Godot_*.exe` directly**: only through `tools/lib/godot.mjs` users. One Godot at a time. Windowed runs
`--position 0,1440`. Fix lint and format findings in your own edit and go on.

## State you inherit
Read `git log --oneline -8` and the gunner section of `docs/art/cast-audit.md` (~line 327): points 1 (rim), 2 (ink) and 3
(shadow) are measured there by the previous call, and the p70 fall double rifle was fixed by an image edit (or not: if the
audit says the fall still shows two rifles, he stays off; say so and stop after step 1).

## Order
1. **Films (point 4)** with `node tools/film/cast_gunner_films.mjs C:/Users/kazda/kiro/gtai-masters/n28/cast 64 32`
   (read it first; it runs `project/dev/cast/cast_gunner_fight` in a 1920x1080 scratch project via runGodot; fix it if the
   64 take is not the close take beside the patrol cop and Rivet, or the 32 take is not Rivet against three gunners):
   - `gunner_close_64.mp4`: 64 px/m, tilt 70, one gunner beside the patrol cop and Rivet: walk, lens tell, fire, hit, fall, rest.
   - `gunner_fight_32.mp4`: 32 px/m, tilt 70, Rivet against three gunners (card on): they tell, fire, get hit and fall.
   - `ffprobe` each: must print `1920x1080`, `60/1`, duration 15-40 s. Extract one frame per second of each
     (`ffmpeg -i x.mp4 -vf fps=1 build/cast/gunner/film_<n>/%02d.png`) and LOOK at every one: lens tell before the first
     harmful tick (`telegraph_s` 0.9 s), flash, recoil, recover, hit holds 0.20 s and returns to walk, fall to rest on his back
     with ONE rifle beside him, no red, no blood, feet on their ring. Rivet about 77 px tall at 32 px/m (about 154 at 64):
     measure on one frame and quote it.
   - Stills in the same dir: `gunner_beside_64ppm_tilt70.png` (card on, beside the patrol cop and Rivet) and
     `gunner_rim_64.png` (copy of the rim exposure). `frames.json` there: JSON array, best first,
     `{ "file", "title", "ppm", "before", "note" }`.
   - Audit: the film row with the ffprobe lines, the Rivet px and what each look showed. Commit (audit + any tool/dev change).
2. **If all four points pass by their bars:** `enabled: true` for `robot_gunner` in `project/data/tables/cast_cards.json`;
   update the gunner section's verdict and his rows in the summary tables (~line 26 and the card table ~233); append ONE line
   to `docs/decisions.md`: `- [2026-11-24] DECISION cast: robot gunner A card on (n28): rim <n>, ink <runs>, shadow <px>,
   films <paths>; with the row false his robot rig draws as before.` Run `node tools/tests/run_unit.mjs --changed` and
   `--select=test_cast_gunner`; he is rendering only: replay digests, quest 1 and prologue tapes must stay byte-identical (if a
   test pins `enabled: false` for him, update that test only). `node tools/gate/quick.mjs`, commit.
   If a point fails: he stays off; the audit row says what fails and by how much. Commit that.
3. Mutate only if time remains 15 min before 19:00: `node tools/mutate/mutate.mjs --file=<FoeGunnerCardView's real path> --max=20 --tests=test_cast_gunner`
   with a 10-minute budget; quote killed/(killed+survived).

## Report at the end
Commits; ffprobe lines; Rivet px; what each looked-at frame showed (list the bad ones); enabled true/false and why; mutate
score; quick gate line; minutes waiting on mem-budget; what you could not do.
