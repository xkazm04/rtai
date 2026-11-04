# Riot blood A/B: blood_fx.json game.settled_redraw_ticks 6 vs 30 (2026-11-04 01:54-01:57, CONTENDED)

Tree 01b034aa (blood drops on their own canvas item since b3b3c92f). Exported windows-bench, riot only,
30 s, zoom 1.0, vsync off, under `gtai-n4/bench.lock`, four runs back to back (6, 30, 6, 30), other
lanes rendering at the same time. Script `evidence/n3/riot_ab.sh`, raw JSON `evidence/n3/bench/`.

| run | settled | p99 CPU ms | avg frame ms | 1 % low fps | blood us/frame | pool redraws | drop redraws |
|---|---|---|---|---|---|---|---|
| 01:54 | 6  | 8.681 | 2.053 | 85  | 59.3 | 301 | 1696 |
| 01:55 | 30 | 6.331 | 1.736 | 112 | 40.5 | 61  | 1696 |
| 01:55 | 6  | 6.466 | 1.800 | 104 | 50.1 | 301 | 1694 |
| 01:56 | 30 | 7.158 | 1.989 | 94  | 49.3 | 61  | 1692 |

Reading: with the drop split the whole combat blood (CombatBlood step + pool redraw + drop redraw, CPU)
is 0.04-0.06 ms a frame, under 3 % of the riot's average frame and about 1 % of its p99. The pools are
never "busy" in the city (landed splats are on the GPU mesh), so they redraw only on the settled cadence;
30 cuts those redraws 5x but the saving (~5-10 us/frame) is inside the run-to-run noise of this load.
The riot p99 swing (6.3-8.7 ms) is the contended machine, not the blood. The remaining riot cost is
elsewhere (sim step, rigs, the 400 actors' canvas); the idle bench of record should re-measure it.
