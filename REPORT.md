# REPORT lane yard, run n26 (2026-11-23): the factory yard, second pass

DRAFT (session 4, 15:20): sections marked TODO are filled after call 04 (line-card), call 06 (card), the gate and the films.

Branch `n26-yard`, worktree `C:\Users\kazda\kiro\gtai-wt\n25-yard`, cut from `main` `0779185ac`. Merged in: `n26-keys` at `8d8bb3787` (MILESTONE keys), TODO `n26-cast`.
The second pass is a new dressing row `line_fire` in `project/data/tables/prologue_yard_dressings.json` and the default; `plain` and `torn_line` stay selectable and keep their pilot bytes.

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. Plate beside game, the gaps | `JOURNAL.md` session 1 (11:12), ten gaps | 10 gaps listed |
| 2. Conveyor and wrecks as real cover | `evidence/yard26/layout_t6000.png`, `evidence/yard26/prologue-yard-pilots.json`, decisions line `DECISION n26 yard: line_fire` | pilot finishes 5/5 seeds; deaths 0/1/0/0/1 (seeds 7/3/11/21/42) vs torn_line 0/2/0/0/0; min hp 36/0/44/28/0 vs 36/0/2.8/36/28; stuck cops 0-2 per run, all at the gate arrival (x 35-36, y 31-32.5), none on new cover |
| 3. Dusk, fire light, broken front | `evidence/yard26/dusk_front_64ppm.png`, `evidence/yard26/dusk_t6000_32ppm.png`, `evidence/yard26/frame-cost.md` | patrol blue keeps 67.2 % of daylight contrast, rifle round 106.1 %, pellet 92.2 % (paper 0.84); frame cost p50 -0.04 ms [CI -0.70, +0.62] (bench lock, debug build); embers cut (+0.585 ms upper bound > 0.5) |
| 4. Chain-link and gate sheet | `evidence/yard26/fence_gate_32ppm.png`, `evidence/yard26/fence_gate_64ppm.png`, `evidence/yard26/fence_tile_check.png` | fence mutate 18/18 |
| 5. Pump tell | `evidence/yard26/pump_32ppm_before_after.mp4`, `evidence/yard26/pump_64ppm.png` | marker 51.2 px at 32 px/m (1.6 m), muzzle lift 28 deg; command view mutate 5/20 |
| 6. Keys merge, lesson cards | TODO films | TODO |

TODO: line join (call 04), ground shade dusk (call 04), cover mutate, card wiring (call 06), gate line, films.

## What does not
TODO

## What blocked or slowed you
- Codex image stall on the copy to `./out` (11:17 to 11:27): ~12 min; `grab.sh` copies by session id afterwards.
- Cast merge blocked twice by `tools/film/kill_reel_*.break.test.mjs` in the pre-commit hook (13:56, 15:08): ~27 min. Cause (cast lane, 15:12): a stale class cache makes the launcher run `--import` first, and the test's fake runner gets that call without `--film-dir`.
- Call 01 hit the 75 min cap without a final message: ~10 min of review by event log.

## Calls for the owner
TODO (dusk depth: ground shade vs screen grade; conveyor S; pump on card vs vector dress)

## Merge notes
- `prologue_stage.json`, `prologue_yard_dressings.json`, `project/boot/prologue/**` are yard's; pilot pins moved (decisions line).
- NEED director: `tools/film/kill_reel_*.break.test.mjs` must stub `dirty` / not depend on a fresh class cache, or every merge that stages tools + project fails its hook.
- Root `JOURNAL.md` / `REPORT.md`: keep each lane's own.

## Next steps
TODO

## Astra ledger
| Call | Tag | Minutes | Verdict |
|---|---|---|---|
| 01 | cover | 84 (cap) | accepted |
| 02 | dusk | 71 | accepted |
| 03 | fence-pump | 68 | accepted |
| 04 | line-card | TODO | TODO |
