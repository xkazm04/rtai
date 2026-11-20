# REPORT lane polish (n21, 2026-11-20)

Lane `polish`, branch `n21-polish`, worktree `C:\Users\kazda\kiro\gtai-wt\n21-polish`. Director: Opus; builder: Astra
(every product change is Astra's, briefs under `evidence/briefs/`). Evidence root for this lane:
`masters:` = `C:\Users\kazda\kiro\gtai-masters`; stills and films under `masters:n21/polish/`, the morning list in
`masters:n21/polish/frames.json`.

## What works

| Item | Evidence | Number |
|---|---|---|
| 1. All-ghosts reel, limited-range encode | `e638d89ed`, `eaf5bb589`; `masters:n21/polish/all_ghosts_32.mp4` | 40.0 s, 1080p60, yuv420p tv range; film node tests 7/7 |
| 2a. Ohm hovers and drifts left in a drawn cell, staff in his own right hand, both tilts | `6f592bdb4`; `masters:n21/polish/ohm/ohm_left_{p70,p55}_{32,64}_{before,after}.png` | 32 hover cells within 1.00% of the shipped coat height; mutate `ohm_drawn.gd` 11/(11+1) = 91.7% |
| 2b. Ohm's top view carried by the jars and the fork | `c89fce348`, `ca9e9d5c3`; `masters:n21/polish/ohm/ohm_top_vs_plate.png`, `ohm_top_{idle,mid,press}_{32,64}_{before,after}.png` | jars x1.40; mutate `ohm_spirit.gd` 13/(13+5) = 72.2% (n20 4/9) |
| 3a. Tonnage's smoke column seated under the hump, edges feathered | `9c9d67255`; `masters:n21/polish/tonnage/tonnage_tail_{rest,turn}_64_{before,after}.png` | - |
| 3b. Tonnage's slam ring reads on the strike frame at 32 px/m | `7ffec84a4`; `masters:n21/polish/tonnage/tonnage_ring_strike_{32,64}_{before,after}.png` | 4 screen-px stroke |
| 4a. Dent's hit reaction: 12 deg lean + tail pulse in tilt 70, tilt 55 and top (before: no lean, top no reaction) | `1123a9881`; `masters:n21/polish/dent/dent_hit_{p70,p55,top}_{32,64}_{before,after}.png`, `dent_hit_{before,after}.mp4` | mutate 15/(15+5) = 75% |
| 4b. Dent's seized car teal in the top view as in the tilts | `e90609ff0`; `masters:n21/polish/dent/dent_car_top_{32,64}_{before,after}.png` | hood RGB (61,185,169) after; mutate 13/(13+7) = 65% |
| 5a. `ghost_flight.gd` mutants (shadow child, overhead scale) killed | `2eae86f02` | 12/(12+0) = 100% on those lines |
| 5b. `tonnage_spectral.gd` pinned | `9e77fb42e` | 19/(19+1) = 95% (n20 27.5%); `tonnage_pose.gd` 9/(9+0) |
| Films | `masters:n21/polish/{ohm,tonnage,dent}/<ghost>_{move_32,attack_32,close_64}.mp4` | 300/300/600 frames, 1080p60 |

| 5c. The speaking apparition washes ghosts that draw their own body (rigs list `GhostDrawn.voice_parts`; restored assert) | `5eba115fd`; `masters:n21/polish/shared/voice_wash_crops_4x.png`, `voice_wash_{tonnage,ohm,dent}_{before,after}.png` | phase 0.44 on every own part, cleared after; mutate `ghost_bridge_fade.gd` 11/(11+2) = 84.6% |
| 6. Cost of the spectral bodies, measured under `bench.lock` (36/36 runs, 4 paired rounds, A/A twin) | `733391b50`; `masters:n21/polish/cost/cost.md`, `cost.json` | p50 spectral - legacy: Tonnage +1.67 ms, Dent +2.21 ms, Ohm +2.23 ms (all beyond the A/A floor); CPU a wash |
| Kerf lane's NEED: a plain blink in Kerf's attack take | `25ffc58cd`; `project/tests/unit/test_ghost_review_input.gd` | presses [28, 77, 126, 200, 250], the 250 press dashes 4 m west with no guard in 9 m / 35 deg |

### The cost table (ghost_review movement take, tilt 70, 32 px/m, D3D12 1080p windowed, 300 frames per run)

| Ghost | Legacy p50 / p99 ms | Spectral p50 / p99 ms | p50 delta (CI95) | A/A floor | Call |
|---|---|---|---|---|---|
| Tonnage | 2.91 / 4.77 | 4.80 / 7.62 | +1.67 (1.43..3.17) | 0.29 | LOSS (p99 WASH) |
| Dent | 3.02 / 5.12 | 5.28 / 9.71 | +2.21 (1.48..3.68) | 1.24 | LOSS (p99 WASH, one stalled round) |
| Ohm | 3.06 / 5.14 | 5.45 / 8.35 | +2.23 (1.87..2.40) | 0.58 | LOSS (p99 +3.49 LOSS) |

Measured, not CONTENDED: every run held `bench.lock`; the machine was shared with lane kerf (2 to 8.5 other Godot
processes at launch, median), which the paired design and the A/A twin absorb. Where the cost is: process CPU is a
wash for all three, so it is the draw side. Every spectral ghost draws the ground shadow and light pool as 44 circles
per redraw; the tail wisps add 5 (Tonnage), 25 (Dent) and 35 (Ohm). Ohm, with the most wisps and four more drawing
nodes than his legacy rig, is the only one that also loses at p99. Per-component GPU time was not measured. In
absolute terms one spectral ghost costs about 2 ms a frame here, with no frame over 25 ms.

## What does not

- Ohm's strikes to the left still mirror (act sheet: 5 rows). 18 takes of the eight-facing act poses: recovery read
  idle, struck read drift, many cells +10..+20% tall (`masters:n21/polish/ohm/ohm_eight_vs_shipped_p70_64.png`). The
  switch is per sheet (`rows` in `ohm_spec_cells.json`), so a later drawn act sheet is one data change.
- In every take the model drew the away-left idle cell as the mirror of away-right (staff on the picture's left).
- Tonnage's HUD chip: the visor was inked (`beb12782b`) but at HUD 1x the face still reads faintly, and a sliver of a
  neighbouring cell shows at its right edge (`masters:n21/polish/tonnage/tonnage_chip_after.png`). The re-cut from a
  three-quarter cell (brief `evidence/briefs/03b-tonnage-chip.md`) was never sent: the cost and the voice hook ranked
  higher for the last code hour.
- The spectral bodies cost about 2 ms a frame more than the legacy ones (item 6). Nobody has tried to bring it down:
  the shadow and pool circles (44 per redraw) and Ohm's 35 wisps are the first places to look.
- The voice wash is faint on the new bodies (54 to 393 pixels change at 1280x800): it is the legacy wash's strength,
  which suited the old sprite. Not tuned.
- Kerf's spectral body has no voice parts yet (NEED kerf below); it keeps the old no-op.

## What blocked or slowed you

- Cost, first call (49 min): the cost tool waited for a machine with no other Godot process; lane kerf ran Godot all
  evening, so 0 runs. The law is one Godot per lane with the bench lock as the perf contract; the second call fixed
  the wait (15 s at most, then record the load) and measured in 22 minutes.
- Missed lane kerf's `NEED polish` (14:47) until 16:05: I read kerf's journal tail at the session start, not a grep
  for `NEED polish` (5 min lost restarting a call to fold it in).
- Ohm's act poses (34 min): 18 takes, recovery and struck never held their pose in eight facings.

## Calls for the owner

1. **Ohm's strikes to the left: keep the mirror?** Hover and drift to the left are drawn (staff in his own right hand);
   the five act rows still mirror, so during a 10 to 20 tick strike to the left the staff swaps hands. 18 drawn takes
   lost the recovery and struck poses (`masters:n21/polish/ohm/ohm_eight_vs_shipped_p70_64.png`, shipped beside drawn).
   I kept the mirror. A drawn act sheet that holds its poses is one data value (`rows` in `ohm_spec_cells.json`).
2. **About 2 ms a frame per spectral ghost (item 6 table).** Accept, or spend a run on it (bake the shadow and light
   pool to a texture instead of 44 circles per redraw; fewer wisps for Ohm). The default stays spectral.
3. **The voice wash on the new bodies is faint** (`masters:n21/polish/shared/voice_wash_crops_4x.png`, before | after
   at 4x). It is the legacy strength; stronger bands are one shader constant (`band_k`).

## Merge notes

- `project/boot/collect_call/view/stage_view.gd:216`: one call-site line (`DentCarTop.covers`) so the top view skips the plain car body while Dent's tinted one is drawn.
- `project/dev/ghost-powers/kerf_beat.gd` is back to its `int-n21` content (`aabe02126`); our edit of it in
  `1123a9881` is undone. `GhostReel.nearest` stays for our own `ohm_beat.gd` and `quest_ghost_rec.gd`.
- Kerf's attack take now has a plain blink at t=250 (`25ffc58cd`, kerf's NEED). It reaches Kerf's films only on the
  merged tree: re-film `kerf_attack_32` after the merge.
- NEED kerf: list Kerf's spectral body parts in `GhostDrawn.voice_parts` (as `dent_body.gd`, `ohm_rig.gd`,
  `tonnage_spectral.gd` do in `5eba115fd`) so the speaking apparition washes them. Until then Kerf keeps the old path.
- Shader include `project/features/souls/ghost_voice.gdshaderinc` is new; `ghost_fade.gdshader`, `ohm_jars.gdshader`,
  `dent_spectral_finish.gdshader` and `ghost_apparition.gdshader` include it (default `voice_phase` -1 = no change).
- Shared files touched: `docs/decisions.md` (appended lines), `steam/ai-provenance/2026-11.jsonl` (appended),
  `tools/film/ghost_films.mjs` (ours this run). No `kerf_*` file touched. No sim, replay, parity or bake digest moved.

## Next steps

- Bring the spectral cost down: shadow + light pool as one baked texture, then re-run `tools/perf/polish_ghost_cost.mjs`
  (it now runs on a shared machine under `bench.lock`).
- A drawn act sheet for Ohm's left strikes (poses as separate jobs per pose, not per pair, with the struck reference
  attached), then flip `rows` to 8.
- Re-cut Tonnage's HUD chip from a three-quarter cell (brief `evidence/briefs/03b-tonnage-chip.md` is ready).
- Kill the two `Voice.clear()` survivors in `ghost_bridge_fade.gd` (a second voice after the first must not keep
  stale parts).

## Astra ledger

| Call | Minutes | Verdict | Note |
|---|---|---|---|
| reel-encode | 27 | accepted | |
| ohm-eight | 34 | accepted (as review) | its "keep the mirror" verdict was right for the act poses, not for hover |
| ohm-hover8 | 22 | accepted | --resume |
| ohm-top | 26 | accepted | |
| tonnage | 57 | accepted (chip open) | |
| dent | 41 | accepted | also edited kerf's `kerf_beat.gd` (dedup); restored in the next call |
| cost | 49 | bounced (tool kept) | waited for a machine with no other Godot: 0 runs |
| kerfbeat-cost-voice | 1 + 47 | accepted | --resume; restarted once after 1 min to add kerf's NEED |

What I would brief differently: say "one Godot per lane, not per machine" in every perf brief; list forbidden files
(other lane's) by name from the first brief; put the NEED grep in my own session start, not just "read the journal".
