# n27-06: the gauntlet seed 7 pilot is the same whatever the key slot order

Question: `e1c4b73d9` changed which ghost each number key deploys (`ghost_forms.json` `deploy_slots`
`["dent","tonnage","kerf","ohm"]`, before `["dent","kerf","ohm","tonnage"]`). The gauntlet bot presses
`GhostNumberKeys.action(form)`. Does the seed 7 pilot still do the same run?

Answer: **yes, byte-identical**, in both pick modes. HEAD = `44142eae5` plus this file; headless, one Godot at a time.
"new" = the committed order, "old" = `deploy_slots` temporarily edited to the old order in the working tree (never committed;
restored with `git checkout -- project/data/tables/ghost_forms.json`, `git diff --quiet` on it exits 0 afterwards).

## Command (n26 style, `docs/gauntlet-loop.md` line 270; n26's own command line was not recorded, this is its form)
```
export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/keys
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
node tools/dev/run.mjs gauntlet --seed=7 --bot=average --pick=greedy --controls=wheel --waves=10 --result=<abs>/slots_{new,old}.json
node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=10 --result=<abs>/random_{new,old}.json     # default pick (random)
```
Files under `build/keys-pilot/` (git-ignored): `slots_new.json`, `slots_old.json`, `random_new.json`, `random_old.json`.
Each run: ~14 s, exit 0.

## Result
| run | sha256 of the result JSON | wave reached | death | deploys |
|---|---|---|---|---|
| greedy, new order | `6969e23b9c744d20f928ec09f2bd84415abe4081ae73a59043efbe23a3b571ab` | 9 | swat, wave 9 | 10 |
| greedy, old order | `6969e23b9c744d20f928ec09f2bd84415abe4081ae73a59043efbe23a3b571ab` | 9 | swat, wave 9 | 10 |
| random, new order | `d14b72a9786dd33235ed819f467024df35fe06c228e2a44698a833f0e558e0a1` | 10 | war_cannon, wave 10 | 12 |
| random, old order | `d14b72a9786dd33235ed819f467024df35fe06c228e2a44698a833f0e558e0a1` | 10 | war_cannon, wave 10 | 12 |

`cmp` new vs old: identical for both pairs. The run logs (minus the command header and the timing line) are also identical
line for line in both pairs (wave announcements, move openings).

## Deploys (from the result JSON `waves[].deploys`, per wave and form; same in new and old)
Greedy (9 waves, 10 deploys, forms Kerf and Ohm; the bot picked `ghost_kerf` at wave 1, `ghost_ohm` at wave 7):
| wave | form: count |
|---|---|
| 5 | kerf 2 |
| 6 | kerf 1 |
| 7 | kerf 1 |
| 8 | kerf 1, ohm 4 |
| 9 | kerf 1 |
| total | kerf 6, ohm 4 |

Random pick (10 waves, 12 deploys; this run moves the key of two forms between orders, Tonnage moves from key 4 to key 2, Kerf from 2 to 3, Ohm from 3 to 4;
a stronger test):
| wave | form: count |
|---|---|
| 4 | tonnage 1 |
| 5 | tonnage 2 |
| 6 | tonnage 1 |
| 7 | tonnage 1 |
| 8 | ohm 2 |
| 9 | ohm 3 |
| 10 | tonnage 1, ohm 1 |
| total | tonnage 6, ohm 6 |
Wave starts (random run, ticks): 1: 272, 2: 1090, 3: 2251, 4: 3501, 5: 4587, 6: 5528, 7: 6458, 8: 7740, 9: 9493, 10: 11077.
Greedy wave starts: 272, 1092, 2417, 3911, 4759, 6605, 8155, 9195, 12057.

Not available: the tick of each single deploy. The gauntlet logs no deploy lines and the result JSON keeps per-wave counts
only; adding a log line is product code, outside this call. Identity of the whole result (every wave's hits, kills, damage,
bond, form seconds, deploy kills) and of the wave-start ticks is what carries it: a deploy one tick off would move those.

## dev_verdict lines
- greedy new: `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 5 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd)`
- greedy old: `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 5 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd)`
- random new: `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 3 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd)`
- random old: `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 3 against KNOWN_FLAGS (res://dev/gauntlet/gauntlet.gd)`

## Difference from n26's line
n26 reported "11 deploys, 9-wave". Greedy here gives 9 waves and 10 deploys; random gives 10 waves and 12. n26 ran on an older HEAD and its exact flags (pick mode, waves) were not recorded, so its count is not
comparable; what is proved is new-vs-old order on the same HEAD.
