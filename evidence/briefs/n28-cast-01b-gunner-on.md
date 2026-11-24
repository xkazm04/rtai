# Brief n28-cast-01b-gunner-on: continue robot gunner A (the first call died at 17:01)

**Read `evidence/briefs/n28-cast-01-gunner-on.md` first: goal, the four open points with their exact bars, films, owned and
forbidden files and repo law all hold unchanged.** Only the times and the state below are new.

**Hard stop 18:15 local** (check `date` often): commit what is green, report and END. Start the first `git commit` by
17:20 (it is ready, see below); start your last commit no later than 18:00.

## State you inherit (do not redo it)
- The previous builder session died at 17:01 (the whole machine went over the shared 8 GB memory cap: peak 9082 MB; its own
  node process was killed). Nothing is committed yet. **Staged and ready (keep them, read them, then commit them as commit 1):**
  `project/dev/cast/cast_gunner_{fight,poses}.{gd,gd.uid,tscn}`, `tools/art/cast_gunner_{ink,review}.py`,
  `tools/art/cast_gunner_poses.mjs`, `tools/film/cast_gunner_films.mjs`, `tools/debt/baseline.json` (dev_loc accepted
  rise "gunner measurement scenes for n28 cast"; if you change the dev files, re-run
  `node tools/debt/debt.mjs --update --accept-regression="gunner measurement scenes for n28 cast"`).
  Partial outputs in `build/cast/gunner/` (`ink_70.png`, `ink_55.png`, `feet.json`, `tracks_*.json`, `run.log`).
- **Its commit failed on `tools/film/kill_reel_scout.break.test.mjs` with a Node out-of-memory crash (v8 LowMemoryNotification
  in `build/lint/tool-tests.txt` line ~300), NOT a stale class cache.** Retry the commit; if that test fails again with the
  same v8 out-of-memory trace, wait until `C:\Users\kazda\kiro\gtai-cap\status\n28.json` shows `usedMB` under 5500 and
  retry once more. Never skip the hook.
- **Never run `Godot_*.exe` directly** (the previous session's last act was a raw `"$GODOT_BIN" --import`): every Godot launch
  goes through `tools/lib/godot.mjs` (`tools/dev/run.mjs <entry>`, your `cast_gunner_poses.mjs` / `cast_gunner_films.mjs` if
  they call `runGodot`, gate, mutate). `runGodot` runs the `--import` itself when the class cache is stale. Before relying on
  your two `.mjs` runners, check they use `runGodot`; fix them if not.
- **RAM:** every `runGodot` waits until 1.2 GB fits under 80 % of the cap. Tonight the machine is near full, so a launch can
  queue for minutes (`mem-budget: waiting` in the log is not a hang). Fold takes into as few Godot launches as possible (one
  launch for all frozen poses at both pitches, one per film). Run only one Godot at a time. If a launch has waited 20
  minutes, write it in your report and spend the time on the sheet-based measures (ink from the sheets is acceptable for the
  Ink point if the live 32/64 px/m frames are also looked at once they render).

## Order now
1. Commit the staged work (commit 1).
2. Frozen poses (rim at 64 px/m, ink, shadow toggle on his rings) in one launch; audit rows with numbers; commit.
3. Films (`gunner_close_64.mp4`, `gunner_fight_32.mp4`, true 1920x1080 60 fps through your `cast_gunner_films.mjs`); ffprobe;
   look at the frames; `frames.json`.
4. If all four points pass by their bars: `enabled: true`, audit + decisions line, tests, quick gate, commit. Else he stays
   off and the audit row says what fails, by how much, or what stayed unmeasured and why.
5. Mutate as in brief 01, only if time remains before 18:00.

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Report at the end as brief 01 asks, plus the minutes you spent waiting on the memory budget.
