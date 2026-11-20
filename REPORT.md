# n20 lane dent: Dent becomes Ejected (REPORT, final)

Branch `n20-dent` (worktree `C:\Users\kazda\kiro\gtai-wt\n20-dent`), cut from `int-n20` `a3eb0bf78`;
merges `n20-flight` only. Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\dent_a.png` (+ `dent_c.png`
borrow). Evidence root: `C:/Users/kazda/kiro/gtai-masters/n20/dent/` (`M/` below); `M/frames.json` lists 13 stills and films, best first.
Final gate: `node tools/gate/run.mjs --rev=86fad2566` (05:36-05:48) -> `gate: PASS; build/gate/86fad25665c4/gate.json`
(lint, unit-tests, scenario-tests 65 passed, parity 1200 exact + planted mutation caught at 629, selftest look goldens
11/11, export-audit 791 loaded 0 failed; full log `evidence/gate-final.out.txt`). Commits after it are docs only (inert).

**Dent now defaults to the spectral Ejected look** (`6d9b5e7a6`); the old body is reachable with `--ghost-look=legacy`.

## What works (item, evidence, number)
- **Body art, legless, both tilts + top** (a1, 5 sheets, take 1 each; top parts take 1 of 3):
  `894b68522` p70 fly, `078d1fa86` p70 act, `3d04f4f8f` p55 fly, `f04ee8a91` p55 act, `a16c37277`
  top parts. Heads 90 px (p70) / 77 px (p55). Keyed on magenta, not green (DECISION 00:30: his teal
  glow fringe is close to the green key).
- **Flight** (a2): `e71f6d647` tilt drawer (HOVER / DIVE / SWING / HIT), `9b130ccac` top rig, `1a2d61a97`
  belt anchor + glass in the comet tail, `1a3f69a45` tail row (torso-wide root, two body lengths).
  Top view now gives a direction (crown disc ahead, shoulder discs, arms trailing, tail behind).
  Stills: `M/scratch/a2/`, `M/scratch/a3/top-64ppm-move-dive-tick110-after.png`.
- **Jab** (a3, a3b): `de8e58cc9` jab and its victim drawn above the seized car for the strike window,
  `c654f6924` six-tick contact mark on the knuckles. Still `M/scratch/a3/a3b-jab-64ppm-ticks94-97.jpg`.
- **Seatbelt strap** (default `tether_look`): `ee665df55` DentLook table + `--dent-tether`,
  `4b9b30257` strap, `49dd0b1d7` 0.48 m belt + 0.58 m buckle, `87b14779d` weave travel.
  Still `M/scratch/a3/a3b-belt-32-and-64ppm-tick160.jpg` (reads at 32 and 64, tilt and top).
- **Overload as one attack**: `a7cd4d0ef` amber ring at the 4.5 m reach + heat wash + spokes,
  `9e0aa327b` ring kept through the blast, shock disc fills it from the car by +8 ticks.
  Still `M/scratch/a3/a3b-blast-32ppm-ticks235-239-243.jpg`.
- **Legacy untouched**: `f7f8884e8` (facing/tether/blast spectral-only); legacy PNGs at ticks 160
  and 200 byte-identical to `9e8bc0619`.
- Sim: replay `cbeb734ff9b97c41` unchanged, parity 1200 steps exact (a3, a3b).
- **Strings look** (`--dent-tether=strings` or `tether_look` in `project/data/tables/dent_look.json`):
  `cd85c4d85` four strings from the hands to the four roof corners (inside pair taut, outside pair
  sags, tremble on strikes), `8a08f80c9` anchored through release, `526781c9e` both pairs on the
  palms of the STEER TWO HANDS cell. Mutate `dent_strings.gd` 16/20 (80 %). Legacy PNGs t160/t200
  byte-identical. Side-by-side film (same seed 20261103, ticks 68..367):
  `M/dent_tether_strap_vs_strings_32.mp4` + `M/scratch/a4/dent_tether_strap_vs_strings_64.mp4`,
  numbers in `M/scratch/a4/strings_eval.json`.
- **Films for the owner** (a5, `--ghost-look=spectral`, tilt 70 above, top below, 1920x1080, 60 fps,
  poster each): `M/dent_move_32.mp4` (5.000 s: dive, rag-doll swing on the turns, hover),
  `M/dent_attack_32.mp4` (5.000 s: jab t94, strap seize t153, two car hits, overload blast t235),
  `M/dent_close_64.mp4` (5.000 s), `M/dent_morph_32.mp4` (6.667 s, flight's real transformation stages:
  Rivet -> teal ring -> Dent and back, no legs at any frame). `M/dent_vs_plate.png` (tick 110 dive,
  64 px/m) is the first entry of `M/frames.json` (13 entries). Report: `evidence/ghost-powers/n20-dent-films.md`.
- **Overload reads as one attack** in both views: `M/scratch/a5/overload_heat_t234.png` (amber strap,
  dashed 4.5 m ring on the road around the car) and `M/scratch/a5/overload_blast_t239.png` (the blast
  fills that ring from the car, a spoke to the struck guard).
- **Second play tilt (55 degrees)**: `M/scratch/a6/tilt55_sheet.jpg` (64 px/m: dive t110, turn t163, jab t94,
  strap t160, heat t234, blast t239): legless p55 cells, strap and ring correct.
- **HUD chip**: `42dcad19f` `dent_spectral.png` cut from the p55 front hover cell (no new drawing),
  still `M/scratch/a6/chip.png`.
- **Overload tests**: `854d276fe`, `007c4cccd`; mutate `dent_overload.gd` 13/20 (was 4/20).
- **Default look**: `961862cb9` (null guards in flight's host test: a ghost drawing its own body has no
  shared sprite or legacy rig), `6d9b5e7a6` Dent's row `look: spectral`. `--changed` 3252 pass 0 fail
  2 skip; quest1_dent, quest1_dent_lock, replay_60s pass; replay `cbeb734ff9b97c41` unchanged.
- Mutate scores: `dent_spectral_drawn` 14/20, `dent_strap` 16/20, `dent_strings` 16/20, `dent_overload` 13/20.

## What does not
- Hit reaction (HIT cell + tail flicker) not checked tonight; the transformation is flight's shared
  stages (filmed: `M/dent_morph_32.mp4`, no legs), not Dent's own roundel-by-roundel ignition.
- Left facings are mirrors (the belt diagonal flips); not judged at 64 px/m.
- The seized car is tinted teal in the tilt views but drawn untinted (cream) in the top view (vehicle
  top sprite, not Dent's file); the generic white hit star at blast +0 is loud (shared).
- Strings: 1 px core; at 32 px/m his two hands sit about 0.3 m apart.
- The flight aura opt-out (`fa2b4dac7`) is not merged here: Dent's spectral body still draws the
  shared aura's ground rings beside flight's light pool (see Merge notes).

## What blocked or slowed you (minutes each)
- a2 cut off with the iteration-1 director session (background Bash dies with the session): ~10 min
  lost, mutate re-run in a3. Since then long calls are launched detached (WMI).
- `git merge n20-flight` brings flight's root `JOURNAL.md` into this branch (see Merge notes).

## Calls for the owner
1. **Strap or strings** for seize-and-steer (your question: can we practically drive the car the
   Puppeteer way?). Film: `M/dent_tether_strap_vs_strings_32.mp4` (strap left, strings right, same
   seed and ticks, tilt 70 above, top below) and the 64 px/m one in `M/scratch/a4/`. Answer:
   - **It is practical.** Four strings read at 32 px/m at 5 m and at 20 m, in the tilt and the top
     view (1 px core + ink, 1.6-1.8 px effective at 20 m); the inside hand pulls back and its roof
     corners dip on a turn. The car itself stays level (no two-wheel tip like the plate).
   - **Clutter:** frames where the tether ink covers a living guard, over the 94 tethered frames:
     strap 0 (tilt) / 0 (top), strings 2 / 4. But at 20 m the 0.48 m strap covers a guard it passes
     over in tilt, while the strings let bodies show through.
   - **Cost** (CONTENDED, `_draw` while tethered, mean): tilt 439 vs 749 us, top 436 vs 829 us
     (strings about 1.8x the strap).
   - **Weakness:** at 32 px/m his two hands sit about 0.3 m apart, so the four strings almost leave
     from one point; the marionette reads fully only at 64 px/m.
   - **Recommendation: keep the strap as the default** (it is the winning plate, reads at a glance at
     any range, and costs less). Strings stay one data value away; worth a second pass (hands wider
     apart, 2 px core, the car tipping on the turn) only if you want the marionette.
2. Keying on magenta instead of chroma green for Dent's sheets (DECISION 00:30).
3. Left facings mirrored (belt diagonal flips): not judged tonight; new left-facing cells would be one more sheet each.
4. Dent's `ghost_forms.json` row is now `spectral` by default (DECISION 05:17; tilt 70 + top filmed, 55
   checked in stills, gate on the final commit). If you prefer the old body until the hit reaction and
   his own transformation land, it is one value back to `legacy`.

## Merge notes
- Root `JOURNAL.md`: flight's committed journal arrived through `git merge n20-flight` (8dc2b5b37);
  this branch's `JOURNAL.md` is Dent's. Keep each lane's journal separately at the morning merge.
- `project/boot/launch_args.gd`: at its debt cap; a3 joined the 2-line header comment into 1 to
  append `--dent-tether`. Other lanes appending a flag will trim the header differently: take one
  header line + every flag.

- `n20-flight` fa2b4dac7 (shared aura yields its ground glow to GhostFlight) landed after Dent's last
  merge: after merging both, add the one line `_aura.form_id = &"dent"` in
  `project/features/souls/dent_body.gd` (flight's request) so Dent's spectral body draws one ground light.
- `project/tests/unit/test_ghost_flight_hosts.gd` (flight's): Dent added a null-sprite guard at line
  114 (a ghost with `own_body` has no shared sprite). Flight accepted it: take n20-dent's version. The merge preview also flags n20-tonnage touching the same
  test: keep both lanes' guards.

## Next steps
- Merge `n20-flight` again and set `_aura.form_id = &"dent"` (one line).
- Hit reaction (HIT cell + tail flicker) in both tilts and top; Dent's own transformation detail.
- Strings second pass only if the owner wants the marionette: hands wider apart, 2 px core, the car tipping on the turn.

## Astra ledger
| tag | minutes | verdict | notes |
|---|---|---|---|
| a1-body-art | 31 | accepted | 5 sheets, take 1 each |
| a2-wiring | 55 | accepted (cut off with the director session) | tilt drawer, top rig, glass |
| a3-attacks | 64 | accepted | DentLook, strap, overload ring, tail row, jab order |
| a3b-followup | 46 | accepted | legacy restore, shock fill, 0.48 m strap, jab mark, strap tests |
| a4-strings | 65 | accepted | strings, two-hand cell, side-by-side film + eval tools; full scenario run cut at 52/65 |
| a4b-strings-hands | 0 | skipped | its main item landed in a4 (`526781c9e`) |
| a5-films | 9 | accepted | four films + posters, plate still, frames.json; flight's film tool made it fast |
| a6-chip-tests | 21 | accepted | chip, overload tests 13/20 |
| a6b-tilt55-default | 9 | accepted (flip held back) | 55 stills; found the red host test |
| a6c / a6d | 1 + 1 | bounced | stopped at each new null / lint line instead of fixing its own edit |
| a6e-fit-and-flip | 5 | accepted | test guard + the flip |

What I would brief differently: say up front "fix lint and format findings in your own edit and go on";
the stop-on-anything wording cost two round trips (a6c, a6d). And run the whole unit suite after every
`git merge n20-flight`, not only the selected Dent tests: the red host test came in at 04:47 and was
found at 05:26.
