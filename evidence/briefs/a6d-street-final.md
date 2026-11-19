# Brief A6d - final street-fight films with the station spacing (lane ai, night n19)

## Why
`films/street-squad.mp4`, `films/street-guard.mp4` and the street stills (`stills/street-squad-t1905.png`,
`street-guard-t1905.png`, `street-squad-t0904.png`, `street-guard-t0904.png`, `street-close-t0876.png`) in
`C:/Users/kazda/kiro/gtai-masters/n19/ai/` were shot at `61bd372a4`, before `27fde67fa`/`01781501f`
(`city.station_spacing_m` 1.65: the five station riot cops keep apart). Both brains' street fights now show the
cops differently, so all street files are stale. Pit files are unchanged (pit digests equal): keep them.

## Environment
`export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/ai` before every Godot run;
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`;
`--rendering-driver d3d12`, `--position 0,1440` (never the main display). One Godot process at a time.
Same tools, seed, camera, length and commands as your A6c commit `f4b08fa71` (`evidence/n19-ai/overlay.md`).

## Do
1. Re-shoot `films/street-squad.mp4` and `films/street-guard.mp4` (32 px/m, 24 s, same seed and camera,
   explicit `--enemy-brain=squad|guard`) at the HEAD you start from; name it in the note.
2. Re-shoot the four street twin stills at the same ticks (1905, 904) and the 64 px/m close-up (876), or new
   ticks from the probe trace if the old ones no longer show COVER/FLANK (state counts in the note).
3. LOOK at every new still: labels on bodies, five station cops apart, no body in a wall. Re-shoot bad ones.
4. Update `frames.json` notes (8 to 15 entries, best first), copy to `evidence/n19-ai/frames.json`; add the
   station pair: `station/after-t0697.png` with `before: station/before-t0697.png` (already shot, A10).
   Delete scratch renders frames.json does not reference (never delete `zebra/`, `prop-lying/`, `station/`).
5. Commit `evidence/n19-ai/**` only: `ai: final street-fight films with station spacing`. No product changes.

## Files you may write
`evidence/n19-ai/**`, `C:/Users/kazda/kiro/gtai-masters/n19/ai/**`. Staged per path; never -A/./-u; no stash.
Do not touch `JOURNAL.md`, `REPORT.md` or `evidence/briefs/`. ASCII only.

## Report
Clip paths and lengths, frames.json entries (title, tick, state counts), what you looked at and threw away.
Time box: 25 minutes; HARD STOP 07:20 whatever the start time (freeze 07:30).
