# JOURNAL - n26 lane `yard`: the factory yard, second pass (2026-11-23)

Branch `n26-yard` from `main` `0779185ac`, worktree `C:\Users\kazda\kiro\gtai-wt\n25-yard`. Director: Opus; builder: Astra.

## Session 1 (11:07, BUILD)
- 11:08 Read: n25-yard REPORT/JOURNAL, owner verdict line (`docs/decisions.md` 1517), plate `gtai-art/factory-n25/out/a-torn-line.png`, game pairs `evidence/yard/pairs/{mid,gate}_32ppm.png`. No Astra lock in `gtai-n26/logs/yard/`. No `NEED yard` or `MILESTONE` in the keys/melee/pressure/cast journals yet.

### Item 1: plate beside game, the gaps (11:12)
1. Time and light: plate is dusk/night, black sky, amber fire light; game is flat pale daylight (cream floor, no shadows, no light pools).
2. Broken front: plate's hall front has two loading doors burst outward, slats peeled, brick spilled, fire roaring inside; game shows roof blocks from above with a little amber in two roof tears, no open front, no fire glow on the yard.
3. Conveyor: plate's torn line snakes in a broad S from the burst doors deep into the yard as one continuous rail with hooks and drums; game has one 5.6 m conveyor piece at the west edge (on the old van footprint) and a flat drag trail.
4. Appliances hanging and fallen: plate has drums hanging from hooks and fridges/washers spilled along the line; game has a few white panels and one fridge row.
5. Pallets: plate has two wrapped pallets of boxed washers in the open foreground as cover; game has one pallet stack in the NE corner, out of the fight.
6. Forklift: plate's forklift is crashed mid-yard by the lamp; game's is on the pickup footprint SW, reads small and flat.
7. Robot arm: plate's toppled welding arm with sparks at a cut cable west of the doors; game's arm piece is a small yellow shape mid-yard without sparks.
8. Lamp: plate has a yard lamp post throwing a pool by the gate and wall lamps over the doors; game has none.
9. Phone at the gate: plate's payphone sits by the gate on the pavement; game has it (gate phone) but drawn small and unlit.
10. Fence and gate: plate has chain-link with barbed wire and a heavy sliding gate; game reuses the quest cage mesh on steel posts.
- 11:10 ASTRA RUNNING cover since 11:10 (Start-Process pid 52976, brief `evidence/briefs/n26-01-cover.md`, hard stop 12:30, last commit 12:25): new dressing row `line_fire` (default) with its own cover layout: conveyor as 4-6 segments in an S with >= 2.5 m gaps, two pallet stacks, forklift, robot arm, fridges; plain/torn_line unchanged; layout test; pilot on seeds 7/3/11/21/42 vs main; stuck-cop counts; re-pin + decisions line.
- 11:10 DECISION yard: the second pass is a new dressing row `line_fire` that may carry its own cover layout (replacing `yard.cover`/`yard.debris` from the stage when present), so `plain` and `torn_line` keep today's yard and pilot bytes, and the default switches with one value (`yard.dressing`). Rejected: moving the stage's shared cover list (would change the old yards too).
- 11:14 Art round `C:\Users\kazda\kiro\gtai-art\factory-n26\` started (gen.mjs, 4 sheets: conveyor-run, front-broken, fence-gate, yard-props). Refs: `game_torn_line.png` (crop of the shipped torn_line yard at 32 px/m), `game_yard.png`, `plate_a.png`. Pieces drawn in neutral light like the city; fire only inside the burst doorways; dusk comes from the engine's light layer.
- 11:27 FRICTION art: conveyor-run stalled in codex after the image existed (11:17); gen.mjs waited its 15 min timeout. Copied by hand into `factory-n26/out/conveyor-run.png` (accepted, first take). Two other lanes' sheets (cast's Mulroney, pressure's rocket) landed in the same generated_images folder at the same minute: matched mine by the path codex logged. fence-gate and yard-props now run as parallel gen.mjs processes beside front-broken. ~12 min lost.
- 11:36 Art in `factory-n26/out/`: conveyor-run, fence-gate, yard-props accepted (first takes; fence, lamp and payphone drawn side-on: squash to the 70-degree camera in the cut). front-broken drawn facade-on (about 45 degrees): kept as a fallback, re-take `front-broken-b` running (70-degree strips: roof edge, short wall band, ground with rubble). `grab.sh` copies each job's image by codex session id, ending the 15-min stall wait.
- 11:45 Art: front-broken-b accepted (four 70-degree hall-front strips with fire through burst doors, one with the conveyor coming out). Brief 02 points at it. Art round done: 5 sheets, 1 reject.
- 12:34 ASTRA cover 84 (STOPPED at the 75 min cap, no final message; review pending). Landed: d6493e585 "Bring the torn conveyor and factory wrecks into the playable yard", c49de89ab "Verify yard pilot compatibility, movement and paired footprint stills". Its event log (`gtai-n26/logs/yard/astra-01-cover.jsonl`) shows pilot runs per seed/dressing (e.g. plain seed 21: 0 deaths, min_hp 36, 8167 ticks) and stills via `yard_stills.tscn --dressing=line_fire --layout-pair`. Not yet verified by me: diffs, five-seed table, stuck counts, decisions line, mutate.

NEXT (session 2, from 12:37):
1. No Astra running (lock gone 12:34). Review d6493e585 + c49de89ab: `git show --stat`, the layout in `prologue_yard_dressings.json` row `line_fire`, `test_prologue_yard_layout.gd`, `evidence/yard26/layout_t0300.png`/`layout_t6000.png` (look at them), the decisions line, plain/torn_line unchanged. Grep the jsonl for the five-seed pilot table (seeds 7,3,11,21,42, line_fire vs torn_line) and stuck counts. If missing: resume call (`--resume`) with a short brief to finish steps 4-6 of brief 01 (tests, five-seed table, decisions line, mutate) first.
2. Then launch brief `evidence/briefs/n26-02-dusk.md` (fill <HARD>/<LAST>: launch+65 min / launch+60) with Start-Process (see 11:10 line). Art is ready: `gtai-art/factory-n26/out/` conveyor-run, front-broken-b (USE), yard-props, fence-gate; notes.md there.
3. Then brief `evidence/briefs/n26-03-fence-pump.md` (fence sheet + pump tell). Check `n23-prologue/JOURNAL.md` for `MILESTONE mulroney` and `n23-controls/JOURNAL.md` for `MILESTONE keys` (merge n26-keys after it, re-check lesson cards).
4. Last new work committed by 17:10; final gate by 17:25; films after.
