## Environment (every Godot run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/controls`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time. Kill only your own processes by PID, never by name. Never rebuild native. Windowed or rendering runs: `--rendering-driver d3d12 --position 0,1440`.

## Repo law
- Stage per path; one commit per change; no `git stash`, no `add -A/./-u`, no `commit -a`, no `reset --hard`, **no amend, no rebase, never push**.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`, UI text through `tr()`, data JSON with schema, no global RNG, sim on `SimClock.TICK_DT`.
- `node tools/gate/quick.mjs` before each commit; **fix lint and format findings in your own edit and go on.** After adding scripts or art run `"$GODOT_BIN" --headless --path project --import` and commit `.uid`/`.import` files.
- Forbidden (other lanes' files): `project/features/gauntlet/**` (except a one-line call site the brief names), `project/dev/gauntlet/**`, `project/data/tables/gauntlet*.json`, `enemies.json`, `bosses.json`, `project/boot/prologue/**`, `project/features/souls/**`, `project/features/combat/ai/**`, `project/features/combat/squad/**`, `project/features/combat/shot*.gd`, `tools/gauntlet/**`, `test_player.json`, the `moves` block of `combat.json`. `combat_arena.gd`: one-line call sites only. **Any path outside the brief's allowlist: stop and report it as a NEED.**
- Mutate cap: `node tools/mutate/mutate.mjs --file=<main file> --max=20 --lines=<your changed lines>`; quote killed/(killed+survived).
- Digests: the 60 s replay (`cbeb734ff9b97c41...`) and every scenario tape stay byte-identical unless the brief says otherwise; a moved digest is reported with a one-line reason.
- Frames and films go to `C:\Users\kazda\kiro\gtai-masters\n23\controls\`. Never fake a frame.
