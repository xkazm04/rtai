# Brief n27-cast-02b-feet-films (resume): the feet films, the missing takes, --changed, mutate

Same session, same brief (`evidence/briefs/n27-cast-02-feet-riot-swat-lancer.md`), same allowlist, forbidden list and repo law.
**Hard stop 07:15 local** (check `date` often): at the hard stop commit what is green, report and END. No new art, no new wiring.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot at a time.

Director's review: `e3ca4c6b6` + `7ebdaa84e` ACCEPTED (all takes under the checklist bars, audit table in). The owner judges by
films and there are none. In this order:

1. **Films first** (true 1920x1080 via the warden films path, `6b3bdffcd`; check on one extracted frame that Rivet stands about
   77 px (front) at 32 px/m): `feet_<riot|swat|lancer>_before_after_64ppm_tilt70.png` (before = the FOUR strip, after = the
   eight, same tick and zoom, sole dots per rendered frame, the contact bracketed), then `feet_three_before_after_32.mp4`
   (each walking across a metre grid, before left / after right, 20 to 40 s, 60 fps; SWAT also runs). If the clip's layout
   costs too long, ship three plain 32 px/m clips (one per character, before and after side by side) instead. `ffprobe` each
   clip. Append entries to `C:\Users\kazda\kiro\gtai-masters\n27\cast\frames.json` (stay a valid JSON array). Look at every
   frame you deliver, and say in the report whether 12.7 to 15.6 drawings/s reads as a flicker on the clip.
2. `node tools/tests/run_unit.mjs --changed`: quote the pass/fail line. If red on your code, fix it (smallest edit) and commit.
3. Stop and turn takes (body jump <= 12 px) for the four sheets if `cast_feet` already has them; add the numbers to the n27
   audit table and commit. Skip if it needs new code.
4. Mutate: `node tools/mutate/mutate.mjs --file=project/features/characters/cast_card_kinds.gd --max=20 --lines=<lines you changed>`;
   quote the score.

Commit any doc or tool change on its own (`git add <path>`; no amend, no rebase). Never fake a number or a frame. Fix lint and
format findings in your own edit and go on. Report (commits, film paths + ffprobe lines, --changed line, mutate score, flicker
verdict) and END by 07:15.
