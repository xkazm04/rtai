# n9 rivet JOURNAL (branch n9-rivet, evidence C:\Users\kazda\kiro\gtai-masters\n9\rivet\)

## it3 (00:54-01:54) - the first iteration that ran (it1 and it2 exited in 5-7 s on billing)

Read: d9 rivet REPORT (`docs/day/2026-11-07/rivet/REPORT.md`), AGENTS.md, the tail of docs/decisions.md,
`git log` (main = d9 merged, branch clean), the asset lane's JOURNAL tail and deliveries
(`rivet_walk8_it112.md`, `rivet_walk_armed_it99.md`). No other n9 lane had a JOURNAL at 01:00.

Registry rules applied (motion-quality-gating, sprite-and-atlas-production, depth-ordered-layered-art,
realtime-combat-semantics; read from memory of the d9 runs, not re-opened this session: FRICTION, time):
- motion: foot-lock acceptance = a planted foot stays put against the ground texture over its contact
  frames; stride-to-speed: cadence x stride length = ground speed, measured, never eyeballed.
- atlas: one scale per grid (no size pulse across a stride), a common foot line, premultiplied resampling.
- layered art: the size change is view only; depth sort stays the rig's ground point.
- combat semantics: the shot origin and the hit box are the sim's; the drawn muzzle is view only and is
  stored in cell px, so it scales with the card (checked by code: RivetMuzzle maps cell px through
  card.offset and the card's transform; the smear root and length use the card's scale too).

- MILESTONE `c0b0bea0` **the new size**: `RivetFrames.HEIGHT_M` 1.1 -> 1.65, p55 1.3 -> 1.95 (in proportion).
  `--rivet-height=<m>` still the flag (clamp 0.8-2.5). Everything that reads his height reads it from
  place(): the card scale (muzzle, smear, fire latch unchanged), the cast shadow / occlusion hip
  (`RigCastShadows.CAST_HIP` = h x ...), the roll ball (ROLL_SHADOW x h). The sim body is untouched.
  Under `top` there is no strip (strip_of returns ""), so the top look goldens cannot move.
- MILESTONE `dbef2e17` **the flamer**: `RivetStrips.cone` empty (the owner's r-7 B, the drawn flame in
  every direction); `--rivet-flame=cone` brings back d9's `CONE_D9`. Film of a diagonal burst: owed.
- MILESTONE `b06c962f` **the 8-frame walk**: the library's walk8 OFFER (all rows A at both pitches; 70
  left = the tone-matched copy) packed by `tools/art/rivet_walk.py --cols=8` into
  `art/view/<p70|p55>/rivet_walk8.png` (contacts `evidence/n9/rivet_walk8_{70,55}_contact_x2.png`).
  The phase now steps by the ground walked (`RivetWalk.phase_of`, the King's-boots method), not by
  the gait phase. `--rivet-walk=4` = d9's 4-frame grid by the gait phase, `--rivet-walk=bob` the card.
  Provenance: 2 lines in `steam/ai-provenance/2026-11.jsonl` (16 source sheets, rounds + prompt_hash).

### Why he glides (measured, it3)
- His walk is **6.75 m/s** (`combat.json` rivet walk_mps; the 2026-11-04 1.5x baseline). That is a
  runner's speed. At 32 px/m = 216 screen px/s.
- The drawn walk8 profile rows: the stance foot travels ~30 cell px from contact to the next contact,
  so one drawn cycle (two steps) = ~60 cell px (`CYCLE_CELL`; p70 and p55 alike) = 0.55 x the figure's
  110 px height. At 1.65 m that is **0.9 m per cycle** (28.8 px at 32 px/m).
- To plant at 6.75 m/s that cycle needs **7.5 cycles/s = 60 drawn frames/s at 8 frames**: unreadable.
  d9's 4-frame grid ran by the gait phase (rig stride ~88 px at that speed: ~2.5 cycles/s, 10 fps), so the
  feet covered ~1/3 of the ground: the glide.
- Built: the distance-tied phase with the measured cycle, the cadence held at `MAX_CYCLES_S` 2.0
  (16 drawn fps). So he plants while he accelerates (0.28 s to top speed at 24 m/s^2), slows, and at
  any speed under ~1.8 m/s; at his full 6.75 m/s the feet still cover 27 % of the ground.
- **No drawn walk can plant at a run's speed.** The fix is a drawn RUN cycle (a stride ~3x the walk's,
  with flight frames where no foot is on the ground): REQUEST below. The alternative (a slower walk) is
  a sim change and not mine: a Call for the owner.

REQUEST to assets: rivet_run8_70, rivet_run8_55, pitch 70 and 55, Rivet's 8-frame RUN cycle (bare
claw), because his on-foot speed is 6.75 m/s (a run) and the walk8 cycle covers only 0.9 m per stride at
his new 1.65 m: the feet cannot plant (measured above). Layout = the walk8 house layout (rows toward,
3/4 toward right, right profile, 3/4 away right, away; + the 3 drawn LEFT rows, never mirrored; tight
`r_c.png` cells, copied by example from `keyed/rivet/rivet_walk8_<p>_cells`, same helmet, claw and scale).
Columns: 1 CONTACT (front heel down, legs spread ~0.6 x the standing height in the profile), 2 DOWN
(loaded, knee bent, the body lowest), 3 PUSH-OFF (the stance foot BEHIND the hip, toe on the ground,
~0.45 x height behind where it landed in col 1), 4 FLIGHT (both feet off the ground ~0.05 x height, the
free knee forward), 5-8 the same with the other foot. Body leaning forward ~10 deg in the profile rows,
arms (claw + the plated arm) swinging opposite to the legs. The key measurement: in the profile rows,
the stance foot's x must travel backwards ~0.45-0.5 x the standing height from col 1 to col 3 (and 5 to 7);
I wire the cycle length from that measure. 70 first.

Item 4 note: the armed walks (it99 OFFER, `rivet_walk_armed_{onehand,twohand,blade,heavy,flamer}`) are
drawn with ONE weapon each (the pistol, the plasma rifle, ...). Taking them for the whole family would put
a pistol in his claw while he holds the ray gun. Plan: wire them per weapon for the weapon they draw
(pistol, plasma rifle, katana, flamer), keep the facing card for the rest, and ask per weapon later.

NEXT (it4):
1. Film the size: before (`--rivet-height=1.1`) / after at 32 px/m tilt70 beside a cop, a ped, a car;
   King and Servo in combo at 48 px/m; check the ghost swap back, the roll ball, the death sprawl length.
2. Film the flamer diagonal burst (64 px/m), check one coherent flame with the game jet.
3. Film the walk8 at 64 px/m in quest 1 frame by frame (accelerating steps = planted; top speed = the cap).
4. Wire the armed walks per weapon (item 4); gates (unit full, lint, reel x3, evidence --no-bench).
