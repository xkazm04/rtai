# Wave cast audit against the patrol cop

Reviewed 2026-11-22. The gauntlet has ten spawnable archetypes and the prologue adds two officers. The first review covered the equipped lancer, door carrier and clamshell cards and the original walker renderer. The [after table](#after-the-four-redraws) records the four completed redraws. The patrol reference measured 43 px and Rivet 77 px in the 32 px/m, 70-degree lineup.

## Which renderer receives the spawn

* **Gauntlet.** `GauntletComposer` consumes the roster, including the production contractor. `gauntlet.json` excludes the sergeant and warden. `GauntletLiveWave.spawn` uses the street squad's `spawn_member`, which forwards to `ArenaSquad.spawn_member` and the arena guard factory. `ArenaRigs` builds a feed for `CharacterRigs`, assigns `ArenaSquadLooks.look`, and attaches the robot, ordnance and shadow views. The human pool selects up to 16 full rigs within 14 m of the group focus. The focus is the centre of a box around Rivet, his look-ahead and nearby hostiles.
* **Near humans.** A full `CutRig` can *display* a whole-figure sheet. `RigHeadCard` supplies the head key. `StreetView` calls `StreetWalkerCards.step`, and `StreetCopWalk` maps cap, riot helmet or SWAT helmet to the armed walk for the current pitch. The card hides the other rig parts. The aim and shoot flags keep that card. Strike, throw and reload can expose the articulated parts. Human wounds and falls select `StreetWalkerHit`, `StreetHitClass` and `StreetWalkerFall` by family and blow. A view without matching card art can expose the underlying rig.
* **Far humans.** `ArenaWaveCards` can draw a living off-pool cop on the same armed sheet, tracking distance, with a flat fallback. The default `ArenaRigs.attach` subscribes it to `_pit.standing`. Live gauntlet spawns enter the arena hostiles and squad membership. A 26 m probe of patrol ID 1 yielded **full rig false, visible fallback false**. In the prologue the additional subscription to `stage.arena.hostiles` yielded **full rig false, visible fallback true**. The close rig's full wound/death coverage does not carry over to the living-only far card.
* **Prologue.** `PrologueGame` binds its own view and the same `ArenaRigs`. The opening patrol includes Dale Winnick (hair and megaphone), ordinary officers and the catcher. The formation adds shield cops, riflemen and Sergeant Mulroney. `PrologueProps` attaches to actual near limbs or card anchors, and the formation adds the shield/rifle and commander dress. `PrologueBodies` owns the staged dead. The other seven gauntlet-only IDs do not occur in these encounters.
* **Quest cards.** `boot/collect_call/view/cast_view.gd` uses `StreetQuestCards` for the original Collect Call quest's heat cop. It chooses a standing patrol strip or the unarmed four-frame walk, anchored at .985 with width 1.15 m. Quest guards can use the contractor's own art through `QuestGuardCast`, which excludes `ArenaStage`. Neither wave nor prologue patrol comes from that quest draw path. Finding a contractor PNG on disk therefore says little about the wave contractor.
* **Machines.** `ArenaRobotRigs.takes` diverts machine fighters from the human pool. Each gets its own `CutRig` from `FoeLooks.robot_plan(id, ThugPlan.build(), rig)`. The thug supplies the gunmetal parts, head and gait. An armed machine gets aim flags. A living hit applies a 40-strength directional shove, and `DeathPipe.kill_robot` drives power-down. The thug has registered fall sheets at both pitches. `FoeOrdnanceView` adds the equipment and mounted views detailed below.

## Measured roster and acceptance on 2026-11-22

The [checklist](cast-checklist.md) defines each gate. **P** = PASS for the equipped character in the audited path. **F** = FAIL for acceptance, including missing evidence. The table separates identity from the individual checks. An existing cue can pass even when its source costume fails. Native pitch coverage here means the standing and moving body and major gear match the camera at both pitches. The hit column separately records the available reaction.

The original roster measurements use the front three-quarter **body and gear** at 32 px/m. The replacement card rows give their own in-game measurements. The first pair is screen pixels (70° / 55°). The pair in parentheses is the same projection divided by 32, in screen-equivalent metres. A helmet, gun, pole or ground footprint can determine the bounds. Rivet's design height is 1.65 m and the patrol reference is 1.70 m. The capture measures neither a collider nor an upright anatomical height.

| Archetype | What spawns and what draws it | Height px (screen m), 70° / 55° | Identity | Walk | Attack + tell | Hit | Fall | Facings | Grid | Pitches | Scale | Ink | Palette | Cut | Feet | Shadow | Provenance |
|---|---|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| patrol_cop | Wave and prologue. Own navy patrol cap, armed-walk, wound and fall cards over the cop rig. | 43 / 45 (1.34 / 1.41) | P | P | F | P | P | P | P | P | P | P | P | P | F | P | F |
| riot_cop | Wave and prologue. Own shield/helmet armed walk, hit and fall. The baton windup releases the card to the rig. The prologue adds a braced shield line. | 53 / 55 (1.66 / 1.72) | P | P | P | P | P | P | P | P | P | P | P | F | F | P | F |
| swat | Wave and prologue. Own helmeted armed walk, hit and fall. The drawn weapon is a pistol. Prologue riflemen get a rifle overlay. | 52 / 54 (1.63 / 1.69) | F | P | F | P | P | P | P | P | P | P | P | P | F | P | F |
| robot_thug | Wave. Own articulated thug body and claw, directional shove and thug power-down/fall. Dark joint hatching becomes dense at 64 px/m. | 60 / 62 (1.88 / 1.94) | P | P | P | P | P | P | F | F | P | F | P | F | P | F | F |
| robot_gunner | Wave. Same thug parts, armed aim feed instead of the claw windup. Uses the ordinary squad ranged trigger. No dedicated cannon charge, wound or collapse silhouette established. | 65 / 61 (2.03 / 1.91) | F | P | F | F | F | P | F | F | P | F | P | F | P | F | F |
| contractor | Wave. Always patrol look 5. Its quest and dock sheets do not reach this spawn. It moves and falls as a blue pistol cop while the squad fires rifle rounds. | 57 / 59 (1.78 / 1.84) | F | F | F | F | F | P | P | P | P | P | F | P | F | P | F |
| rocket_trooper | Lancer. Own five-facing armed walk, shoulder/lock/discharge/recover, hit and fall. Both films show a nonfatal hit before death. | Prone at 64 px/m and 70 degrees, 120.8 px versus patrol 121.3 px | P | P | P | P | P | P | P | P | P | P | P | P | F | P | P |
| sentry_turret | Clamshell. Stationary apron, rotating dome, barrel charge, flash, cooling, hit and exposed-cage wreck. The live aim line remains visible. | Plate 1.41 m wide, depth 1.38 / 1.43 m after pitch correction. Dome 1.16 / 1.19 m across | P | P | P | P | P | P | P | P | P | P | P | P | P | F | P |
| shield_robot | Door carrier. A card replaces the thug rig. The shove lane stays visible through the plant and lunge. The slab separates from the dead carrier. | Body 2.04 / 1.98 m. Slab 46 / 41 px at 64 px/m against 40.96 px of shove width | P | P | P | P | P | P | P | P | P | P | P | P | F | F | P |
| war_machine | Pile-driver card off. The wave still draws the enlarged thug rig, cannon, louvres and procedural legs. Packed source art alone cannot pass the in-wave checks. | Live placeholder 178 / 168 px (5.56 / 5.25 screen m) | F | F | P | F | F | F | F | F | F | F | P | F | F | F | F |
| sergeant_mulroney | Prologue formation only. ID-selected squad look under `PrologueCommanderDress`'s coat, brass, p70 cap and shotgun. Command cue is visible, personal shotgun releases on cooldown. | 51 / 48 (1.59 / 1.50) | P | F | F | F | F | F | F | F | P | F | P | F | F | P | F |
| appliance_warden | Prologue patrol only. ID-selected cop body, olive dyed overalls, straps, work cap and catch pole. Bare-rig and card branches dress it differently. Living-only dressing loses the catcher's silhouette on death. | 72 / 69 (2.25 / 2.16) | P | F | F | F | F | F | F | F | P | F | P | F | F | P | F |

**How to read the failures.** Patrol and SWAT keep the aimed walk while firing. A `telegraph_s` entry alone does not draw an anticipation on the first squad shot. SWAT's own walk passes as animation, but the equipped wave identity fails the rifle check. The riot's two armed sheets passed the key scan, but its p55 standing strip has one strong green pixel. A machine's procedural turning or planting can pass without a directional card, while its proposed five-facing sheet set is still missing. The feet marks use the moving probe below. The turret keeps a bolted base. The walker also renders procedural legs with its own tick-and-speed phase, so its measured underlying thug feet do not verify the visible pile-driver footfalls. Machine contact shadows did not separate clearly from their feet or base at 32 px/m. Role-specific cut and ink lack clean source-cell or screen evidence on the assembled placeholders. The original shield, walker and turret placeholders failed the screen-size comparison. The current card measurements appear in the table. The warden's extended pole accounts for much of its box.

**Provenance.** The current eight lancer, eight door and six clamshell PNGs each have an exact SHA-256 match in the November ledger. The p70 patrol, riot, SWAT and thug between-fall files still lack exact matches. The audit keeps the planted-foot and contact-shadow failures wherever current equipped footage lacks the corresponding measurement.

**Original rig ground-contact measurements.** With the camera fixed at 32 px/m, 70?, each mobile actor walked right at 2.4 m/s. After warm-up the probe sampled 88 rendered frames. All seven human hosts moved up to **10.24 screen px (0.32 m)** across a single held drawing, so its supporting boot moved by the same amount against the stationary floor. For thug, gunner, shield and walker the visible rig foot sprite moved **0.00 px** during continuous planted intervals (95 foot samples per actor). The walker adds independently posed legs. Reproduce with `GTAI_CAST_STRIDE=1` on the single 32/70 run and read the `stride at 2.4 m/s` lines.

**Stride drawings.** The project's film tool tracks the rightmost boot in the bottom 5% of the profile silhouette. Applied to the two armed contact-to-pass pairs, its measured leftward travel in source pixels is 27.5 and **−41.5** for p70 patrol, versus 48 and 36.5 at p55. Unarmed patrol gives 28.5 and 32 at p70, 41.5 and 33.5 at p55. The negative result flags a change of which boot the landmark finds. It calls for frame-by-frame support-foot inspection before signing off the armed loop. Riot gives 43.5/45.5 and 32.5/27.5, and SWAT gives 44/30 and 47.5/36 at p70 and p55. These are atlas displacements. Ground drift also depends on actor travel while a single drawing is held.

**Original renderer shadow evidence.** In the front three-quarter 32 px/m, 70° exposure, enabling the game shadow darkened 236 pixels by at least 12/255 for patrol and 575 for Rivet. The counts for thug, gunner, turret, shield robot and war machine were 9, 9, 0, 3 and 49. Their bounding boxes kept the same height. The warden's shadow is visible (228 pixels) even though the pole sets the height in both exposures.

## Reproducing the contact sheets

The masters are `gtai-masters/n24/cast/audit_lineup_{32,64}ppm_tilt{70,55}.png`. Each 1920 × 1080 plate shows all twelve archetypes and Rivet, front three-quarter and back. The same foot mark, zoom, full-rig distance and facing are used for every subject. Subjects are photographed individually so population LOD cannot remove a neighbour. Every portrait is an unscaled viewport sample including its game shadow. A second exposure hides the shadow and measures the inclusive bounds against the matte, accepting a change of at least 12/255 in any colour channel. Both pitches use the shipped combo contact shadow.

The masters directory also holds `cast_lineup_source.patch`, the capture scene, its UIDs, and its serial runner in one Git patch. A checkout without the scene can use `git apply --check` followed by `git apply` on that patch. Set `APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/cast` and `GODOT_BIN` to the pinned Godot 4.7.2 console binary. The runner checks that all four outputs are fresh. Run `node tools/art/cast_lineup.mjs C:/Users/kazda/kiro/gtai-masters/n24/cast` from the worktree. For a single plate set `GTAI_CAST_OUT` to that directory, `GTAI_CAST_PPM` to 32 or 64, and `GTAI_CAST_PITCH` to 70 or 55.

```powershell
& $env:GODOT_BIN --rendering-driver d3d12 --windowed --position 0,1440 --resolution 1920x1080 --path project --fixed-fps 60 --quit-after 4000 res://dev/cast/cast_lineup.tscn
```

## After the four redraws

The comparison pairs use tick 60, a 70° camera and 64 px/m. Each left panel disables only the named cast row. Each right panel enables it. Rivet and the patrol cop share the same positions, poses and actor IDs in both exposures. Every PASS links to its evidence.

| Checklist item | Lancer | Door carrier | Clamshell | Pile-driver |
|---|---|---|---|---|
| Identity | [PASS][cast-after-1] | [PASS][cast-after-2] | [PASS][cast-after-3] | [PASS][cast-after-4] |
| Walk or fixed mount | [PASS][cast-after-5] | [PASS][cast-after-6] | [PASS][cast-after-7] | [PASS][cast-after-8] |
| Attack and tell | [PASS][cast-after-5] | [PASS][cast-after-6] | [PASS][cast-after-7] | [PASS][cast-after-8] |
| Hit | [PASS][cast-after-5] | [PASS][cast-after-6] | [PASS][cast-after-7] | [PASS][cast-after-8] |
| Death or wreck | [PASS][cast-after-5] | [PASS][cast-after-6] | [PASS][cast-after-7] | [PASS][cast-after-8] |
| Facings | [PASS][cast-after-9] | [PASS][cast-after-10] | [PASS][cast-after-11] | [PASS][cast-after-12] |
| Grid | [PASS][cast-after-13] | [PASS][cast-after-13] | [PASS][cast-after-13] | [PASS][cast-after-13] |
| Pitches | [PASS][cast-after-14] | [PASS][cast-after-15] | [PASS][cast-after-16] | [PASS][cast-after-17] |
| Scale | [PASS][cast-after-1] | [PASS][cast-after-2] | [PASS][cast-after-3] | [PASS][cast-after-18] |
| Ink | [PASS][cast-after-9] | [PASS][cast-after-10] | [PASS][cast-after-11] | [PASS][cast-after-19] |
| Palette | [PASS][cast-after-20] | [PASS][cast-after-21] | [PASS][cast-after-22] | [PASS][cast-after-23] |
| Cut | [PASS][cast-after-9] | [PASS][cast-after-10] | [PASS][cast-after-11] | [PASS][cast-after-13] |
| Feet | [FAIL · boot slides 10 px][cast-after-26] | [PASS · boot holds at 0 px][cast-after-27] | [PASS][cast-after-24] | [PASS · boot holds at 0 px][cast-after-26] |
| Contact shadow | [PASS][cast-after-9] | FAIL · no separate ground contact demonstrated | FAIL · no separate ground contact demonstrated | [PASS][cast-after-18] |
| Provenance | [PASS][cast-after-13] | [PASS][cast-after-13] | [PASS][cast-after-13] | [PASS][cast-after-13] |

### Standing scale and ground contact

Inclusive body-and-gear bounds come from the 64 px/m front three-quarter standing exposure. The shadow was hidden and the walker was then hidden for a background subtraction at the same position. The threshold is 12/255 in any channel. Rivet's design height is 1.65 m. His shipped visual multiplier is visible in each plate.

| Pitch | Walker body | Drawn height | Visible shadow pixels |
|---|---:|---:|---:|
| 70° | 155 px | 2.42 m | 4243 |
| 55° | 158 px | 2.47 m | 4535 |

The walker uses the patrol facing order. The cell boards contain all 16 action rows in all eight directions at both pitches and zooms. The foot test follows motion across a held cell and the following contact. The two live pile-driver films use the arena's own cannon and stomp decisions. The cast film sets health only in the capture process.

The fixed camera tracks each walk at 0.84 m/s and 32 px/m. The lancer's boot moved 10 px per held drawing. The door carrier now holds its ground point through a walk cell and advances when the drawing changes. Across four complete holds, its boot moved 0 px at each of the three ink thresholds (100, 125 and 145), down from 11 px. The pile-driver held at 0 px in the earlier [sole track][cast-after-26]. Its [unit test][cast-after-25] checks that the next contact advances. The 64 px/m shadow-off exposure measured 0 separate shadow pixels for both the door carrier and the clamshell in both facings. The clamshell's locomotion check follows the fixed apron through the rotating sweep.

[cast-after-1]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/lancer_before_after_64.png>
[cast-after-2]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/door_before_after_64.png>
[cast-after-3]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/clamshell_before_after_64.png>
[cast-after-4]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/pile_before_after_64.png>
[cast-after-5]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/lancer_wave_32.mp4>
[cast-after-6]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/door_wave_32.mp4>
[cast-after-7]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/clamshell_wave_32.mp4>
[cast-after-8]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/pile_wave_32.mp4>
[cast-after-9]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/lancer_64ppm_tilt70.png>
[cast-after-10]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/door_64ppm_tilt70.png>
[cast-after-11]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/clamshell_64ppm_tilt70.png>
[cast-after-12]: <C:/Users/kazda/kiro/gtai-art/foes-n24/05-takes/cells_64_70.png>
[cast-after-13]: <C:/Users/kazda/kiro/gtai-art/foes-n24/05-art-metrics.log>
[cast-after-14]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/lancer_32ppm_tilt55.png>
[cast-after-15]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/door_32ppm_tilt55.png>
[cast-after-16]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/clamshell_32ppm_tilt55.png>
[cast-after-17]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/pile_32ppm_tilt55.png>
[cast-after-18]: <C:/Users/kazda/kiro/gtai-art/foes-n24/05-scale.json>
[cast-after-19]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/pile_64ppm_tilt70.png>
[cast-after-20]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/lancer_32ppm_tilt70.png>
[cast-after-21]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/door_32ppm_tilt70.png>
[cast-after-22]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/clamshell_32ppm_tilt70.png>
[cast-after-23]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/pile_32ppm_tilt70.png>
[cast-after-24]: <C:/Users/kazda/kiro/gtai-masters/n24/cast/clamshell_close_64.mp4>
[cast-after-25]: <../../project/tests/unit/test_cast_war_machine.gd>
[cast-after-26]: <C:/Users/kazda/kiro/gtai-art/foes-n24/05-sole-track.json>
[cast-after-27]: <C:/Users/kazda/kiro/gtai-art/foes-n24/06-door-sole.json>

## Planted feet, n26

The fixed-camera take samples the actual equipped wave sprites and the two prologue officers after each rendered frame at 60 Hz. Each column gives **maximum sole travel / maximum body jump**, in screen pixels at 32 px/m. A check means contact stayed within 2 px and the largest consecutive body jump stayed within 12 px. The bolted apron has a zero-travel limit. An em dash means that take has yet to run. U means a sole could not be measured. The JSON retains full precision for judging.

The sole comes from alpha >128 inside the support shoe in the game PNG, projected through the displayed cell's full viewport transform. The windows in `tools/art/cast_soles.py` distinguish the support from the swing boot and equipment. Card contacts span contact and pass drawings. The articulated robots use each visible foot's own planted intervals. The apron stays under observation through an eight-direction sweep. Body jump follows the upper-body outline midpoint at 30% of crop height, or the articulated torso origin. Both measurements include drawing changes. Before is the original game at `0779185ac`.

Nominal walk speed comes from the live `EnemyRoster` (`enemies.json` / `speed_mps`). The patrol also uses the free city walk in `heat.json`, the arrival walk in `prologue_stage.json` and the frightened patrol retreat in that same table. SWAT's run is the rifle-post bound. The warden has the additional arrival walk. The other sampled actors have no separate gameplay run in these encounters. A lunge is an attack. The turret stays mounted.

| Archetype | Gait (m/s) | Pitch | Before right | After right | Before down-right | After down-right |
|---|---|---:|---:|---:|---:|---:|
| patrol_cop | walk (3.2) | 70 | 21.40 / 3.47 ✗ | 0.00 / 3.67 ✓ | 32.75 / 2.93 ✗ | 0.00 / 7.18 ✓ |
| patrol_cop | walk (3.2) | 55 | 14.98 / 4.33 ✗ | 0.00 / 2.56 ✓ | 29.17 / 4.20 ✗ | 0.00 / 3.76 ✓ |
| patrol_cop | arrival walk (3.8) | 70 | 26.20 / 3.79 ✗ | 0.00 / 4.36 ✓ | 37.31 / 3.22 ✗ | 0.00 / 7.95 ✓ |
| patrol_cop | arrival walk (3.8) | 55 | 19.78 / 4.65 ✗ | 0.00 / 3.04 ✓ | 33.43 / 4.49 ✗ | 0.00 / 4.70 ✓ |
| patrol_cop | city walk (1.4) | 70 | 16.71 / 2.51 ✗ | 0.00 / 3.90 ✓ | 28.32 / 2.08 ✗ | 0.00 / 5.97 ✓ |
| patrol_cop | city walk (1.4) | 55 | 12.07 / 3.37 ✗ | 0.00 / 1.99 ✓ | 25.05 / 3.36 ✗ | 0.00 / 3.66 ✓ |
| patrol_cop | run (6.65) | 70 | 27.72 / 5.31 ✗ | 0.00 / 6.51 ✓ | 38.76 / 4.64 ✗ | 0.00 / 9.80 ✓ |
| patrol_cop | run (6.65) | 55 | 22.72 / 6.17 ✗ | 0.00 / 4.71 ✓ | 34.79 / 5.84 ✗ | 0.00 / 6.75 ✓ |
| riot_cop | walk (2.8) | 70 | 14.31 / 3.07 ✗ | 14.31 / 3.07 ✗ | 16.83 / 3.39 ✗ | 16.83 / 3.39 ✗ |
| riot_cop | walk (2.8) | 55 | 14.46 / 3.50 ✗ | 14.46 / 3.50 ✗ | 31.46 / 2.41 ✗ | 31.46 / 2.41 ✗ |
| swat | walk (3.4) | 70 | 17.54 / 3.16 ✗ | 17.54 / 3.16 ✗ | 36.26 / 2.61 ✗ | 36.26 / 2.61 ✗ |
| swat | walk (3.4) | 55 | 16.18 / 4.39 ✗ | 16.18 / 4.39 ✗ | 19.63 / 2.61 ✗ | 19.63 / 2.61 ✗ |
| swat | run (6) | 70 | 25.54 / 4.54 ✗ | 25.54 / 4.54 ✗ | 40.83 / 3.88 ✗ | 40.83 / 3.88 ✗ |
| swat | run (6) | 55 | 24.17 / 5.78 ✗ | 24.17 / 5.78 ✗ | 26.94 / 3.77 ✗ | 26.94 / 3.77 ✗ |
| robot_thug | walk (2.4) | 70 | 0.00 / 1.29 ✓ | 0.00 / 1.29 ✓ | 0.01 / 1.26 ✓ | 0.01 / 1.26 ✓ |
| robot_thug | walk (2.4) | 55 | 0.00 / 1.29 ✓ | 0.00 / 1.29 ✓ | 0.01 / 1.20 ✓ | 0.01 / 1.20 ✓ |
| robot_gunner | walk (2.2) | 70 | 0.00 / 1.18 ✓ | 0.00 / 1.18 ✓ | 0.01 / 1.15 ✓ | 0.01 / 1.15 ✓ |
| robot_gunner | walk (2.2) | 55 | 0.00 / 1.18 ✓ | 0.00 / 1.18 ✓ | 0.01 / 1.10 ✓ | 0.01 / 1.10 ✓ |
| contractor | walk (3) | 70 | 18.41 / 3.95 ✗ | 18.41 / 3.95 ✗ | 34.12 / 3.29 ✗ | 34.12 / 3.29 ✗ |
| contractor | walk (3) | 55 | 15.46 / 5.09 ✗ | 15.46 / 5.09 ✗ | 30.03 / 5.00 ✗ | 30.03 / 5.00 ✗ |
| rocket_trooper | walk (3.2) | 70 | 13.66 / 2.03 ✗ | 13.66 / 2.03 ✗ | 22.24 / 2.89 ✗ | 22.24 / 2.89 ✗ |
| rocket_trooper | walk (3.2) | 55 | 15.11 / 13.44 ✗ | 15.11 / 13.44 ✗ | 19.45 / 3.48 ✗ | 19.45 / 3.48 ✗ |
| sentry_turret | sweep (0) | 70 | 0.00 / 4.02 ✓ | 0.00 / 4.02 ✓ | 0.00 / 4.02 ✓ | 0.00 / 4.02 ✓ |
| sentry_turret | sweep (0) | 55 | 0.00 / 2.66 ✓ | 0.00 / 2.66 ✓ | 0.00 / 2.66 ✓ | 0.00 / 2.66 ✓ |
| shield_robot | walk (1.6) | 70 | 7.35 / 13.29 ✗ | 7.35 / 13.29 ✗ | U / 13.23 ✗ | U / 13.23 ✗ |
| shield_robot | walk (1.6) | 55 | 6.64 / 11.95 ✗ | 6.64 / 11.95 ✗ | U / 11.80 ✗ | U / 11.80 ✗ |
| war_machine | walk (1.8) | 70 | U / 17.84 ✗ | U / 17.84 ✗ | 24.75 / 13.22 ✗ | 24.75 / 13.22 ✗ |
| war_machine | walk (1.8) | 55 | 29.07 / 11.88 ✗ | 29.07 / 11.88 ✗ | 22.97 / 13.35 ✗ | 22.97 / 13.35 ✗ |
| appliance_warden | walk (2.8) | 70 | 17.51 / 3.55 ✗ | 17.51 / 3.55 ✗ | 31.16 / 2.96 ✗ | 31.16 / 2.96 ✗ |
| appliance_warden | walk (2.8) | 55 | 13.43 / 4.55 ✗ | 13.43 / 4.55 ✗ | 27.48 / 4.46 ✗ | 27.48 / 4.46 ✗ |
| appliance_warden | arrival walk (3.8) | 70 | 25.51 / 4.08 ✗ | 25.51 / 4.08 ✗ | 38.70 / 3.44 ✗ | 38.70 / 3.44 ✗ |
| appliance_warden | arrival walk (3.8) | 55 | 18.03 / 5.08 ✗ | 18.03 / 5.08 ✗ | 34.49 / 4.93 ✗ | 34.49 / 4.93 ✗ |
| sergeant_mulroney | walk (3.2) | 70 | 16.97 / 2.91 ✗ | <0.001 / 3.75 ✓ | 33.63 / 2.41 ✗ | <0.001 / 8.58 ✓ |
| sergeant_mulroney | walk (3.2) | 55 | 15.75 / 4.01 ✗ | <0.001 / 2.87 ✓ | 18.72 / 2.40 ✗ | <0.001 / 3.42 ✓ |

### Patrol cop, eight-drawing walk and run

All 64 captures passed at 32 px/m. The largest sole excursion was 0.000975 px. The largest body jump was 10.79 px on the tall near rig during the 70° down-right arrival. At the former 55° profile trouble spot, the tall near rig measured 6.39 px on retreat. The four-drawing projection was 16.11 px.

The cutter measures the support boot and upper-body midpoint after matching the shipped patrol’s mean opaque height per facing. For each profile contact it measures horizontal torso advance relative to the sole between the heel and passing drawings, divides by two drawing intervals, and converts at that pitch’s nominal world scale. Averaging both contacts and both pitches gives **0.1765 m/drawing** for the walk and **0.3917 m/drawing** for the run. Above **4.0 m/s** the near rig, far wave card and quest card select the run. Set `StreetCopWalk.PLANTED` to `FOUR` to restore the old strips and 0.135 m interval at every speed.

Each support anchors in world space. Between drawing centres the torso leans over that boot toward the neighbouring measured pose, with at most 0.22 horizontal shear and 0.12 vertical stretch. In the run, drawings 4 and 8 carry the body to its next landing in the air and contribute no sole dots. The quest card uses its standing-strip scale. Actor 262472 gives exactly 1.16 on the tall near rig and the far wave card.

Each host cell gives **maximum sole travel / maximum body jump** in pixels at 32 px/m. Cadence is ground speed divided by distance per drawing. The full-precision `build/cast/cop8/feet.json` includes an independent cadence count between rendered drawing boundaries. The director’s strobe threshold is 24 drawings/s.

| Gait (m/s) | Pitch | Facing | Drawings/s | Near rig | Tall near rig | Tall far wave card | Quest card |
|---|---:|---|---:|---:|---:|---:|---:|
| City walk (1.4) | 70° | right | 7.93 | 0.0010 / 3.90 | 0.0008 / 3.60 | 0.0006 / 3.60 | 0.0005 / 3.90 |
| City walk (1.4) | 70° | down-right | 7.93 | 0.0009 / 5.97 | 0.0009 / 8.10 | 0.0005 / 8.10 | 0.0006 / 6.72 |
| City walk (1.4) | 55° | right | 7.93 | 0.0007 / 1.99 | 0.0008 / 1.52 | 0.0006 / 1.52 | 0.0005 / 1.80 |
| City walk (1.4) | 55° | down-right | 7.93 | 0.0008 / 3.66 | 0.0008 / 2.29 | 0.0006 / 2.29 | 0.0006 / 3.17 |
| Wave walk (3.2) | 70° | right | 18.13 | 0.0010 / 3.67 | 0.0008 / 3.54 | 0.0005 / 3.54 | 0.0005 / 3.60 |
| Wave walk (3.2) | 70° | down-right | 18.13 | 0.0007 / 7.18 | 0.0008 / 9.74 | 0.0005 / 9.74 | 0.0005 / 8.07 |
| Wave walk (3.2) | 55° | right | 18.13 | 0.0008 / 2.56 | 0.0008 / 3.47 | 0.0005 / 3.47 | 0.0004 / 2.66 |
| Wave walk (3.2) | 55° | down-right | 18.13 | 0.0006 / 3.76 | 0.0008 / 2.57 | 0.0005 / 2.57 | 0.0005 / 3.00 |
| Arrival (3.8) | 70° | right | 21.53 | 0.0008 / 4.36 | 0.0007 / 4.21 | 0.0005 / 4.21 | 0.0005 / 4.27 |
| Arrival (3.8) | 70° | down-right | 21.53 | 0.0007 / 7.95 | 0.0008 / 10.79 | 0.0004 / 10.79 | 0.0005 / 8.93 |
| Arrival (3.8) | 55° | right | 21.53 | 0.0006 / 3.04 | 0.0006 / 4.12 | 0.0006 / 4.12 | 0.0004 / 3.16 |
| Arrival (3.8) | 55° | down-right | 21.53 | 0.0007 / 4.70 | 0.0008 / 3.05 | 0.0005 / 3.05 | 0.0005 / 3.56 |
| Retreat (6.65) | 70° | right | 16.98 | 0.0008 / 6.51 | 0.0008 / 4.75 | 0.0004 / 4.75 | 0.0004 / 5.26 |
| Retreat (6.65) | 70° | down-right | 16.98 | 0.0007 / 9.80 | 0.0006 / 8.35 | 0.0005 / 8.35 | 0.0004 / 7.13 |
| Retreat (6.65) | 55° | right | 16.98 | 0.0007 / 4.71 | 0.0007 / 6.39 | 0.0005 / 6.39 | 0.0004 / 4.90 |
| Retreat (6.65) | 55° | down-right | 16.98 | 0.0005 / 6.75 | 0.0006 / 6.36 | 0.0004 / 6.36 | 0.0006 / 4.95 |

The four-drawing patrol changed at 23.70 drawings/s on the wave walk and 49.26 drawings/s on retreat.

The door carrier's slab hides the supporting boot in its down-right pass. The 70° pile-driver profile shows a flat rear pad in all four drawings, with no identifiable lift or change of pad identity. Neither observation supports a numeric whole-contact pass for that facing.

From the worktree root, with the lane's APPDATA and GODOT_BIN set, run `node tools/art/cast_feet.mjs`. The terminal and `build/cast/feet.json` report the same rows. The source captures are `build/cast/tracks_{70,55}_32.json`. Run `python tools/art/test_cast_feet.py` for the synthetic planted, sliding and drawing-change controls.

The 64 px/m stills show the same fixed viewport and tick 38, with one orange sole dot per rendered frame of the bracketed contact. The film replays ten recorded six-metre traverses in gait order. Both panels use native 32 px/m samples and separate 64 px/m captures for the feet insets. Dots accumulate on a fixed metre grid at both scales.

- [70° still](<C:/Users/kazda/kiro/gtai-masters/n26/cast/feet_cop_patrol_before_after_64ppm_tilt70.png>)
- [55° still](<C:/Users/kazda/kiro/gtai-masters/n26/cast/feet_cop_patrol_before_after_64ppm_tilt55.png>)
- [19.8 s owner comparison](<C:/Users/kazda/kiro/gtai-masters/n26/cast/feet_cop_patrol_before_after_32.mp4>)

Capture the current patrol with `node tools/art/cast_feet.mjs build/cast/cop8 32 patrol_cop` and repeat at 64. With the original takes in `build/cast/before`, run `python tools/art/cast_feet_plate.py build/cast/before build/cast/cop8 patrol_cop <output-directory>` and `python tools/art/cast_feet_clip.py build/cast/before build/cast/cop8 <output.mp4>`.


## Planted feet, n27

The riot cop, SWAT (walk and the rifle-post run) and the lancer (`rocket_trooper`) now draw eight-drawing walks on the patrol's anchored placement (`CastRiotAnchors`, `CastSwatAnchors`, `CastLancerAnchors`, selected by their `WALK` constant; `FOUR` restores the shipped strip). Source art: `gtai-art/foes-n26/{riot8c,swat8c,swat8run,lancer8}`, cut by `tools/art/cast_foe_eight.py`, soles registered by `tools/art/cast_foe_soles.py`. Same take and columns as n26 (sole travel / body jump, screen px at 32 px/m; checklist bars sole <= 2 px over a contact, body jump <= 12 px between consecutive rendered frames). Before is `main` `a3b3f1466` (the n26 rows). The after sole is 0.00 because the placement pins the very ink the take registers; the windows were checked on overlay sheets (`pack/soles_*.png` in each source folder), not by a second oracle.

| Archetype | Gait (m/s) | Pitch | Before right | After right | Before down-right | After down-right |
|---|---|---:|---:|---:|---:|---:|
| riot_cop | walk (2.8) | 70 | 14.31 / 3.07 ✗ | 0.00 / 3.77 ✓ | 16.83 / 3.39 ✗ | 0.00 / 5.10 ✓ |
| riot_cop | walk (2.8) | 55 | 14.46 / 3.50 ✗ | 0.00 / 2.68 ✓ | 31.46 / 2.41 ✗ | 0.00 / 3.69 ✓ |
| swat | walk (3.4) | 70 | 17.54 / 3.16 ✗ | 0.00 / 3.10 ✓ | 36.26 / 2.61 ✗ | 0.00 / 7.21 ✓ |
| swat | walk (3.4) | 55 | 16.18 / 4.39 ✗ | 0.00 / 5.46 ✓ | 19.63 / 2.61 ✗ | 0.00 / 6.23 ✓ |
| swat | run (6) | 70 | 25.54 / 4.54 ✗ | 0.00 / 4.65 ✓ | 40.83 / 3.88 ✗ | 0.00 / 9.13 ✓ |
| swat | run (6) | 55 | 24.17 / 5.78 ✗ | 0.00 / 7.09 ✓ | 26.94 / 3.77 ✗ | 0.00 / 7.17 ✓ |
| rocket_trooper | walk (3.2) | 70 | 13.66 / 2.03 ✗ | 0.00 / 2.77 ✓ | 22.24 / 2.89 ✗ | 0.00 / 9.21 ✓ |
| rocket_trooper | walk (3.2) | 55 | 15.11 / 13.44 ✗ | 0.00 / 3.34 ✓ | 19.45 / 3.48 ✗ | 0.00 / 3.95 ✓ |

| Sheet | Metres per drawing | Drawings per second | 64 px/m edge (added dark exterior pixels, 70 / 55) | Height vs shipped walk |
|---|---:|---:|---|---|
| cop_riot_planted8_armed_walk | 0.2161 | 12.8 at 2.8 m/s (above 12) | 0 / 0 | 1.000 / 1.000 |
| swat_planted8_armed_walk | 0.2437 | 13.9 at 3.4 m/s (above 12) | 0 / 0 | 0.999 / 1.000 |
| swat_planted8_run | 0.4720 | 12.7 at 6 m/s (above 12) | 0 / 0 | 1.000 / 1.000 |
| rocket_trooper_planted8_armed_walk | 0.2057 | 15.6 at 3.2 m/s (above 12) | 0 / 0 | 0.999 / 1.000 |

All four cadences are above the 5 to 10 a second a drawn walk usually wants and the checklist's 12; the drawn strides are short for these speeds, so the drawing changes are quick. Soles hold and the jump stays under 12 px, but the cadence is the thing to judge on the film. Reversal (aim one way, step the other; `test_cast_walk_reversal.gd`): 9.60 px on every new sheet at both pitches (the 0.30 m/tick body-catch limit, bar 12). Walk, stop and turn jumps are the take's maxima above; the dedicated stop and turn takes were not run in this call. Tool: `node tools/art/cast_feet.mjs <dir> 32 riot_cop,swat,rocket_trooper`, 64 px/m edge via `cast_feet.mjs ... 64` then `tools/art/cast_foe_edge.py`, size via `tools/art/cast_foe_scale.py`.

## Sergeant Mulroney card admission, 2026-11-23

| Archetype | Renderer | Identity | Walk | Attack/tell | Hit | Death | Facings | Grid | Pitches | Scale | Ink | Palette | Cut | Feet | Shadow | Provenance | Enabled |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `sergeant_mulroney` | Human cast card on the prologue formation boss | PASS | PASS | PASS in staged fight | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS (9.59 px worst fight jump) | PASS | PASS 10/10 | **true** |
| `robot_gunner` | Robot card on the gauntlet wave (`FoeGunnerCardView`) | PASS | PASS | PASS in staged fight (n28 films) | PASS | PASS | PASS | PASS | PASS | PASS | PASS (ink runs within 2 px of the patrol) | PASS | PASS | PASS | PASS (shadow 210-243 px) | PASS | **true** |

### Cut edge and reversal review

The old 70° fight jumped 30.49 px from frame 290 to 291 at 32 px/m. The shotgun still pointed down-right as the actor stepped back-left. The walk stayed on the same strip and facing, changing support from drawing 4 to 5. Its next foothold used the new travel direction while the previous torso still carried the old landing offset. A column change also jumped 16.41 px at frame 30. The shared placement now seeds the initial step from velocity and carries the displayed torso through each handover around the planted boot. The recaptured 32 px/m fight measured 9.36 px on frames 290–291 and 9.59 px across all consecutive moving walk frames, below the 12 px limit. The original patrol walk also failed the aimed-reversal test at 70° (14.17 px). The regression drives both officers at both pitches.

On the 64 px/m street, the live impact material added solid black pixels outside the wound drawing. On the same frozen frame the unshaded texture had a clean outline. The sergeant's painted wound now uses the raw head socket material. Both hit sheets were re-cut from their source with the eight-drawing walk key and despill treatment at the original scale, crop, and boot registration. The other sheets were checked at both pitches: both walk strips, all four attack/pump rows including the shotgun, and all three fall rows including the loose shotgun have clean edges. Each of the ten sheets passed the cell-boundary and strong key-spill checks.

At tick 519 the number of added dark exterior pixels fell from 354 to 0 at 70° and 462 to 0 at 55°. The count compares the live card, its raw texture and the empty street at one fixed pose (`tools/art/cast_mulroney_edge.py --measure`). [Native street before/after](<C:/Users/kazda/kiro/gtai-masters/n26/cast/mulroney_hit_edge_64.png>)

### Eight-drawing admission at `8cf84806f`

The formation marches at the roster speed of 3.2 m/s. There is no separate run. The two profile contact-to-pass advances at each pitch give **0.1903 m/drawing**, or **16.82 drawings/s**. The 60 Hz captures independently counted 16.82 drawings/s. The near rig and far card use the same support-sole registration. To select the original walk at both pitches, set `StreetMulroneyAnchors.WALK` to `FOUR` in the anchor generator and regenerate.

| Pitch | Facing | Before sole travel / body jump | After sole travel / body jump |
|---|---|---:|---:|
| 70° | Right | ≥11.95 / 2.88 | 0.00076 / 3.75 |
| 70° | Down-right | 32.98 / 6.87 | 0.00075 / 8.58 |
| 55° | Right | ≥11.95 / 2.56 | 0.00065 / 2.87 |
| 55° | Down-right | ≥10.92 / 3.67 | 0.00071 / 3.42 |

Distances are screen pixels in the fixed 32 px/m viewport, rounded upward for the after sole values. Before is the four-drawing card at `745d86cde`. The independent 64 px/m takes also passed after conversion to 32 px/m. Each native pose take showed all eight drawings in all eight octants at both review scales. The stance begins ahead of the pelvis so its shadow crosses the supporting boot during the step. The new cuts match mean equipped walk height to within 0.05% of the original at either pitch. Both cuts have zero strong key pixels at alpha ≥128. All ten shipped sergeant PNGs have matching SHA-256 provenance entries.

**Living hit and shadow.** The head socket applied its reaction after the card had already received a wound displacement. The sole therefore moved again while the shadow tracked a single displacement. The hit now rotates about the measured flat boot after the socket has posed. In the rear 70° drawing the lifted boot extends below the planted one. Mirroring preserves the flat boot's ground point.

Three incoming pistol octants each displayed 12 wound frames followed by idle. At both pitches and both scales the projected support sole stayed within 0.001 native px of the shadow's ground point on all 36 frames per take. In paired 32 px/m exposures the three wounds changed 211 / 209 / 220 visible shadow pixels at 70° and 148 / 165 / 178 at 55°. The forward pump changed 261 / 246 pixels. In the 64 px/m upward-blow exposure, the nearest boot and visible shadow pixels had been 7.0 px apart at 70° and 12.04 px at 55°. They now share a pixel boundary at both pitches. Mean hit height relative to the new walk is +0.02% / −0.08% by `street_hit_size.heights`.

**Reproduction.** Capture `node tools/art/cast_feet.mjs <out> 32 sergeant_mulroney`, then run `python tools/art/cast_mulroney_measure.py <out> 32` to apply his eight-drawing shoe windows to the recorded transforms. Repeat at 64. The companion uses the checklist's alpha-band, projection, body-jump and contact-span methods. The archived baseline is under `gtai-art/foes-n26/mulroney/pack`. Final source cuts, viewport exposures, traces, and film tools are under `gtai-art/foes-n26/mul8/pack`. The pose and film scenes emit post-draw measurements with `--cast-mulroney-trace`.

[Planted soles at 64 px/m](<C:/Users/kazda/kiro/gtai-masters/n26/cast/feet_mulroney_before_after_64ppm_tilt70.png>) · [Living hit with shadow toggled](<C:/Users/kazda/kiro/gtai-masters/n26/cast/mulroney_hit_shadow_64.png>)

The seed-7 prologue displayed the equipped eight-drawing card at tick 5321. The yard's vector commander dress also drew its cap, coat and shotgun over the card, obscuring most of the painted figure. The painted boots remain visible. [Prologue exposure at 32 px/m](<C:/Users/kazda/kiro/gtai-masters/n26/cast/mulroney_prologue_card.png>)

### Four-drawing admission review at `745d86cde`

The first review kept the card disabled. Walk, Feet, Hit and Shadow failed. The measurements below describe that build.

**Drawing and scale.** The plate's rolled sleeves, upper-arm chevrons, peaked cap and wood-stock shotgun carry through the front, back, flinch and fall. His gun and cap land separately. The moustache reads best at 55°. At 32 px/m, the 70° front three-quarter silhouettes measure 41 × 42 px for Mulroney, 27 × 43 for patrol and 60 × 77 for Rivet. At 55° they measure 45 × 45, 32 × 44 and 52 × 75. The corresponding 64 px/m heights are 85 / 86 / 154 and 90 / 88 / 151. These are equipped screen bounds for the spawned IDs, excluding shadows. The 1.11 drawing correction applies to every action at both rig distances. [70° lineup](<C:/Users/kazda/kiro/gtai-masters/n26/cast/mulroney_beside_64ppm_tilt70.png>) · [55° lineup](<C:/Users/kazda/kiro/gtai-masters/n26/cast/mulroney_beside_64ppm_tilt55.png>)

**Action and facing.** The near host displayed every walk row in all eight octants at 32 and 64 px/m, both pitches. The native sheets have five facing columns and 4 / 4 / 1 / 3 action rows for walk, attack, hit and fall. Source attack columns 1–4 become game rows 0–3. The staged fight first shows aim at tick 168, recoil when the pellets leave at 218, pump back at 219 and pump forward at 242. At 55° straight down, recoil and pump back have similar silhouettes. Down-right, the forward left arm and lowered barrel read at 32 px/m. Three incoming pistol directions showed the drawn hit and return to idle. The mean drawn hit height differs from walk by less than 0.2% at either pitch, but the wound transform tips or lifts the support boot away from its ground mark. A shock kill shows buckle, descent and rest. A pistol kill opens on the hit drawing and joins the fall at its second row. The prone pose persists after the reaction ends. [Pump plate](<C:/Users/kazda/kiro/gtai-masters/n26/cast/mulroney_pump_64.png>)

**Feet.** `PrologueFormation.march` reads Mulroney's 3.2 m/s roster speed. He has no separate run gait. These are screen pixels at 32 px/m. The independent 64 px/m captures give the same values when converted to 32 px/m. The 70° down-right support was tracked across contact and pass. Both profiles and the 55° down-right sequence repeat the lead, so the travel within a held drawing is a measured lower bound. Each bound alone exceeds the 2 px limit. All upper-body jumps pass the 12 px limit. The normal card stride is used throughout.

| Pitch | Facing | Max support-sole travel (px) | Max body jump (px) |
|---|---|---:|---:|
| 70° | Right | ≥11.95 | 2.88 |
| 70° | Down-right | 32.98 | 6.87 |
| 55° | Right | ≥11.95 | 2.56 |
| 55° | Down-right | ≥10.92 | 3.67 |

**Ink, cut and shadow.** At the front pass, the three contour samples are 2 / 3 / 6 texels at 70° and 4 / 2 / 1 at 55°. The outlines close at both review scales. The walk navy means are 222.4° / .470 / .327 and 221.8° / .440 / .329. The eight final RGBA grids have zero strong green or magenta pixels at alpha ≥128. Light and dark matte checks retain the hands, muzzle, loose gun and cap. The stationary front three-quarter shadow toggle changes 248 / 221 pixels at 32 px/m for 70° / 55°. The forward pump changes 261 / 246. The shadow draws separately, but stays behind the displaced boot on a living wound.

**Reproduction.** `cast_mulroney_lineup.tscn` uses the ordinary cast lineup and actual formation boss. `cast_mulroney_poses.tscn` checks the displayed texture, octant and row. Both read `GTAI_CAST_OUT`, `GTAI_CAST_PITCH` and `GTAI_CAST_PPM`. The feet capture uses `GTAI_CAST_PREVIEW=sergeant_mulroney` and `node tools/art/cast_feet.mjs <output-directory> 32 sergeant_mulroney` (also run at 64). The preview enables only the in-memory row. Source sheets, cutter, matte checks, viewport crops and sole tracks are in `gtai-art/foes-n26/mulroney/`. The final hashes match the eight entries beginning at line 2668 of `steam/ai-provenance/2026-11.jsonl`. [64 px/m close film](<C:/Users/kazda/kiro/gtai-masters/n26/cast/mulroney_close_64.mp4>) · [32 px/m fight](<C:/Users/kazda/kiro/gtai-masters/n26/cast/mulroney_fight_32.mp4>)

## Appliance warden (Peg Dolan) after the card landed (n27, row `enabled: true`)

The card row, the anchored eight-row walk (`CastWardenAnchors`, step 0.2543 m), the padded cells and the catch rows are in code
and unit-tested (`test_cast_warden.gd`). The row is **`enabled: true`**: every point below passes except the prologue's catch view, which lands with the yard's patch. Measured with her card forced on
(`GTAI_CAST_PREVIEW=appliance_warden`). Screen pixels, 32 px/m unless stated.

| Point | Number | Verdict |
|---|---|---|
| Planted feet, support-sole travel (`cast_feet.mjs`, walk 2.8 m/s and arrival walk 3.8 m/s, right and down-right, 70/55) | 0.00 px in all eight takes (64 px/m take gives the same values) | PASS |
| Body jump, feet tool, 70 degrees: walk right / down-right, arrival right / down-right | 3.07 / 9.07, 3.63 / 9.15 px (Mulroney: 2.88 / 6.87) | PASS against the checklist's 12 px (0.375 m) at 32 px/m |
| Body jump, feet tool, 55 degrees, same four | 2.79 / 5.36, 2.77 / 5.81 px (Mulroney: 2.56 / 3.67) | PASS against 12 px |
| Aimed reversal on the live near host (`cast_warden_poses`, 32 px/m, torso track) | seam 9.47 px at 2.8 m/s and 1.91 at 3.8 m/s (70); 8.96 and 2.18 (55); worst frame in the track 9.52 / 9.55 (70), 9.48 / 9.48 (55). Mulroney's was 30 px before his fix | PASS against 12 px (Mulroney ships the 12 px bound) |
| Body jump by transition (`test_body_jump_on_walk_stop_turn_and_reversal`, contact model, 2.8 m/s, 70 / 55) | start 6.19 / 4.87 px; steady walk 9.60 px; stop 0.00 (nothing after the halt); turn 9.60; reversal 9.60 (no spike above the steady walk). At 64 px/m: start 12.38 / 9.73, held 19.20. The stride's own travel is 1.49 px per tick at 32 and 2.99 at 64 | PASS against 12 px at 32 (24 at 64); the turn and the reversal add nothing to the steady 9.60 px drawing-change step |
| Drawings per second | walk 2.8 m/s / 0.2543 m = 11.0; arrival walk 3.8 m/s = 14.9 (above 12; Mulroney ships 16.8 at 3.2 m/s) | noted, not a fail |
| Palette, all ten sheets (`tools/art/cast_warden_edge.py`) | blue on solid pixels 0 to 3 px per sheet, except p70 attack 126 px (0.06 %); strict red (r>120, g<60, b<60) at most 14 px per sheet | PASS: no blue, no red outside the 4 to 14 px of ink |
| Edge, **sheet proxy** at 64 px/m drawn size, fringe px per cell (alpha 0 to 0.5, colour below 64): walk / attack / hit / fall / planted8, p70 | 429 / 482 / 512 / 525 / 233 against Mulroney 456 / 454 / 381 / 473 / 244 | comparable; hit is 35 % above Mulroney's painted wound |
| Edge, **sheet proxy**, p55, same order | 376 / 401 / 357 / 419 / 168 against Mulroney 459 / 487 / 343 / 365 / 180 | comparable |
| Edge, live-frame rim at 64 px/m (`cast_warden_poses` frozen live/raw/ground exposures, `cast_warden_review.py`): added dark exterior pixels | 0 on all ten: armed_walk, planted8, attack, hit, fall at 70 and at 55 (visible pixels 1792 to 3353) | PASS |
| Size, 32 px/m 70 degrees, front / back (`cast_warden_lineup` plate, 1920 x 1080) | Equipment included: Peg 47 / 55, patrol cop 43 / 44, Mulroney 44 / 48, Rivet 77 / 73. **Pole excluded** (silhouette opened with a 3 px kernel, which removes the 1 to 2 px pole; the back pose lifts it 12 px above the head): Peg 47 / 43. At 64 px/m: 96 / 87 against 110 incl. pole | PASS: about the patrol cop's height and not taller than Rivet (77 / 73) |
| Wound contact (card pivot to shadow ground, hit_1, hit_4, hit_6, both pitches, 32 and 64 px/m) | 0.000 to 0.001 px (bar 1.0) | PASS |
| Catch view in the live prologue | `set_catch` is unit-tested and driven by `cast_warden_fight` (first catch tick 193, held 126 ticks) | wired at the merge by the yard's patch (NEED yard), not a fail of the card |

**Why she is on.** The checklist's body-jump bound is 12 screen px at 32 px/m. Her worst is 9.60 px (the drawing-change step every 0.2543 m; down-right 9.07 / 9.15 at 70 degrees, start 6.19). Soles hold (0.00 px), the live edge rim is 0, the wound boot sits on the shadow, there is no blue, she is not taller than Rivet. Until the yard's patch lands, the prologue still dyes the rig and draws its vector pole behind her card: that double-draw is the yard's call 2 below.

**The yard's three calls (NEED yard, not edited here).**
1. `project/boot/prologue/prologue_stage.gd`, `PrologueStage._move()`, right after the `if combat.catcher != null: ... combat.catcher = null`
   block (about line 43) and before `if at_receiver or combat.catcher != null:`, every tick:
   ```gdscript
   for h: Fighter in combat.hostiles:
   	if h.archetype == FoeWardenCardView.ID:
   		FoeWardenCardView.set_catch(h, h == combat.catcher, tick)
   ```
2. `project/boot/prologue/prologue_props.gd` must skip all three of its warden sites when `CastCards.current(&"appliance_warden") != null`:
   the overalls dye (line 31, `h.alive() and h.archetype == &"appliance_warden"`), the dress loop (line 90, the same archetype test)
   and the vector pole and straps (`_warden(chest, head, h.facing)` at line 112, defined at line 158). Otherwise her card and the dyed rig double-draw.
3. `cast_lineup.gd` hides the prologue's `LightLayer` now: the yard's lights printed rings into every prologue portrait (Mulroney's lineup
   failed the same way on this branch).

## Robot gunner A (navy plates) as a card (n27; n28 row `enabled: true`)

Source: the director's `gunnerA` sheets (owner pick 2026-11-24, navy kept as bolted plates on a gunmetal frame, pale box head with no cap, one lens, hose arms, brass belt to a back drum). Cut by `tools/art/cast_gunner_pack.py` at the patrol cop's drawn height per facing (fill 1.12 / 1.08), one foot line, muzzle flash and the dropped rifle kept as props. Code: `FoeGunnerCardView` (a sprite sibling of his robot rig, hidden rig, the rig stays the body for the shove and the power-down), `CastGunnerAnchors` (step 0.2704 m), `test_cast_gunner.gd`. With the row off his robot rig draws exactly as before (`show_rig` returns the rig's own visibility). Measured with his card forced on in a dev process (`GTAI_CAST_PREVIEW=robot_gunner`, `CastMulroneyPreview.enable`). Screen px at 32 px/m unless stated.

| Point (checklist bar) | Number | Verdict |
|---|---|---|
| Planted feet, support-sole travel (bar 2 px; `cast_feet.mjs`, walk 2.2 m/s from `enemies.json`, right and down-right, 70/55; no run) | 0.00 px in all four takes | PASS |
| Body jump, feet tool (bar 12 px): 70 right / down-right; 55 right / down-right | 9.60 / 9.18; 9.60 / 8.52 | PASS |
| Body jump by transition (bar 12 px, `cast_gunner_turns` + `cast_gunner_transitions.py`, 70 right / down-right; 55 right / down-right) | stop 3.77 / 5.19; 2.77 / 4.72 (**18.80 / 17.78; 20.17 / 15.09 before** `FoeGunnerCardView._hold_stop` kept the last planted drawing); turn 9.60 / 9.18; 9.60 / 8.52; reversal (aim one way, step the other) 9.60 / 9.40; 9.60 / 9.00 | PASS (the steady drawing-change step is the max) |
| Drawings per second | 2.2 / 0.2704 = 8.14 observed 8.13 | PASS (bar 24) |
| Size, 70 degrees front / back, silhouette without his shadow rings (first `cast_gunner_lineup` run) | gunner 46 / 49, patrol cop 43 / 44, Rivet 77 / 73, today's robot rig 65 / 81 | PASS: about the patrol cop's height, well below Rivet |
| Size with his own shadow rings, 70 front / back, 55 front / back, 64 px/m 70 | 53 / 56, 54 / 56, 107 / 114 (patrol 87 / 88 at 64); rings add about 7 px; the 55 silhouette alone was not measured separately | noted |
| Palette, all ten sheets (`cast_gunner_palette.py`, `cast_warden_edge.py`) | navy (hue 190-250) 5.0 to 6.6 % of solid px (Mulroney 20-35 % blue); strict red at most 60 px (p70 attack, 0.02 %: the lit lens edge) and 0 to 9 elsewhere; no teal, no vermilion | PASS |
| Cut / key (`check_cells` in the cutter) | zero strongly green-leading opaque px on every cell; flash and rifle inside the cells | PASS |
| Edge, **sheet proxy** fringe px per cell, p70: walk / attack / hit / fall / eight | 469 / 462 / 529 / 642 / 300 (Mulroney 456 / 454 / 381 / 473 / 244) | comparable; fall is 36 % above |
| Edge, **live rim** at 64 px/m (`rim()` of `tools/art/cast_mulroney_edge.py` on the `edge_*` exposures of `tools/art/cast_gunner_poses.mjs`, frozen street, card vs raw vs ground; `build/cast/gunner/poses/poses{70,55}_64/`) | dark exterior px, walk-8 / attack / hit / fall: 70: 0 / 0 / 0 / 0; 55: 0 / 0 / 0 / 0 (patrol and warden: 0). Looked at `live.png` for fall, attack, hit: clean outline, no black fringe. Caveat: the `edge_fall` exposure is fall cell 0 (still upright, first power-down drawing); the lying cells 1 and 2 have no ground twin and were looked at only (`fall_1`, `fall_2`) | PASS (0 against bar 0) |
| Shadow (`cast_gunner_poses`, 32 px/m, 70 deg, front three-quarter; his ring node hidden in the `_no_shadow` twin, px darkened by >= 12/255) | stand 210, tell 232, fire 235, hit_1 232, hit_4 226, hit_6 243 (patrol 236, cop8 248 / 221): the toggle reaches his rings (diff is not 0). Separate ground contact seen under the feet in every walk frame, still under him after the shot and in the three wound frames; no baked key shadow | PASS (bar roughly 150 to 350) |
| Ink (3, 3, 4 px runs; `tools/art/cast_gunner_ink.py`, sheets at the shipped 192 px cell height, from the sheets, the live 32 / 64 frames not yet looked at) | planted-8 passing cells, 70: 1,2,2 / 2,2,2 / 2,2,1 (patrol 3,3,4); 55: 2,3,2 / 2,4,3 / 2,4,3 / 1,3,3 / 2,3,3 / 1,3,2 (patrol 3,3,3): every one within 2 px of the patrol. Some cells show one run of 19 to 24 px at a single y (70 walk row 0 y 75, row 1 y 80; 55 planted-8 row 6 y 75, row 1 y 70 = 12): the contour there crosses the dark hose-arm joint, where the pixels stay under RGB 48 past the outline. Contact sheets `build/cast/gunner/ink_70.png`, `ink_55.png`: contours closed, hands and rifle intact, no duplicate hatching seen | sheet side PASS; live look PASS: all eight walk frames at 70 deg, 32 and 64 px/m (`build/cast/gunner/poses/poses70_{32,64}/walk_0_*.png`) looked at: contours closed, hands and rifle whole, no double hatching |
| p70 fall, double rifle (found by the director in `poses70_64/fall_2.png`) | double rifle in rows 1-3 cols 1-2 removed by image edit (n28; 1 image, `gtai-art/foes-n28/gunner-fall/`, six cells composited into the sheet, others byte-identical; original kept as `gunnerA_fall_70_v1_double_rifle.png`). Re-cut: only `p70/robot_gunner_fall.png` changed, zero strongly green px. Before `build/cast/gunner/poses_before_fall_fix/poses70_64/fall_{1,2}.png`, after `build/cast/gunner/poses_after/poses70_64/fall_{1,2}.png`: one rifle per cell, dropped rifle to his right, hands empty. **n28 01e:** that edit left the cell rifle AND the game's pickup in the films (two rifles); the fall sheets now draw the body only at 70 and 55 (the pickup is the one rifle). At 55 the lying cells 1-2 of the source show a rifle held in the hand as part of the body drawing; it is not removed by the cut (see the 01e report). `edge_fall` rim after: 0 at 70 and 55 | PASS |
| p55 fall, rifle in the hand (found by the director) | rifle removed from the hand in the lying drawings (8 source cells: middle column x5, right column rows 3-5) by image edit (n28; 1 image, `gtai-art/foes-n28/gunner-fall55/`, composited into the sheet, other cells byte-identical; original kept as `gunnerA_fall_55_v1_hand_rifle.png`). Re-cut: only `p55/robot_gunner_fall.png` changed, 14 strongly green px. Looked at on grey: empty open hands, bodies whole; `build/cast/gunner/poses_after55/poses55_64/fall_{1,2}.png`: no rifle, hand empty. Master `gtai-masters/n28/cast/gunner_fall55_64.png` | PASS |
| Attack tell, hit and death in a live fight (n28 films, `tools/film/cast_gunner_films.mjs`, scene `project/dev/cast/cast_gunner_fight`, card on, `gtai-masters/n28/cast/`; every one-per-second frame of both, 20 of each, looked at) | `gunner_close_64.mp4`: ffprobe `1920,1080,60/1`, duration 20.016667 s; `gunner_fight_32.mp4`: `1920,1080,60/1`, 20.016667 s. Rivet measured on a frame crop: about 145 px tall at 64 px/m and about 74 at 32 (sprite top to soles, by eye). Log: lens row (attack/0) starts 54 ticks (0.9 s = `telegraph_s`) before the first round for every gunner, then attack/2 flash, attack/3 recoil, back to the walk row at +6 ticks; hit/0 at tick 298 and back to walk at 310 (12 ticks = 0.20 s); fall to rest on his back. Frames: 64 take, patrol cop and Rivet beside him, lens lit in the 3 s frame, Rivet's own muzzle burst (orange/red, Rivet's weapon fx, not the gunner) at 8 s, then the gunner lies on his back and a white/black smoke puff, no red and no blood on him. **First films (corrected, the earlier "one rifle each" was wrong):** every fallen gunner showed TWO rifles, the one drawn in his fall cell and the game's `GroundRifle` pickup (a squad foe with `assault-rifle` drops one); the pickup is gameplay and stays. **Fix (n28 01e):** `cast_gunner_pack.py` crops the fall cells as before but draws the body only (the fall rifle island is dropped; body pixels identical to before, 0 px shift, only the two fall PNGs changed). **New films:** frames at 16-19 s of both clips looked at: each fallen gunner has exactly one rifle, the pickup, beside the body and nothing drawn on or under it; 32 take, three gunners walk in, tell, fire, are shot one by one and rest in a row each with one pickup rifle, small dark oil spatter on the third (black, not red). The pickup rifle draws a little red/pink (43 px in an 90x40 crop at 64 px/m, from the mp4 via `ffmpeg -pix_fmt rgb24`, R>G+60 and R>B+40; `ground_rifle*` is not ours and untouched). Bad frames: none; at 32 px/m the lens is a few px and is judged from the log rows, not the pixels | PASS |
| Identity at 32 px/m beside the patrol cop (`gunner_vs_cop_32.png`) | the pale box head, tan frame and hose arms read as a machine; navy is a few patches, where the cop is navy all over with a round cap | PASS (judged by eye on one still) |

**Verdict (n28, 2026-11-24): he is on.** All four open points pass their bars: live rim 0 (bar 0), ink runs within 2 px of the patrol's, shadow 210-243 px (bar about 150-350), and the two films show tell, fire, hit and fall as specified. The row is `enabled: true`; with it false his robot rig draws exactly as before.

## Planted feet, n28 (door carrier)

The door carrier (`shield_robot`) keeps its shipped four-drawing walk (no art change) and is placed by the same anchored mechanism as the riot, SWAT and lancer (`CastDoorAnchors`, `StreetCopWalk.Contact`/`StreetPatrolPose`, five facings x four drawings, generated by `tools/art/cast_door_soles.py` from the shipped alpha with the `cast_soles.OTHERS` windows). The sheet is 192 px high, so it skips the 256/192 cell ratio (`CastCardKinds.cell_ratio`): same on-screen size as before. Shove lane and slab-on-death untouched. Soles are measured only in the right facing; the down-right contact hides the supporting boot behind the slab, so there (and in the unmeasured facings) the table holds the lowest opaque pixels, a body anchor, not a verified sole.

STEP_M 0.16 m per drawing (10.0 drawings/s at 1.6 m/s). The first estimate from the drawn body advance (0.2036) gave sole 6.31 / 4.29 px; 0.26 gave 6.89 / 4.71 (worse); 0.15 gave 5.55 / 3.87. 0.16 is the largest step inside the 10 drawings/s bound.

| Archetype | Gait (m/s) | Pitch | Before right (sole / jump) | After right | Before down-right | After down-right |
|---|---|---:|---:|---:|---:|---:|
| shield_robot | walk (1.6) | 70 | 7.35 / 13.29 ✗ | 5.74 / 5.51 ✗ | U / 13.23 ✗ | U / 10.82 (jump ✓, sole unmeasurable) |
| shield_robot | walk (1.6) | 55 | 6.64 / 11.95 ✗ | 3.98 / 5.93 ✗ | U / 11.80 ✗ | U / 9.82 (jump ✓, sole unmeasurable) |

Body jump over a turn / a 140-degree reversal, per tick, 32 px/m (`test_cast_door_walk.gd`): p70 6.70 / 7.65 px, p55 9.60 / 9.60 px (<= 12). A stop resets the contact (no jump to measure). **Verdict: Feet still FAILS** on the sole (<= 2 px): the four-drawing walk has two contacts of unequal drawn advance, so the sole slides 4 to 6 px over a contact; the body-jump half now passes. A planted eight-drawing redraw would be needed for the sole (new art, not in this call). Before values are the n26 table above (`main` `d0ab9d03a`). No films, pile-driver or impact-edge item in this call.
