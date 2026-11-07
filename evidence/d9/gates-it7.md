# Gates it7 (on feb56ca2, 11:31-11:39)

node tools/evidence/run.mjs --no-bench with TEMP/TMP set to a lane-private dir (gtai-d9/scratch/rivet/it7/tmp): release-compile no longer meets the foreign %TEMP%\gtai-release-compile. EXIT 0.

```
PASS lint: lint: all 15 checks pass over 1207 GDScript files
PASS unit-tests: unit-tests: 1695 passed, 0 failed, 0 skipped (GUT, headless)
PASS scenario-tests: scenario-tests: 52 passed (headless)
PASS parity: parity: native == GDScript reference bit for bit over 1200 steps (40 snapshot checks, 3516 floats); planted mutation caught at step 629
PASS selftest: selftest: D4 city frames rendered (32 px/m ok, 100 actors, 132 colours; 48 px/m ok, 89 actors, 145 colours); 86 art textures, 0 placeholders, prewarm 32 ms; look goldens 11/11 within me
PASS export-audit: release-compile: 599 loaded, 0 failed
```
