# n20 lane dent: Dent becomes Ejected (REPORT, draft from 03:50; final at 07:40)

Branch `n20-dent` (worktree `C:\Users\kazda\kiro\gtai-wt\n20-dent`), cut from `int-n20` `a3eb0bf78`;
merges `n20-flight` only. Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\dent_a.png` (+ `dent_c.png`
borrow). Evidence root: `C:\Users\kazda\kiro\gtai-masters\n20\dent\` (`frames.json` best first).
Final gate: TODO `node tools/gate/run.mjs --rev=HEAD` line + `gate.json` path.

## What works (item, evidence, number)
- **Body art, legless, both tilts + top** (a1, 5 sheets, take 1 each; top parts take 1 of 3):
  `894b68522` p70 fly, `078d1fa86` p70 act, `3d04f4f8f` p55 fly, `f04ee8a91` p55 act, `a16c37277`
  top parts. Heads 90 px (p70) / 77 px (p55). Keyed on magenta, not green (DECISION 00:30: his teal
  glow fringe is close to the green key).
- **Flight** (a2): `e71f6d647` tilt drawer (HOVER / DIVE / SWING / HIT), `9b130ccac` top rig, `1a2d61a97`
  belt anchor + glass in the comet tail, `1a3f69a45` tail row (torso-wide root, two body lengths).
  Top view now gives a direction (crown disc ahead, shoulder discs, arms trailing, tail behind).
  Stills: `scratch/a2/`, `scratch/a3/top-64ppm-move-dive-tick110-after.png`.
- **Jab** (a3, a3b): `de8e58cc9` jab and its victim drawn above the seized car for the strike window,
  `c654f6924` six-tick contact mark on the knuckles. Still `scratch/a3/a3b-jab-64ppm-ticks94-97.jpg`.
- **Seatbelt strap** (default `tether_look`): `ee665df55` DentLook table + `--dent-tether`,
  `4b9b30257` strap, `49dd0b1d7` 0.48 m belt + 0.58 m buckle, `87b14779d` weave travel.
  Still `scratch/a3/a3b-belt-32-and-64ppm-tick160.jpg` (reads at 32 and 64, tilt and top).
- **Overload as one attack**: `a7cd4d0ef` amber ring at the 4.5 m reach + heat wash + spokes,
  `9e0aa327b` ring kept through the blast, shock disc fills it from the car by +8 ticks.
  Still `scratch/a3/a3b-blast-32ppm-ticks235-239-243.jpg`.
- **Legacy untouched**: `f7f8884e8` (facing/tether/blast spectral-only); legacy PNGs at ticks 160
  and 200 byte-identical to `9e8bc0619`.
- Sim: replay `cbeb734ff9b97c41` unchanged, parity 1200 steps exact (a3, a3b).
- **Strings look** (`--dent-tether=strings` or `tether_look` in `project/data/tables/dent_look.json`):
  `cd85c4d85` four strings from the hands to the four roof corners (inside pair taut, outside pair
  sags, tremble on strikes), `8a08f80c9` anchored through release, `526781c9e` both pairs on the
  palms of the STEER TWO HANDS cell. Mutate `dent_strings.gd` 16/20 (80 %). Legacy PNGs t160/t200
  byte-identical. Side-by-side film (same seed 20261103, ticks 68..367):
  `dent_tether_strap_vs_strings_32.mp4` + `scratch/a4/dent_tether_strap_vs_strings_64.mp4`,
  numbers in `scratch/a4/strings_eval.json`.
- **Films for the owner** (a5, `--ghost-look=spectral`, tilt 70 above, top below, 1920x1080, 60 fps,
  poster each): `dent_move_32.mp4` (5.000 s: dive, rag-doll swing on the turns, hover),
  `dent_attack_32.mp4` (5.000 s: jab t94, strap seize t153, two car hits, overload blast t235),
  `dent_close_64.mp4` (5.000 s), `dent_morph_32.mp4` (6.667 s, flight's real transformation stages:
  Rivet -> teal ring -> Dent and back, no legs at any frame). `dent_vs_plate.png` (tick 110 dive,
  64 px/m) is the first entry of `frames.json` (11 entries). Report: `evidence/ghost-powers/n20-dent-films.md`.
- **Overload reads as one attack** in both views: `scratch/a5/overload_heat_t234.png` (amber strap,
  dashed 4.5 m ring on the road around the car) and `scratch/a5/overload_blast_t239.png` (the blast
  fills that ring from the car, a spoke to the struck guard).
- TODO chip / overload tests (a6).

## What does not
- TODO. Known: overload mutate 4/20 at a3b (a6 item 4); the generic white hit star at blast +0
  still dominates (shared, not Dent's); left facings are mirrors (belt diagonal flips).

## What blocked or slowed you (minutes each)
- a2 cut off with the iteration-1 director session (background Bash dies with the session): ~10 min
  lost, mutate re-run in a3. Since then long calls are launched detached (WMI).
- `git merge n20-flight` brings flight's root `JOURNAL.md` into this branch (see Merge notes).

## Calls for the owner
1. **Strap or strings** for seize-and-steer (your question: can we practically drive the car the
   Puppeteer way?). Film: `dent_tether_strap_vs_strings_32.mp4` (strap left, strings right, same
   seed and ticks, tilt 70 above, top below) and the 64 px/m one in `scratch/a4/`. Answer:
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
3. Left facings mirrored (belt diagonal flips): TODO still.
4. Dent's `ghost_forms.json` row: TODO stays legacy-default unless body+flight+all attacks are filmed
   in both tilts and gate-green.

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
  114 (a ghost with `own_body` has no shared sprite). Flight accepted it: take n20-dent's version.

## Next steps
- TODO

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
