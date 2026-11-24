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

## Sergeant Mulroney card admission, 2026-11-23

| Archetype | Renderer | Identity | Walk | Attack/tell | Hit | Death | Facings | Grid | Pitches | Scale | Ink | Palette | Cut | Feet | Shadow | Provenance | Enabled |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `sergeant_mulroney` | Human cast card on the prologue formation boss | PASS | PASS | PASS in staged fight | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS (9.59 px worst fight jump) | PASS | PASS 10/10 | **true** |

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
