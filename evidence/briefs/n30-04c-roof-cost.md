# Brief n30-04c `roof-cost`: bring the hall roof's frame cost under the bar (lane yard, run n30)

HARD STOP: see the time in the prompt that launched you (report and END). FIRST COMMIT (if the value changes) started no later than 25 minutes after launch; LAST COMMIT started no later than 12 minutes before the hard stop. Check `date` often. Never amend, never rebase, never `--no-verify`.

## Setup
As `evidence/briefs/n30-04b-roof-place.md` (env exports, runGodot-only tools, renders d3d12 at `--position 0,1440`). Lane Godot slot `build/yard-godot.lock` (tag `roof-cost`) around every Godot launch and every `git commit`; table lock `build/yard-table.lock` (tag `roof-cost`) before any edit of `project/data/tables/prologue_yard_dressings.json` (incl. the temporary `arched_noroof` row), released after the commit / after the temporary row is removed (check `git diff --quiet` on the table afterwards). Another builder (`mouth-deeper`) may share the worktree: never stage paths you did not edit; always `git commit -m ... -- <paths>`.

## Where it stands
`evidence/yard30/roof_frame_cost.md` (04b): three paired rounds under the bench lock, p50 delta (after - before) mean +0.444 ms, CI95 [-0.402, +1.290]: bar "p50 upper CI95 < 0.5 ms" NOT proven. Rounds 2/3 +0.25 ms, round 1 +0.84 ms; round 2 hitched in both arms. Its batch scripts are in `build/roof/` (`probe.mjs`, `batch2.sh`), the probe's arm whitelist got a measuring-only id `arched_noroof` that was restored afterwards. The five roof slabs (`hall_roof_*` rows in `arched_line.factory_front`) carry `ochre: true`, so `PrologueYardPaint.attach_ochre` draws each 15.45 x 5.5 m slab a second time.

## Work
1. Look first: `ochre: false` on the five slab rows only (one data value each). Front still at 32 px/m (`--place=front`, tick 2858) and the roof at 64 px/m (`--place=roof`), before (HEAD) | after, to `evidence/yard30/roof_ochre_off_{32,64}ppm.png`. LOOK: if the roof loses its print look badly (it turns flat or a different hue from the facade), keep `ochre: true` and go straight to step 3 with HEAD as is (a measurement only). Otherwise keep it: `node tools/tests/run_unit.mjs --changed` (the roof test), pilots seeds 7/3/11/21/42 in ONE Godot process to `evidence/yard30/prologue-yard-pilots-roof-cost.json` identical to the newest `evidence/yard30/prologue-yard-pilots-*.json` (if not: stop, revert, report). COMMIT 1.
2. (only if step 1 kept the change) nothing else to change.
3. Frame cost: the 04b method with FIVE paired rounds of 60 s (order ABBA-style: before/after, after/before, before/after, after/before, before/after), before = 98cd845b2's `arched_line` as the temporary `arched_noroof` row (and the probe whitelist edit, restored byte-for-byte). Hold `C:/Users/kazda/kiro/gtai-n30/bench.lock` for the whole batch (noclobber; if it exists and is younger than 20 min wait up to 10 min, then measure without it and write CONTENDED; older = stale, delete it); delete it after. Record load per sample (`GTAI_CAP_STATUS` used MB, CPU %). A round whose sim ticks in 60 s fall below 3000 in either arm is a hitch: re-run it once at the end. Write the table, the paired mean and CI95 and the verdict into `evidence/yard30/roof_frame_cost.md` (a new section at the top, keep 04b's below). Bar: p50 upper CI95 < 0.5 ms. Append one `docs/decisions.md` line `- [2026-11-25] DECISION yard n30 roof cost: ...` (committed at once after `git diff --quiet -- docs/decisions.md`). COMMIT 2.

## Owned files (allowlist). Any other path: stop and report a NEED.
`project/data/tables/prologue_yard_dressings.json` (the five `hall_roof_*` rows' `ochre` key, plus the temporary measuring row never committed), `project/dev/prologue_yard/yard_frame_probe*` (temporary whitelist edit, restored), `project/tests/unit/test_prologue_yard_roof.gd` (only if it pins `ochre`), `evidence/yard30/**`, `docs/decisions.md` (one line), `C:/Users/kazda/kiro/gtai-n30/bench.lock`, `build/**`.

## Forbidden
Every other repo path (`JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, `project/features/**`, the span rows and art), other worktrees, image generation, codex/astra/builder.mjs. No `git add -A/./-u`, `git commit -a`, stash, amend, rebase, reset --hard, push.

## Report (final message, then END)
Commit shas; ochre kept or off and why (what you saw); the five-round table summary (p50 mean, CI95, verdict, CONTENDED or not, load); pilots identical yes/no; what was not done.
