# JOURNAL n10-perf (2026-11-08 night, lane perf)

## it1 (21:01-) BUILD
Plan: item 1 rig cost under combo (target <= 1 ms p50 at 50 people), item 2 feed snapshot scan native, item 3 riot release A/B vs main 9bbe6d0a, item 4 research loop.

MILESTONE (it1, 21:5x) item 1 first cut committed d006d70e: a walker's hidden limbs are not posed (CutRig.limbs_cold; legs/arms skipped while a walker's whole figure card hides the parts, warm_limbs on release / kill cut). rig_bench 50 people combo headless, 3 interleaved pairs, CONTENDED (10-12 Godot processes): base 1.16-1.24 ms p50 (r1 base discarded: import cold, p99 2.6 s), head 0.53-0.66 ms. Files touched in characters' area: cut_rig, rig_gait, rig_pose, street_walker_cards + new street_walker_rows (tables moved to stay <= 200), rig_head_card, street_crowd_cards, rig_build (the on_view body moved, cut_rig debt 265 -> 263). test_rig_limbs_cold: 4 tests. Lint green on the commit. FRICTION: this machine is loaded (git diff 120 s, ripgrep timeouts); long timeouts needed. Owed for item 1: full unit, director reel x3, a frame check that walkers still draw, mutate on the cold path.

MILESTONE (it1, 21:46) a9370647: halo fix after a frame compare caught cream rims showing at walker feet (5683 px differed); after the fix base vs head 0 px at combo. Full unit on d006d70e: EXIT 0. Files: evidence/perf/n10-rig/{ab.sh,run1,run2,framecmp}.
DECISION perf/cold-limbs in docs/decisions.md.
NEXT: (1) when the run2 A/B lands, finish LEDGER/REPORT numbers and commit; (2) gates on the head: `node tools/lint/lint.mjs`, `node tools/tests/run_unit.mjs`, director reel x3 (top, tilt70, combo; --quit-after 40000), `node tools/evidence/run.mjs --no-bench`; (3) mutation on rig_pose/rig_gait cold paths; (4) item 2 (feed snapshot scan, native), item 3 (riot release A/B under bench.lock), item 4 research loop. Note: machine is heavily loaded: give shell commands 5-10 min timeouts; Grep times out (use narrow paths).

## it5 (22:10-) BUILD
Plan: gates owed on item 1, then item 2 (native feed scan), item 3 (release riot A/B under bench.lock), item 4.
FRICTION (it5, 22:3x): director reel `top` on 55cbf9db exited 139 (native crash, no backtrace, last line: electro_gun chapter, frame 4641), 0 SCRIPT ERROR. NOT explained yet: I edited city_fx_feed.gd and native sources in the same tree during that run, so the run is not clean evidence either way. To do: re-run top alone on a quiet tree; if it crashes again, repeat on base 9bbe6d0a before blaming or clearing limbs_cold.
