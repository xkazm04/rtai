# n10 perf REPORT (DRAFT, kept current; branch `n10-perf`, cut from main 9bbe6d0a)

Method and every number: `docs/perf/LEDGER.md` section "n10 night".

## What works, with its evidence
1. **Rig cost under combo (item 1) cut under the 1 ms target.** rig_bench 50 people, `--view=combo`, headless, CONTENDED, interleaved against main 9bbe6d0a: p50 ~1.2 ms -> ~0.6 ms (`evidence/perf/n10-rig/`). The walkers' whole-figure cards hid the cut rig's parts, yet every pose step still solved both legs and both arms: now the limbs are skipped while the card is up (`CutRig.limbs_cold`), posed on the card's release and before a kill's cut reads them. Pixels: a frame-compare of the rig stress at combo differs by 0 pixels against main (`evidence/perf/n10-rig/framecmp/`). Commits d006d70e, a9370647; tests `test_rig_limbs_cold` (5); full unit exit 0 on d006d70e.

## What does not work / not done yet
- Item 2 (the feed snapshot scan, native), item 3 (the release riot A/B), item 4 (the research loop): not started as of it1.
- Item 1 owed: director reel x3 on the head, the evidence gate, a mutation run on the cold path.

## Calls for the owner
(none yet)

## Next steps
See JOURNAL `NEXT:`.
