# Brief n28-combat-02b (fresh, continues 02): the red audit, the deflect film, mutate

Lane `combat`, branch `n28-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP 19:22 (wall clock): report and END, even mid-task. Commit each finished part at once (audit by 19:08).**
Read `evidence/briefs/n28-combat-02-deflect-red.md`: its Why, D, E, Checks, Repo law and Allowlist bind you.

## State
Call 1 committed the fix `7e95d96fb`: the red fleck was `BareGunFx.shot`'s stand-in muzzle flash (`flash_pistol`, cream star
with a vermilion core, `project/boot/collect_call/view/bare_gun_fx.gd:34`) drawn for a turned round whose range the deflect
resets; `PlayerDeflect.TURNED` meta now skips it. Before/after stills + crops are in
`C:/Users/kazda/kiro/gtai-masters/n28/combat/stills/deflect_{guard,blade}_{before,after}_64[_crop].png` (guard tick 105,
blade = take `blade6_spaced`). Render command: `node tools/gauntlet/pressure_films.mjs --out=<abs dir> --only=guard_return_64.png,blade_spaced_return_64.png`
with `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe GTAI_GODOT_EST_MB=1000`.
Reddish = R>170, G<110, B<90 (recreate the counter in `evidence/n28/red/count_red.py`, run it with `python -I`).

## What, in order
1. **D, the red audit** (list only, fix nothing): exactly as brief 02 section D, into `evidence/n28/red/audit.md` +
   `evidence/n28/red/cells.png`. Include the plasma sword's red-ringed hilt (seen in `deflect_blade_after_64_crop.png`, 92
   reddish px) and every `flash_*` cell with a vermilion core (Rivet's and the stand-in muzzle flashes). One row per source;
   the three worst first. Commit (no Godot needed; python + grep).
2. **E, the film**: brief 02 section E (`deflect_6m_32.mp4` re-take on the fixed tree, one encode, ffprobe line). Find how
   n27 made it in `tools/gauntlet/pressure_films.mjs` / `evidence/n27-pressure/`. Add to
   `C:/Users/kazda/kiro/gtai-masters/n28/combat/frames.json` (keep the two existing entries; read it, append, write valid
   JSON): the film, `deflect_guard_after_64.png` (before = `deflect_guard_before_64.png`), `deflect_blade_after_64.png`
   (before = `deflect_blade_before_64.png`). Commit any tool change.
3. **Mutate**, if 12 minutes remain: `node tools/mutate/mutate.mjs --file=project/boot/collect_call/view/bare_gun_fx.gd --max=8 --lines=34-35 --tests=test_bare_gun_fx,test_deflect_marks,test_live_deflect`
   (stop it at the hard stop; say so). Score into `evidence/n28/red/mutate.txt`, commit.

## Report and END
Commits; audit row count + the three worst; film path + ffprobe line; mutate score; what was left.
