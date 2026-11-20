# n20 flight, package 2: make hover, tail and shadow real (on the legacy bodies)

You committed the Spectral look interface in package 1 (`GhostLook`, `ghost_hover.json`, `GhostHover`,
`GhostTail`, `GhostShadow`, `GhostFlight`, `GhostDrawn.hover`). **Names and signatures stay as committed**
(four other lanes code against them now). You may ADD fields to `ghost_hover.json` rows (schema too) and
add methods; never rename or remove one.

Same law as package 1: visual only, no sim/replay/parity/bake digest moves, `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/flight`,
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`, `--rendering-driver d3d12`
for anything that renders, windowed runs `--position 0,1440`, one Godot at a time, never kill by name, stage
per path, no stash / add -A / reset --hard / commit -a, never push. Same file list as package 1 (flight owns
`project/features/souls/ghost_*`, `soul_*`, `power_*`, the README, `ghost_hover.json`, the dev review driver,
new art under `project/features/souls/art/shared/`); never edit `tonnage_*`, `hauler_*`, `ram_*`, `kerf_*`,
`ohm_*`, `dent_*`, `gearbox_link.gd`, `slam_debris.gd`, `plate_sparks.gd`.

## The target: look at these before you start, and again when you judge a frame
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\tonnage_b.png`, `dent_a.png`, `kerf_a.png`, `ohm_c.png`
(the owner's winners). What they share and what you build:
- **Tail**: ragged teal vapour that streams from the body's lower end and thins to nothing; brighter, denser
  and almost white-teal at the root, darker teal toward the ragged edges, several flame tongues, small wisps
  that peel off the edges and drift and fade. Not a plain gradient, not a smooth cone. Per plate:
  - dent_a: one long comet tongue from the belt, tapering to a point, slight S-wiggle (strands 1, long).
  - kerf_a: no fat tail: thin vapour wisps streaming straight back along the hull, plus (kerf lane's job, not
    yours) beam streamers. Short, thin, many fine strands (strands 3, narrow, high stretch).
  - ohm_c: a tattered robe hem: 4 to 5 hanging tatters of vapour, slow sway, wisps rising at the sides.
  - tonnage_b: a thick twisting smoke column from the chest/back that curls UP and back (rise), heavy, slow.
  Add row fields to express this (suggested: `tail.strands`, `tail.spread_m`, `tail.rise_m`, `tail.wisps`,
  `tail.flow_ticks` (vapour scroll period)); keep the existing ones.
- **Ground**: under every plate's ghost the wet street glows teal (soul light on the ground), with a darker
  core directly below. `GhostShadow` draws both: a soft dark core ellipse and a wider, faint teal light pool;
  higher = core smaller and fainter, pool wider and fainter; it breathes with the bob. On the ground plane
  (squashed by `ground_k()` in tilt views), never lifted. Add row fields `shadow.pool_m`, `shadow.pool_alpha`.
- **Hover/bank/lag**: weight and speed without feet. Heavy Tonnage sinks a little on a stop and lifts on a
  start (overshoot), slow bob, small bank, the body lags; Kerf is level and dart-like, banks hard, almost no
  lag, no visible bob at speed; Dent leans forward into a dive at speed (superhero dive), twitchy; Ohm drifts,
  sways, big slow bob. Put any new tunables in the rows.

## FIRST, before anything else (one small commit; lanes wait on it)
tonnage (01:3x) draws its own spectral body (TonnageSpectral, its own sheet names) and needs GhostDrawn never
to draw a second one: add `var own_body: bool = false` to GhostDrawn; when true, GhostDrawn shows no sprite at
all (no legacy cell, no spec sheet; the rig parts' visibility is left to the rig) while still accepting
feed()/step() calls without error, and the flight mount keeps working. Default false keeps today's behaviour
(missing spec sheets fall back to the legacy cell holding its standing column; Kerf relies on that). Unit
test both. Document in README "Spectral look". Commit: `Let a form draw its own spectral body (GhostDrawn.own_body)`.
Dent draws its own cells too (dent_sp_fly / dent_sp_act); it hides GhostDrawn's sprite itself today but may use
`own_body` as well.

## Lane feedback to honour
- dent (01:13): the shared tail drawn today is "a thin faint wisp offset below the plume, not the plate's broad
  bright tongue": the root must be able to be as wide as the torso at the belt, taper over about two body
  lengths, brightest at the root, and sit ON the anchor (no offset below it). Check the tail root position in
  the tilt views against the body's anchor.
- Rows: each ghost lane now owns and tunes its own row in `ghost_hover.json` (dent and kerf already have):
  do NOT overwrite their row values when you add fields; give new fields defaults in the reader when a row
  omits them, or add them to every row with the value that keeps today's look. Append to `docs/decisions.md`:
  `- [2026-11-20] DECISION souls/flight: each ghost lane owns its own ghost_hover.json row (as ghost_forms.json); flight owns the schema and new fields.`
- Read the other lanes' current use before changing anything they call: `git log n20-dent n20-kerf n20-ohm n20-tonnage --oneline -- project/data/tables/ghost_hover.json project/features/souls/ghost_form_view.gd` (read only, never merge them).

## Technique (decide, but keep it cheap and deterministic)
- The tail is a triangle strip (or several) along the GhostTail chain drawn with a `ghost_tail.gdshader`
  CanvasItem shader: UV.x along the tail (0 root, 1 tip), UV.y across; a noise texture (a
  `NoiseTexture2D` generated in code with a FIXED seed, or a small committed noise PNG under
  `art/shared/`) scrolled by a `tick` uniform you set from the sim tick (NEVER `TIME`: two films at the same
  tick must be identical), eroding the edges into tongues and holes, alpha falling to zero at the tip,
  root bright (near `#CFFFF7`), body `#2EC4B6`, edges darker `#127A72`, additive or mixed so it reads as light
  on the dark street but still visible on the light arena floor. Wisps: a few small puffs per tail that spawn
  from the edges on fixed tick intervals and drift back and fade (deterministic from tick, no RNG streams).
- Tilt views: the tail root is at body height (screen up by `lift_m * ViewMode.lift_k()` px), the tip sinks
  toward the ground; it is drawn BEHIND the body when the body moves toward the camera and over the shadow
  always. Top view: a flat ribbon behind the body.
- Legless bridge for the legacy bodies (so the film can read as spectral before the new art lands): a
  `ghost_fade.gdshader` on the tilted drawn sprite (`GhostDrawn`'s Sprite2D) under the spectral look that fades
  the bottom of the figure (below a row value `fade_from`, 0..1 of the cell height from the bottom, 0 = off)
  into teal vapour with a noisy, tick-driven edge, so the tail emerges where the legs were. The ghost lanes
  will set `fade_from` to 0 for their new legless art. Top view: leave the rigs' legs (speed 0, rest pose).
- Everything steps on sim ticks (`steps` from `GhostFormView`); a frame without a sim step draws the same.

## Evidence (look at every frame yourself before you report it)
1. A film tool you can reuse: if `tools/film/` has nothing that films `project/dev/ghost-powers/ghost_review.tscn`
   in both views, write `tools/film/ghost_films.mjs` (node, no new deps; ffmpeg is on PATH):
   `--ghost=<id> --look=spectral|legacy --out=<dir> [--takes=move,attack,close] [--stills=<ticks>]`, running the
   driver once per view (`--view` of the driver: the 70 degree play tilt and the top view) with `--fixed-fps 60
   --write-movie`, `--ppm=32` (close: `--ppm=64`, 5 s of move then 5 s of attack), stacking tilt above and top
   below into one 1920x1080 mp4 (each panel 1920x540) with a dark title bar (ghost name, speed, px/m, take,
   look) and a small label per panel ("Play tilt 70°", "Top view 90°"), plus a poster `.jpg` (a frame where the
   ghost is mid-turn), named `<ghost>_move_32.mp4`, `<ghost>_attack_32.mp4`, `<ghost>_close_64.mp4`. This is
   last night's layout: see `C:\Users\kazda\kiro\gtai-masters\n19\ghosts\kerf_move_32.jpg` and `INDEX.md`.
   Add a test (`tools/film/ghost_films.test.mjs`, node --test) for its argument parsing and output naming, and
   a line in `tools/README.md`. Commit it on its own.
2. With that tool: `--look=spectral --takes=move` for all four ghosts and `--takes=close` for kerf and tonnage,
   into `C:\Users\kazda\kiro\gtai-masters\n20\flight\` (names as above, prefixed `flight_`: e.g.
   `flight_kerf_move_32.mp4`). Same takes with `--look=legacy` for kerf into `...\flight\before\` (the before).
3. Stills: 64 px/m, both views, a tick where the ghost turns: tail + shadow + fade visible. Save them next to
   the films with honest names (`flight_<ghost>_turn_64_t<tick>.png`).
4. Zero foot contact under spectral: a unit or scenario test that drives a ghost form across the arena under
   `GhostLook.override_for_test(&"spectral")` for each of the four forms and asserts no walk-driven foot event
   fires (Tonnage's `stamped`, any foot mark/dust you found in package 1) and `GhostDrawn`'s column does not
   advance; and the legacy run of the same drive does fire them (so the test can fail).
5. Checks before each commit: `node tools/godot/check.mjs <changed .gd>`, `node tools/lint/lint.mjs`,
   `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`. A legacy-look frame must not change:
   compare one legacy still at the same tick before and after your change (`tools/film/compare.mjs` or two
   stills) and say it is pixel-identical.
6. After the last code commit: `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_hover.gd`;
   quote killed/(killed+survived).

## Order and time
Hover/bank/lag tuning and the shadow first (small), then the tail shader (the main work), then the fade, then
the film tool and the films. Commit after each piece (small commits). Stop by the 75-minute mark with
everything committed; list what is left.

## Report
Commits (sha + one line), files, every check and its result, every film/still path, what you judged in the
frames (one line each), and what is still weak.
