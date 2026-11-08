# REPORT: lane handheld (n10, 2026-11-08/09), IN PROGRESS

Branch `n10-handheld`, cut from main 9bbe6d0a, with `n10-world` aadc7430 merged (half-height walls). Every number is **on the simulator** (this PC under a device profile), never on a device, and every one is CONTENDED. Research and tables: `docs/handheld/LEDGER.md` section 9. Stills: `C:\Users\kazda\kiro\gtai-masters\n10\handheld\frames.json` (6 entries, not the 8-15 asked: no more subjects were worth filing).

## What works (with evidence)

1. **The rows on the new main, with lane world's walls.** Re-run after the merge: the director reel in combo, headless, under `--device=deck`, `deck40`, `handheld_1080`, `switch-handheld`: 19 of 19 chapters fully down on every row, 0 SCRIPT ERROR (`evidence/n10h/it5/reel/`). I stopped the four runs about 10 minutes after their last chapter, so **no exit code was observed**. Windowed city in combo on the iGPU on all four rows, exit 0 (`evidence/n10h/it5/sim/`, LEDGER E22). The walls read as two whole storeys with the grey print kept, at 32, 40 and 64 px/m on the Deck row and at 40 on `handheld_1080` (stills looked at; `frames.json`).
2. **Windows handheld model strings.** 19 strings on `handheld_1080` from public tables, each source named in LEDGER section 9. New tonight: the ROG Ally (`ROG Ally RC71L`) and the Legion Go, Go S and Go 2 (Lenovo's type numbers, in a new whole-name list `models_exact`). Tested in `test_device_auto_pick`. None confirmed on a device.
3. **The Steam checks, as far as they go with no Steam app.** `Platform.hardware()` is the auto-pick's first check, and the prompts now ask `SteamGlyphs.texture()` first, so one backend line is the whole glyph swap (`test_steam_glyphs`: a fake backend returning a real PNG swaps the glyph; no path or a bad path keeps the drawn one). The GodotSteam method names in the comments are now read from 4.24's source. Nothing has run against Steam.
4. **The research loop and the port readiness table.** Table updated (LEDGER section 7). The loop stopped by the brief's rule: Windows display scaling and the controller-first shell both give nothing this simulator can measure (LEDGER section 9).

Gates on this work, head 0822e5cc: the lint hook passed on the commit. The director reel in top, tilt70 and combo, `--quit-after 40000`: 19 of 19 chapters fully down, 0 SCRIPT ERROR, **exit 0 observed on all three** (`evidence/n10h/it9/reel/`). Each log carries two engine lines marked ERROR, neither a script error: a shader-compiler condition raised from `kill_char_fx.gd:189` (also in the it5 Deck reel) and "90-91 resources still in use at exit". Lint 15 / 15 and full unit 1971 passed, 0 failed, 371 files (`build/evidence/unit-tests.junit.xml`, this run). Mutation on `steam_glyphs.gd` at 0822e5cc: 4 mutants, 2 killed, 0 survived, **2 undecided** (both on line 26, the unreadable-image guard, timed out at 300 s on the loaded machine). The tool prints 100 %, which counts only the 2 decided. **The evidence run (`node tools/evidence/run.mjs --no-bench`) on 0822e5cc passed lint and unit, then was stopped at its 40-minute limit while re-judging `rig_stress`: scenarios, parity and release-compile have no verdict on this head and are owed.**

## What does not work yet

- **`handheld_1080` did not hold 60 in the city after the merge:** p50 27.0 ms, 991 frames in the run, with 9 other Godot processes going (E22). Render GPU is 9.3 ms, against E9's 60 hold at 9.9. One contended run with no pre-merge arm: not attributed to the walls or to anything else. The Deck row held its lock in the same batch (p50 16.66 ms).
- **The walls' cost on a handheld row is unmeasured.** E22 has no pre-merge arm, so it says the rows run, not what the walls cost.
- **The quest 1 freeze on a handheld row:** 0 frozen in 8 runs on each arm of the enabled / mailbox A/B (one round short of the plan). That is a small sample. The rows keep `vsync: enabled` (DECISION `handheld/rows-keep-vsync`).
- **The MSI Claw line and the ROG Xbox Ally do not pick their row:** only board names are public.
- **The rich-text card keeps the drawn glyphs** when Steam's would show in the prompts: a remapped pad would see both.
- The ESteamHardwareType numbers 0-3 are not confirmed: GodotSteam's source binds the names in that order, not the values.

## What blocked, and for how long

- The machine is heavily loaded (7-9 other Godot runs at a time): commits wait minutes on the lint hook, and plain file reads time out.
- Iteration 1 lost about 25 minutes to my own hunt script (void runs, not counted). Iteration 5 lost one unit run to my own `timeout` wrapper, which killed the runner before it reported.
- Iteration 9: the pre-merge A/B for E22 was not run. `bench.lock` was held by lane perf when I tried at 23:27, and the run's rule is to skip the bench for that iteration. The scratch arm is ready for a later one.

## Calls for the owner

1. **The auto-pick's Steam source** (no frame: an API change). Steamworks SDK 1.65 removed the Deck check the brief named. a) `IsRunningOnSteamHardware()`, built; b) `GetSteamHardwareDefaultConfig()`, which Valve's changelog offers for default settings, to be judged with a real SDK.

## Next steps

- Read the evidence run on 0822e5cc; the exe at the freeze.
- E22's 60 Hz miss: the interleaved pre-merge A/B on `handheld_1080` in the city (a1c1edfd vs head, scratch worktree ready). It prices `aadc7430`'s storeys only, because `height_k` is already 0.5 at a1c1edfd.
- Merge `n10-world` again if it lands more wall work (none since aadc7430: pole shadows and corpses).
- One DMI dump each for the MSI Claw line and the ROG Xbox Ally; the numeric hardware types against the SDK header when GodotSteam is vendored.
