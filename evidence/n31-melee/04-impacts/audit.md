# Impact audit: what is drawn and felt per weapon and case (n31 04a, Godot-free)

Owner: "Animations from weapons/projectiles and impact on enemies are inconsistent - some detailed and well thought, some on surface done without care."

Read from code and data at HEAD `6fe9a052c`; nothing launched. Score: 0 nothing distinct, 1 a stop or kick only, 2 a drawn mark or a class-specific feel, 3 reference (claw rake marks for melee, plasma rifle scorch for guns, saw grind for kills). Wheel list: `project/data/tables/gauntlet_bonuses.json` ids `weapon_*` (chainsaw, electro_baton, flamethrower, gatling, gloria, hand_cannon, katana, machine_pistol, pistol, plasma_rifle, plasma_sword, rocket_launcher) plus the claw from the start; the shotgun is `enabled:false` so off the wheel but audited as asked. The gauntlet view is a `CollectCallView` (`project/features/gauntlet/gauntlet_view.gd:2`), so FxView marks, MeleeFeel, ReactLink and ShieldSparks all apply there.

## Scores (0-3)

| weapon | hit human | hit robot | hit shield | kill today (generic) | kill with `--kill-feed` (signature row) |
|---|---|---|---|---|---|
| claw | 3 | 2 | 2 | 1 | 3 |
| chainsaw | 1 | 0 | 1 | 1 | 3 |
| electro_baton | 2 | 2 | 1 | 1 | 3 |
| katana | 1 | 1 | 2 | 1 | 3 |
| plasma_sword | 1 | 1 | 1 | 1 | 3 |
| pistol | 1 | 1 | 2 | 1 | 2 |
| machine_pistol | 1 | 1 | 2 | 1 | 2 |
| gloria | 1 | 1 | 2 | 1 | 2 |
| gatling | 1 | 1 | 2 | 1 | 3 |
| hand_cannon | 2 | 2 | 2 | 1 | 2 |
| plasma_rifle | 3 | 2 | 2 | 1 | 3 |
| flamethrower | 2 | 1 | 1 | 2 | 3 |
| rocket_launcher | 2 | 2 | 1 | 2 | 3 |
| shotgun | 0 | 0 | 0 | 0 | 0 |

Kill-feed scores for the gun rows and the baton are estimated from the row data (style, spray, pieces, hitstop), not from a film; the melee rows 03p2 proved at 100% (`evidence/n31-melee/03-fatal/table.md`). That table only ran melee weapons; `signature_kills.gd:51` gives any human killed by a weapon with a row its signature, so the gun rows play too under the feed (the table's assault-rifle and ally lines have no row, hence generic).

## Shared facts that decide most cells

- **Blood is one weapon-agnostic set.** A non-lethal hit on a human draws no blood at all: `CombatBlood` reacts only to kills (`project/features/fx/combat_blood.gd:164-181`) and to Rivet's own hits (`:190`). A kill sprays one `kill` kind along the blow whatever the weapon (`:213-225`, blood_fx.json game.death_hit). A robot kill leaks one `robot_hit` oil splash (`:183`); a living robot is hit with nothing.
- **A hit on a robot is a hit on a human minus blood.** Guns: `gun_fx_rounds.gd:53` makes every hostile a BODY (ink burst 0.12 m, 4 ticks). Melee: `arena_robot_rigs.gd:100-105` shoves and flashes the rig. `blood_fx.json` already has a `thug_hit` row (the robot thug's spark-and-oil spray, 10 drops in 70 deg) that only `dev/enemy_ai/enemy_rig_fight.gd:20` and a unit test read: it is not wired to the gauntlet.
- **Shield: only the guns' blocks and melee `blocked` get sparks.** `ShieldSparks` (`shield_sparks.gd:12-41`) fires on `ReactLink.blocked` (a `shield` family). The chainsaw, baton and plasma sword go `through` (`melee_weapons.json:76,164,333`), so nothing is drawn on the slab for them.
- **`melee_marks.json` has rows for claw (rake), plasma sword (deflect of a round only), saw (kill only) and the swing pullback**: no hit mark for katana, plasma sword, chainsaw or baton.
- **Stop/shake/kick (`hit_feel.json` weapons rows; camera.json ticks: melee_hit 4, kill 6, boss_hit 8, rivet_hit 3, slice_hit 2)**: chainsaw none, kick 1/4; claw rivet_hit 3, kick 2/6; baton melee_hit 4, kick 2.5/7; katana and plasma sword melee_hit 4, kick 3/8; no melee weapon has a shake. Every kill adds the kill stop 6 (`hit_feel.json` kill_hitstop) with no weapon difference.
- **Today's gauntlet kill** is generic: `human_reactions.json` death_map (melee -> death_melee, light/medium/heavy -> death_bullet, blast -> death_blast, burn -> death_burn) drawn by the rig (DeathPipe, foe cast view) with the one blood kill spray. Under `--kill-feed` the signature row replaces it for humans (robots: the baton shutdown only).

## Evidence per cell

### claw (melee; wheel: hands (default, always owned))
- **hit human** [3]: ClawMarks: three cream/ink rakes across the victim on the hit frame, full length held by the stop, fade 10 ticks (claw_marks.gd:44-56, project/data/tables/melee_marks.json claw; drawn by FxView, boot/collect_call/view/fx_view.gd:73, which the gauntlet view extends: gauntlet_view.gd:2). Stop rivet_hit 3 ticks, kick 2 px/6, no shake (project/data/tables/hit_feel.json:293). Reaction melee = spin (side) or fold (front) (project/data/tables/human_reactions.json map.melee). No blood on a wound: CombatBlood only bleeds a kill (combat_blood.gd:164-181).
- **hit robot** [2]: Same rakes (keyed by weapon, not victim) and stop; the robot rig shoves and flashes (arena_robot_rigs.gd:100-105). No sparks, no oil: oil is thrown only on the kill (combat_blood.gd:183).
- **hit shield** [2]: vs_shield blocked (project/data/tables/rivet_melee.json:65): the slab takes it, the shield recoil family plays and ShieldSparks throws white sparks off the face (react_link.gd:130-135, shield_sparks.gd:12-24). The rake mark draws only if CombatArena.wounded fires (unverified on film).
- **kill, today (generic)** [1]: generic death_melee + kill stop 6 ticks (camera.json hitstops kill; fx_triggers rivet_kill) + red spurt/pool (combat_blood.gd:213-225).
- **kill, `--kill-feed` row** [3]: claw_rake_kill (style rake, own cells + fall, variants x5; project/data/tables/signature_kills.json); proof table evidence/n31-melee/03-fatal/table.md: 100% own variant.

### chainsaw (melee; wheel: weapon_chainsaw)
- **hit human** [1]: No mark: SawMarks live only in KillSplitFx (kill_split_fx.gd:121,166), never on a wound. hitstop empty, shake empty, kick 1 px/4 once per strike (the grind lands every tick, MeleeWound gap) (project/data/tables/hit_feel.json:285-291). Reaction spin/fold; no blood on a wound.
- **hit robot** [0]: Identical to the human case minus blood: nothing metal (no sparks, no oil) while the saw grinds a machine.
- **hit shield** [1]: vs_shield through (project/data/tables/melee_weapons.json:76), shield_break 40 ticks (project/data/tables/melee_weapons.json:52): the saw goes through the slab; nothing drawn for the shield breaking.
- **kill, today (generic)** [1]: generic death_melee + kill stop 6 + red spurt.
- **kill, `--kill-feed` row** [3]: chainsaw_grind: grind 54 ticks, saw_chunks 8, spray 24 at 70 deg, SawMarks release burst 1.2 m, held-body judder 0.06 m (project/data/tables/signature_kills.json, project/data/tables/melee_marks.json saw). The reference 3; 138/138 in the proof table.

### electro_baton (melee; wheel: weapon_electro_baton)
- **hit human** [2]: Stop melee_hit 4 ticks, kick 2.5 px/7 (project/data/tables/hit_feel.json:312); a stunned body gets ShockJolt arcs following the torso (shock_arcs_view.gd:98-101, StunCrowd.electric); stun 30/90 ticks (project/data/tables/melee_weapons.json baton hits). No mark of its own. No shake.
- **hit robot** [2]: machine_stun_ticks 150 (project/data/tables/melee_weapons.json:134) with the same arcs on the stunned chassis; no sparks at the contact point.
- **hit shield** [1]: vs_shield through (project/data/tables/melee_weapons.json:164): arcs on the bearer, nothing on the slab.
- **kill, today (generic)** [1]: generic death_melee + kill stop 6; on a robot the standard robot death.
- **kill, `--kill-feed` row** [3]: baton_overload (style cook, own variants x5; humans) and electric_shutdown:<id> (robots, RobotShutdownFx) (project/data/tables/signature_kills.json); 03-fatal table 100% own variant. Art not re-viewed (Godot-free).

### katana (melee; wheel: weapon_katana)
- **hit human** [1]: NO impact mark (melee_marks.json has claw, deflect, saw, swing only). Stop melee_hit 4, kick 3 px/8, no shake (project/data/tables/hit_feel.json:320); reaction spin/fold; no blood on a wound. Only the swing arc (rig) and the stop say a blade landed.
- **hit robot** [1]: As the human case minus blood; nothing metallic (no spark where a blade meets a chassis).
- **hit shield** [2]: vs_shield blocked (project/data/tables/melee_weapons.json:249): shield recoil + ShieldSparks; the same sparks every gun gets.
- **kill, today (generic)** [1]: generic death_melee + kill stop 6 + red spurt.
- **kill, `--kill-feed` row** [3]: katana_split: cut_deg 55, streak 1 m x 0.06, stop 6, own halves x5 variants (project/data/tables/signature_kills.json).

### plasma_sword (melee; wheel: weapon_plasma_sword)
- **hit human** [1]: NO hit mark and no scorch for the blade (DeflectMarks fires only on a bat of a round: deflect_marks.gd, project/data/tables/melee_marks.json deflect). Same row as the katana: stop melee_hit 4, kick 3/8 (project/data/tables/hit_feel.json:344).
- **hit robot** [1]: As the human case; no scorch, no spark on metal.
- **hit shield** [1]: vs_shield through (project/data/tables/melee_weapons.json:333): nothing drawn on the slab.
- **kill, today (generic)** [1]: generic death_melee + kill stop 6.
- **kill, `--kill-feed` row** [3]: plasma_sword_split (own halves x5 variants; project/data/tables/signature_kills.json).

### pistol (gun; wheel: weapon_pistol) [gun_fx.json pistol: casing .24, mag_drop, spikes 3, smoke 1.4]
- **hit human** [1]: BODY hit: ink burst 0.12 m for 4 ticks and the shot trail (pistol trail_ticks) (gun_fx_marks.gd:9-15,66-67; gun_fx_rounds.gd:53,64). Class light: flash 4, kick 1 px, no stop, no shake, flinch (project/data/tables/hit_feel.json classes.light). No blood on a wound. Muzzle star k1.6 (project/data/tables/hit_feel.json:272).
- **hit robot** [1]: Same BODY ink burst as a human (gun_fx_rounds.gd:53 takes every hostile): a robot is not drawn differently; oil only on the kill (combat_blood.gd:183).
- **hit shield** [2]: METAL (gun_fx_rounds.gd:57 via GunFx.shield_test, react_link.gd:154-166) + ShieldSparks: white sparks fanned back off the slab, shield recoil (shield_sparks.gd:12-41).
- **kill, today (generic)** [1]: generic death_bullet + kill stop 6 + spurt.
- **kill, `--kill-feed` row** [2]: pistol_snap (style snap, cells, track; project/data/tables/signature_kills.json).

### machine_pistol (gun; wheel: weapon_machine_pistol) [gun_fx.json machine_pistol: spikes 4, casing .17]
- **hit human** [1]: BODY hit: ink burst 0.12 m for 4 ticks and the shot trail (machine_pistol trail_ticks) (gun_fx_marks.gd:9-15,66-67; gun_fx_rounds.gd:53,64). Class light: flash 4, kick 1 px, no stop, no shake, flinch (project/data/tables/hit_feel.json classes.light). No blood on a wound. kick 0.6 px, quieter than the pistol.
- **hit robot** [1]: Same BODY ink burst as a human (gun_fx_rounds.gd:53 takes every hostile): a robot is not drawn differently; oil only on the kill (combat_blood.gd:183).
- **hit shield** [2]: METAL (gun_fx_rounds.gd:57 via GunFx.shield_test, react_link.gd:154-166) + ShieldSparks: white sparks fanned back off the slab, shield recoil (shield_sparks.gd:12-41).
- **kill, today (generic)** [1]: generic death_bullet + kill stop 6.
- **kill, `--kill-feed` row** [2]: smg_stitch (style stitch; project/data/tables/signature_kills.json).

### gloria (gun; wheel: weapon_gloria) [gun_fx.json: none (default row)]
- **hit human** [1]: BODY hit: ink burst 0.12 m for 4 ticks and the shot trail (gloria trail_ticks) (gun_fx_marks.gd:9-15,66-67; gun_fx_rounds.gd:53,64). Class light: flash 4, kick 1 px, no stop, no shake, flinch (project/data/tables/hit_feel.json classes.light). No blood on a wound. Fire kick 1.5 px; no gun_fx.json row (default: smoke only).
- **hit robot** [1]: Same BODY ink burst as a human (gun_fx_rounds.gd:53 takes every hostile): a robot is not drawn differently; oil only on the kill (combat_blood.gd:183).
- **hit shield** [2]: METAL (gun_fx_rounds.gd:57 via GunFx.shield_test, react_link.gd:154-166) + ShieldSparks: white sparks fanned back off the slab, shield recoil (shield_sparks.gd:12-41).
- **kill, today (generic)** [1]: generic death_bullet + kill stop 6.
- **kill, `--kill-feed` row** [2]: nail_pin (style pin: pins the body; project/data/tables/signature_kills.json).

### gatling (gun; wheel: weapon_gatling) [gun_fx.json gatling: spikes 6, casing .17, smoke .6]
- **hit human** [1]: BODY hit: ink burst 0.12 m for 4 ticks and the shot trail (gatling trail_ticks) (gun_fx_marks.gd:9-15,66-67; gun_fx_rounds.gd:53,64). Class light: flash 4, kick 1 px, no stop, no shake, flinch (project/data/tables/hit_feel.json classes.light). No blood on a wound. Medium class by data but hitstop and shake overridden empty (project/data/tables/hit_feel.json:221): a rumble only.
- **hit robot** [1]: Same BODY ink burst as a human (gun_fx_rounds.gd:53 takes every hostile): a robot is not drawn differently; oil only on the kill (combat_blood.gd:183).
- **hit shield** [2]: METAL (gun_fx_rounds.gd:57 via GunFx.shield_test, react_link.gd:154-166) + ShieldSparks: white sparks fanned back off the slab, shield recoil (shield_sparks.gd:12-41).
- **kill, today (generic)** [1]: generic death_bullet + kill stop 6.
- **kill, `--kill-feed` row** [3]: gatling_shred (style shred, spray 28 at 50 deg; project/data/tables/signature_kills.json).

### hand_cannon (gun; wheel: weapon_hand_cannon) [gun_fx.json hand_cannon: fat 3, ring_m 1.2, dump 6, smoke 2.4]
- **hit human** [2]: BODY ink burst + trail 4 ticks; class heavy: stop melee_hit 4, hit shake 4 px/10, kick 5 px/10, stagger 24 ticks (project/data/tables/hit_feel.json:239, classes.heavy). Ring 1.2 m at the muzzle (gun_fx.json). No blood on a wound.
- **hit robot** [2]: Same BODY ink burst as a human (gun_fx_rounds.gd:53 takes every hostile): a robot is not drawn differently; oil only on the kill (combat_blood.gd:183). The heavy stop and shake still land.
- **hit shield** [2]: METAL (gun_fx_rounds.gd:57 via GunFx.shield_test, react_link.gd:154-166) + ShieldSparks: white sparks fanned back off the slab, shield recoil (shield_sparks.gd:12-41).
- **kill, today (generic)** [1]: generic death_bullet (heavy) + kill stop 6.
- **kill, `--kill-feed` row** [2]: hand_cannon_blowback (style blowback, wound_m 0.2, stop 3; project/data/tables/signature_kills.json).

### plasma_rifle (gun; wheel: weapon_plasma_rifle) [gun_fx.json plasma_rifle: scorch, pop, bolt_px 13]
- **hit human** [3]: Reference. Bolt scorch ring + pop on the body (gun_fx.json plasma_rifle scorch, pop_*; gun_fx_marks.gd:89-108), PlasmaScorchView burnt marks on the body, 120-tick glow + smoke 150 ticks (plasma_scorch_view.gd:14-19, react_link.gd:139-148), own heavy stagger family (human_reactions weapon_wound). Medium class: stop rivet_hit 3, gunfire shake 1.5 px.
- **hit robot** [2]: Scorch ring + pop draw (they key off the weapon); PlasmaScorchView marks only on human rigs (ReactLink); no oil.
- **hit shield** [2]: METAL + sparks; the bearer still staggers (react_link.gd:139-148).
- **kill, today (generic)** [1]: generic death_bullet + kill stop 6.
- **kill, `--kill-feed` row** [3]: plasma_hole (style hole, hole_up 0.4 m, scorch 0.3 m; project/data/tables/signature_kills.json).

### flamethrower (gun; wheel: weapon_flamethrower) [gun_fx.json: default row]
- **hit human** [2]: Class burn: no stop, no kick, no shake; the burning reaction (flails 2.5 s) and a char tint (human_reactions map.burn; DRY_KILLS blood_victims.gd:9-12). Ignite whump kick + flare (project/data/tables/hit_feel.json:210). Flame and patch drawn by FightAreasArt.
- **hit robot** [1]: Burn class reaction none (project/data/tables/hit_feel.json classes.burn); the fire patch is all there is.
- **hit shield** [1]: No shield case drawn: the cone passes round the slab; nothing distinct.
- **kill, today (generic)** [2]: death_burn + kill stop 6, dry (no red).
- **kill, `--kill-feed` row** [3]: burn_char (any fire death, style burn, ash .62 m, crumble 75 ticks; project/data/tables/signature_kills.json; signature_kills.gd:54-55).

### rocket_launcher (gun; wheel: weapon_rocket_launcher) [gun_fx.json: default row (FightAreasArt draws the rocket)]
- **hit human** [2]: Class blast: boss_hit stop 8, explosion shake 10 px/24, kick 7, knockdown 60 ticks (project/data/tables/hit_feel.json:280, classes.blast); explosion + smoke + debris. Splash 3.5 m.
- **hit robot** [2]: As the human case (blast class, knockdown).
- **hit shield** [1]: Splash passes the slab: no distinct case.
- **kill, today (generic)** [2]: death_blast + kill stop 6.
- **kill, `--kill-feed` row** [3]: rocket_gib (style gib, spray 18, scorch 1.3 m; project/data/tables/signature_kills.json).

### shotgun (gun; wheel: not on the wheel (enabled:false)) [gun_fx.json: none]
- **hit human** [0]: 8 pellets (weapons.json shotgun enabled:false): would take the light class; no hit_feel row, no gun_fx row, no signature row. Not buyable.
- **hit robot** [0]: -
- **hit shield** [0]: -
- **kill, today (generic)** [0]: generic death_bullet
- **kill, `--kill-feed` row** [0]: none (no row in signature_kills.json)

## Lift list (worst first, in the order the gauntlet meets them)

| rank | where it meets the player | score | smallest change and owner |
|---|---|---|---|
| 1 | katana, plasma sword, chainsaw, baton: hit on a patrol/riot/SWAT cop (wave 1 onward; every melee pick except the claw) | 1 | Add rows `katana`, `plasma_sword`, `chainsaw`, `electro_baton` to `melee_marks.json` and read them in `claw_marks.gd` instead of the hardcoded `WEAPON = &"claw"` (`claw_marks.gd:13,44-55`): one cream-and-ink slash streak (blades), a short spark stroke at the bite (saw), a crack-star (baton), reusing `KillSlashStreak` (streak 1 m x 0.06, already in the katana kill). Owner: `project/features/combat/react/claw_marks.gd` + `project/data/tables/melee_marks.json` (lane-owned). |
| 2 | Hit on a robot, any weapon (robot_thug from wave 2, robot_gunner wave 3) | 0-1 | Throw the existing `thug_hit` sparks (`blood_fx.json`) on a wound of an id in `blood.victims.robot_ids`, the call `ShieldSparks.throw` already makes. Owner: a new `project/features/combat/react/robot_hit_sparks.gd` beside `shield_sparks.gd`, wired next to `project/features/arena/arena_rigs.gd:71`. combat_blood.gd is at its size stop. NEED if arena_rigs is another lane's. |
| 3 | Chainsaw hit (any victim): no stop, no shake, 1 px kick, nothing drawn on a wound | 1 (0 on a robot) | Data only: `hit_feel.json` chainsaw row `kick_px` 1 -> 2.5 and `shake: gunfire` (1.5 px, 4 ticks) once per strike (MeleeWound's gap already limits it to one per strike; no stop, the grind must not stutter); the bite spark stroke comes from item 1's row. Owner: `project/data/tables/hit_feel.json` (lane-owned). |
| 4 | Chainsaw/baton/plasma sword on a riot cop's shield (wave 1-3) | 1 | `vs_shield: through` draws nothing on the slab. Throw `ShieldSparks.throw` at the face when the blow passes the slab (`MeleeWound.past_slab`, react_link.gd:130-135) on the strike tick. Owner: `project/features/combat/react/react_link.gd` + `shield_sparks.gd` (confirm the react folder is melee's to touch). |
| 5 | Pistol, machine pistol, gloria, gatling hit on a cop (wave 1 guns): a 4-tick ink dot, 1 px kick, no blood | 1 | Smallest: `hit_feel.json` classes.light flash 4 -> 6 and kick_px 1 -> 2 (the assault rifle row already did exactly this: kick_px 2, hit_feel.json weapons assault_rifle); a 3-drop spurt along the round for a body hit needs `gun_fx_marks.gd`. Owner: `hit_feel.json` (lane-owned) / `gun_fx_marks.gd`. |
| 6 | Kill today, every weapon (generic death + one blood spray) | 1 | Make `--kill-feed` the gauntlet default after 03p2's digest re-pin: lifts every melee kill to 3 and the gun rows to 2-3. Owner: `project/features/gauntlet/gauntlet_session.gd:35` + the re-pinned digests. |
| 7 | Flamethrower and rocket on a shield or a robot | 1 | A burn mark / blast ring on the slab and a scorch on a robot chassis: reuse `fight_scorch_art.gd`. Owner: `project/features/combat/weapons/fight_scorch_art.gd`. |
| 8 | The plasma sword leaves no scorch though the plasma rifle does | 1 | A `weapon_wound` row for plasma_sword in `human_reactions.json` plus `PlasmaScorchView.mark` on its wound (react_link.gd:139-148). Owner: `human_reactions.json` / `plasma_scorch_view.gd`. |

Wave order (`project/data/tables/enemy_waves.json`, steep/standard): w1 patrol cops + riot cops; w2 SWAT + riot cops + robot thug; w3 robots + SWAT + riot cops. Lifts 1, 3, 5, 6 are met in wave 1.

## Caveats
- Godot-free: no film re-viewed; hit-cell scores come from what the code draws, the kill-feed scores for gun and baton rows from the row data. `claw_marks.gd` draws on `wounded`/`kill_landed` (shield-blocked claw hits unverified). `melee_weapons.json` and `rivet_melee.json` carry uncommitted edits from builder 02p3 (cited line numbers are of the working tree: chainsaw :76, baton :164, katana :249, plasma sword :333, claw rivet_melee :65).
- Verified: the shotgun has no signature row (no `shotgun` weapon in `signature_kills.json`); katana and plasma sword have no impact mark; the chainsaw has no hit-stop or shake and its SawMarks live only in KillSplitFx; blood is one weapon-agnostic set.
