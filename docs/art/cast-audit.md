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

### Door carrier evidence, n28 (films)

`tools/film/cast_door_films.mjs` (before = `CastDoorAnchors.SHEET` renamed in the working tree for the run, which puts the
sheet back on the shipped unanchored four-drawing placement; after = the committed placement), `cast_foot_film.gd` with
`GTAI_CAST_DIR=right|downright`, sole texels from `tools/art/cast_door_film_soles.py`. Stills at 64 px/m tilt 70, right
facing, 1.6 m/s: the shipped placement draws three wide sole brackets per cycle that slide (each bracket spans the whole
contact); the planted one draws a bracket per drawing, narrower, the cyan/orange contacts alternating without gaps. The
down-right take has no dots (the sole is hidden by the slab). The clip has no 64 px/m inset: the tool does not support one.

## Pile-driver feet, n28

**Verdict: Feet FAILS: no exchange of support drawn at 70, needs new art. Nothing wired, nothing shipped.**
Evidence: `pile_lift_70.png` (masters `n28/cast/`; the right-facing column of `war_machine_armed_walk.png`, four drawings,
p70 on top, p55 below, the lowest opaque row drawn in cyan). Looked at it. The n26 line "no lift drawn" is not literally
true: at p70 drawings 1 and 3 each tilt the FRONT (right) pad so its underside shows. But it is the same pad both times,
the rear pad is flat and planted in all four drawings, and drawings 0 and 2 are the same two-pad stance (front pad 5 px
apart). A walk that lifts one pad twice and never the other has no alternation of support, so no per-drawing sole table
can carry one ground point through a continuous 1.8 m/s walk the way `CastDoorAnchors` does. At p55 the exchange IS drawn
(drawing 1 tilts the rear pad, drawing 3 the front pad), so a p55 table is possible; the checklist needs both pitches, so
none was written (a placement that cannot pass at 70 would only move the failure).
`CastCards` still has `war_machine` `enabled: true` in this tree (the brief said `false`): the wave draws the pile-driver
card (`FoeWarCardView`, `HEIGHT_M` 2.6, a held-foot placement, no anchor table). Not touched.

| Character | Gait | Pitch | Sole / body jump, right (main `d0ab9d03a`) | After | Down-right (main) | After |
|---|---|---:|---:|---:|---:|---:|
| war_machine | walk (1.8) | 70 | U / 17.84 | unchanged (not wired) | 24.75 / 13.22 | unchanged |
| war_machine | walk (1.8) | 55 | 29.07 / 11.88 | unchanged (not wired) | 22.97 / 13.35 | unchanged |

Turn and reversal jump, stop: not measured (nothing changed to measure). **Size, rendered** (`cast_foot_film.gd`,
1920 x 1080, 32 px/m, tilt 70, the card walking right, then the silhouette measured on the frame): **70 x 77 px**
(Rivet 77 / 75 in the same audit; not enlarged: the card is `HEIGHT_M` 2.6 m over a 200 px body, figure bbox 184 px of
the 288 px cell). What else on the checklist still fails: the Feet row (sole 23 to 29 px, jump over 12 px at 70 right and
down-right) and every other cell of its row in the n26 table above that was F; none was worked on in this call.

## Impact outline, n28

Question (lane item 4): does the hit flash (`CutRig.set_tint`, the shared `PartMaterials` tinted material) draw dark teeth
outside the silhouette on other cards' hit poses at 64 px/m, as it did on Mulroney's (354 / 462 px before `af94f1c6e`)?
Measured in ONE Godot launch by `project/dev/cast/cast_impact_edge.gd` (wave street, tilt 70, one pistol hit each, the same
frozen frame exposed live / raw / empty, flash on = pulse, off = calm, `tools/art/cast_impact_edge.py` -> `rim()` of
`cast_mulroney_edge.py`: dark exterior pixels). Sheet: `impact_edge_64.png` (masters `n28/cast/`, pulse row then calm row).

| Card | Hit drawing shown | Pulse (flash on) | Calm (flash off) | Flash material on the card |
|---|---|---:|---:|---|
| patrol cop | `cop_patrol_shoulder_hit.png` | 1 | 0 | yes (silhouette flash) |
| riot | `cop_riot_hit.png` | 6 | 0 | yes |
| SWAT | `swat_hit.png` | 7 | 0 | yes |
| lancer | `rocket_trooper_hit.png` | 0 | 0 | yes |
| door carrier | `shield_robot_hit.png` | 0 | 0 | none: its card sprite never takes the rig tint |
| warden | `appliance_warden_hit.png` | 0 | 0 | painted ink path (`painted_ink`): draws in colour, no flash |
| gunner | `robot_gunner_hit.png` | 0 | 0 | none (card sprite beside the robot rig) |

Looked at the sheet: on patrol, riot, SWAT and lancer the flash is the intended black-and-cream silhouette print; the
exterior fringe is 0 to 7 px per frame against Mulroney's 354 / 462, so no card shows his teeth. The 6 to 7 px on riot and
SWAT are single stray pixels along the shield rim / rifle, not a band. No fix made: the flash material is shared
(`PartMaterials`, outside this lane's allowlist), so if the 6 to 7 px ever matter it is a NEED for the material's owner;
the card-path fix (`CastCards.painted_ink`) is for painted wounds and would only turn the flash off for these cards.
Caveats: the flash was forced on the frozen tick (`natural_tint` was false 3 ticks after the strike, the game's own pulse is
shorter than that); p70 only; the door carrier's and gunner's flash in the real fight is not a rig tint, so their pulse
column is 0 by construction, not by a measured clean flash.

## Contractor, n28: state (step 1 of the brief done, 2026-11-24 evening)

Cut art only. No `cast_cards.json` row, no wiring, nothing measured in the engine yet.

Shipped sheets (`project/features/characters/art/view/{p70,p55}/`, cut by `tools/art/cast_contractor_pack.py`,
palette and cut check `tools/art/cast_contractor_palette.py`, provenance `tools/art/cast_contractor_provenance.py`):
`contractor_armed_walk` (4 drawings), `contractor_planted8_armed_walk` (8 drawings, from the ten `contractor8c` sheets),
`contractor_attack` (4 columns: aim, fire, recoil, recover), `contractor_cast_hit`, `contractor_cast_fall`.
The hit and fall are named `contractor_cast_*`, not `contractor_hit/fall`: quest 1's dock corpses and hit strip
(`street_quest_cards.gd`, `street_quest_hit.gd`, `signature_kills.json`) still read the old `contractor_fall.png` /
`contractor_hit.png`, which are untouched, so the quest tapes cannot move.

Measured (sheet level, opaque px):

| point | before | after |
|---|---|---|
| hat mean saturation (top 13 % of the figure), walk / 8-walk / attack / hit, p70 | .147 to .206 | .068 / .071 / .054 / .097 |
| the same at p55 | .192 to .232 | .065 / .069 / .086 / .123 |
| hat value | .79 to .85 | .78 to .85 |
| vest hue (median of yellow-leaning px), p70 walk / 8-walk | 51 / 51 | 51 / 51 (untouched) |
| cut check, green / magenta-leading opaque px, ten sheets | | 0 / 0 on every sheet |
| red, teal, vermilion px (the 8 non-fall sheets) | | red 0 to 6, teal 0, vermilion 0 |

Open or failing at sheet level: p55 hit hat saturation .123 (bar .12) with value .779 (bar .78): a hair under the bar
on both, the hat is shaded on that sheet; p55 vest median hue 46.5 to 47.5 with 14 to 16 % of the vest px under hue 45
(pale lemon wants 50 to 62; the p70 sheets are 51 and 2 to 3 %): a vest tone pass was not authorised, the live frame
decides. The p70 fall draws the body only (the source has the hat on the head AND a second floating hat). The p55 fall
keeps the dropped hat; its drawing-1 rifle is erased by polygon (one stray speck beside the boot).

Not done yet (next call): row `contractor` (`enabled: false`) and the 8-drawing anchored walk in `CastGunnerAnchors`'
way, feet at 70 and 55 (right and down-right, stop, turn, reversal), drawings per second, size beside the patrol cop and
Rivet, ink, live rim, shadow, tell / hit / fall films, before/after.

**Contractor, n28: state after step 2 (row off, anchored walk wired).**
- Row `contractor` is in `cast_cards.json` with `enabled: false` (hit/fall are `contractor_cast_hit/fall.png`), so
  `CastCards.lookup` returns null and the card-off path is as on main. `test_cast_contractor.gd` pins that.
- `CastContractorAnchors` (generated by `tools/art/cast_foe_soles.py contractor`, the lancer/gunner way, from
  `contractor_planted8_armed_walk.png`, 5 facings x 8 drawings at both pitches); `CastCardKinds` and `CastCards` know it,
  `WALK` selects the eight, `FOUR` restores the four. Sole markers checked on the overlay sheet
  (`gtai-art/foes-n26/contractor8c/pack/soles_{70,55}.png`, p70 looked at: the ring sits on the support boot in every
  facing).
- `WALK_STEP_M` = 0.2202 m per drawing (contact-to-pass advance, four measurements 0.202 / 0.246 / 0.220 / 0.212).
  At his 3 m/s that is 13.6 drawings/s: ABOVE the 5 to 10 bar (and above 12). Open for the feet call: a larger step trades
  cadence against sole slip, as the warden's 0.16 did; not tuned yet.
- Not measured yet: `cast_feet.mjs` right / down-right at 70 and 55, stop / turn / reversal, size beside the patrol and
  Rivet, ink, live rim, shadow, tell / hit / fall films, before/after; there is no contractor card view yet (nothing draws
  the card), so the row cannot be turned on.

**Contractor, n28: walk step sweep (part 2, row still off).** `WALK_STEP_M` swept by editing the constant and running
`GTAI_CAST_FORCE=contractor node tools/art/cast_feet.mjs <dir> 32 contractor` (a dev-only env forces the row on in the
feet tool, left uncommitted: it adds 5 lines to project/dev/cast and the debt ratchet refuses; `cast_feet.py` now knows the contractor sheet's sole windows). He walks at 3 m/s (enemies.json). Sole slip is
0.001 px at every step (anchored carrier); the step only moves cadence and the body jump. Drawings/s is
speed / step (observed in the take in brackets); jump is px at 32 px/m, bar <= 12; sole bar <= 2.

| step m | drawings/s | 70 right jump | 70 down-right | 55 right | 55 down-right | verdict |
|---|---|---|---|---|---|---|
| 0.2202 | 13.62 (13.68) | 3.11 | 4.83 | 3.45 | 4.26 | cadence FAIL (> 10) |
| 0.26 | 11.54 (11.56) | 2.64 | 7.75 | 3.12 | 5.22 | cadence FAIL (> 10) |
| 0.30 | 10.00 (9.91 right, 10.00 down-right) | 3.73 | 9.04 | 5.09 | 7.94 | PASS |

Chosen: 0.30, the smallest swept step at or under 10 drawings/s. `cast_foe_soles.py contractor` now writes 0.30 itself
(`STEP_OVERRIDE` in the tool; the measured 0.2202 is only printed): regenerating `CastContractorAnchors` leaves
`git diff` on the anchors file empty (checked, and regenerating the gunner's file is empty too).

**Contractor, n28: stop, turn, reversal (brief 08 part B, row still off).** Scene `project/dev/cast/cast_contractor_turns.gd`
(the gunner's `cast_gunner_turns` with his row forced on by `GTAI_CAST_FORCE=contractor`, 3.0 m/s, 30 walk-in ticks, then a
stop / a 90-degree turn over 20 ticks / a reversal: aim one way, step the other), run by `tools/art/cast_contractor_turns.mjs`,
analysed by `tools/art/cast_contractor_transitions.py` from the stored tracks. 32 px/m, screen px between consecutive
rendered frames (bar 12); the stop row also gives the travel of the support sole of the drawing held after the stop (bar 2).
Reversal is judged by the number only (no backwards drawing step larger than the walk's own step; the largest jump is the
steady drawing-change step), not by a film.

| take | 70 right | 70 down-right | 55 right | 55 down-right | verdict |
|---|---|---|---|---|---|
| stop, body jump | 3.73 | 7.97 | 5.09 | 6.32 | PASS |
| stop, support sole travel after the stop (held drawing row 1) | 0.00 | 0.00 | 0.00 | 0.00 | PASS (bar 2) |
| turn, body jump | 9.28 | 9.06 | 9.06 | 8.14 | PASS |
| reversal, body jump | 9.60 | 9.39 | 9.60 | 9.01 | PASS |

The strafing speed in a fight was not measured separately (the fight film moves him at the sim's own speed).

**Contractor, n28: checklist (brief 08 part C, one frozen-exposure launch, row stays OFF).** Tools: `project/dev/cast/cast_contractor_poses.gd`
(one launch: 70/32, 70/64, 55/64, frozen live/raw/ground exposures and shadow-off pairs, row forced on by `CastMulroneyPreview.enable`),
`cast_contractor_lineup.gd` (+ `tools/art/cast_contractor_lineup.mjs`: Rivet, patrol, contractor at 70/32, 55/32, 70/64),
`tools/art/cast_contractor_review.py` (rim, shadow, live palette), `tools/art/cast_contractor_ink.py`. Evidence in
`build/cast/contractor/` (git-ignored); beside still `gtai-masters/n28/cast/contractor_beside_64ppm_tilt70.png`. Screen px.

| Point (checklist bar) | Number | Verdict |
|---|---|---|
| Size at 32 px/m, front / back silhouette, 70: contractor 56 / 58, patrol 43 / 44, Rivet 77 / 73; 55: contractor 57 / 59, patrol 44 / 46, Rivet 75 / 74 | never taller than Rivet (21 px under at 70 front); 13 px (30 %) taller than the patrol cop, so not "the cop's height" (at 64 px/m 70: 111 / 117 against patrol 87 / 88, Rivet 154 / 146) | PASS on the bar (not taller than Rivet); note: much taller than the patrol |
| Live 64 px/m rim, dark exterior px, walk / attack, 70 and 55 | 0 / 0 and 0 / 0 | PASS |
| Live rim, hit, pulse frame (4 ticks after the strike, flash lit) 70 / 55 | 175 / 221 (bar 0) | **FAIL** |
| Live rim, hit, calm frame (9 ticks after the strike, still the hit drawing) 70 / 55 | 0 / 0 | PASS |
| Live rim, fall cell 0 / 1 / 2 70 | 604 / 87 / 0 (55: 720 / 165 / 0) | **FAIL** on cells 0 and 1 (the flash is lit); cell 2 PASS |
| Control, same harness, the shipped lancer card (`GTAI_CAST_CONTROL=rocket_trooper`), 70 | walk 0, attack 0, hit 482, fall cell 0 1161 (55: hit 596, fall 1079) | the shared hit flash (`CutRig.set_tint`, tinted part material on a raw card) draws a black halo while lit; the shipped lancer shows it too. Warden (`painted_ink`) and gunner (no tint) are 0 by construction. Looked at `edge_fall/live.png` against `raw.png`: a solid black outline about 4 px wide around the whole figure on the live one |
| Shadow, same-pose toggle, 32 px/m 70 front three-quarter, px darkened >= 12 | stand 237, tell 280, fire 280, hit_1 159, hit_4 284, hit_6 283 (patrol 236) | PASS (150-350); separate ground contact seen under him in every frame, no baked key shadow |
| Ink, sheets at 192 px, front passing pose, left contour y = 70 / 75 / 80 (patrol 3,3,4 / 3,3,3), 8-drawing walk col 0 rows 0-7 | 70: 2,2,1 / 2,2,2 / 1,2,1 / 1,2,1 / 1,3,1 / 1,2,1 / 1,3,1 / 1,2,1; 55: 2,1,2 / 2,1,2 / 2,1,2 / 2,1,2 / 3,1,1 / 3,1,1 / 2,1,2 / 2,1,2 | within 2 px at 55; at 70 the y = 80 run is 1 where the patrol's is 4 (3 px, row 1 is 2): thinner than the patrol by about 3 px there. Live frames at 64 and 32 (walk_1_0, walk_1_2, walk_2_3, walk_3_5) looked at: contours closed, hands and SMG whole, no double hatching: PASS on the look |
| Live palette, hat (S <= 0.12, V >= 0.78): walk / attack, 70 and 55 | S 0.067 / 0.051 (70), 0.068 / 0.078 (55); V 0.896 / 0.903, 0.886 / 0.862 | PASS |
| Live palette, vest (median hue >= 45) | walk 51.0 (70), 46.7 (55); attack 45.8 (70), 46.3 (55); share under 45: 1.2 / 41.9 % (70), 9.3 / 32.5 % (55) | PASS on the median; thin margin on attack (45.8) |
| Live palette, red, vermilion, teal, blue / navy px on the figure | 0 / 0 / 0 / 0 on walk and attack at both pitches; the hit and fall frames hold the black flash only | PASS |
| **Size jump on attack and hit (found while looking)** | same facing, 70 at 64 px/m, silhouette height: stand 86, tell 64, fire 65, hit_1 55, hit_4 69 (55: 88 / 66 / 68 / 53 / 66). Ratio about 0.74 to 0.77 = 192/256: the eight-drawing walk and the `padded` sheets take the 256/192 cell ratio (`CastCardKinds.fill`, `padded`: only `appliance_warden_` and `robot_gunner_`), his `contractor_attack` and `contractor_cast_hit` (256 px cells, figure 187 texels like the walk) do not, so he shrinks by a quarter whenever he aims or is hit | **FAIL** (likely cause; needs `contractor_` in `CastCardKinds.padded`, `project/features/characters/cast_card_kinds.gd`, outside this lane's allowlist: NEED) |

**Verdict (n28, brief 08): he stays OFF.** Failing: the live rim on the hit and fall exposures while the flash is lit (175 / 221 and 604 / 720 dark exterior px against bar 0; calm 0; the shipped lancer shows the same, so this may be the bar's reading rather than his art) and the attack / hit size jump (about 0.75 of the walk, a likely one-line `padded` NEED). Not done because of that: the two films, `enabled: true`, the decisions line, `frames.json`.

**Contractor, n28: size jump fixed, flashed-rim rule (brief 09 parts A and B).** Sheets measured with the alpha bbox (alpha > 40), texels, cell height / figure height:
walk `contractor_planted8_armed_walk` 256 / 198-204 (70), 198-201 (55); `contractor_attack` 256 / 195-223 (70), 197-201 (55); `contractor_cast_hit` 256 / 201 (70), 199 (55);
`contractor_cast_fall` grid cells 264 high (figure 167-201 per row); old quest sheets `contractor_card` 192 / 190, `contractor_hit` 288 / 278, `contractor_fall` 510 cell / 188-192 (two rows; unchanged, quest 1 reads them).
The attack and hit cells carry the same padding as the walk (figure about 200 of 256), so `CastCardKinds.padded` now lists exactly `contractor_attack.png` and `contractor_cast_hit.png`
(the fall stays out by the existing `_fall.png` rule, the quest sheets are not named). Warden and gunner lines are unchanged (pinned in `test_cast_card_kinds.gd`).
Live 64 px/m, tilt, same facing, no-shadow silhouette height in screen px, before -> after (frozen-exposure launch `cast_contractor_poses`):

| Pitch | stand | tell | fire | hit_1 | hit_4 | hit_6 |
|---|---|---|---|---|---|---|
| 70 before | 86 | 63 | 64 | 55 | 69 | 62 |
| 70 after | 86 | 85 (-1.2 %) | 86 (0) | 82 (-4.7 %) | 82 (-4.7 %) | 87 (+1.2 %) |
| 55 before | 88 | 66 | 68 | 53 | 66 | 63 |
| 55 after | 88 | 88 (0) | 91 (+3.4 %) | 83 (-5.7 %) | 87 (-1.1 %) | 91 (+3.4 %) |

Within 5 % everywhere except hit_1 at 55 (-5.7 %, 0.7 point over). hit_1 is the drawn flinch lean (looked at the strip: the figure bends away, head low), and its cell figure
is 199 texels like the walk's 198-201, so the scale is the walk's; the remaining gap is the pose, not a size jump (it was -40 % before). Fall: fall_0 103, fall_1 71 (walk stand 101 with its shadow); the rest body lies about 55 px
(by eye; the 123 px bbox of `rest` includes the blood splat spikes), not taller than stand.

Flashed rim rule (director decision 22:02): a cell drawn while the shared hit flash is lit is judged against the shipped lancer card in the same harness, not against 0; calm cells keep bar 0.
Re-run numbers (70 / 55), dark exterior px: hit pulse 289 / 403 against lancer 482 / 596 (PASS); fall cell 0 604 / 720 against 1161 / 1079 (PASS); fall cell 1 87 / 165 (lancer cell 1 not measured; PASS by being under cell 0); hit calm 0 / 0, walk 0 / 0, attack 0 / 0, fall cell 2 0 / 0 (PASS).
Shadow re-run: stand 237, tell 234, fire 235, hit_1 203, hit_4 201, hit_6 224 (PASS 150-350). Palette: hat S 0.052-0.078, V 0.875-0.907; vest median hue walk 51.0 / 46.7, attack 45.9 / 46.4; stray 0 / 0 / 0 / 0 (PASS).
Rule added to `docs/art/cast-checklist.md` (Rim row). The two earlier FAIL rows (hit pulse, fall cells 0 and 1, size jump) now read PASS under the rule and the padded fix.

**Contractor, n28: live height vs the lineup (brief 10, measured from `gtai-masters/n28/cast/contractor_close_64.mp4`, no Godot).** Close film 1920x1080, 64 px/m, tilt 70, frames extracted with ffmpeg, silhouette = outline-dark / bright / saturated pixels inside a window per figure, shadow excluded, hat top to lowest boot px, screen px. Rivet and the patrol cop do not move in the film (149 px, rows 450-598; cop 112 px, rows 339-450, every frame). The contractor, walking in at 0.5 s then standing and aiming: 1 s, 1.5 s, 2 s, 2.5 s, 4 s 78 px (rows 401-478); 3 s 87; 5 s and 6 s 82; 8 s 88; 9 s 84; 10 s 71 (aim / fire / hit poses). Ratio contractor / cop 78/112 = 0.70 on the five steady frames (0.63-0.79 over all), contractor / Rivet 0.52. The live game's numbers are these (the film's spawn path, `cast_contractor_fight.gd:74` `patrol_cop` via `spawn_member`, is the game's), and they agree with `cast_contractor_poses` (stand 86 before the pad, tell 64-65, hit 55-69 then padded to 0.94-1.05). The beside still (`cast_contractor_lineup.gd`, made 20:59 before the 22:12 pad commit) says contractor 111 / 117, cop 87 / 88, Rivet 154 / 146: Rivet agrees within 3 %, the contractor is about 1.3-1.4 times the live height and the cop about 0.78 times, so the still reverses the live order (contractor taller than the cop there, a third shorter than the cop in the film) and must not be used as a size reference. What the lineup does (file:line): it spawns both through `spawn_member` (`cast_contractor_lineup.gd:18`), pins Rivet 12 m away and the subject at MARK with a forced facing and 32 idle ticks (`cast_lineup.gd` `_portrait`), then `CastPlate.add_portrait` takes the body-only bounds of a 640x704 crop with the shadow hidden (`cast_plate.gd:33,43,64-72`); there is no scaling in the plate, and the cop's 87 is the same in the 07:40 baseline log (`build/cast/gl/log_70_64.txt`), so it is not new. The cause of the 87 / 111 against the film's 112 / 78 is NOT established: the plate code cannot produce it by itself, and the likeliest suspects (unproven, they need a launch) are that the lineup's idle, MARK-spaced layout draws the cop and the contractor through a different representation than the fight scene does (`ArenaWaveCards` card vs full rig, `arena_wave_cards.gd:62-80` scales the card by `StreetWalkerCards.HEIGHT_BY_ART` and `fill_of`, `arena_rigs.gd:14` FOCUS_REACH_M) or a different cell (idle stand vs aim). Action: judge size from the films (live), re-take the lineup in the fight scene's setup before it is quoted again.

## Card foes beside the rig patrol cop, n29

Brief n29-cast-01, part A. Scene `project/dev/cast/cast_size_beside.gd` (the fight street of `cast_contractor_fight.gd`, combo, tilt 70, `p70`, HUD and light layers hidden, 1920x1080, content scale off) spawns, in one process, the patrol cop (`spawn_member(..., &"patrol_cop")`) and then every row `CastCards.shipped().lookup(id, "p70")` returns (all eight are `enabled: true`, so the table itself admits them: no `CastMulroneyPreview.enable` call), each through `ArenaSquad.spawn_member`. Per foe: foe at x -3 m, cop at 0, Rivet at +3 m on one ground row, all facing (1, 1), 44 idle ticks, then a beside still (`build/look/n29-size/<id>_<ppm>.png`), the rig shadow layer hidden (`<id>_<ppm>_body.png`) and the figure parked (`_gone_<who>.png`). All figures logged `full rig true, far card false`. `tools/art/cast_size_measure.py` takes the changed pixels between body and gone inside a 3 m band (a robot's own ground shadow, an even darkening at or below the ground row, removed), the densest row run, top px to lowest px. Eye check: the war machine crop (`crop_war_machine_64_war_machine.png`, 3x) reads lamp top to foot ring bottom 155 px, as measured. Stills `gtai-masters/n29/cast/size_before_{64,32}.png`.

Rivet 154 / 77 px (64 / 32 px/m). Patrol cop (actor id 1) 86 / 43 px; its whole-figure card carries the per-actor scale `StreetCrowdCards.body_scale(1)` = 0.855, so the unjittered cop is 100.6 / 50.3 px. "/ cop" below is against the measured cop of this run (86 / 43), "/ cop base" against 100.6.

| id | current body_scale | 64 px/m | 32 px/m | / cop (64, 32) | / cop base | / Rivet (64, 32) | notes |
|---|---|---|---|---|---|---|---|
| appliance_warden | 1.1 | 104 | 52 | 1.21, 1.21 | 1.03 | 0.68, 0.68 | actor id 2, jitter 1.104; enemies.json `body: human` |
| contractor | (1.0) | 104 | 51 | 1.21, 1.19 | 1.03 | 0.68, 0.66 | actor id 3, jitter 1.032 |
| robot_gunner | 1 | 93 | 46 | 1.08, 1.07 | 0.92 | 0.60, 0.60 | `FoeGunnerCardView` never sets `pose.actor_id`, so every gunner draws with `body_scale(0)` = 0.926 |
| rocket_trooper | (1.0) | 83 | 35 | 0.97, 0.81 | 0.83 | 0.54, 0.45 | actor id 5, jitter 0.890; crouched aim cell; enemies.json `body: human` |
| sentry_turret | (1.0) | 107 | 53 | 1.24, 1.23 | 1.06 | 0.69, 0.69 | body_scale NOT read: `foe_turret_card_view.gd:77` scales by `PLATE_M`; plate bottom 50 px below its ground point |
| sergeant_mulroney | 1.11 | 102 | 51 | 1.19, 1.19 | 1.01 | 0.66, 0.66 | actor id 7, jitter 1.067 |
| shield_robot | (1.0) | 108 | 53 | 1.26, 1.23 | 1.07 | 0.70, 0.69 | body_scale NOT applied: `foe_shield_card_view.gd:64` sets `scale` from `HEIGHT_M` 2.0 after `draw_pose`; door bottom 14 px below the ground point (in front of the feet) |
| war_machine | (1.0) | 155 | 77 | 1.80, 1.79 | 1.54 | 1.01, 1.00 | body_scale NOT read: `foe_war_card_view.gd:7,114` `HEIGHT_M` 2.6 |

Readers of `body_scale` (every one): `cast_cards.gd:45-46` parses it; `street_walker_cards.gd:168-169` (`place`, the whole-figure card on a full rig: warden, contractor, rocket trooper, Mulroney, and the cop with no row) and `cast_far_card.gd:80` (`_configure`: the far card and its subclasses `FoeGunnerCardView`, `FoeShieldCardView`) multiply it by `StreetCrowdCards.body_scale(actor_id)` (`street_crowd_cards.gd:68-69`, `SCALE_VAR` 0.16 at `:22`). The turret and war machine views never read it, and the shield view overwrites it.

**Why the lineup said contractor 111 / cop 87 and the film 78 / 112 (cause found).** Not the representation: in the lineup's own layout (subject on the mark, Rivet 12 m right, `cast_lineup.gd` `_portrait`) the cop and the contractor are full rigs here too (logged), and the re-run lineup (`cast_contractor_lineup`, 64 px/m, tilt 70, 2026-11-25 01:20) again says cop 87 / 88, contractor 111 / 117. The cause is the per-actor build jitter: every whole-figure card is scaled by `StreetCrowdCards.body_scale(actor_id)` = 1 +- 0.16 (`street_walker_cards.gd:168`, `street_crowd_cards.gd:68-69`, `SCALE_VAR` `:22`), a hash of the fighter id. The lineup spawns Rivet (id 0), then the cop (id 1, 0.855), then the contractor (id 2, 1.104) (`cast_contractor_lineup.gd:17-18`); the fight film spawns the contractor first (id 1, 0.855) and the cop second (id 2, 1.104) (`cast_contractor_fight.gd:66,74`). The ids, and so the jitters, are swapped. Check with this run's unjittered heights (cop 100.6, contractor 104 / 1.032 = 100.7): lineup cop 100.6 x 0.855 = 86 (measured 87), lineup contractor 100.7 x 1.104 = 111 (111), film cop 100.6 x 1.104 = 111 (112), film contractor 100.7 x 0.855 = 86 (the film's standing 78 was measured by colour thresholds over aim cells; `cast_contractor_poses` said stand 86). Both stills were right for their ids; neither is "the" size: any card human is drawn 0.84 to 1.16 of its row's height depending on its id. So every size comparison has to divide by the logged jitter, as the table does.

**n29 part B: proposal under the first rule, NOT applied.** (Committed in d198af897 by mistake after the director withdrew the rule at 02:18: the rule used Rivet's 1.5x visual height and warden and lancer are body human; the values were reverted in the next commit, `cast_cards.json` is back to warden 1.1, gunner 1, Mulroney 1.11. The decisions.md line of 2026-11-25 "n29 cast card scale" is therefore void.) Humans: unjittered height = cop base x 1.00 (contractor), x 1.05 (Mulroney), +-4 %. Street robots (appliance_warden, robot_gunner, rocket_trooper, shield_robot as the brief lists them): 0.90 x Rivet, +-4 %. War machine <= 1.10 x Rivet. Turret: only if above Rivet. New `body_scale` = current x target / measured (unjittered, 64 px/m): appliance_warden 1.1 -> 1.62, robot_gunner 1 -> 1.49, rocket_trooper (1.0) -> 1.49, sergeant_mulroney 1.11 -> 1.23; contractor stays (1.00 x cop base already), sentry_turret and war_machine stay. Re-run of the same scene (2026-11-25 01:56), same actor ids:

| id | body_scale before -> after | 64 px/m before -> after | 32 px/m before -> after | after, unjittered / target (64, 32) | verdict |
|---|---|---|---|---|---|
| appliance_warden | 1.1 -> 1.62 | 104 -> 154 (hat to boot 147) | 52 -> 77 (74) | hat to boot: 0.865, 0.871 of Rivet (bar 0.864-0.936); with the noose loop 0.906 | PASS at the low edge: the 1.62 came from the before height that included the noose hanging 3 px below the boots; hat-to-boot alone gives 1.67 (not re-measured) |
| contractor | (1.0) | 104 -> 104 | 51 -> 51 | 1.002, 0.982 of cop base | PASS |
| robot_gunner | 1 -> 1.49 | 93 -> 139 | 46 -> 69 | 0.903, 0.896 of Rivet | PASS |
| rocket_trooper | (1.0) -> 1.49 | 83 -> 123 | 35 -> 62 | 0.898, 0.905 of Rivet | PASS (its 32 px/m before was a crouched cell) |
| sentry_turret | (1.0) | 107 -> 107 | 53 -> 53 | 0.695, 0.688 of Rivet, under Rivet | PASS (left) |
| sergeant_mulroney | 1.11 -> 1.23 | 102 -> 113 | 51 -> 57 | 1.003, 1.012 of cop base x 1.05 | PASS |
| shield_robot | (1.0), not changed | 108 -> 108 | 53 -> 53 | 0.701, 0.688 of Rivet | FAIL: `body_scale` has no effect, `foe_shield_card_view.gd:64` sets its scale from `HEIGHT_M` 2.0; the rule needs `HEIGHT_M` about 2.57 (x 1.28) in that file, which this lane may not touch (the other builder's file) |
| war_machine | (1.0) | 155 -> 155 | 77 -> 77 | 1.006, 1.000 of Rivet (<= 1.10) | PASS (left) |

Unjittered = measured / `StreetCrowdCards.body_scale(actor_id)` for the whole-figure cards (warden, contractor, lancer, Mulroney); the gunner's card always uses `body_scale(0)` (its pose never gets an actor id), so its measured height is every gunner's. In the game each card human still varies 0.84-1.16 around these by its id. Feet: the after crops (`build/look/n29-size/crop_*_64_*.png`, contact `gtai-masters/n29/cast/size_after_64.png`) show every scaled card's soles on the street at its ground row (boot soles at the ground row, -1 to +1 px, at 64 px/m; the warden's lowest px +6 is her noose loop, her boots end at 539), no float. The war machine's and turret's views are unchanged. The shield door ends 14 px below its ground point because it stands in front of the feet. Open for the director: `enemies.json` gives appliance_warden and rocket_trooper `body: human`, and their art is human, so the robot rule makes them 1.38 x the cop base (154 px beside an 86 px cop in this run); under the human rule they would be 1.1 x 100.6 / 94.2 = 1.17 (warden) and 1.0 x 100.6 / 93.3 = 1.08 (lancer).

**n29 part B, applied** (brief n29-cast-01b, 2026-11-25 03:08). Card foes drop the per-actor build jitter (`cast_cards.json` `build_jitter` 0; `CastCards.Sheets.scale_of`, read by `cast_far_card.gd` `_configure` and the card branch of `street_walker_cards.gd` `place`); the shield and war machine views multiply `HEIGHT_M` by the row's `body_scale`. Same scene, same actor ids as part A (warden 2, contractor 3, gunner 4, lancer 5, turret 6, Mulroney 7, shield 8, war machine 9), plus two more spawns each of the contractor (ids 10, 11) and the gunner (ids 12, 13). "/ cop" is against the unjittered patrol cop (100.6 / 50.3 px); target from the director's rule, +-4 %.

| id | old body_scale | new | 64 px/m | 32 px/m | / cop (64, 32) | target | verdict |
|---|---|---|---|---|---|---|---|
| appliance_warden | 1.1 | 1.18 | 101 | 51 | 1.004, 1.014 | 1.00 | PASS |
| contractor | (1.0) | 1.00 | 100 | 49 | 0.994, 0.974 | 1.00 | PASS |
| robot_gunner | 1 | 1.10 | 110 | 55 | 1.093, 1.093 | 1.10 | PASS |
| rocket_trooper | (1.0) | 1.08 | 100 | 51 | 0.994, 1.014 | 1.00 | PASS |
| sentry_turret | (1.0), not read | (1.0) | 107 | 53 | 1.064, 1.054 | unchanged (107) | PASS (unchanged) |
| sergeant_mulroney | 1.11 | 1.23 | 106 | 53 | 1.054, 1.054 | 1.05 | PASS |
| shield_robot | (1.0), overwritten | 1.03 | 111 | 56 | 1.103, 1.113 | 1.10 | PASS |
| war_machine | (1.0), not read | 0.84 | 130 | 65 | 1.292, 1.292 | 1.30 | PASS (0.84 of Rivet's 154 px) |

Jitter proof: contractor ids 3 / 10 / 11 (old jitter 1.032 / 0.853 / 1.102) measure 100 / 100 / 100 px at 64 and 49 / 49 / 49 at 32; gunner ids 4 / 12 / 13 measure 110 / 110 / 110 and 55 / 55 / 55 (the gunner's pose never carries an actor id, so it was one size before too; it now draws at its body_scale instead of `body_scale(0)` 0.926). Eye check of the 64 crops (`build/look/n29-size/crop_<id>_64_<id>.png`): every figure whole, nothing clipped, soles on the ground row (lowest px 539-543, the warden's noose loop at 543), no float; the turret plate still ends 50 px below its ground point and the shield door 14 px below (both as in part A). The cop in these stills has no cast row, so it keeps the crowd's own jitter (actor id 1, 0.855, 86 px): in the game, patrol cops still vary 0.84-1.16 while card foes do not. Fall and corpse: `street_walker_cards.gd` `place` passes the card's `scale_of` into `StreetWalkerFall.draw`, and the far card and both robot views size their fall cells with the same scale, so a scaled card falls at its own size. `street_crowd_corpse.gd` bakes crowd looks only (no card foe). Open: `features/combat/kills/kill_fall_cells.gd` `_scale` and `height_px` size a kill victim with `1 + SCALE_VAR x vary(actor_id)` and no `body_scale` or `build_jitter`, so a killed card foe in a kill style is drawn at the crowd jitter (Mulroney 1.23 would drop to 0.84-1.16); outside this lane's allowlist. Stills `gtai-masters/n29/cast/size_after_{64,32}.png`.

## Door carrier on eight drawings, n29

**Verdict: WALK stays FOUR.** The eight-drawing walk is cut, packed, anchored and switchable, but it is worse than the
shipped four in the right facing at both pitches, so the rule "ship only if every facing is no worse" keeps the four.
Sheets `shield_robot_planted8_armed_walk.png` (p70 151x192 cells, p55 144x192, 5 facings x 8 drawings), cut by
`tools/art/cast_door_eight.py` from `gtai-art/foes-n29/door8/out/door8_{70,55}_{facing}.png`: each facing scaled to the
shipped four's mean body height (p70 161.5 / 146.2 / 139.5 / 149.0 / 175.2 px four, 161.5 / 146.0 / 139.5 / 148.8 / 175.5
eight; p55 155.5 / 144.2 / 133.0 / 146.8 / 178.2 four, 155.5 / 144.4 / 132.8 / 146.9 / 178.4 eight, down to up), torso
registered, the tallest up drawings (p70 up 1 and 5, 4 px; p55 up 1 and 5, 2 px; p55 dr 5, 1 px) rested on the cell
floor. Key-clean 0 opaque px with a 50-level green or magenta lead at both pitches; strict red (green under 0.45 red)
four 17 / 5 px, eight 0 / 0 after 129 / 148 burnt-orange stripe-shadow px from the source were lifted to amber.
Anchors: `cast_door_anchors.gd` now carries FOUR70/55 (unchanged values) and EIGHT70/55 (`tools/art/cast_door_soles.py`,
the foe-eight sole windows with the profile slab bar dropped), `WALK`, `SHEET = WALK`, and WALK70/55/WALK_STEP_M = the
selected walk's. EIGHT_STEP_M 0.1842 (the drawn advance; 8.65 drawings/s observed at 1.6 m/s).

Feet, measured in the delivered frames (`cast_feet.tscn` at 64 px/m, 1.6 m/s, analysed by `cast_feet.py` through
`tools/art/cast_door_feet.py`; px in the tool's 32 px/m unit as in n28, double them for raw 64 px/m pixels). Before =
the shipped anchored four, after = the eight in a staged copy with the switch applied (`tools/film/cast_door_films.mjs
feet`). Bars: sole <= 2, jump <= 12.

| Pitch | Facing | Four (sole / jump) | Eight (sole / jump) | Eight vs four |
|---:|---|---:|---:|---|
| 70 | right | 5.08 / 6.04 FAIL | 8.88 / 8.90 FAIL | worse (+3.80 sole) |
| 70 | down-right | U / 11.01 FAIL | 5.22 / 13.71 FAIL | sole now measurable; jump +2.70, over the bar |
| 55 | right | 3.29 / 6.29 FAIL | 6.16 / 10.90 FAIL | worse (+2.87 sole) |
| 55 | down-right | U / 10.31 FAIL | 4.62 / 13.02 FAIL | jump +2.71, over the bar |

Cause found on the way (a probe, not shipped): `FoeShieldCardView.update_fighter` sets `scale` (HEIGHT_M 2.0 x body_scale
/ BODY_PX 160 = 0.824 px/texel at 64 px/m) after `CastFarCard` placed the anchored drawing at its own `_base_scale`
(1.7 x body_scale / 192 = 0.584 at p70), so every sole lands 1.41x (p55 1.2x) farther from the pivot than the
placement planted it and slides as the drawings change. Re-planting the sole after the rescale (`cast_door_films.mjs
keep`, the view patch applied to the staged copy only): four 2.42 / 4.34 (70 right), 2.03 / 5.09 (55 right), down-right
U / 10.50, U / 10.43; eight 2.83 / 6.47, 2.16 / 9.61, down-right 1.39 / 12.21, 3.45 / 13.28. With it the four is still
the better right-facing walk and neither passes every bar. The eight's second contact (drawings 5-8) is drawn unplanted
in the p70 profile (support sole at +18, +8, +12, -34 px from the torso: drawing 7 steps forward), its first contact is
even (+19, -4, -18, -37).

Held drawings: the director's flagged facings `70_ur`, `55_right`, `55_dr` are not repeated poses (leg-mask change
0.08 to 0.29 between neighbours) except `55_dr` 4 -> 5 (0.04); `55_down` holds near-identical legs in pairs (0.02, the
slab hides them). Film `gtai-masters/n29/cast/door8_walk_32.mp4` (the eight, right then down-right, 32 px/m, tilt 70,
1920x1080, 60 fps, 25.85 s); still `door8_feet_before_after_64.png` (tick 150, four left, eight right, sole brackets).
Switching to EIGHT also needs two lines in `cast_card_kinds.gd` (not this lane's file this session): `rows()` must return
4 for `CastDoorAnchors.FOUR` (not `SHEET`), and `cell_ratio()` must return 1.0 for both `FOUR` and `EIGHT`; the sheet swap
itself is `FoeShieldCardView.walk_sheet`.

### Re-plant shipped, n29 (brief 09)

`FoeShieldCardView._rescale` (`project/features/combat/squad/foe_shield_card_view.gd`) now re-plants the anchored sole
after the view's HEIGHT_M / BODY_PX rescale: the sole's world point under the placement's base scale is kept, the sprite
is moved by the difference (walking drawings only; a standing door scales about its ground point as before). The
`SOLE_PATCH` probe and the `keep` mode left `tools/film/cast_door_films.mjs`; its eight switch lost the two
`cast_card_kinds.gd` lines, which are now in the tree (`rows()` returns 4 for `CastDoorAnchors.FOUR`, `cell_ratio()`
returns 1.0 for `FOUR` and `EIGHT`). The switch to the eight is still four lines of `cast_door_anchors.gd` (`WALK`,
`WALK70`, `WALK55`, `WALK_STEP_M` each name the four's table), not one value. WALK stays FOUR.

Feet (`node tools/film/cast_door_films.mjs build/look/n29-door9 feet`, the tree's code, `cast_feet.tscn` at 64 px/m,
1.6 m/s, `cast_door_feet.py`, px in the tool's 32 px/m unit). Before = `fac845dd9`'s table above. Bars: sole <= 2, jump <= 12.

| Pitch | Facing | Four before | Four after | Eight before | Eight after |
|---:|---|---:|---:|---:|---:|
| 70 | right | 5.08 / 6.04 FAIL | 2.42 / 4.34 FAIL (jump passes) | 8.88 / 8.90 FAIL | 2.83 / 6.47 FAIL (jump passes) |
| 70 | down-right | U / 11.01 FAIL | U / 10.50 (jump passes) | 5.22 / 13.71 FAIL | 1.39 / 12.21 FAIL (sole passes) |
| 55 | right | 3.29 / 6.29 FAIL | 2.03 / 5.09 FAIL (0.03 over; jump passes) | 6.16 / 10.90 FAIL | 2.16 / 9.61 FAIL (jump passes) |
| 55 | down-right | U / 10.31 FAIL | U / 10.43 (jump passes) | 4.62 / 13.02 FAIL | 3.45 / 13.28 FAIL |

The after values equal the builder's `keep` probe to the hundredth, so the shipped code is the probe. The four's sole
slide roughly halves at both pitches; no right-facing sole reaches the 2 px bar (p55 misses by 0.03), the down-right
contact stays unmeasurable behind the slab. The four is still the better right-facing walk, so WALK stays FOUR.

Size: `cast_size_beside.tscn` (run in a junction mirror, `build/film/door9-size`, so `build/look/n29-size` of the tree
was not rewritten; `tools/art/cast_size_measure.py`): shield_robot 111 px at 64 px/m (56 at 32), same as after
`51de13fb6`; patrol cop 86, Rivet 154. A standing door is not moved by the re-plant, so its height cannot change.

Other card views: none rescales after an anchored placement. `foe_gunner_card_view.gd:62-65` and
`foe_thug_card_view.gd:63-66` call `draw_pose` and then scale only their shadow child (`_shadow.scale`), the sprite keeps
the placement's transform; `foe_war_card_view.gd:115-122` and `foe_turret_card_view.gd:74-77` set `position` to the
ground point and then `scale`, but they have no anchored contact (no `CastFarCard`, the pivot is the ground point, so
nothing slides); `foe_warden_card_view.gd` is a RefCounted row picker that draws nothing.

## Door eight with the redrawn drawing 7, n29

**Verdict: WALK stays FOUR.** The director's image edit `gtai-art/foes-n29/door8b/out/door8_70_right_f7.png` redraws
drawing 7 of the p70 right facing with the support boot behind drawing 6's. The edit did not keep the other drawings'
pixels: every drawing was re-encoded (drawings 1-6 and 8: mean 4.6-4.9 levels, max 67-85, 0.2-0.35 % of a cell over
24 levels; their silhouettes xor 0 against the accepted source; drawing 7: mean 16.8, 25 643 px over 24, silhouette xor
6 695 px). So `tools/art/cast_door_eight.py` cuts from `door8b/out/door8_70_right_f7_splice.png` (the accepted source
with only drawing 7's grid cell taken from the edit) and replaces only that sheet cell (p70, right, row 7): the tone
pass is global (it moved the other cells by 1 level), so every other cell keeps the previous sheet's bytes (byte
compare: 39 of 40 p70 cells and all 40 p55 cells identical). Body heights unchanged (p70 four 161.5 / 146.2 / 139.5 /
149.0 / 175.2, eight 161.5 / 146.0 / 139.5 / 148.8 / 175.5), key-lead 0, strict red 0. The registered sole of drawing 7
moves from +12 to -6 sheet px of the torso, so the second contact reads +18.5, +8, -6, -34 (first: +19, -4.5, -17.5,
-37): planted now. `EIGHT70` regenerated by `cast_door_soles.py`; `EIGHT_STEP_M` stays 0.1842.

Feet (`node tools/film/cast_door_films.mjs build/look/n29-door11 feet`, `cast_feet.tscn` at 64 px/m, 1.6 m/s,
`cast_door_feet.py`, px in the tool's 32 px/m unit; the four re-measured to the hundredth of brief 09's). Bars: sole <=
2, jump <= 12.

| Pitch | Facing | Four (09, = now) | Eight before (09) | Eight with f7 | Eight vs four |
|---:|---|---:|---:|---:|---|
| 70 | right | 2.42 / 4.34 | 2.83 / 6.47 | 2.04 / 6.47 | sole better (-0.38, 0.04 over the bar), jump worse (+2.13) |
| 70 | down-right | U / 10.50 | 1.39 / 12.21 | 1.39 / 12.21 | jump worse (+1.71, over the bar) |
| 55 | right | 2.03 / 5.09 | 2.16 / 9.61 | 2.16 / 9.61 | sole worse (+0.13), jump worse (+4.52) |
| 55 | down-right | U / 10.43 | 3.45 / 13.28 | 3.45 / 13.28 | jump worse (+2.85, over the bar) |

The redraw fixed what it targeted (p70 right sole 2.83 -> 2.04, the eight's best right-facing contact), but the
eight is still worse than the four in every facing's jump, so the four ships. Where the eight still fails, by drawing
(scratch probe `build/look/n29-door11/probe.py` over the takes): p70 right sole 2.04 on drawings 5-8 and the 6.47 jump
on 4 -> 5; p70 down-right jump 12.21 on 8 -> 1; p55 right jump 9.61 on 7 -> 8 and sole 2.16 on 1-4; p55 down-right
jump 13.28 on 7 -> 8 and sole 3.45 on 5-8. The largest misses are p55 drawing 8 (right and down-right: the torso
jumps entering it) and p70 down-right drawing 1 (entering it from 8); those are the next one-row edits.

One-value switch: `cast_door_soles.py` now emits `WALK70` / `WALK55` / `WALK_STEP_M` as constant ternaries on `WALK`
(`const WALK70: Array[Vector4] = EIGHT70 if WALK == EIGHT else FOUR70`), so switching the walk is the one `WALK` line;
the film tool's staged switch is that one line. `test_cast_door_walk.gd` pins that every derived table (and
`CastCardKinds.foe_marks` / `foe_step`) follows `WALK`, its four-only counts now follow `WALK`, and a height test pins
`FoeShieldCardView._rescale`'s formula: 2 m over the 160-texel body, 0.4 px per texel at 32 px/m at body_scale 1
(0.412 at the table's 1.03, i.e. 0.824 at 64 px/m: the size scene's 111 px door), linear in body_scale.

## Pile-driver on eight drawings, n29

**Verdict: `WALK` stays `FOUR`. The n29 pad placement (`5d8e4b6f8`) made the four WORSE than `20be6ffaa` in every
measured facing (body jump +7 to +21 px); reported to the director, not reverted. The eight is worse than the four
(HEAD) in 3 of 4 facings.** Measured by `node tools/film/cast_war_films.mjs build/look/n29-war8/feet feet` (+ `feet
eight_held`): `cast_feet.tscn` at 64 px/m, the roster's 1.8 m/s, both pitches, right and down-right, analysed by
`tools/art/cast_war_feet.py`, px in the tool's 32 px/m unit; bars sole <= 2, jump <= 12. Four staged copies, the tree
untouched: **before** = `FoeWarCardView` from `20be6ffaa` (held foot; `5d8e4b6f8` changed only the view and its test,
so this is the `20be6ffaa` render without a second worktree), **four** = HEAD (`WALK = FOUR`, pad placement),
**eight** = HEAD with `WALK = EIGHT`, **eight held** = the eight on the `20be6ffaa` view. Two sole readers: *pad* = the
`CastWarAnchors` registered pad (four: lowest band of the cell, contact = drawings 1-2 / 3-4; eight: the foe-eight
windows, contact = drawings 1-4 / 5-8), *n28* = `cast_feet.pile_points`, the n28 audit's reader (four only; U = it
refuses the p70 profile: the rear pad never lifts). Under the pad placement the pad reader reads 0.00 by construction
(the pinned point IS the measured point), so the jump is the number that tells.

| Pitch | Facing | Before (pad / n28 sole, jump) | Four, HEAD | Eight, HEAD | Eight held | Eight vs four (HEAD) |
|---:|---|---:|---:|---:|---:|---|
| 70 | right | 12.50 / U, 16.82 | 0.00 / U, 23.80 | 0.00, 41.54 | 18.16, 10.73 | jump worse (+17.74) |
| 70 | down-right | 18.86 / 24.36, 12.87 | 0.00 / 28.59, 28.77 | 0.00, 37.69 | 27.45, 10.37 | jump worse (+8.92) |
| 55 | right | 21.94 / 28.11, 11.78 | 0.00 / 35.36, 32.50 | 0.00, 30.80 | 20.91, 10.74 | jump better (-1.70) |
| 55 | down-right | 18.64 / 20.94, 12.87 | 0.00 / 43.07, 27.19 | 0.00, 31.60 | 23.86, 9.93 | jump worse (+4.41) |

(n28's main numbers were 24.75 / 22.97 sole, 13.22 / 13.35 jump down-right: the "before" n28 column reproduces them
within 2.1 px on today's tree.) Every cell FAILS a bar. **Why the placement hurts** (frame-by-frame body jumps over the
takes): it pins one registered point per contact, but that point is not one physical pad through the contact. The
four's lowest band flips from the front pad to the rear pad inside a contact (p70 right sole x 191.5 -> 125.5 sheet px
in drawings 3 -> 4: the 21.7 px jump on 3 -> 4; 23.8 on 2 -> 3, the contact boundary, where the body snaps back to the
fighter's ground). The eight's windows register the trailing pad in drawings 4 and 8 of dr / right / ur and the lead
pad in 1-3 / 5-7, so its jumps sit inside a contact where the registered pad changes (p55 right 30.5 / 30.8 on
3 -> 4 / 7 -> 8; down-right 29.3 / 31.6 on 7 -> 8; p70 right 23.8 on 2 -> 3, 26.2 on 7 -> 8) and on the snap to the
fighter's ground at the contact boundary (4 -> 5: p70 right 41.5, down-right 37.7 / 30.7; 8 -> 1: down-right 23.7 /
23.8). On the held-foot view the eight's jump PASSES in every facing (9.93 to 10.74, the four's
before: 11.78 to 16.82) while its sole slides 18-27 px: the art carries the body evenly, the placement does not.
What would fix it (not done, a director call): register per contact the pad that is planted through all of that
contact's drawings (one window per contact, not per drawing), and carry the body across the contact boundary instead
of snapping to the fighter's ground.

**Planted pad per drawing** (read from the packed sheets, `gtai-art/foes-n29/war8/STATE.md`; L / R = screen-left /
screen-right pad, "blob" = both pads overlap in silhouette) for the measured facings, and what the eight's anchor
registers: p70 right R R L L R R R L (the support moves front -> rear twice a cycle, not a 4 / 4 exchange; registered:
front front rear rear front front front rear); p70 down-right L L L R R R R R; p55 right R R R L R R R L (row 2
repeats row 1); p55 down-right L L L R R R R R. The four (`war_machine_armed_walk.png`): the rear pad flat in all four
p70 profile drawings (n28).

Files: `tools/film/cast_war_films.mjs` (the `cast_door_films.mjs` twin: stills / clip / feet; feet walks `before`,
`four`, `eight`, `eight_held`), `tools/art/cast_war_feet.py` (pad / n28 readers, `--film-soles`), a `war_machine` step
entry in `project/dev/cast/cast_feet.gd` (`CastWarAnchors.WALK_STEP_M`). `test_cast_war_machine.gd`: the stand-row pins
now follow `WALK` (`_walk()` / `_stand_row()`), so a later `WALK = EIGHT` is the one generator line.

**Placement reverted (director, 06:28).** `FoeWarCardView` is back to its `20be6ffaa` held-foot behaviour (the one-value
`WALK` switch, `walk_sheet` / `walk_rows` / `walk_step_m` kept; `_plant` / `pad_local` gone), `WALK` stays `FOUR`; the
pad-pinned test is dropped, the held-walk test is the `20be6ffaa` one, the stand-row pins still follow `WALK`. Re-run
(`node tools/film/cast_war_films.mjs build/look/n29-war8/feet_reverted feet four`): pad sole / jump 70 right 12.50 /
16.82, 70 down-right 18.86 / 12.87, 55 right 21.94 / 11.78, 55 down-right 18.64 / 12.87; n28 sole U / 24.36 / 28.11 /
20.94: identical to the "before" column (difference 0.00 px). With the placement gone the "eight held" column is what
`WALK = EIGHT` would ship: jump passes in every facing (9.93 to 10.74), sole slides 18 to 27 px (the four: 12.50 to
21.94); the owner decides. `war8_feet_before_after_64.png` = the four held (left, ships) beside the eight held (right,
staged), and `war8_walk_32.mp4` = the eight held as a staged preview.

## Heights in size_beside_32.mp4, n29

Brief n29-cast-13. Film `gtai-masters/n29/cast/size_beside_32.mp4` (1920x1080, 33.75 s, 32 px/m, tilt 70; its on-screen labels are nominal: 50 px x actor scale). Tool `tools/art/cast_film_heights.py` over 51 frames (1.5 fps, `build/look/n29-size-film/all/`); 50 frames separated all 12 figures. Method: camera and street are static and the row walks, so the per-pixel median of 26 frames is the empty street; a figure is the changed pixels (sum |frame - median| > 60) minus the ground shadow (an even darkening: frame/median 0.45-0.95 with the same ratio in all channels, spread < 0.12), grouped by connected components (5x9 dilation), left to right = warden, contractor, gunner, rocket_trooper, sentry_turret, mulroney, door_carrier, war_machine, cop 0.92, cop 0.85, cop 1.10, rivet. The label bands are cut off at the first dense text row minus 5 px. Height = first to last row with at least 2 changed pixels. Looked at: `crop_{rivet,war_machine,door_carrier,sentry_turret,mulroney}_{10,30}.png` (4x, top red line, bottom green line) and `boxes_*.png`.

Stills column = part B applied, 32 px/m. Unjittered cop: the three film cops divided by their nominal scale (46 / 0.92 = 50.0, 41 / 0.85 = 48.2, 53.5 / 1.10 = 48.6) against the stills' 50.3.

| figure | frames | film px median (min-max) | stills 32 px/m | delta | / Rivet (film, stills) | verdict |
|---|---|---|---|---|---|---|
| appliance_warden | 50 | 51 (43-80) | 51 | 0 | 0.64, 0.66 | PASS |
| contractor | 50 | 50 (34-84) | 49 | +1 | 0.63, 0.64 | PASS |
| robot_gunner | 50 | 55 (42-65) | 55 | 0 | 0.69, 0.71 | PASS |
| rocket_trooper | 50 | 48 (37-53) | 51 | -3 | 0.60, 0.66 | marginal: the film draws the lancer in his walk cell, the still in the aim cell |
| sentry_turret | 50 | 45 (41-48), lower bound | 53 | n/a | - | NOT SEPARABLE: the plate's bottom runs under the name label (stills: plate bottom 50 px below its ground point); every frame hits the label cut, so the 45 is a lower bound, not a height |
| sergeant_mulroney | 50 | 54 (49-65) | 53 | +1 | 0.68, 0.69 | PASS |
| shield_robot (door carrier) | 50 | 63 (54-75) | 56 | +7 | 0.79, 0.73 | OVER the 2 px bar: eye check (`crop_door_carrier_10.png`) shows him whole, facing down, door held in front, top hazard stripe to boots 63; the still faces (1,1) in the idle cell. Cause not measured here (facing and walk cell scale are the candidates) |
| war_machine | 50 | 73.5 (67-82) with its ground shadow | 65 | +8.5 | 0.92, 0.84 | SHADOW NOT REMOVED (it is darker than 0.45 of the street): eye read from the crops, lamp top to foot bottom, 64 (frame 10) and 68 (frame 30): within 3 of the still, no number is claimed beyond that |
| cop 0.92 / 0.85 / 1.10 | 50 | 46 / 41 / 53.5 | 50.3 unjittered | -0.3 / -2.1 / -1.7 | 0.58 / 0.51 / 0.67 | PASS within 2.1 (unjittered 50.0 / 48.2 / 48.6) |
| rivet | 50 | 80 (74-85) | 77 | +3 | 1.00 | +3: walk bob and a facing-down pose; looked at, whole, soles at the lowest row (`crop_rivet_10.png`) |

Could not do: the turret (label overlap, above) and a clean war machine number (shadow). A looser shadow rule (0.2-0.97) was tried and rejected: it also ate outlines (Rivet 76, unjittered cops 47-48). Nothing here is re-rendered; Godot was not run.

## Door carrier height, film vs stills, n29

Brief n29-cast-14. Same 50 frames and method as the section above; `tools/art/cast_film_heights.py` now also writes each figure's bounding box into `h.json`, and the facing of a frame is the direction of the figure's bottom-centre move to the next frame (dominant axis, moves under 8 px skipped; frames at a corner are noisy). Looked at: `build/look/n29-door-height/sheet_door_carrier.png` and `sheet_rivet.png` (4x, frames 3 down, 7 right, 10 up, 14 left, 23 up).

| figure | facing | frames | height median (min-max) |
|---|---|---|---|
| shield_robot (door carrier) | down | 18 | 62 (54-67) |
| | right | 10 | 55 (54-64) |
| | up | 14 | 69 (64-74) |
| | left | 7 | 54 (54-73) |
| rivet | down | 18 | 77 (75-84) |
| | right | 8 | 78.5 (74-81) |
| | up | 16 | 81.5 (74-85) |
| | left | 7 | 78 (75-83) |

Cause: facing. The door carrier is a different drawing per facing: seen from the back (walking up) the door's hazard-striped top edge is held above the head and he reads 64-74 (crop f10, f23); walking down 62; in side view the door is a vertical pole beside him and the figure is 54-55 (crop f7, f14), which matches the 56 of the still (facing (1,1)). The film median 63 is the mix of the four facings (the rectangle walk spends most frames going down and up), so the 7 px gap to the still is the up/down door pose, not a scale error. The max values at corners (73, 75) are the up pose caught early.
Rivet 80 vs 77: the same effect, smaller: down 77 (= still), sides 78-78.5, up 81.5 (back view, helmet and stride taller); the film median is the facing mix, +3 over the down-facing still. Not measured: whether the up-facing door pose is intended art (it needs the sheet, not this film). Godot not run, no code changed beyond the tool's json.

## Pile-driver, n30

Brief n30-cast-02. **`CastWarAnchors.WALK = EIGHT` ships (`bc22b9749`, the owner's n29 pick). Pads by registration
(one planted pad per contact, carried across contacts) was built, measured and NOT committed: it lowers the body jump
but raises the sole slide in every facing, because the art keeps the planted pad torso-fixed through a contact.**
Measured by `node tools/film/cast_war_films.mjs build/look/n30-c02/feet{A,B} feet four,eight[,eight_reg]`:
`cast_feet.tscn` at 64 px/m, 1.8 m/s, px in the tool's 32 px/m unit; bars sole <= 2, jump <= 12. Since `bc22b9749`
the committed tree IS the eight; the tool's `four` stages `WALK = FOUR`. Readers: *pad* = the n29 foe-eight windows
(contact = drawings 1-4 / 5-8, the n29 column's reader), *contact* = the planted pad per drawing (the lower pad blob by
> 6 px, a tie keeps the previous drawing's pad), keyed by its contact (a cyclic run of drawings on one pad).

| Pitch | Facing | Four (pad sole, jump) | Eight, Part A = ships (pad / contact sole, jump) | Eight registered (pad / contact sole, jump) |
|---:|---|---:|---:|---:|
| 70 | right | 12.50, 16.82 | 18.16 / 18.34, 10.73 | 27.76 / 27.93, 8.92 |
| 70 | down-right | 18.86, 12.87 | 27.45 / 36.01, 10.37 | 36.75 / 45.21, 9.49 |
| 55 | right | 21.94, 11.78 | 20.91 / 20.42, 10.74 | 30.00 / 29.50, 1.22 |
| 55 | down-right | 18.64, 12.87 | 23.86 / 39.43, 9.93 | 31.56 / 48.14, 1.51 |

The Part A eight equals n29's "eight held" column to 0.00 px in every cell (18.16 / 10.73, 27.45 / 10.37,
20.91 / 10.74, 23.86 / 9.93). Registered vs Part A: sole +9.6 / +9.3 / +9.1 / +7.7 (pad reader), +9.6 / +9.2 /
+9.1 / +8.7 (contact reader), jump -1.81 / -0.88 / -9.52 / -8.42: worse on the failing bar in every facing, so
not a net win.

**Why registration cannot pass on this art** (planted pad x per drawing, sheet px from the torso, from the packed
sheets; "carry" = how far the drawn body moves over the planted pad through the contact, "need" = the fighter's path
through the contact (drawings x 0.3244 m) minus the carry, both px at 32 px/m: what the card must either slide the
pad by or jump the body by at the boundary):

| Pitch | Facing | Contacts: drawings, planted pad x, carry, need |
|---:|---|---|
| 70 | right | R 1-2: +40 +17, 7.9, 12.9; L 3-4: -51 -52, 0.2, 20.6; R 5-7: +42 +17 +34, 2.8, 28.3; L 8: -38, 0, 10.4 |
| 70 | down-right | L 1-3: -28 -29 -30, 0.3, 30.8; R 4-8: +65 +38 +39 +40 +42, 8.2, 43.7 |
| 55 | right | R 1-3: +30 +28 +28, 0.7, 30.4; L 4: -54, 0, 10.4; R 5-7: +32 +29 +29, 1.2, 29.9; L 8: -55, 0, 10.4 |
| 55 | down-right | L 1-3: -28 -28 -29, 0.3, 30.8; R 4-8: +53 +48 +50 +50 +56, -1.0, 53.0 |

The drawn body advances over the planted pad only in p70 right 1 -> 2 and 5 -> 6 (about 8 px each); everywhere else
the planted pad sits at a fixed offset from the torso for the whole contact (it steps in place). With sole <= 2 the
boundary jump must be the "need" (10.4 to 53 px, over the 12 bar in 6 of the 8 multi-drawing contacts); with jump
<= 12 the pad must slide by need - 12. Both bars at once need art where the planted pad moves back about 10 px
(at 32 px/m, about 30 sheet px) per drawing through every contact: in the right facing that is drawings 3-4 and 5-8 at
p70 and 1-3 / 5-7 at p55, in down-right 1-3 and 4-8 at both pitches. A director call (one-row image edits; the brief's
fallback named p70 right 3-4 and 7-8, the table says those and more).

The registered view as built (kept as `build/look/n30-c02/register_pads.patch`, not in the tree): generator
`cast_war_soles.py` emits `CONTACT70` / `CONTACT55` (Vector3 planted pad x, y, first drawing of its contact);
`FoeWarCardView.REGISTER_PADS` holds the contact's pad at one ground point, lands a new contact's pad where the card
already stands (no body jump) and drags the pad once the card lags the fighter by more than `CATCH_UP_M = 0.25` m;
`cast_war_feet.py --reader=contact`; `cast_war_films.mjs` walk `eight_reg`. Not committed: it loses, and as built it
pushes the view to 222 lines and the generated anchors to 236 (soft cap 200, debt ratchet) with `sample` at 43 lines.

Ships: the Part A eight. Still `build/look/n30-c02/war8_feet_before_after_64.png` (64 px/m, right, same tick: the
four staged left | the eight that ships right; "Part A eight | what ships" would be one picture twice). Clip
`gtai-masters/n30/cast/war8_walk_32.mp4` (the committed eight, 32 px/m, right then down-right; ffprobe 1920x1080,
60 fps, 25.85 s). Mutate: not run, the view has no committed changed line (Part A changed only the generated
constant `WALK`; the registered code is not in the tree).

## Patrol cop build jitter, n30

Owner pick: a cop's whole-figure build varies +-8 % (`StreetCrowdCards.COP_SCALE_VAR` 0.08, `body_scale_of(rig)`: a rig whose plan `art_dir` is `cop`, plus the arena wave cop in `arena_wave_cards.gd`), the crowd keeps +-16 % (`SCALE_VAR`, byte-identical per id: unit test over ids 0..999). Commit `c2281acbb`.

Measured (re-run of `cast_size_beside.gd`, 64 px/m, tilt 70, `tools/art/cast_size_measure.py`): patrol cop actor id 1 is 93 px (n29: 86 at jitter 0.855; now 1 + 0.08 x vary = 0.927 x 100.6 = 93.3 predicted). Rivet 154 px. The unjittered cop is 100.6 px (n29 measurement). The min and max rows were first COMPUTED; they are now MEASURED in `cop_jitter_64.png` (`project/dev/cast/cast_cop_jitter.gd`, not yet committed: the `dev_loc` debt ratchet refuses +85 lines, NEED director; cops spawned with Fighter.id forced to 710, 793 (vary 0.00002, the unjittered build) and 230, beside the card foes and Rivet, `tools/art/cast_size_measure.py`): 92 / 100 / 108 px. `vary(710, 3)` = -0.9966 and `vary(230, 3)` = +0.9994 are the extreme ids over 0..999.

| cop | scale before (+-16 %) | px at 64 before | scale after (+-8 %) | px at 64 after | / unjittered (after) | / Rivet 154 (after) |
|---|---|---|---|---|---|---|
| min (id 710) | 0.841 | 84.6 | 0.920 | 92 (measured; computed 92.6) | 0.920 | 0.60 |
| unjittered (id 793) | 1.000 | 100.6 | 1.000 | 100 (measured) | 1.000 | 0.65 |
| max (id 230) | 1.160 | 116.7 | 1.080 | 108 (measured; computed 108.6) | 1.080 | 0.71 |
| id 1 (measured) | 0.855 | 86 | 0.927 | 93 | 0.927 | 0.60 |

Same run, card foes beside the cop (64 px/m, px): contractor 100, appliance_warden 101, rocket_trooper 100, robot_gunner 110, robot_thug 141 (the other n30 lanes' changes are in this tree; not this part's). Known gap: `kill_fall_cells.gd` `victim_scale` sizes a killed pose-less cop by `body_scale(actor_id)` (0.16), so a killed street cop would jump to the crowd build at death (NEED combat). Card cops with a cast row are unaffected (they use `scale_of`).

## Door eight with three more edits, n30

**Verdict: WALK stays FOUR.** The eight now passes both bars at p70 (right and down-right), but p55 still blocks it:
p55 right sole 2.15 (four 2.03, bar 2) and jump 7.69 (four 5.09), p55 down-right sole 3.06 (bar 2) and jump 11.93 (four
10.43). Three one-row image edits (`gtai-art/foes-n30/door8c`, 3 images, no retries): p55 drawing 8 right (rear support
boot set forward to drawing 4's place) and down-right (rear boot set down onto the floor plane; the x part of the ask,
~36 source px forward, was NOT drawn), p70 down-right drawing 1 (front boot set forward, level with drawing 5's). Each
edit re-encoded its whole row, so only the redrawn grid cell was spliced into the accepted source
(`door8c/out/<job>_splice.png`, other cells' silhouettes xor 0). `tools/art/cast_door_eight.py` `REDRAWN` cuts from the
three splices and replaces only those sheet cells; the n29 p70 right row 7 keeps its bytes (re-toning moves it a level,
so it left `REDRAWN_CELLS`). Byte compare against the previous sheets: p70 39 of 40 cells identical (dr 1 changed,
silhouette xor 490 px), p55 38 of 40 (right 8: 577, dr 8: 436). Key-lead 0, strict red 0 at both pitches; body heights
unchanged but p70 dr 146.0 -> 146.4. Registered soles (`cast_door_soles.py`, sheet px from the cell centre): p55 right 8
-47 -> -42 (drawing 4: -43.5), p55 dr 8 (-33, -9.5) -> (-32, -0.5) (depth fixed, x not), p70 dr 1 11 -> 16.5.
`EIGHT_STEP_M` 0.1842 -> 0.1799 (the measured mean, so every eight number below moved, the unedited p70 right too).
Commit `da11ce846`.

Feet (`node tools/film/cast_door_films.mjs build/look/n30-c05/feet feet`, `cast_feet.tscn` at 64 px/m, 1.6 m/s,
`cast_door_feet.py`, px in the tool's 32 px/m unit; the four re-measured to the hundredth of n29). Bars: sole <= 2,
jump <= 12. Culprit = the scratch probe (`build/look/n30-c05/probe.py`, the n29-11 probe) over the takes: worst jump
(from -> to drawing), worst sliding contact (drawings).

| Pitch | Facing | Four (sole / jump) | Eight n29 (with f7) | Eight with the n30 edits | Eight vs four | Culprit (eight n30; four where over a bar) |
|---:|---|---:|---:|---:|---|---|
| 70 | right | 2.42 / 4.34 FAIL | 2.04 / 6.47 FAIL | 1.96 / 6.61 PASS | within both bars | four: sole 2.42 on 3-4; eight: jump 4 -> 5, sole 1-4 |
| 70 | down-right | U / 10.50 | 1.39 / 12.21 FAIL | 1.39 / 12.00 PASS | within both bars (jump at the bar) | eight: jump 12.00 on 8 -> 1 (was 12.21), next 11.29 on 4 -> 5 |
| 55 | right | 2.03 / 5.09 FAIL | 2.16 / 9.61 FAIL | 2.15 / 7.69 FAIL | sole +0.12, jump +2.60: BLOCKS | four: sole 2.03 on 3-4; eight: jump 7.69 on 7 -> 8 (was 9.61), sole 2.15 on 5-8 |
| 55 | down-right | U / 10.43 | 3.45 / 13.28 FAIL | 3.06 / 11.93 FAIL | sole over the bar, jump +1.50: BLOCKS | eight: jump 11.93 on 4 -> 5 (7 -> 8 now 9.14, was 13.28), sole 3.06 on 5-8 |

The edits did what they targeted: p55 right 7 -> 8 jump 9.61 -> 7.69, p55 down-right 7 -> 8 13.28 -> 9.14, p70
down-right 8 -> 1 12.21 -> 12.00 (just inside). What still blocks: p55 down-right's second contact (drawings 5-8) slides
3.06 px, because drawing 8's rear boot stayed 13.5 sheet px behind drawing 4's in x (the edit fixed only its depth),
and its worst jump is now 4 -> 5 (11.93, the first-to-second contact boundary); p55 right is within 0.15 px of the four's
sole but its jump stays 2.6 px over the four's (7 -> 8 still the largest). Next edit, if the director wants one: p55
down-right drawing 8 again with the x ask alone (rear boot ~1/2 foot forward, same depth), then re-measure 4 -> 5.
Still `gtai-masters/n30/cast/door8_edits_64.png` (`cast_door_films.mjs stills`: p70 right, tick 150, four left, eight
right, sole brackets; no edited drawing is in that frame); old | new cell crops of the three edits (with the preceding
drawing) `build/look/n30-c05/edited_cells_2x.png`.

## Door eight, p55 round, n30

**Verdict: WALK stays FOUR; the art ships (`15590aa9b`).** Two one-cell edits make both blocking p55 numbers better and none
worse (p55 right 2.15 / 7.69 -> 2.05 / 6.98, p55 down-right 3.06 / 11.93 -> 2.72 / 11.78; p70 sheet byte-identical), but
neither p55 facing reaches the owner's rule yet: right sole 2.05 (bar 2), down-right sole 2.72 (bar 2).

Plan (from `EIGHT55` at `da11ce846` and the probe, per drawing sole x in sheet px from the cell centre, D1..D4 | D5..D8):
right 14, 10.5, 6, -43.5 | 15, 11, 11.5, -42: half B stalls on 6 -> 7 (-0.5 where half A advances 4.5) and then takes 53.5 on
7 -> 8 (half A 49.5); the contact slide follows the largest knot gap inside the contact (2.00 at 49.5, 2.15 at 53.5).
Down-right (x, y) (29.5, 17.5) (30.5, 17.5) (30.5, 17.5) (-18.5, 0.5) | (4, 23.5) (22.5, 21.5) (16.5, 21.5) (-32, -0.5):
the boot landed in D5 sits 18.5 px behind where D6 plants it, so the body runs backwards inside the 5-8 contact.
p55 right's jump under the four's 5.09 is out of reach of any one cell (3 -> 4 is 6.77 and 4 -> 5 6.98, neither touches
D7/D8), so right takes the bars route (jump already <= 12, sole must go <= 2). Cells: right D7 support boot back ~5 sheet
px (~12 source px, landmark: the toe-to-bar gap as wide as the bar, as in D3); down-right D5 landed boot right ~20 sheet
px (~45 source px, landmark: centred under the slab's lower edge, as in D6). Neither cell is in `EIGHT_STEP_M` (right
D1/D4/D5/D8 only): 0.1799 unchanged.

Images (`gtai-art/foes-n30/door8d`, 6 of 8, Ref 1 = the current source row incl. the n30 drawing 8 splice): right f7
accepted (boot 193-295 -> 185-287 source px, D3's place); down-right f5 accepted as partial (boot 189-277 -> 211-301, half
the ask); f5b / f5c / f5d (further, toe under the slab's right corner, copy D6's leg) moved the boot 3 / 0 / 0 px: the
model holds that boot. Right f7b ("a few px more") overshot (169-269): measured, worse, not shipped. Each splice: other
cells' silhouettes xor 0; sheet byte compare vs the previous p55 sheet: 38 of 40 cells identical (right 7: 343 px,
down-right 5: 601 px); p70 byte-identical. Registered soles: right D7 11.5 -> 8, down-right D5 4 -> 13.

Feet (`node tools/film/cast_door_films.mjs build/look/n30-c16/feet feet`, sole / jump, tool's 32 px/m unit; culprit =
`build/look/n30-c16/probe_all.py`, worst jump per transition and worst contact):

| Pitch | Facing | Four | Eight n30 (`da11ce846`) | Eight c16 (`15590aa9b`) | Culprit (eight c16) |
|---:|---|---:|---:|---:|---|
| 70 | right | 2.42 / 4.34 | 1.96 / 6.61 PASS | 1.96 / 6.61 PASS (sheet unchanged) | jump 4 -> 5, sole 1-4 |
| 70 | down-right | U / 10.50 | 1.39 / 12.00 PASS | 1.39 / 12.00 PASS (sheet unchanged) | jump 8 -> 1 |
| 55 | right | 2.03 / 5.09 | 2.15 / 7.69 FAIL | 2.05 / 6.98 FAIL | jump 4 -> 5 (7 -> 8 now 6.88, was 7.69), sole 2.05 on 5-8 (1-4: 2.00) |
| 55 | down-right | U / 10.43 | 3.06 / 11.93 FAIL | 2.72 / 11.78 FAIL | jump 4 -> 5, sole 2.72 on 5-8 (1-4: 1.69) |

What the rejected f7b taught: right D7's sole at 11.5 / 8 / 0 gives the 5-8 slide 2.15 / 2.05 / 2.23, a minimum near 6.5 of
about 2.04, so D7 alone cannot bring p55 right under 2; the 5-8 contact needs a second cell (D8 moves `EIGHT_STEP_M` and so
every facing; D5 / D6 do not). Down-right needs the D5 boot ~11 sheet px further right (an image edit would not move it:
three asks, 3 / 0 / 0 px) or D6 and D7 set back to meet it, and very likely D8 forward as well (7 -> 8 knot gap 53 vs half
A's 52). Next round, if wanted: down-right D6 + D7 boots back (the model moves boots back readily, and overshoots: ask
for half), then re-measure; right D5 or D6 as the second cell. Crop of the two edited sheet cells with their neighbours
and registered soles: `build/look/n30-c16/edited_cells_sheet_2x.png`.

## Door eight, p55 round 2, n30

**Verdict: WALK stays FOUR; the art ships (`4c62f3b65`, `6ee306fd8`).** Three one-cell edits to p55 down-right (drawing 6,
then drawing 7 twice; the second D7 replaces the first) take its 5-8 contact slide 2.72 -> 2.08 with the jump unchanged
(11.78) and p70 byte-identical, but no facing newly passes: p55 down-right sole 2.08 (bar 2), p55 right 2.05 (bar 2).

What the probe says (`build/look/n30-c17/probe_all.py`, round 1's probe plus the per-frame track of each slipping
contact; every drawing restarts the planted sole at 0, so the slide is the worst drift inside one drawing's hold):
- p55 right 5-8: holds drift D5 -0.60, D6 -0.31, D7 -1.93, D8 -2.04. D5 and D6 do not set the number; the D8 hold
  does (half A's D4 hold: -1.93). The right drawing 6 edit (`door8e` right f6, support boot 193-299 -> 192-297 source px,
  registered sole 11 -> 12) measured 2.05 / 6.98, identical, and 7 -> 8 jump 6.88 -> 6.92: not shipped. Neither D5 nor D6
  can bring p55 right under 2; only D8 (`EIGHT_STEP_M`, every facing) can, and that stays out of scope.
- p55 down-right 5-8 at `15590aa9b`: holds D5 +0.38, D6 +0.37, D7 -2.33 (diameter 2.71): the planted boot slid forward
  across D5 -> D6 (registered x 13 -> 22.5). D6 back to D5's place (226-332 -> 215-301 source px, sole 22.5 -> 13.5) and
  D7 a few px back (218-310 -> 216-303, 16.5 -> 15) remove the forward drift (D5 / D6 holds +0.06 / +0.08): 2.15. D7 rolled
  back about a tenth of a boot (216-303 -> 200-286, 15 -> 8.5): 2.08, 7 -> 8 jump 8.79 -> 8.50. What is left is the late
  D7 hold (-1.97; half A's D3: -1.67), the body running into the D8 knot: like right, a D8 matter.

Images (`gtai-art/foes-n30/door8e`, 5 of 6, Ref 1 = the current source row incl. every accepted splice): dr f6
accepted (asked "toe where drawing 7's toe ends", toe moved 31 px, landing on D5's place, as the overshoot rule predicts);
dr f7 accepted ("a few pixels", 7 px); right f6 measured, no change, not shipped; dr f7b ("heel in line with D5 / D6",
Ref 1 = the f6 + f7 splice) moved 0 px, not used; dr f7c ("rolled back about a tenth of a boot") 16 px, accepted. dr f6
stalled in `gen.mjs`; copied by hand from `~/.codex/generated_images/`. Every splice: other cells' silhouettes xor 0;
LOOKED at the 2x crops (identity, slab, body unchanged). Sheet: 38 of 40 p55 cells byte-identical to `15590aa9b` (down-
right rows 6 and 7 changed), p70 byte-identical, `EIGHT_STEP_M` 0.1799 unchanged. Crop of the sheet's down-right
drawings 5-8 before / after: `build/look/n30-c17/edited_cells_sheet_2x.png`.

Feet (`node tools/film/cast_door_films.mjs build/look/n30-c17/feet3 feet`, sole / jump, tool's 32 px/m unit):

| Pitch | Facing | Four | Eight c16 (`15590aa9b`) | Eight c17 (`6ee306fd8`) | Culprit (eight c17) |
|---:|---|---:|---:|---:|---|
| 70 | right | 2.42 / 4.34 | 1.96 / 6.61 PASS | 1.96 / 6.61 PASS (sheet unchanged) | jump 4 -> 5, sole 1-4 |
| 70 | down-right | U / 10.50 | 1.39 / 12.00 PASS | 1.39 / 12.00 PASS (sheet unchanged) | jump 8 -> 1 |
| 55 | right | 2.03 / 5.09 | 2.05 / 6.98 FAIL | 2.05 / 6.98 FAIL (cells unchanged) | jump 4 -> 5, sole 2.05 on the D8 hold of 5-8 |
| 55 | down-right | U / 10.43 | 2.72 / 11.78 FAIL | 2.08 / 11.78 FAIL | jump 4 -> 5, sole 2.08 on the late D7 hold of 5-8 |

Next, if wanted: both remaining p55 soles sit in the hold before drawing 8 (right D8 hold -2.04, down-right D7 hold
-1.97), so the only one-cell lever left is drawing 8 itself, which moves `EIGHT_STEP_M` and so every facing at both
pitches; it needs the director's call and a full re-measure. No further D5 / D6 / D7 edit is expected to cross 2.

## Door eight, p55 drawing 8, n30

**Verdict: no drawing-8 move works; no images, no art change, WALK stays FOUR.** No p55 right drawing-8 sole move brings
p55 right's sole to 2 or under while p70 keeps passing, so the round stopped after the computation (`door8f`: 0 images).

Method (no Godot; scratch `build/look/n30-c19/`, `model.py`, `predict.py`, `scan.py`, `scan_fine.log`): a port of
`StreetCopWalk.Contact` and `StreetPatrolPose` (pose, settle, centre stance) reads `EIGHT70` / `EIGHT55` and recomputes
`EIGHT_STEP_M` the way `cast_door_soles.py` does. On c17's tracks (`build/look/n30-c17/feet3`) it reproduces the drawing
sequence in all four facings (225 of 225 frames) and the card shear within 0.02-0.10. The tracks show that a planted
sole drifts inside one drawing's hold by the change in lean times the registered sole's height below the cell pivot
(p55 right drawing 8: 0.200 x 20.5 / 2 = 2.05 tool units, measured 2.04). The roll pivots on the cell's pivot line,
not on the sole. Prediction = the feet3 hold drift + the model's change for a drawing-8 sole moved dx sheet px (right p55
drawing 8 moves `EIGHT_STEP_M` by 0.000868 m per px; down-right drawing 8 is not in the step).

| Move (sheet px) | `EIGHT_STEP_M` | p70 right | p70 down-right | p55 right | p55 down-right |
|---|---:|---:|---:|---:|---:|
| none (c17, measured) | 0.1799 | 1.96 (D1) | 1.36 (D7) | 2.04 (D8), 2.00 (D3) | 1.97 (D7) |
| right D8 -6 / -3 | 0.1851 / 0.1825 | 2.16 / 2.12 | 1.36 / 1.35 | 2.08 / 2.05 | 1.97 / 1.95 |
| right D8 +3 / +6 / +10 | 0.1773 / 0.1747 / 0.1712 | 2.09 / 2.02 / 1.99 | 1.37 / 1.38 / 1.41 | 2.21 / 2.30 / 2.36 | 1.99 / 2.00 / 2.04 |
| right D8 +12 / +16 / +20 | 0.1695 / 0.1660 / 0.1625 | 1.99 / 1.96 / 1.89 | 1.41 / 1.37 / 1.34 | 2.03 / 2.31 / 2.06 | 1.86 / 1.82 / 1.75 (dr +4) |
| down-right D8 +3 / +6 / +10 | 0.1799 | 1.96 | 1.36 | 2.04 | 1.84 / 1.72 / 1.66 (D3) |

(worst hold's x drift in tool units, bar 2; the rows marked "dr +4" also move down-right drawing 8 by +4.)

Why: the right drawing-8 hold drifts with the lean from the drawing-7 knot to the next half's drawing-1 knot. Moving the
drawing-8 sole shifts lean between the drawing-7 and drawing-8 holds, but their sum stays the same. The step change it
brings moves every half-boundary hold (p70 right D1, p55 right D4 / D8). No step in the scanned range (0.1625-0.1886) puts
p55 right under 2. p55 right's half-A drawing-3 hold (2.00) does not depend on drawing 8 at all. Down-right drawing 8 forward 3-6
sheet px (about 7-15 source px) would take p55 down-right under 2 and move nothing else. That alone does not pass the
owner's rule, so it was not drawn.

Caveat: the model matches the mid-half holds (p55 right D3 2.03 vs 2.00 measured, D7 1.97 vs 1.93) but reads low on
the half-boundary holds (p55 right D8 1.71 vs 2.04, p70 right D1 1.00 vs 1.96; the settle and stance shift). Its deltas
there jitter with dx because of frame sampling. The right-facing verdict rests on those holds; a Godot re-measure of
one candidate would settle it.

Next, if wanted (director's call): down-right drawing 8 forward (fixes p55 down-right alone). p55 right needs a non-D8 change
to both its drawing-3 hold (2.00) and its drawing-8 hold (2.04), or a pose-code change (roll the hold about the
registered sole, not the pivot line), which would move every facing of every foe eight and is not this lane's.

## Held walk cell pins the sole, n30

**Fault (c20).** The gap between the registered anchor and the feet reader is 0. Inside a held walk drawing, though, the
line that stays still is the cell pivot (y 168), not the registered sole (y 188.5), in all 8 takes:
`FoeShieldCardView.update_fighter` sets `position = last_ground` on a held cell. That throws away the
`StreetPatrolPose` shear about the registered sole, so the drawing leans about its pivot.

**Fix tried (c21a, committed dae6d8982).** On a held cell: `position += last_sole - transform * _sole_local()`, which
pins the registered sole. c21a's feet table (`cast_door_films.mjs ... feet`, 64 px/m, sole / jump, bars 2 / 12):

| walk | p70 right | p70 down-right | p55 right | p55 down-right |
|---|---|---|---|---|
| four before | 2.42 / 4.34 | U / 10.50 | 2.03 / 5.09 | U / 10.43 |
| four sole pin | 0.00 / 3.41 | U / 10.39 | 0.00 / 4.07 | U / 9.66 |
| eight before | 1.96 / 6.61 | 1.39 / 11.999 | 2.05 / 6.98 | 2.08 / 11.78 |
| eight sole pin | 0.00 / 7.95 | 0.00 / 12.04 | 0.00 / 5.03 | 0.00 / 11.77 |

**Delivered frames (c21b).** Door four, p70 right, 64 px/m, 1920x1080 raw movie, before fe4139075 and after dae6d8982,
same ticks. Horizontal shift of a screen row band from the first frame of each held drawing to its last (SSD with a
sub-pixel fit, `build/look/n30-c21/c21b_holds.py`, frames `build/look/n30-c21/c21b/{sb,sa}`):

| band (screen rows) | 11 holds, ticks 114-180 | before | after |
|---|---|---|---|
| 527-533 (boot bottom) | mean / max of the absolute slide | 0.86 / 1.65 px, backward | 1.60 / 3.15 px, forward |
| 520-527 (boot) | mean / max of the absolute slide | 0.09 / 0.20 px | 2.56 / 5.03 px |

The still line moves from the boot (y ~524) to y ~541, the marker row, about 7 px below the drawn sole. The front boot
heel goes 934 -> 933 before and 934 -> 938 after over hold 132-138. Strip: masters `n30/cast/door_sole_pin_64.png`.

**Verdict.** NOT shipped. The feet reader tracks the registered point. That point sits about 7 screen px below the drawn
boot at 64 px/m, so the reader cannot see the drawn boot slide. Pinning the registered point moves the slide onto the
boot that the player actually sees. Reverted in 97bb564a2, so the pivot pin ships again. Mutate on dae6d8982 lines 60 and
71: 0 / (0 + 2) killed, 2 invalid, so the unit tests do not pin either behaviour.

War card: see c21w (`build/look/n30-c21w/NOTES.md`). The war card applies no lean, so its pivot pin is already the
sole pin.

Next: register the door sole at the drawn boot bottom (this regenerates every door anchor), then measure with
`c21b_holds.py` in the delivered frames, not with the feet reader alone.

## Door four and eight on the drawn boot, n30

**Verdict.** On the drawn boot the eight does not pass the 2 px bar in every facing: its in-hold slide reaches 2.03 at
p55 down-right (2.00 in x alone). It beats the four only at p70 right (1.71 against 2.10). At p70 down-right, p55 right
and p55 down-right it is worse than the four. The contact slide (plant to lift across all drawings of one contact) is
**not measured**: the tracker below could not hold one boot through a drawing change. `CastDoorAnchors.WALK` is unchanged.

**Method (c22, measure only; scratch `build/look/n30-c22/`).** `c22_clip.mjs` renders the door carrier through
`runGodot` (one launch per take, 8 launches, each `exit 0` in 19-22 s, 325 frames 1920x1080 by ffprobe) at 64 px/m, 1.6
m/s, 300 ticks. The takes cover the four and the eight, p70 and p55, right and down-right. All renders come from staged
copies, so the tree is untouched:
- eight = `CastDoorAnchors.WALK = EIGHT`, the same switch `cast_door_films.mjs` uses;
- p55 = `_pitch = 55` in the staged `cast_foot_film.gd`;
- every staged film drops the sole-dot overlay, so the frames hold only the drawn art, and logs the drawn card row and
  `xf` and the registered sole point for each tick.

`c22_measure.py` then works on the frames:
- **Alignment.** Movie frame = tick + 24. The image-change spikes fall exactly on the logged drawing changes.
- **Background.** A per-pixel median over the take is subtracted, so the grid and Rivet do not pin the SSD.
- **In-hold slide.** This is c21b's method. The boot band is the lowest 7 ink rows of the carrier within 120 px of the
  registered sole in each hold's first frame. Band rows: right 537-544 at p70 and 537-552 / 538-544 at p55. Down-right
  rows follow the walk (368-727). The band's shift from the hold's first frame to its last uses SSD over +-10 px x and
  +-3 px y with a parabolic sub-pixel fit.

These band rows are the drawn sole. c21b's 527-533 band sits about 10 px higher, nearer the pivot (y ~524), which is
why its four p70 right read 0.86 / 1.65 and this one reads 2.13 / 4.20. Every slide is backward (negative x).

| take (64 px/m, 300 ticks) | holds | in-hold mean / max, 64 px/m | in-hold mean / max, 32 px/m | feet reader sole (32 px/m) | contact slide |
|---|---:|---|---|---:|---|
| four p70 right | 50 | 2.14 / 4.20 | 1.07 / **2.10** | 2.42 | not measured |
| four p70 down-right | 50 | 1.44 / 2.99 | 0.72 / 1.50 | U | not measured |
| four p55 right | 50 | 1.82 / 3.06 | 0.91 / 1.53 | 2.03 | not measured |
| four p55 down-right | 50 | 2.01 / 3.87 | 1.01 / 1.94 | U | not measured |
| eight p70 right | 45 | 2.46 / 3.42 | 1.23 / 1.71 | 1.96 | not measured |
| eight p70 down-right | 45 | 1.74 / 3.78 | 0.87 / 1.89 | 1.39 | not measured |
| eight p55 right | 45 | 1.94 / 3.43 | 0.97 / 1.72 | 2.05 | not measured |
| eight p55 down-right | 45 | 1.46 / 4.06 | 0.73 / **2.03** | 2.08 | not measured |

(magnitude of the (x, y) shift; the x shift alone is within 0.06 px of it (eight p55 down-right 4.00 / 2.00). Rivet
stands in the walk path in 4-9 holds per take, reported apart by the tool, and none of those sets a maximum. The worst
hold of each take: four p70 right ticks 108-114 (drawing 2); eight p55 down-right ticks 48-53 (drawing 7), where the
boot's toe goes from x 869 to about 865 at the 4x zoom while the body runs on.)

**Contact slide: why it is not measured.** Three trackers were tried on the planted boot (`c22_measure.py` keeps the
last one):
- a 44x14 SSD patch chained across drawing changes;
- one plant-frame template matched in every frame within +-16 px;
- a run of ground-touching columns.

All three gave 6-24 px per contact, often at the search clamp (16.00), and none of those readings survives a look. At
the four p70 right drawing change 0 -> 1 (frames 121 / 126, 5x zoom, `build/look/n30-c22/tmp/z5.png`), the near boot's ground run moves
from 862-893 to 841-877, while a darker boot about 5 px higher (the far leg) holds 861-888. From the frames alone it is
not clear which boot the drawing means to plant, so no contact number is quoted. The registered sole itself holds within
2.5 px across the four's contact (878.8 -> 876.3 screen px).

**Looked.** `build/look/n30-c22/looks_2x.png` has one 2x crop per take at the plant frame of the contact with the worst hold.
- Right facings: carrier, door bar and boots read cleanly, with no smear or doubled edge.
- Down-right: the crop centres on the registered sole from the profile column, so the boots sit low in the crop, and
  Rivet's dome covers the boots early in the walk.

`build/look/n30-c22/eight_p55_contact_2x.png` shows frames 51 / 60 / 72 / 77 of eight p55 down-right ticks 27-53, one fixed 2x crop:
- the red lines mark the boot's toe (x 869) and the ground row (y 448) at the worst hold's first frame;
- in 51 / 60 the carrier's boots are behind Rivet;
- in 72 -> 77 the front boot's toe slides about 4 px back off the line while the shield and body move on.

Next (director): whether the drawn boot is planted at all across the four's drawings 0 -> 1 needs an owner look at
`build/look/n30-c22/tmp/z5.png` or a per-drawing boot label from the art. A contact number is meaningful only after that.
