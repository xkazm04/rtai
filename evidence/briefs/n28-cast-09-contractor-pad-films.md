# Brief n28-cast-09: contractor size jump (padded), rim bar vs lancer, films, on only if all pass

Lane `cast`, branch `n28-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
**Hard stop 22:50 local** (check `date` often): at the hard stop commit what is green, report and END.
**Start your first commit by 22:22; start your last commit by 22:40.** Never leave finished work uncommitted; if a part is
not green by 22:40, commit nothing half-made and list the paths in your report.

Read first, in full: `evidence/briefs/n28-cast-08-contractor-checklist.md` (env, Films path in part D, ALLOWLIST, FORBIDDEN,
checks and repo law: ALL of it binds this call) and the "Contractor, n28" sections at the end of `docs/art/cast-audit.md`
(the checklist table and its verdict). Done: `5df931099`, `33adcae5c` (checklist; he stays OFF for two reasons below).

Env, every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Never run `Godot_*.exe`
directly (not even `--import`): use `tools/dev/run.mjs`, the film tools, or `node -e` with `runGodot` from `tools/lib/godot.mjs`.
One Godot at a time; rendering `--rendering-driver d3d12`; windowed `--position 0,1440`.

## Work, in order

A. **Size jump fix** (`project/features/characters/cast_card_kinds.gd` is a cast file: it is in your allowlist for THIS call).
   Today he shrinks to ~0.75 of his walk height when he aims or is hit (64 px/m, 70: stand 86, tell 64, fire 65, hit_1 55,
   hit_4 69; 55: 88/66/68/53/66), because `CastCardKinds.padded` lists only `appliance_warden_` and `robot_gunner_`.
   First MEASURE per contractor sheet (`project/features/characters/art/view/{p70,p55}/contractor_{planted8_armed_walk,attack,
   cast_hit,cast_fall,card}.png`): cell height and figure (opaque bbox) height in texels, and write it in the audit; then make
   `padded()` true for exactly the contractor sheets whose cells are padded like the walk (likely `contractor_attack`,
   `contractor_cast_hit`; the fall only if its cells carry the same padding; the old `contractor_hit/fall.png`
   and `contractor_card.png` (192 px) must NOT change: quest 1 reads them). Prefer a precise prefix list
   (`contractor_attack`, `contractor_cast_`) over a bare `contractor_`.
   Bar: re-run the checklist poses launch (`cast_contractor_poses` via its mjs, one launch): silhouette height on tell, fire,
   hit_1, hit_4 within 5 % of stand, same facing, 70 and 55, 64 px/m; fall rest not taller than stand. Also show the warden and
   gunner numbers do not move (a test or the same launch). Add a unit test in `test_cast_contractor.gd` (or a new
   `test_cast_card_kinds.gd`) that pins `padded()` true for his attack/hit and false for `contractor_hit.png`,
   `contractor_fall.png`, `contractor_card.png`. Commit (code + test + audit rows).

B. **Rim bar on flashed cells** (DECISION by the director, 22:02): a cell drawn while the shared hit flash is lit
   (`CutRig.set_tint` on a raw card) is judged against the shipped lancer card in the same harness, not against 0:
   pass = no worse than the lancer (hit pulse <= 482 at 70 / 596 at 55; fall cell 0 <= 1161 / 1079). Calm cells keep bar 0.
   Re-quote his numbers from the A launch (they may change with the size); write the rule and the verdict into the audit
   table, and add it to `docs/art/cast-checklist.md` under the rim point (one or two lines).

C. **Only if A and B pass**: films exactly as brief 08 part D (1920x1080 scratch-project path of
   `tools/film/cast_gunner_films.mjs`, a contractor variant under `tools/film/`; never edit `project/project.godot`):
   `contractor_close_64.mp4` (walk, aim tell, fire, hit, fall to rest) and `contractor_fight_32.mp4` (Rivet against three
   contractors, card on) to `C:\Users\kazda\kiro\gtai-masters\n28\cast\`, both 1920x1080, 60/1, 15-40 s: quote the
   `ffprobe` lines. Extract frames at 1 fps around tell, fire, hit and rest and LOOK at them: describe what you see,
   including: no size jump between walk and aim; ONE gun at every rest (the game's pickup); white hat, pale lemon vest;
   Rivet about 77 px tall at 32 px/m. Then `enabled: true` in `cast_cards.json` (contractor row), flip the test in
   `test_cast_contractor.gd`, check every test that pins his card-off look (`run_unit.mjs --changed`, and grep tests for
   `contractor`), one line appended to `docs/decisions.md`:
   `- [2026-11-24] DECISION cast n28: contractor card on (white hat, pale lemon vest, 8-drawing walk at 0.30 m) ...` with the
   numbers and the flashed-rim rule; add both films to `C:\Users\kazda\kiro\gtai-masters\n28\cast\frames.json` (valid JSON
   array; keep the existing entries). Commit. If enabling him moves a scenario or tape (the gauntlet uses the production
   contractor): run `node tools/gate/quick.mjs --files=<changed>` and the scenarios that name contractor; if any shipped
   replay/tape digest moves, keep him OFF and report it (a re-pin is the director's call).
   If any point fails: he stays OFF; write which bar fails and by how much.

Allowlist: brief 08's plus `project/features/characters/cast_card_kinds.gd` and `project/tests/unit/test_cast_card_kinds.gd`.

## Report (then END)
Commits; A per-sheet measures + before/after heights table; B numbers and rule text; film paths + ffprobe + frame
descriptions; `run_unit.mjs --changed` summary line (quote it); on/off and why; uncommitted paths. No mutate. No images.
