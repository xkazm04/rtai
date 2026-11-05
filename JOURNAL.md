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

### 20:35: gates on the head (1fe158d7, code as of b0ee403d)
lint 13/13; unit 1128/0 (`unit-it2c.log`, at 2f012dea; b0ee403d is a drawn-car view change);
scenarios 52 ran / 0 failed (`scenarios-it2b.log`); director reel 19/19 (at 745ce3cf; the shared
combat code has not changed since). Session stops here; NEXT is the iteration-3 list above.

## Iteration 3 (session from 20:36)

Read: JOURNAL, git log, servo's JOURNAL (REQUEST 4 open), BOSSES.md target image again.
Registry rules applied: `combat-pacing-and-dramatic-arc` (the phase-3 signature move must
actually happen, or phase 3 has no new beat), `encounter-balance-simulation` (a stander and a
dodger as the two ends; numbers with n stated), `motion-quality-gating` (judge in motion, at
48 px/m, frame strips, not one still).

### 20:38 REQUEST 4 from servo taken (d86e36fe)
Cherry-picked servo's 567ef26b (`bodies()`, `threat_away()`, `telemetry()` on BossMoves; BossHook
syncs the bodies; BossBot reads threat_away; dev `--seed=<n>`). Conflict in boss_moves.gd taken
from servo's c37ea648 (which already holds both sides: their hooks + my write_state detour).

### MILESTONE 20:44: King's gold at game zoom (a02406bb)
- DECISION: no image generation for King's wealth tonight. At 32 px/m the rig prints flat
  stickers (PartMaterials LOD), so a new gold part sheet would not show at game zoom (the gang's
  gold chains proved it in iteration 2). Instead a print swap: `print_part` swap 5 = gold leaf
  (paper and wash print GOLD..GOLD_DK, ink kept), at every zoom; `BodyPlan.arm_swap` (forearms +
  hand). `KingRigs.king_plan()` gilds the chest and press arms; KingPlan (the enemy-ai thug's base)
  and ThugPlan stay steel (unit test_king_gold 3/3). Alternative = `KingRigs.GOLD_SWAP = -1`.
- Looked at it: `evidence/king/shots/gold_ab_p3_32ppm_2x.png` (32 px/m, 2x crop; left the first
  darker gold mapping, right the shipped one). The press arms read gold beside the vermilion
  cape and the drawn gold crown; the torso is mostly under the crown at this zoom.
- Each attack now plays on King's rig from its windup (RigClips.strike on the attack's own
  timing: twist back through the tell, strike on active, ease back over recovery; the slam lifts
  both plates through the tell via the hands-up envelope). Per-attack arm in `ATTACK_ARMS`.
- unit 1131/0 (`evidence/king/unit-it3a.log`).

### FOUND 20:47: the press slam never fires against either bot
Both bots hold an 8 m band; the slam reached 6 m and its ring sat on King himself. So phase 3
was charge + coin fan only and the slam was unmeasured.
### MILESTONE 20:52: the leaping slam (376d3875)
- Generic `BossAttack.leap_m` (bosses.json, schema `leap_m` 0-20): a circle's ring tracks Rivet up
  to leap_m out, locks, and the boss hops onto it during the lock, landing as the windup ends.
  King's slam: leap_m 6, max_m 10. `test_boss_leap` 3/3 incl. planted leap_m 0 (misses the stander).
- `KingShock`: on impact an ink-and-gold shockwave ring runs out to the hit radius with 22 coins
  bursting out (render only, golden-ratio scatter, no RNG).
- `--boss-cam` (BossCam, view only): camera 0.45 of the way from Rivet to the boss, for clips.
- Looked at it in motion: `evidence/king/shots/slam_frames_48ppm_it3.png` (8 fps strip, 48 px/m):
  thin ring tracking ahead of King, plates up, ring fills at the lock, the hop, the shockwave and
  coins, plates down-forward in the recovery. Reads.
- Numbers (CONTENDED, n=1, phase 3 only, 900 ticks): stander slam 1/1 landed, charge 1/2, coin 1/1,
  66 dmg; dodger slam 0/1, charge 0/2, coin 0/1, 0 dmg (`evidence/king/slam-{stand,dodge}-it3.json`).
  With leap_m 5 the band-holding stander backed out of the ring (0/1): 6 is the value that lands.
- Clips: `gtai-masters/n7/king/king_slam_stand_48ppm_it3.mp4` (telegraph, hop, hit),
  `king_phase3_dodge_48ppm_it3.mp4` (15 s, all three phase-3 attacks dodged).
- Note: I amended 376d3875's message once (two staged changes went into one commit after a lint
  fail); lint re-run on the tree after: 13/13.

### MILESTONE 21:02: music and phase beats (4e2df035, e4ee9c55)
- `BossMusic` (features/bosses, generic): the dev arena attaches no StageAudio, so the boss cues
  never played there. Now the stinger + `boss_loop` start with the engage; the defeat stops the
  loop and hits the stinger again (unit test_boss_music). Answers servo's "check whether king
  wired the boss music": yes, in BossView.attach, every boss gets it.
- `KingBeats`: smoke builds from the hood through the stall into the court and keeps steaming;
  at the court's end King steps down off the car's right side with his cape (from 45 % into the
  2.5 s transition; `KingMoves.step_down` moves the sim body at the phase change) and the car stays
  where it stalled, smoking (render only, NOT cover yet: DECISION line); the crown falls off and
  rolls 1.4 m with 1.5 turns on the defeat. Unit test_king_beats 2/2; unit 1137/0
  (`evidence/king/unit-it3b.log`).
- Full fight before the beats (dodging bot, 32 px/m, boss cam, n=1, CONTENDED): King down at tick
  4639 (77.3 s); Rivet took 30 (one ram); tries ram 3, coin 8, decree 3, slam 2, charge 1; landed
  ram 1; gang 5/16. The dodging bot now meets the slam twice per fight (it never did before).

### 21:10: the fight filmed with the beats and music, looked at
- `gtai-masters/n7/king/king_fight_bot_dodge_32ppm_it3_music.mp4` (80 s, 32 px/m, --boss-cam, on
  e4ee9c55, 0 script errors, audio track = stinger + boss loop). Looked at the contact sheet and
  two strips: the step-down off the car's side, the car staying as a smoking wreck, the leaping
  slam from beside it with its coin shockwave, and the defeat (King sprawls, the crown rolls off).
  Found, NOT fixed: the smoke is faint at 32 px/m; the 8 dead gang lie in a heap for good (corpse
  fade); the boss cam drifts over the cream off-floor ground near the boulevard's ends.
- `king_procession_enter_32ppm_it3.mp4` (first 22 s), `king_stepdown_wreck_slam_32ppm_it3.mp4`,
  `king_target_vs_game_car_it3.png` (target 90-degree panel | game car, 32 px/m 2x). Target gaps,
  honestly: the round fur collar and the big jewelled crown over King, plum drapes along the
  sides, the gang hanging off the car's sides in gold chains (ours stand at the corners, grey).
- frames.json: 12 entries, newest first; masters folder cleaned of unreferenced renders.
- Numbers, full fight, seed fixed, n=1, CONTENDED (`evidence/king/bot-{dodge,stand}-it3.json`):
  dodging bot: King down at 77.3 s (tick 4637, the same tick headless and windowed); Rivet took
  30, 0 deaths; King landed ram 1/3, coin 0/8 (1 rolled), slam 0/2, decree 3, charge 0/1; gang 5/16.
  Standing bot: King down at 88.5 s; 1 death; King landed coin 8/8, slam 2/2, ram 2/2; gang 11/20;
  252 dealt. The slam now lands on a stander and is dodged by a reader, as the moveset wants.
- Gates at e4ee9c55: lint 13/13 (pre-commit); unit 1137/0 (`unit-it3b.log`); scenarios 52 ran /
  0 failed (`scenarios-it3.log`).

### MILESTONE 21:13-21:17: corpse fade, ermine collar, decree buff, Ohm's daze
- 0965780d: King's downed gang lie 6 s, then ink out and sink over 1.5 s and leave the floor
  (CorpseFade's look, on the boss's clock). Looked at `evidence/king/shots/fade_smoke_p2_32_t1500.png`:
  one fresh body left, the rest gone, the oil stays; the hood smoke shows over the stalled car.
- afd0da8b: the ermine collar (cream fur ring with ink tails, open at the front) and a bigger
  jewelled crown (0.42 m) over the rig. Looked at the 3-way comparison
  (`evidence/king/shots/ermine_target_before_after_32ppm.png`, target | before | after): the fur
  ring + crown is the target panel's strongest read and now shows at 32 px/m.
- 6809f7ba: the decree does something now. Generic attack field `buff_adds {damage_k, speed_k, s}`
  (schema), applied by BossAdds.buff on the active window, BossMoves.speed_k; King's decree x1.3 /
  x1.2 for 6 s. View: vermilion shout rings pulse off King; a vermilion danger ring on each buffed
  gang bot. Unit test in test_boss_adds. Court at 48 px/m, standing bot (`court_decree_48ppm_contact_it3.png`):
  decree 2 tries, gang 10/12 landed, the bot died in the court. FRICTION: at 48 px/m the dev
  arena's noir print turns every robot rig into an ink mass (known since iteration 2).
- 65651353: `--boss-cam` follows Rivet alone when the boss is over 20 m away (after the standing
  bot's respawn the camera framed empty off-floor ground).
- Ohm's daze (next commit; unit 1140/0, `unit-it3d.log`): a new stun on the boss's body (FightAreas fx stun_ticks, rising edge:
  Ohm's bolt, the electro gun) cancels a tell and dazes for at most `BossFight.DAZE_MAX` 36 ticks
  (0.6 s): no walk, no new attack; never an active attack, a recovery or a transition. Unit
  test_boss_fight +2 (incl. "never cancels an active attack"). NOT seen live yet (no bot plays Ohm).
- Combat no-regress at a02406bb+ (shared print shader, rig_build, body_plan touched):
  `--bot=reel --reel=director --loadout=pistol` headless, 19/19 chapters fully down, 0 script
  errors (`evidence/king/director-reel-it3.log`).
- Unit at 6809f7ba: 1137/1, the 1 = test_noir_shadows (known flake), 2/2 alone
  (`unit-it3c.log`, `unit-it3c-noir-rerun.log`).

NEXT (iteration 4, in order):
1. See Ohm's daze live: a `--bot=boss --ghost=ohm` (or the bot pressing Ohm's bolt when King is in
   a tell) and a 48 px/m clip; check Kerf / Dent / Tonnage on King and the gang in one clip each.
2. The human-like bot (reads ~70 %, own RNG stream) + an n-seed runner (`--seed=1..5`, servo's
   flag) -> `evidence/king/boss-numbers.json`: time to kill, damage taken, per-attack hit rates for
   dodging / human / standing. Then tune (the stander dies once; the dodger takes only 30).
3. The wreck as cover in phase 3 (a generic BossMoves prop hook -> arena blockers).
4. 48 px/m clips per attack: the dev arena's noir print inks the robot rigs at 48: try `--look`
   options or film at 32 with a 2x crop; per phase 32 px/m real-time clips (`--phase=N`).
5. Gang on the car's sides (target: hanging off the sides in gold chains), plum drapes on the car.
6. The Windows exe export for the owner by 08:30 (int-day recipe in docs/decisions.md) and REPORT
   with Calls for the owner: gold swap vs steel (`KingRigs.GOLD_SWAP`), leap_m 6 vs 0 (the
   on-the-spot slam), decree buff on/off.

### FYI to servo (21:20): framework changes since 745ce3cf (your next merge brings them)
- REQUEST 4 taken verbatim (d86e36fe, your 567ef26b cherry-picked; boss_moves.gd = your c37ea648).
- bosses.json attack fields (optional, schema in `evidence/king/write_bosses.mjs`): `leap_m` (a
  circle's ring tracks Rivet up to leap_m out and the boss hops onto it through the lock) and
  `buff_adds {damage_k, speed_k, s}` (the active window buffs the standing adds: BossAdds.buff,
  `BossAdds.damage_k/speed_k/buffed(tick)`, `BossMoves.speed_k` scales the default walk). Your row
  needs nothing; your drones could take a buff from a horn if you want one.
- `BossFight.daze(ticks)` / `dazed` / `DAZE_MAX` 36: a new FightAreas stun on the boss body (Ohm,
  the electro gun) cancels a tell and dazes; BossHook reads it each tick (`_stun_check`). In a
  daze `step()` returns after `moves.tick()` (your late hazards keep running).
- `BossMusic` (stinger + boss_loop on engage, loop off + stinger on defeat) and `BossCam`
  (`--boss-cam`) are attached by `BossView.attach` for every boss; `BossHook.rivet_pos()`.
- Shared rig: print_part swap 5 (gold leaf), `BodyPlan.arm_swap` (default -1: nothing changes).

### 21:22: court clip at 32 px/m looked at
`gtai-masters/n7/king/king_phase2_court_decree_32ppm_it3.mp4` (30 s, --phase=2, dodging bot, 0
script errors; frames.json 13). The decree's rings and the buffed gang's danger rings read.
FOUND, NOT fixed: the stalled car pivots on the spot to aim at Rivet (the body's facing tracks
him in the court). Fix first in iteration 4: KingMoves keeps the stall facing at phase_entered(1);
KingBodyView draws the car on it and swivels only the hood cannon to `fight.aim`; KingBeats.king_px
and KingRigs place the throne on the stall facing.
NEXT (iteration 4): 0. that fix; then the list above (1. Ohm's daze live, 2. human-like bot +
seeds, 3. wreck as cover, 4. 48 px/m clips, 5. gang on the car's sides, 6. exe + REPORT).

### 21:25: the stalled car holds, the cannon swivels (fixed after all)
KingMoves keeps `stall_facing` at the court; `KingBeats.car_dir` gives the car's heading (the
body's while it drives, the stall's after); KingBodyView draws the car on it and swivels only the
hood cannon to `fight.aim`; the throne and the step-down follow the car's heading. Looked at
`evidence/king/shots/court_car_holds_cannon_swivels_32ppm.png` (court, t900 | t1500: same heading,
cannon turned to the cone). test_king* 5/5, test_boss* 25/25; scenarios 52 ran / 0 failed at
fbe2d97f (`scenarios-it3b.log`). NEXT item 0 is done; NEXT starts at item 1.
