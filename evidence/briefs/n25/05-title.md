LAUNCH NOTE: wall-clock hard stop 05:38 (check the clock), commit deadline 05:36. Base: HEAD 69f1099c2 (packages 01-04 committed; keep them).
**The Director's final gate is running now (pid 73116, a node process; it spawns Godot in a snapshot). Do NOT start any Godot process
until pid 73116 has exited** (PowerShell: `Wait-Process -Id 73116`; it should end about 05:20). Edit and lint (no Godot) meanwhile.
If pid 73116 is still alive at 05:28, commit nothing, stop, and say so.

# Package 05 `title`: the title card names the chapter that Start opens

Today the slice title card (`project/boot/quest1_card.gd:61`) reads "Quest 1: Collect Call" under "RTAI: Uprising", but
since package 03 the Start button on the real menu opens the PROLOGUE (`project/boot/new_game_path.gd` `press_start`:
`campaign_menu or main_menu`, not `--autostart`, not `--skip-prologue`). The owner's morning film opens on this card
(`C:/Users/kazda/kiro/gtai-masters/n25/path/film-title.png`).

1. When Start will open the prologue (the same condition `press_start` uses: factor it into one `NewGamePath` predicate so the
   card and the button can never disagree), the card's vermilion subtitle reads the prologue's own name as the prologue shows it
   (its title card shows "Prologue": find the existing loc key/text the prologue end card uses, reuse it; do not write new story
   text). Otherwise (embedded runners, `--skip-prologue`, `--autostart`) the card is byte-for-byte as today. Text through the
   card's existing `_t()` (LOC-01). One unit test: the predicate and the subtitle for main-menu vs skip-prologue.
2. Every shipped scenario and tape stays byte-identical; quest 1's lines untouched.
3. Checks (after pid 73116 is gone): `node tools/tests/run_unit.mjs --changed` green; `node tools/godot/check.mjs` on the files;
   the scenarios that use the card (`quest1_input`, `quest1_keys`, `autosave_input`, `handheld_focus_pause`, `prologue_handover`):
   `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd -- --only=<names>` (or the runner's own --only form)
   green; `node tools/tests/release_compile.mjs` exit 0; `node tools/gate/quick.mjs` green; ONE commit. Then
   `node tools/mutate/mutate.mjs --file=project/boot/quest1_card.gd --max=10 --lines=<changed>` if time allows.
4. A still `C:/Users/kazda/kiro/gtai-masters/n25/path/title-prologue.png` (1920x1080, the menu as the real game opens, d3d12,
   `--position 0,1440`) only if it takes under 5 min; else skip it and say so.

Owned paths for this package: `project/boot/quest1_card.gd`, `project/boot/new_game_path.gd`, `project/tests/unit/test_prologue_*.gd`,
`project/boot/prologue/**` (non-scenery), `docs/decisions.md` (one appended line). Any other path: stop and report a NEED.

## Final message
The commit sha, the numbers, the still path or "skipped", anything left. Keep it short.
