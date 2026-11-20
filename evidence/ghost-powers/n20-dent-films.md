# Dent (Ejected) film review

The five-second attack includes the jab, strap steering and overload. In both camera traces the jab lands at tick 94, the seize registers at 153, the car hits guards at 179 and 212, and the blast lands at 235. The blast begins 185 frames into the delivered film (3.08 s).

The media root is `C:/Users/kazda/kiro/gtai-masters/n20/dent/`. Its `frames.json` has 11 entries. Every file, poster and comparison path resolves.

## Films

The table records the ffprobe video dimensions, frame rate, duration and frame count. The four new films have H.264 High video, AAC audio from the tilted pass, and 960 × 540 JPEG posters taken from the finished MP4s. Each decoded through its last frame. The MP4 index precedes the media data in all four.

| Film and poster | ffprobe | Poster and three decoded frames inspected |
| --- | --- | --- |
| `dent_move_32.mp4`, `dent_move_32.jpg` | 1920×1080 · 60/1 · 5.000000 s · 300 | The poster shows the head turning ahead of the tail. At tick 110 Dent dives right. At 205 the tail curls up through a turn. At 337 he is upright again with a short trail. |
| `dent_attack_32.mp4`, `dent_attack_32.jpg` | 1920×1080 · 60/1 · 5.000000 s · 300 | The poster shows the strap attached to the roof inside the heat ring. At 94 the fist reaches the guard beside the parked car. At 192 the car has moved away with the strap taut. At 239 the bright blast centre and flying panels fill the ring. |
| `dent_close_64.mp4`, `dent_close_64.jpg` | 1920×1080 · 60/1 · 5.000000 s · 300 | The poster catches the teal contact flash. At 97 the arm is extended at the car, at 160 the webbing meets the roof buckle, and at 243 the expanding blast fills the right side. Dent's head, arms and tail root are visible in both views. The close-up uses the attack chapter throughout. |
| `dent_morph_32.mp4`, `dent_morph_32.jpg` | 1920×1080 · 60/1 · 6.666667 s · 400 | The poster catches Dent emerging through the teal ring. Tick 73 shows Rivet above the forming ring, 165 shows the spectral body in flight, and 295 shows Rivet returning. Both traces pass from base to Dent to base. The index uses the earlier movement film as the body reference because n19 has no morph take. |
| `dent_tether_strap_vs_strings_32.mp4`, `dent_tether_strap_vs_strings_32.jpg` (a4) | 1920×704 · 60/1 · 5.300000 s · 318 | The existing poster shows the thick strap beside the finer strings at tick 220. Frame 32 shows the jab in both arms of the comparison, 151 shows the tethers at range, and 194 shows the same blast in both. |

## Stills

| File relative to the media root | What to inspect |
| --- | --- |
| `dent_vs_plate.png` | Full concept plate at 1080 px high on the left. On the right, tilt and overhead show the same tick-110 dive at 64 px/m. |
| `dent_turn_64_t163.png` | The overhead view shows the head turning down and right while the tail still points left. |
| `scratch/a5/jab_over_car_t94.png` | Before and current tilt crops registered on the same car roof. The current fist has a teal contact flash against the guard. |
| `scratch/a5/overload_heat_t234.png` | Both views one tick before detonation. The amber strap reaches the roof inside the dashed heat ring. |
| `scratch/a5/overload_blast_t239.png` | Four ticks after detonation, with Dent and the entire outer ring visible in both views. |
| `scratch/a5/tail_0b_t110.png` | Earlier and merged tails at the same native scale in tilt and overhead. The brighter belt root fits within the torso and tapers to loose puffs. Dent retained his existing tail width. |

## Capture checks

Merged Flight through `ff370f539` in `1f03405db`. The five requested Dent test files passed all 23 tests, with zero failures or skips. All ten D3D12 film passes exited 0. The log scan returned `SCRIPT ERROR 0` and `SHADER ERROR 0` for each pass. Both preliminary still passes reported `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh`. Godot reported resources and allocator pages still in use at shutdown.

Captured with `tools/film/ghost_films.mjs` using spectral Dent, the default strap, move/attack/close/morph and still tick 163. The final cut uses the native tilt and top panels, retains all 1920 columns, and takes the audio and the first movie frame from the same trace position. The two views matched on simulation ticks, positions, facings and attack events throughout every cut. Capture logs and source panels are under `build/ghost-films/dent-spectral-FvF444/` in the Dent worktree.
