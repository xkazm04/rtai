# REPORT: lane handheld (n10, 2026-11-08/09), IN PROGRESS

Branch `n10-handheld`, cut from main 9bbe6d0a. Every number is **on the simulator** (this PC under a device profile), never on a device. Research and tables: `docs/handheld/LEDGER.md` section 9.

## What works (with evidence)

1. **The rows on the new main (combo, 1.65 m Rivet, mailbox).** The director reel in combo, headless, under `--device=deck`, `deck40`, `handheld_1080`, `switch-handheld`: 19 of 19 chapters fully down on every row, 0 SCRIPT ERROR in the logs. The four runs were stopped by the session's 30-minute job limit before they exited by themselves, so **no exit code was observed**. Windowed runs on the iGPU are still owed.
2. **Windows handheld model strings** (`models` on `handheld_1080`, and on `deck` for a Deck running Windows), each confirmed as a firmware product name by the Linux kernel's DMI tables or an upstream patch, sources in LEDGER section 9. Tested: `test_device_auto_pick` (full unit run at 63f2df68: 1959 passed, 0 failed; lint 15 / 15). A windowed boot with `SteamDeck=1` on the 1920x1080 screen logs "the desktop row" with the model read, exit 0, 0 SCRIPT ERROR (`evidence/n10h/it1/smoke/`).
3. **The Steam checks, as far as they go with no Steam app.** `Platform.hardware()` is the auto-pick's first check and `action_glyph_path()` is the glyph stub, each one call to fill in `steam_backend.gd`. Nothing has run against Steam.

## What does not work yet

- **The quest 1 freeze on a handheld row is unmeasured.** The rows set `vsync: enabled`, which perf's freeze fix did not cover (Windows handheld rows are the concern). The first 20-run hunt is inconclusive and is not a result: most low readings measured the console wrapper instead of the game. The harness is fixed; the enabled / mailbox A/B (`deck` vs the study row `deck_mailbox`) is owed.
- **ROG Ally (RC71L), Legion Go and MSI Claw do not pick their row**: no source read confirms their firmware product name, so they are left out.
- The GodotSteam method names in the comments of `steam_backend.gd` are unconfirmed (godotsteam.com refused the fetch).

## What blocked, and for how long

- The machine is heavily loaded (about 14 Godot processes across the lanes): ripgrep timed out, a 5-file unit run took 8 minutes.
- About 25 minutes lost to my own hunt script (two wrong paths, a probe of the wrong process). Those runs are void and not counted.

## Calls for the owner

1. **The auto-pick's Steam source** (no frame: an API change). Steamworks SDK 1.65 removed the Deck check the brief named. a) `IsRunningOnSteamHardware()`, built; b) `GetSteamHardwareDefaultConfig()`, which Valve's changelog offers for default settings, to be judged with a real SDK.

## Next steps

- The enabled / mailbox freeze A/B on the rows, then the windowed iGPU runs; merge `n10-world` when its walls land.
- The research loop and the port readiness table (LEDGER section 7).
