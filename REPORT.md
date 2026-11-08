# REPORT: lane handheld (n10, 2026-11-08/09), IN PROGRESS

Branch `n10-handheld`, cut from main 9bbe6d0a, with `n10-world` aadc7430 merged (half-height walls). Every number is **on the simulator** (this PC under a device profile), never on a device, and every one is CONTENDED. Research and tables: `docs/handheld/LEDGER.md` section 9. Stills: `C:\Users\kazda\kiro\gtai-masters\n10\handheld\frames.json` (6 entries, not the 8-15 asked: no more subjects were worth filing).

## What works (with evidence)

1. **The rows on the new main, with lane world's walls.** Re-run after the merge: the director reel in combo, headless, under `--device=deck`, `deck40`, `handheld_1080`, `switch-handheld`: 19 of 19 chapters fully down on every row, 0 SCRIPT ERROR (`evidence/n10h/it5/reel/`). I stopped the four runs about 10 minutes after their last chapter, so **no exit code was observed**. Windowed city in combo on the iGPU on all four rows, exit 0 (`evidence/n10h/it5/sim/`, LEDGER E22). The walls read as two whole storeys with the grey print kept, at 32, 40 and 64 px/m on the Deck row and at 40 on `handheld_1080` (stills looked at; `frames.json`).
2. **Windows handheld model strings.** 19 strings on `handheld_1080` from public tables, each source named in LEDGER section 9. New tonight: the ROG Ally (`ROG Ally RC71L`) and the Legion Go, Go S and Go 2 (Lenovo's type numbers, in a new whole-name list `models_exact`). Tested in `test_device_auto_pick`. None confirmed on a device.
3. **The Steam checks, as far as they go with no Steam app.** `Platform.hardware()` is the auto-pick's first check, and the prompts now ask `SteamGlyphs.texture()` first, so one backend line is the whole glyph swap (`test_steam_glyphs`: a fake backend returning a real PNG swaps the glyph; no path or a bad path keeps the drawn one). The GodotSteam method names in the comments are now read from 4.24's source. Nothing has run against Steam.
4. **The research loop and the port readiness table.** Table updated (LEDGER section 7). The loop stopped by the brief's rule: Windows display scaling and the controller-first shell both give nothing this simulator can measure (LEDGER section 9).

Gates so far on this work: mapped unit tests 40 / 0. **The full unit run, scenarios, parity and the evidence run on the merged head are owed** (see Next steps).

## What does not work yet

- **`handheld_1080` did not hold 60 in the city after the merge:** p50 27.0 ms, 991 frames in the run, with 9 other Godot processes going (E22). Render GPU is 9.3 ms, against E9's 60 hold at 9.9. One contended run with no pre-merge arm: not attributed to the walls or to anything else. The Deck row held its lock in the same batch (p50 16.66 ms).
- **The walls' cost on a handheld row is unmeasured.** E22 has no pre-merge arm, so it says the rows run, not what the walls cost.
- **The quest 1 freeze on a handheld row:** 0 frozen in 8 runs on each arm of the enabled / mailbox A/B (one round short of the plan). That is a small sample. The rows keep `vsync: enabled` (DECISION `handheld/rows-keep-vsync`).
- **The MSI Claw line and the ROG Xbox Ally do not pick their row:** only board names are public.
- **The rich-text card keeps the drawn glyphs** when Steam's would show in the prompts: a remapped pad would see both.
- The ESteamHardwareType numbers 0-3 are not confirmed: GodotSteam's source binds the names in that order, not the values.

## What blocked, and for how long

- The machine is heavily loaded (7-9 other Godot runs at a time): commits wait minutes on the lint hook, and plain file reads time out.
- Iteration 1 lost about 25 minutes to my own hunt script (void runs, not counted). This iteration lost one unit run to my own `timeout` wrapper, which killed the runner before it reported.

## Calls for the owner

1. **The auto-pick's Steam source** (no frame: an API change). Steamworks SDK 1.65 removed the Deck check the brief named. a) `IsRunningOnSteamHardware()`, built; b) `GetSteamHardwareDefaultConfig()`, which Valve's changelog offers for default settings, to be judged with a real SDK.

## Next steps

- Full unit run, scenarios, parity, evidence run and the director reel in top / tilt70 / combo on the merged head, then the exe at the freeze.
- Re-run `handheld_1080` in the city on a quiet machine, with a pre-merge arm, to settle the 60 Hz miss in E22.
- Merge `n10-world` again if it lands more wall work.
- One DMI dump each for the MSI Claw line and the ROG Xbox Ally; the numeric hardware types against the SDK header when GodotSteam is vendored.
