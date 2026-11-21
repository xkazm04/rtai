# n22-street brief 04: every result field, the five-wave film, mutate

Lane `street`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-street`, branch `n22-street`. Briefs 01 to 03 are
committed (read `git log --oneline -20` first). Never rename anything from the interface commit.

**Wall-clock hard stop: 03:45 (stop working, write the final message). Commit deadline: 03:38.** Commit each item when it works. Fix lint and
format findings in your own edits and go on. Never amend, never rebase. No `git stash`, no `git add -A/./-u`,
no `commit -a`, no `reset --hard`, no tags, no merges. Stage per path; never stage `JOURNAL.md` or
`evidence/briefs/**` (the director's). Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
(`--rendering-driver d3d12` for rendering, `--position 0,1440` on any windowed run: never the main display).
One Godot process at a time; free your own by PID. Mutate: `--max=20 --lines=<changed>`.

## Allowlist (any other path: stop that item and report `NEED <owner lane>: <file> <why>`)
`project/dev/gauntlet/**`, `project/features/gauntlet/**` except `bot/**` (lane loop's), `gauntlet.json`,
`gauntlet_bonuses.json` + their schemas, `gauntlet_run.schema.json`, `project/tests/unit/test_gauntlet_*.gd`,
`test_stat_mods.gd`, translation rows for your own `tr()` keys, `evidence/street/**`, one appended line in
`docs/decisions.md` per decision, and `C:\Users\kazda\kiro\gtai-masters\n22\street\` for frames and clips.
`tools/film/shots.mjs`: you may add ONE `gauntlet` entry to `SHOTS` (one line plus a comment; name it in the
final message) if that is the shortest way to film; nothing else in `tools/`.
Forbidden: `project/features/player/**`, `project/features/combat/**`, `project/features/souls/**`,
`arena_projectiles.gd`, `arena_dodges.gd`, `enemies.json`, `weapons.json`, `combat.json`,
`input_actions.json`, `TickInput`, `tools/gauntlet/**`, `project/boot/**` except one appended
`KNOWN_FLAGS` line if a new launch flag needs it (then `node tools/debt/debt.mjs --update
--accept-regression="<flag> for n22 street"`).

## Items, in order
0. **Colour law (director's review of 7a3ce0bc1 / ec142944f).** Teal is only for souls (the ghosts). Street's
   new UI uses teal for non-soul things: `GauntletHud.TEAL` (#83d7ba) fills the health bar and colours the
   "Wave N cleared" caption, and `GauntletPickCard.LEAF` (#28584e, a dark teal) draws the kind label, the stat
   number and the focus outline. Replace them with the shipped HUD's palette (`HudArt` / `hud_view.gd`: INK
   #17131b, the paper tone; read how the shipped HUD colours Rivet's health and use the same). Red is blood
   only; vermilion only for danger, objectives and the collar; amber only for heat, overload and a cancelled
   cast. A ghost card may keep the ghost's own art. Re-take `pick_screen_32.png` after it. One commit.
1. **Telemetry fields** of `gtai.gauntlet-run/1` per wave, measured by street's own code by reading state each
   tick (never by editing the player's files): `rolls` (count Rivet's roll starts: `PlayerMotion` exposes
   `roll_progress()` / `can_roll()`; a rising edge of "rolling" is one roll), `form_seconds{<form>: s}`
   (ticks spent in each form incl. `rivet` / base, / 60, two decimals or as the schema says),
   `shots`/`hits`/`damage_taken` already exist: check that they are right with a weapon in hand (a pick gives
   a gun: shots > 0). `guard_deflects`: guard's deflect code is not on this branch: omit the key (never 0) and
   leave one clearly named function where the merge wires it (name it in the final message). A value that was
   not measured is omitted. Update the result schema if it lacks a field (keep `gtai.gauntlet-run/1`; adding
   optional keys is fine). Unit test: a run with a forced form change and a forced roll records both.
2. **Film flag for the pick screen.** A human sees the cards; a bot does not. For the owner's film add a dev
   launch flag `--pick-view` (declared in the scene's `KNOWN_FLAGS`; dev scene only): with a bot, the three
   cards show for 90 ticks (sim paused, the HUD visible) before the bot's choice is shown highlighted for
   30 more ticks, then the run goes on. Off by default; headless results with it off stay byte-identical to
   before item 2 (prove it with seed 7: cmp against a run without the flag at the same commit).
3. **The film.** A 32 px/m, tilt 70, 1080p60 film of 20 to 40 s of seed 7 (or a seed that shows more
   variety: say which and why) with `--bot=average` if lane loop's bot exists on this branch, else the
   fallback walker, `--pick-view`, through five waves including the wave-5 war machine and at least two pick
   screens visible. Use `tools/film/film.mjs` if a `gauntlet` shot fits (it gives stills + the numbers),
   else Godot's `--write-movie <file>.avi --fixed-fps 60` on the windowed scene and `ffmpeg -c:v libx264
   -pix_fmt yuv420p -crf 18` to mp4. If five waves exceed 40 s, cut it into `gauntlet_waves1-3_32.mp4` and
   `gauntlet_waves4-5_32.mp4` (each 15 to 40 s) or speed nothing up: never time-lapse. Output to
   `C:\Users\kazda\kiro\gtai-masters\n22\street\`. Also a 64 px/m close-up still of Rivet fighting at a cover
   prop (`fight_cover_64.png`). Look at the frames yourself (extract 4 stills per clip with ffmpeg and open
   them): Rivet visible, enemies visible, HUD readable, cards readable, no black or title frames, the camera
   follows. Say what each still shows.
4. **frames.json** in that folder: 8 to 15 entries, best first,
   `[{ "file", "title", "ppm", "before", "note" }]` (`before` = null where there is no before), covering the
   film(s), the pick screen, the six segment stills, the close-up. Delete scratch renders it does not reference.
5. **Mutate** (commit first): `node tools/mutate/mutate.mjs --file=features/gauntlet/gauntlet_draw.gd --max=20`
   and on the bonus-apply file; quote killed/(killed+survived); add a test for any survivor that is a real
   behaviour gap (not an equivalent mutant), one commit.
6. **Wave pacing numbers** (measure only, change nothing in the table): seed 7, 8, 9 headless 10 waves: per
   wave seconds and deaths, into `evidence/street/pacing.json` with the commit sha. The design target is 15 s
   per wave; report the median and the worst wave per seed. Lane loop's tuner owns the numbers.

## Final message
Commits, files, test counts, verdict lines (`tools/dev/run.mjs` verdict), byte-compares, every file in the
masters folder with a one-line description of what you saw in it, mutate scores, pacing table, every NEED,
anything undone.
