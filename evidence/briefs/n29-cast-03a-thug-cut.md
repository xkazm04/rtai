# Brief n29-cast-03a: robot thug A, step 1 only: cut, pack, tone, provenance (no row, no code)

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent.
**Hard stop 03:55 local** (check `date +%H:%M` often). **Start your commit by 03:40** (the pre-commit hook can take
~12 min). Never end with finished work uncommitted. Then report and END.

## Read first
`evidence/briefs/n28-cast-04-thug.md` in full: its "checklist's exact bars", "Source sheets", "Build, in order" step 1 and
step 2's walk paragraph, and the "Added 20:45" lessons bind you. Where it says n28, read n29: APPDATA is
`C:/Users/kazda/kiro/gtai-n29/appdata/cast`, films go to `C:\Users\kazda\kiro\gtai-masters\n29\cast\`, the machine cap is
16 GB (`mem-budget: waiting` is not a hang).

## This call's scope: step 1 + the walk cut, nothing else
1. Check names first: `project/features/characters/art/view/p70/thug_*.png` are the HUMAN thug (never touch). Every file
   you write is `robot_thug_*`; `ls`/grep that none exists yet.
2. Cut and pack the eight 4-drawing sheets `gtai-art/foes-n26/thug/out/thug_{armed_walk,attack,hit,fall}_{70,55}.png` into
   `project/features/characters/art/view/{p70,p55}/robot_thug_{armed_walk,attack,hit,fall}.png` the way the gunner's were
   (`tools/art/cast_gunner_pack.py`; reuse it by a kind/id argument if the change is small, else a sibling
   `tools/art/cast_thug_pack.py`), patrol layouts, hit sheets scaled to the walk's body height, the `hit_70` col 3 green patch
   handled (say how).
3. Cut the 8-drawing walk `gtai-art/foes-n26/thug8c/out/thug8c_{70,55}_{down,dr,right,ur,up}_t3.png` into
   `robot_thug_planted8_armed_walk.png` at both pitches (the contractor's 8-drawing pack `tools/art/cast_contractor_pack.py`
   and cop8 are the models), every facing matched to one body height (the 4-drawing walk's), stripes toned to the 4-drawing
   sheets' stripe hue (median within 5 deg; quote both medians before/after), never red or vermilion (strict-red px 0
   outside the lens; quote the lens hue).
4. Key-clean: zero strongly green- or magenta-leading opaque px (alpha >= 128, 50-level lead) on every shipped PNG; quote
   the counts. Look at every sheet yourself at 1x on grey (Read tool on a PNG you compose under `build/look/n29-thug/`) and
   say what you see per sheet (the fall: no loose part that reads as a weapon or pickup).
5. Provenance: one `steam/ai-provenance/2026-11.jsonl` line per shipped PNG (model: the gunner's lines, `tools/art/cast_gunner_provenance.py`).
6. Run one Godot `--import` through runGodot (`node tools/dev/run.mjs` imports a stale cache; or
   `node -e "import('./tools/lib/godot.mjs').then(m=>m.runGodot(['--headless','--path','project','--import'],{name:'import'}))"`
   - read `tools/lib/godot.mjs` for the exact signature), so the `.import` files exist; commit PNG + `.import` + pack tool +
   provenance in one commit. Pack intermediates in `gtai-art/foes-n29/thug/pack/` (not in the repo).

## Repo law (binding)
- Godot only through runGodot; before it `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/cast` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- **Lane Godot lock**: take `until mkdir build/lane-godot.lock 2>/dev/null; do sleep 15; done` before any Godot launch and
  `rmdir build/lane-godot.lock` right after (also on failure); stale after 25 min.
- Stage per path, commit only your paths. Banned: `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend, rebase,
  branch switches, push. Never skip the hook; if it fails on `tools/film/kill_reel_*.break.test.mjs`, import and commit again.
- Fix lint and format findings in your own edit and go on. Python tools: keep them small and readable.
- No image generation. Commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
`project/features/characters/art/view/{p70,p55}/robot_thug_*` (+ `.import`), `tools/art/cast_thug_*.py` or a small
kind-argument edit of `tools/art/cast_gunner_pack.py` / `cast_contractor_pack.py`, `steam/ai-provenance/2026-11.jsonl`
(append), `C:\Users\kazda\kiro\gtai-art\foes-n29\thug\**`, scratch `build/look/n29-thug/`.
Forbidden: `cast_cards.json` (step 2 is the next call), every `.gd`, `docs/**`, other characters' art, other lanes' files.

## Report (then END)
Commit sha, file list, per-sheet cell size and body height, key-clean counts, stripe medians, lens hue, what you saw on
each sheet, what you could not do.

## Added 03:23 (this call is short: 32 minutes)
The director's session ends at 04:01 and you die with it. Work in this order and keep
`C:\Users\kazda\kiro\gtai-art\foes-n29\thug\STATE.md` updated after every step (what is cut, packed, checked, committed; the
exact commands), so the next call can resume. Do steps 1-2 (the four-drawing sheets) first and commit them with their
`.import` and provenance by 03:40 even if step 3 (the 8-drawing walk) is not done; the walk goes in a second commit only if it
is checked by 03:50. Skip the full-suite unit run (no `.gd` changes); run `node tools/gate/quick.mjs` before the commit.
