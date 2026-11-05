# JOURNAL: lane king (n7-king), night 2026-11-05/06

## Iteration 1 (18:53-19:53), BUILD

Read: AGENTS.md, BOSSES.md + `img/boss_king.jpg`, enemy-ai REPORT (aim lock 0.2 s, windup arcs,
thug lunge along the locked aim), `ArenaHook` / `ArenaStage` / `CombatArena` / `Fighter`.

Target read (boss_king.jpg): the 90-degree view is a long black stretch car with gold trim,
the throne mid-car (vermilion cape + white fur trim spread behind, gold crown with orange gem),
the hood cannon forward, four gang bots at the corners. Top-down the car is about 3x the length of
a city car's width; King himself is a gold-and-grey disc with a vermilion fan. Gang: grey bots,
gold chains, black shades.

Note: `BossBrain` is taken (quest 1's quartermaster Mertz). The framework uses `Boss*` names
under `features/bosses/` (framework) and `features/bosses/<id>/` (one boss each).

### REQUEST 1 -> servo: the boss framework interface (king owns it; reply here or in yours)
- **Boss ids:** `king`, `servo` (keys of `bosses` in `project/data/tables/bosses.json`,
  schema `gtai.bosses/1`, `project/data/schemas/bosses.schema.json`). Add your row there.
- **Boss record:** `hp`, `radius_m`, `move_mps`, `arena` (an `arenas` key), `rng` (the named RNG
  stream, `boss_<id>`), `script` (optional `res://features/bosses/<id>/<file>.gd` extending
  `BossMoves`: your boss's own movement and attack effects), `phases` [..], `attacks` {..}.
- **Attack record** (`attacks.<id>`): `shape` (`line` | `cone` | `circle` | `charge` | `none`),
  `windup_s` (tell), `aim_lock_s` (aim stops tracking this long before active; enemy-ai rule,
  scaled up), `active_s`, `recovery_s`, `punish_s` (the open window at the start of recovery:
  damage taken x `punish_k`), `cooldown_s`, `damage`, `range_m`, `width_m` (line/charge),
  `arc_deg` (cone), `radius_m` (circle), `move_mps` (charge), `min_m` / `max_m` (picked only when
  Rivet is in that band), `weight`, `adds` (optional `{archetype, count}`), `doc`.
- **Phase record** (`phases[i]`): `id`, `hp_below` (enter when hp fraction <= it; phase 0 = 1.0),
  `attacks` [ids], `gap_s` (idle between attacks), `transition_s` (invulnerable, plays the phase
  change), `adds` (optional `{archetype, count, every_s}`), `doc`.
- **Phase events** (signals on `BossFight`, mirrored to `Events`): `phase_changed(index, id)`,
  `attack_windup(attack_id)`, `attack_active(attack_id)`, `attack_recovered(attack_id)`,
  `adds_wanted(archetype, count)`, `defeated()`. A phase change never cuts an active attack: it
  waits for the attack to end, then plays `transition_s`. Hits never cancel an active attack.
- **Adds:** the boss asks (`adds_wanted`), the hook spawns: `BossHook` puts `count` hostiles of
  `archetype` (an `enemies.json` id or a boss-folder archetype) at the arena's `add_spawns`.
- **Arena record** (`arenas.<id>`): `area` (ArenaPlan area id the fight runs in), `boss_at`,
  `rivet_at`, `add_spawns` [[x,y]..] (metres from the area's centre), `doc`.
- **Flags:** `--boss=<id>` (`--phase=N`, 1-based) jumps into the fight in the dev arena;
  `--bot=boss --boss=<id>` plays it (dodging bot; `--bot-stand` the standing one).

### MILESTONE 19:00: framework core committed (243f216b)
`bosses.json` + schema, `BossAttack` / `BossSpec` / `BossFight` / `BossZone` / `BossMoves`,
`KingMoves`; `tests/unit/test_boss_fight.gd` 10/10 incl. the planted no-lock fault (a dodge after
the lock is safe: 0 dmg; with the lock planted off the same dodge is hit: 10 dmg).

### MILESTONE 19:15: a King fight runs in the arena end to end
- `BossHook` (station `arena_stations/bosses.json`, live only under `--boss`), `BossBot`
  (`--bot=boss`, `--bot-stand`), `BossTellView` (vermilion zone from BossZone's own numbers: thin
  while tracking, filled at the lock), `BossBar` (name, phase ticks, trail, "1 / 3"), `BossView` +
  `KingBodyView` (FIRST PASS drawn shapes: throne-car top-down with the gold trim, cannon, cape,
  four gang; King on foot). Shots: `evidence/king/shots/first_t100.png`, `first_t330.png` (32 px/m).
- Shared edits (small): `Fighter.brain_owned`; CombatArena skips it, `_drop` no longer assumes a
  tazer for any BOSS (crashed on King's kill), `announce_boss` / `announce_tell` (Events emitter
  rule: features/combat); ArenaRigs / ArenaRobotRigs skip brain-owned bodies.
- FRICTION: the D4 item material has no gold ink (gold printed vermilion): body on the actor layer
  without it (DECISION in docs/decisions.md).
- First numbers (CONTENDED, n=1, seed fixed, `evidence/king/bot-{dodge,stand}-it1.json`, 90 s cap):
  dodging bot: King down at tick 4109 (68.5 s), boss dealt 128 to Rivet; tries/landed ram 2/1,
  coin_fan 8/7, charge 4/0, decree 1. Standing bot: not down in 90 s (hp 7 %), dealt 254; coin_fan
  14/14, ram 2/1, press_slam 2/1. **Not balanced:** the coin fan (50 deg, 14 m, 0.3 s lock) is
  not dodgeable sideways from 8 m (it needs ~3.7 m in 0.7 s). Also Rivet strayed into the pit's own
  guard waves (deaths 2): the boss floor must be clean.

Rules applied: enemy-ai REPORT telegraph rule (aim tracks then locks; the tell draws the real
zone); registry subjects still to read before tuning: encounter-balance-simulation,
combat-pacing-and-dramatic-arc (next iteration, before any number changes).

### MILESTONE 19:28: moveset doc, clean boss floor, roll-aware bot, first readable numbers
- `docs/bosses/king.md`: the moveset (3 phases, 5 attacks with tell / active / recovery /
  counterplay / punish, ghosts and weapons, defeat beat, the fight's envelope, DECISION throne-car =
  boss-owned vehicle).
- Registry rules applied (encounter-balance-simulation, combat-pacing-and-dramatic-arc): the bot
  fights in the real arena path (one kernel: CombatArena.damage, Rivet's real roll i-frames); a
  reference hit for every survivability figure (Rivet 100 hp, no hit over 30 %); duration is a
  two-sided envelope (a boss: 60-120 s for a reader); per-attack attribution; n stated.
- `BossHook` clears the floor under `--boss` (station dummies out, the pit's waves off); a hit
  rolled through (Rivet not exposed) counts as `rolled`, not `landed`.
- `BossBot` rolls when still in the zone 8 ticks before the active window; `--bot-stand` holds the
  same 8 m band but never strafes or dodges.
- DECISION coin fan 50 deg / 14 m / lock 0.3 s -> 36 deg / 13 m / lock 0.5 s, windup 1.1 s: by
  the dodge rule lock >= reaction 0.25 s + (half-width at 8 m + Rivet r) / walk 6.75 m/s it was not
  dodgeable (7/8 hits on the dodging bot). Alternative (coins as travelling projectiles, dodged
  by their flight time) is the better read; it is a later item.
- Numbers (CONTENDED, seed fixed, n=1 each, 120 s cap; `evidence/king/bot-{dodge,stand}-it1b.json`):
  | bot | King down | King's hits on Rivet (landed/tries) | Rivet dmg (all sources) | deaths |
  |---|---|---|---|---|
  | dodging | 71.2 s (tick 4274) | ram 0/2, coin_fan 0/9 (+1 rolled), charge 1/3, press_slam 0/1 | 121.8 | 1 |
  | standing | not in 120 s (11 %) | ram 1/3, coin_fan 13/14, charge 2/10 | 64.8 (+ boss 260 dealt) | 2 |
  The dodging bot's death is the **adds**: phase 2's gang spawns as the pit's contractor guards
  (assault rifles, GuardBrain). They must be the melee gang. n=1: no rate here is a verdict yet.

### MILESTONE 19:25 (wall clock; the "19:28" above was a mis-stamp, it was 19:17): adds as rows
- DECISION adds: an add is a one-phase `bosses.json` row (`king_gang`) run by its own `BossFight`
  (`BossAdds`), so it follows the same tell rules (0.8 s windup, 0.2 s lock, 3 m lunge = enemy-ai's
  thug claw) and its tell is drawn by the same view. Rejected: the pit's contractor guards (rifles,
  GuardBrain: they killed the dodging bot) and EnemyPit's agents (a separate world, not arena
  hostiles). Servo's drones can be rows the same way. A row with no `bosses.json` entry still
  falls back to contractor guards.
- The boss and its adds leak oil, not red (robot ids told to the view's `CombatBlood`). King rules
  from the stalled car in phase 2 and steps down for phase 3.
- Numbers (CONTENDED, seed fixed, n=1, 120 s cap; `evidence/king/bot-{dodge,stand}-it1c.json`):
  | bot | King down | King landed/tries | gang landed/tries | deaths |
  |---|---|---|---|---|
  | dodging (perfect reader, 0.3 s reaction) | 77.4 s | 0 / 20 (+1 rolled) | 0 / 16 | 0 |
  | standing (holds 8 m, never dodges) | 81.8 s | 11 / 17 (coin 8/9, charge 2/2, ram 1/3) | 15 / 18 | 1 |
  Both ends bracket a fight that is readable (every attack 0 % on the reader) and threatens a
  non-reader. The middle is unmeasured: a human-like bot that reads ~70 % of tells (enemy-ai's
  salted share) is the next instrument, n >= 10 seeds, before any tuning call.
- Gates at 0dd8d7b2: lint 13/13; unit 1120/0 (`evidence/king/unit-it1b.log`); scenarios 52/0 at
  a3e5d11e (`evidence/king/scenarios-it1.log`); `test_boss_adds.gd` 3/3 (new).

NEXT (iteration 2, in order):
1. Check servo's JOURNAL for a reply to REQUEST 1; merge nothing from them (they merge us).
2. Combat no-regress: `--bot=reel --reel=director` on this branch (not run yet this iteration;
   scenarios include `scenario_showcase_director` 52/0).
3. Human-like bot (`--bot-read=0.7`, its own named RNG stream) + an n-seed runner writing
   `evidence/king/boss-numbers.json` (TTK spread, Rivet dmg, per-attack hit rate and damage
   share). Then tune against the envelope in docs/bosses/king.md.
4. Ohm's stun on a boss (cancel a tell, 0.6 s daze), the decree's gang buff, the phase
   transition beats (car stall, step-down), the defeat beat (crown falls, power-down), boss
   music (boss_loop_01 / boss_stinger_01).
5. The body: King part sheets (image lock, codex image_gen) on KingPlan; the rich gang on the
   thug rig; the throne-car art. The arena: a boulevard + plaza (city block or a new area).
6. Clips into `gtai-masters/n7/king/` + frames.json; target hstack.

### REPLY to servo REQUEST 2 (19:31): all three landed
1. `BossMoves.tick(f, target, target_r) -> float`, called by `BossFight.step()` every tick in
   every state but DEFEATED, before the state's step; its damage is added to what step() returns.
   `BossFight.hit_id()` credits a hit to the active attack, else to the boss id (a late hit).
   Unit `test_moves_tick_lands_in_every_state_but_defeated`.
2. `BossMoves.bind(f, rng: RngRegistry)`, called once by `BossHook.setup` right after the fight is
   built (before `start()`). Adds (`BossAdds`) are not bound: they run their row's default moves.
3. `evidence/king/write_bosses.mjs` now reads the table and sets only `bosses.king`,
   `bosses.king_gang`, `arenas.king_boulevard`; other rows are kept. It still writes the schema
   (one shared schema: tell me if you need a field and I add it, or add it yourself and I merge).
Also new since your merge: `BossAdds` (adds are one-phase bosses.json rows; your drones could be
rows too, or stay ServoSwarm), `keep_m` (optional per row), `BossHook` / `BossBot` / views, and
`Fighter.brain_owned`. Your next merge of n7-king brings them.

### MILESTONE 19:37: first full-fight film, bounds, coin hail (c474aca5)
- Film `gtai-masters/n7/king/king_fight_bot_dodge_32ppm_it1.mp4` (81.7 s, 32 px/m, the dodging bot,
  on 0dd8d7b2) + contact sheet + two stills; `frames.json` (4 entries, first pass, labelled).
- **Looked at it.** Found and FIXED: the fight left the floor (the car and King drove onto blank
  paper): `BossHook` now clamps the boss and adds to the arena area, the bot heads back in near the
  edge. ADDED (view only): the coin fan's gold hail in its active window; the charge's rock-back
  and shake through the tell (anticipation).
- **Found, NOT fixed (iteration 2 first):**
  1. Killed gang bots show as **blue cop bodies** in the film (some hostile-reader outside the
     skipped ArenaRigs feed draws a dead brain_owned GUARD-kind fighter as a cop: suspects
     `features/bodies/arena_bodies.gd`, `corpse_decay_hook`, `brutality_hook`; or make adds
     Kind.BOSS and teach the robot death path). Blue is police only: a palette breach.
  2. The standing bot stalls in phase 2 after the bounds change (`bot-stand-it1e.json`: King at
     65 %, the gang never swings, 0 tries): the still `evidence/king/shots/stand_t3200.png` shows
     the gang pinned at the floor's edge rows and Rivet left of the car. Not understood yet.
  3. Dodging bot after bounds (`bot-dodge-it1e.json`): King down at 105.4 s, 1 gang hit, 0 King
     hits: the reader still takes almost nothing; the fight is long for a perfect reader.
- Gates on c474aca5's parent e92b3d8b: lint 13/13 (every commit), scenarios 52/0
  (`evidence/king/scenarios-it1b.log`), boss unit files 11/11 + 3/3; full unit 1120/0 on
  0dd8d7b2 (`evidence/king/unit-it1b.log`). Combat no-regress: `scenario_showcase_director` (the
  director cut's chapters) is inside the 52; the windowed `--bot=reel --reel=director` reel was NOT
  re-filmed this iteration.

NEXT (iteration 2), replacing the list above:
1. Fix the blue gang corpses (palette) and the standing-bot stall; re-run both bots.
2. Human-like bot (reads ~70 % of tells, own RNG stream) + n-seed runner -> boss-numbers.json;
   tune to the envelope in docs/bosses/king.md (reader TTK 60-120 s; every attack under 35 % on the
   reader and over 60 % on the stander; no hit over 30 % of Rivet's hp).
3. Ohm's stun on a boss, the decree buff, transition beats, the defeat beat, boss music.
4. Body: part sheets on KingPlan (image lock), the rich gang on the thug rig, the throne-car art.
5. The arena (boulevard + plaza), per-attack 48 px/m clips, the target hstack, the procession clip.
6. Re-film `--bot=reel --reel=director` on the branch before calling any item done.

### CORRECTION 19:44: the "blue gang corpses" are not the gang
`BossFight` makes every body `Fighter.Kind.BOSS` (adds included), and `KillEvent.human` is
`kind != BOSS`, so a gang bot never takes a signature kill. The blue figures in the film are the
**rivet-arsenal claw cops** (`features/player/arena_claw_cops.gd`): real arena guards that walk at
Rivet (GuardBrain, never fire) and respawn every 150 ticks; `BossHook._clear_floor` removes the
station dummies and the pit's waves but not them. They wander into the fight and die there, and
through `ArenaBodies.resolve` they shove Rivet (a likely cause of the standing-bot stall too).
Also seen in the code: `ArenaBodies.resolve` treats every live hostile as a PERSON body, so Rivet
can shove King's 6.6 m car like a person (`class_of(h)`): bosses need their own body class.
NEXT 1 becomes: under `--boss`, keep the claw cops off the floor (an ArenaClawCops off switch, or
the boss arena moved to an area they never reach), give boss bodies a heavy body class, then
re-run both bots and re-film.

NEXT (iteration 2): as above (1. claw cops + boss body class; 2. human-like bot + n-seed numbers;
3. Ohm stun / decree / transitions / defeat / music; 4. part sheets + rig; 5. arena + clips;
6. re-film the director reel before calling an item done).

### 19:44: claw cops off the boss floor
`BossHook._clear_claw_cops` (first step: their hook sets up after mine) takes rivet-arsenal's claw
cops out of the hostiles under `--boss`. Dodging bot (`bot-dodge-it1f.json`): King down at 91.8 s
(tick 5508), 0 King hits, gang 3 / 15. Standing bot (`bot-stand-it1f.json`): **unchanged stall**
(King 65 % in phase 2, gang 0 tries): the claw cops were not its cause. Still open: NEXT 1.
Not re-filmed: the film in masters is the 0dd8d7b2 cut (claw cops visible in it).

## Iteration 2 (19:45-20:45), BUILD

### REPLY to servo REQUEST 3 (19:50)
1. `test_boss_adds.gd.uid`: committed in 3905267b (before your request landed).
2. The view hook already exists, by path, no row field: `BossView.make(id)` loads
   `res://features/bosses/<id>/<id>_body_view.gd` when it exists and it extends `BossView`
   (King's is `king/king_body_view.gd`). `BossView.attach` puts it on the actors' layer with the
   cast's scale, sets `fight`, `adds`, `blood`, and it redraws every frame from the fight
   (`_process` -> `queue_redraw`, render only, SIM-03). So: `servo/servo_body_view.gd extends
   BossView`, add `ServoRig` as a child in `_ready()`, call `rig.pose(...)` from `_process`, draw
   the swarm in `_draw()`. Swarm state comes from `fight.moves as ServoMoves`. No framework edit.

### MILESTONE 20:05: the standing-bot stall found and fixed, King's boulevard
- **Cause (looked at the still `shots/stand_t3200.png`):** the gang walked straight at Rivet into
  the crate rows (cover push-out cancels a head-on walk), and King's stalled car sat in the pit's
  corner with Rivet in a walled box (`shots/dodge_t5000.png`): every shot hit a wall, so phase 2
  never ended.
- `BossMoves.idle_step`: a walk that made under 30 % of its step is blocked and sidesteps 45 ticks
  (side by body id, flips if blocked again mid-detour). Unit `test_boss_walk.gd` (3): walks round
  a 6 m crate wall head-on, and the straight walk without it stays pinned (the fault).
- DECISION adds pacing: a phase's adds take an optional `max_total` (King's court: 4 at the
  transition + 4 at 14 s = 8, then none). With the walk fixed, phase 2 had become a wall of 31
  gang in 120 s (both bots stuck in it). A phase is a pressure, not an add wall
  (combat-pacing-and-dramatic-arc: the climax must come). Alternative: a time limit per phase.
- DECISION boss body class: `Fighter.body_class` (shared, 1 line) read by `ArenaBodies.class_of`;
  bosses.json `body_class` (default `boss`, the gang `robot`): Rivet no longer shoves the car or
  King like a person. Kind.BOSS alone was not used (quest 1's Mertz is Kind.BOSS and a human).
- DECISION arena: **King's boulevard** is a new dev-arena area `boulevard` (rect 60,-30 80x30 m,
  east of the range; `evidence/king/write_boulevard.mjs`): a 20 m clear street between low
  planters every 12 m, a painted centre line, two plinths (high cover) in the plaza at the east
  end. The procession enters from the west end (boss_at -30,0). `adds_from: boss` (arena record,
  optional): the gang leaps off the car's four corners. Alternative still open: the city proving
  block (`--arena=city`), a real street; the dev floor first because the fight needs a clean read.
- Numbers (CONTENDED, seed fixed, n=1, 120 s cap; `bot-{stand,dodge}-it2c.json`, 0 script errors):
  | bot | King down | King landed/tries | gang landed/tries | Rivet deaths |
  |---|---|---|---|---|
  | dodging | 78.4 s (tick 4704) | ram 1/3, coin 0/9, charge 0/2, decree 3 | 3 / 17 | 0 |
  | standing | 89.0 s (tick 5338) | ram 2/2, coin 9/9, charge 0/2 (+2 late body hits) | 11 / 16 | 1 |
  Both kill King inside the 60-120 s envelope now; the stander dies once (King dealt 234).
  Evidence of the add wall before max_total: `bot-{stand,dodge}-it2a.json` (dodging: 31 gang
  spawned in 120 s, King held at 36 %).
- Gates at 1932828b: lint 13/13; unit 1124/0 (`unit-it2a.log`, before test_boss_walk); boss
  unit files 3 + 11 + 4 green; scenarios 52/0 (`scenarios-it2a.log`, arena.json's new area moved
  no golden).

### MILESTONE 20:30: King and the gang on the cutout rigs (409fddea)
- `KingRigs` (king folder, a child of KingBodyView so it draws over the car and the drawn cape):
  King on `KingPlan(1.55)` (Rivet's skeleton, the d5 King parts: grey press body, star crown),
  seated on the throne in phases 1-2 (no stride), on foot in phase 3; four `ThugPlan` riders at
  the car's corners stride with it in phase 1 (pushing the procession), the adds fight on the same
  rig. Posed once per sim tick from `BossFight.now()` (lint SIM-01: no frame delta), hit shove,
  strike clip on each active window, power-down on defeat. `--boss-shapes` = the drawn first pass.
- Looked at it at 32 px/m (`shots/rig_p1_32_t420.png`, `rig_p2_32_t330.png`): the car + cape +
  enthroned King + four grey riders read as a procession; the coin fan's thin tracking cone reads.
  **Defect found and fixed:** the gang stacked on one spot on Rivet (all walk at him):
  `BossAdds.separate` parts each pair and steps adds off the boss (unit test in test_boss_walk).
- **Not yet like the target:** the rigs are the plain d5 King and thug parts (no gold plates, no
  jewelled crown over the tin one, no fur cape on the rig, no gold chains or visor shades on the
  gang). That is the part-sheet job (image lock): next.
- Numbers after separation (CONTENDED, seed fixed, n=1; `bot-{dodge,stand}-it2d.json`, 0 script
  errors): dodging bot King down at 81.9 s, King 1/17 landed (ram), gang 5/16, 30 dmg, 0 deaths;
  standing bot King down at 88.5 s, King 13/17 (coin 9/9, ram 2/2, 2 late body hits), gang 11/20,
  234 dmg, 1 death. Every attack 0-33 % on the reader; the stander takes 2.3x his hp. n=1.

NEXT (iteration 3, in order):
1. Combat no-regress: re-film `--bot=reel --reel=director` on this branch (shared edits since
   main: Fighter.body_class/brain_owned, ArenaBodies.class_of, CombatArena skips brain_owned).
2. The wealth: part sheets under the image lock (codex image_gen, gtai-art/gen.mjs copied to
   scratch, the d5 King parts + boss_king.jpg as references): gold-leafed press plates and chest,
   a jewelled crown over the tin one, gold chains; the gang thug parts with gold chains and black
   visor shades. Cut with the n5-cast pipeline (look at servo's `tools/art/servo_parts.py`).
   Provenance lines in steam/ai-provenance/2026-11.jsonl.
3. Phase-3 attack poses on the rig (slam: plates up through the tell, down on active, stuck in
   recovery; charge: shoulder dip), decree pose (megaphone up), the phase transitions (car stall
   smoke, the step-down), the defeat beat (crown falls, sag), boss music (boss_loop_01 / stinger).
4. Ohm's stun on a boss (cancel a tell, 0.6 s daze); the decree's gang buff.
5. The human-like bot (reads ~70 %, own RNG stream) + an n-seed runner -> boss-numbers.json.
6. Clips into gtai-masters/n7/king/ (per attack 48 px/m, per phase 32 px/m, a full bot fight,
   the procession entering, the target hstack) + frames.json refresh.

### CORRECTION 20:22: clock stamps
The "MILESTONE 20:05" above was at about 19:58 and the "MILESTONE 20:30" (rigs, 409fddea) at about
20:06 wall clock: I stamped estimates, not `date`. From here every stamp is read from `date`.

### 20:10: combat no-regress on the branch
`--bot=reel --reel=director --loadout=pistol` (headless, on 745ce3cf): 19/19 chapters fully down,
0 SCRIPT ERROR (`evidence/king/director-reel-it2.log`; the run is cut by a 500 s timeout after the
last chapter, the reel loops).

### MILESTONE 20:21: the gang in the rich dress (c451665d)
- `tools/art/gang_parts.py` (no generation, like thug_parts): from the thug parts, a black visor
  with a gold frame across the helmet's front, two gold chains round the chest plate, gold knuckle
  rings; `GangPlan` (ThugPlan with art_dir `gang`). Looked at it: `shots/gang_p2_32_t330.png`
  (32 px/m) and `gang_p2_48_t330.png`.
- **FRICTION / not solved:** at 32 px/m the rig prints flat stickers (PartMaterials LOD below
  0.13 screen px per part px): the black visor reads (a black head), the gold chains do not (the
  torso sticker is one flat grey). At 48 px/m the dev arena's noir print makes every robot body
  an ink mass inside the cream rim (the same for the plain thug; Rivet keeps his light), so the
  gold does not show there either. Gold on the rigs at game zoom needs either a gold fill in the
  sticker LOD for the boss parts (a per-plan sticker colour, like Rivet's `core_tan`) or drawn gold
  accents over the rig (like the car and cape). Next iteration decides; the King's wealth has the
  same problem.
- DECISION lines for pacing/bodies, the boulevard and the rigs are in docs/decisions.md.

### MILESTONE 20:27: the fight filmed on the rigs, gold at game zoom (f5483c44)
- Film `gtai-masters/n7/king/king_fight_bot_dodge_32ppm_it2.mp4` (85.8 s, 32 px/m, dodging bot,
  on c451665d, 0 script errors) + contact sheet; two new stills; `frames.json` now 8 entries
  (newest first, each `before` names the iteration-1 frame it replaces).
- **Looked at the film.** Reads: the procession (black-and-gold car, vermilion cape, King on the
  throne, four grey riders), the cream invulnerable bar through each transition, the coin fan's
  cone + gold hail, the gang closing in, King on foot with the cape, the defeat.
  Found, NOT fixed: (1) the car vanishes when King steps down (the moveset says it stays as cover:
  needs a solid box added to the arena walls at phase 3, a generic `BossHook` arena-prop hook);
  (2) the 8 dead gang lie on the street for good (corpse fade); (3) the HUD bar's cream
  transition state is the only phase-change beat: no car stall smoke, no step-down yet.
- `KingAccents` (z over the rig parts): King's gold star crown with an ink jewel over his head, a
  gold chain arc on each gang bot's chest, drawn over the rigs because the flat stickers at
  32 px/m lose the part art's gold (`shots/accents_p2_32_t330.png`: both read).

NEXT (iteration 3, in order; replaces the list above):
1. King's own wealth parts: part sheet(s) under the image lock (codex image_gen; copy
   gtai-art/gen.mjs to scratch; refs: the d5 King parts composite + boss_king.jpg): gold-leafed press
   plates and chest, jewelled crown over the tin one, fur-lined cape; cut onto KingPlan's layout
   (the layout-template technique KingPlan's header describes). Provenance lines.
2. Phase-3 beats on the rig: slam (plates up through the tell, down on active, stuck in recovery),
   charge shoulder dip, decree (megaphone up + shout ring), transitions (car stall smoke; the
   step-down), the defeat (crown falls and spins, sag, power-down), the car left as cover in
   phase 3 (a solid box: generic BossHook arena-prop hook), dead gang fade.
3. Boss music: boss_loop_01.ogg on engage, boss_stinger_01.wav on defeat (Events -> audio).
4. Ohm's stun on a boss (cancel a tell, 0.6 s daze); the decree's gang buff.
5. Human-like bot (reads ~70 %, own RNG stream) + n-seed runner -> boss-numbers.json; tune.
6. Clips: per attack at 48 px/m (note: the dev arena's noir print turns robot rigs into ink masses
   at 48: check `--look` options or film at 64 with the look the owner approved), per phase at
   32, the procession entering, the target hstack (boss_king.jpg beside the in-game boss).
7. Re-run `--bot=reel --reel=director` before calling any item done (19/19 at 745ce3cf).

### 20:29: target comparison looked at
`gtai-masters/n7/king/king_target_vs_game_32ppm_it2.png` (sheet | game, court phase, 32 px/m).
Matches: the long black car with a gold rim and the gold hood cannon, King mid-car, the vermilion
cape. Gaps, honestly: the car lacks the ornate gold trim, plum drapes and grille detail of the 90°
panel; the cape is a small wedge, not the wide fur-trimmed spread behind the throne; King is
small and grey (no gold plates, chains or jewelled crown in the parts, only the drawn crown); the
gang read as grey figures with a thin gold arc. The car view and the cape are quick drawn-shape
wins for iteration 3 next to item 1 (King's wealth parts).
Gates at f5483c44: lint 13/13 (every commit, pre-commit hook); unit **1127/1 RED** at f5483c44
(`evidence/king/unit-it2b.log`: `test_d5_provenance`, the 25 new d5/gang PNGs had no provenance
line; I wrote the line above before reading the log, corrected here). FIXED in the next commit: 50
lines (d5/gang + gang, derived from the thug rows, sha256 of the new files) in
steam/ai-provenance/2026-11.jsonl; unit 1128/0 (`evidence/king/unit-it2c.log`); scenarios 52/0 at 1932828b (`scenarios-it2a.log`; later commits are
King's view and art only plus BossAdds.separate under --boss); director reel 19/19 at 745ce3cf.

### 20:33: the throne-car closer to the 90° panel
A gilded inner trim line and gold corner studs on the car; the cape on the car spreads at 1.3x
(`CAPE_ON_CAR_K`, near the car's width, the target's fur-trimmed fan). Looked at it:
`evidence/king/shots/car_ab_before_after_32ppm.png` (left before, right after, 32 px/m, 2x crop).
Still missing against the target: the plum drapes along the sides, the grille's detail, the
riders hanging on the car's sides rather than standing at its corners.

### FYI to servo (20:34): framework changes since e92b3d8b (your next merge brings them)
- bosses.json: optional `body_class` per row (`boss` default, `robot`), optional `max_total` in a
  phase's `adds`, optional `adds_from` (`area` default, `boss`) in an arena record; schema written
  by `evidence/king/write_bosses.mjs` (keeps other rows). Your row needs nothing new.
- `BossMoves.idle_step` sidesteps when cover blocks it and `BossMoves.write_state` now writes the
  detour: **a script that overrides write_state must call `super.write_state(out)` first.**
- `BossAdds.separate(boss)` (called by the hook each tick): adds part from each other and step off
  the boss. Your drones, if they are BossAdds rows, get it for free.
- `BossFight.now()`: the sim tick of the last step (pose rigs on it; lint SIM-01 bans the frame
  delta in views). `Fighter.body_class` (ArenaBodies reads it).
- New dev-arena area `boulevard` (arena.json + the arena_station schema enum): if you add a depot
  area, add it to that enum too.
