# n31 ghost 31: where Tonnage drops, aim point (shipped) | on Rivet, in gauntlet play

Builder `g31-drop-at`, 2026-11-26. Evidence only, no product change. This is a clip for REPORT's first owner call, "Tonnage
drops at the aim point (shipped) or on Rivet".

## Recipe

- Temp worktree `gtai-wt/g31-rivet` at `673bd263e`, detached, with this worktree's git-ignored runtime copied (`project/.godot`,
  `project/data/generated/city`, `project/native/bin`). 1920x1080 is set only in that worktree's own `project.godot`.
- One value changed only in that temp worktree, never committed: `ghost_attacks.json` `deploy.tonnage.drop_at` `"aim"` -> `"rivet"`.
- Scene and flags are exactly the `take-drop.md` recipe: `res://dev/ghost_n31/ghost_n31_take.tscn`, seed 3,
  `--bot=average --pick=greedy --controls=wheel --waves=3 --pick-view`.
- Render: 1920x1080, `--fixed-fps 60 --write-movie`, d3d12, windowed at 0,1440, 3800 frames, through `runGodot` under the
  lane lock (`build/n31/g31lock.sh`). Scratch is in `build/n31/g31/` (git-ignored).
- Headless runs of the same scene give the same deploy ticks as the movie:
  - rivet, all 3 waves;
  - aim restored in the temp worktree, at `673bd263e`: press 238 / 856 / 1337 / 1818 and hits 4 / 3 / 8 / 9. These are exactly
    the shipped clip's numbers, so the left side is still the existing `extra/take-drop-head-32ppm.mp4` (`5d0f98ccd`).

The two runs share the seed and split at the first Tonnage. On rivet the bot holds its first press until tick 1262
(aim: 238). It waits that long because its drop spot is Rivet himself, and it does not press until enough cops are near him.
So "deploy 2" is wave 1 on the aim side and wave 2 on the rivet side.

## Per deploy (press / dump tick, hits / kills, foes within 9 m)

| deploy | aim (shipped) | rivet |
|---|---|---|
| 1 | wave 1, 238 / 265, 4 / 4 (4) | wave 1, 1262 / 1289, 3 / 3 (5) |
| 2 | wave 1, 856 / 883, 3 / 3 (4) | wave 2, 1954 / 1981, 2 / 2 (5) |
| 3 | wave 2, 1337 / 1364, 8 / 8 (10) | wave 3, 2707 / 2734, 3 / 3 (4) |
| 4 | wave 3, 1818 / 1845, 9 / 9 (12) | - |
| whole 3-wave run | 4 deploys, 24 / 24, waves done at tick 2189 | 3 deploys, 8 / 8, waves done at tick 3586 |

Movie frames of the rivet dumps: 1331, 2201 and 3118.

## Clip

Each side starts 150 frames before its own deploy 2 dump and runs 1662 frames:

- aim: frames 765-2426 of the shipped take. Dumps at clip 2.5 s (wave 1), 13.1 s (wave 2) and 23.4 s (wave 3).
- rivet: movie frames 2051-3712. Dumps at clip 2.5 s (wave 2) and 17.8 s (wave 3). Its wave 1 deploy comes before the clip.

## Files

Files are in `C:\Users\kazda\kiro\gtai-masters\n31\ghost\`; lengths are from ffprobe.

- `take-drop-aim-vs-rivet-32ppm.mp4`: 3840x1080, 1662 frames, 27.70 s, no audio, labelled "drop_at aim (shipped)" |
  "drop_at rivet".
- `take-drop-aim-vs-rivet-dump.png`: the wave 2 dump still pair. aim is t1364 (shipped clip frame 783); rivet is t1981
  (movie frame 2201).
- `frames.json`: entry 12 of 16, right after the Kerf take. Its `before` is `extra/take-drop-head-32ppm.mp4`.
- Rivet-only clip, movies, deploy JSON and dump frames: `build/n31/g31/`.

## Read from the dump frames (32 px/m)

**Wave 1**
- aim (t883): Rivet is at the ring's upper-left edge and Tonnage is about 3 m to his right, on the cops. 3 go down inside
  the dust ring.
- rivet (t1289, 17.5 s into the wave): Tonnage's body covers Rivet in the middle of the road. 3 go down at the ring edge,
  among bodies Rivet's claw had already dropped.

**Wave 2**
- aim (t1364): Tonnage is in the pack about 4-5 m right of Rivet, on the plaza island. 8 go down around him.
- rivet (t1981): Tonnage lands on Rivet at the island's top edge. About 7 cops stand 2-6 m to the lower right, mostly
  outside the ring and still shooting, and 2 go down. Ten frames earlier (movie frame 2191, about t1971), the cracks run out from under Rivet and
  the pack is untouched.

**Wave 3**
- aim (t1845): the ring is centred on the pack, with Rivet at its left edge. 9 go down.
- rivet (t2734): Tonnage is on Rivet at the left. About 9 cops are bunched 3-8 m to his right, most of them outside the
  ring, and 3 go down (the ones pressed against Rivet).

## What a player would see

With drop_at rivet, the robot crashes down on Rivet himself and flattens only the two or three cops already touching him,
while the pack a few metres off keeps shooting. The shipped aim drop lands in the middle of the crowd, and 8-9 go down in
one dust ring.
