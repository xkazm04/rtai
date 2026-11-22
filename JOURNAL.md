# JOURNAL - lane cast (n24, branch n24-cast)

## Session 1 (17:24)
- 17:25 start. main = b3f4727c0, tree clean. No `NEED cast` in the other four journals. No astra.lock in logs/cast.
- 17:28 Godot --import done (build/dev/import-n24.log, 0 errors).
- 17:26 read: enemies.json has 12 archetypes; the four new ones are rig placeholders (rocket_trooper wears the swat rig
  + FoeLauncherView; sentry_turret hides the rig and draws FoeTurretView; shield_robot / war_machine are the thug robot
  rig scaled 1.18x / 1.65x in FoeLooks.robot_plan). The cop standard: library keyed sheets (5 facings x 4 stride, 192 px
  cells) cut by tools/art/street_walk.py, toned by tools/art/street_tone.py, one provenance line per file.
  Owner's concept picks: gtai-art/foes-n22/out/{rocket-trooper-b,sentry-turret-a,shield-robot-a,war-machine-b}.png.
- 17:27 ASTRA RUNNING audit since 17:27 (pid 35848; brief evidence/briefs/n24-cast-01-audit.md: audit + checklist + contact sheet + lancer gen round). Note: first wrote the brief over an old tracked 01-audit.md from an earlier lane; restored it with git checkout, my briefs carry the n24-cast- prefix.
- 17:55 looked at the audit lineup (gtai-masters/n24/cast/audit_lineup_*): turret / shield robot / war machine are vector
  placeholders with borrowed thug claws; shield robot 121 px and war machine 178 px against Rivet 77 px, patrol 43 px (32 px/m, tilt 70).
- 18:12 reviewed the lancer round (gtai-art/foes-n24/out): armed_walk_70, attack_70 (kneel tell, backblast), hit_70 ACCEPTED;
  fall_70 REJECTED take 1: he dives prone still aiming the tube, reads as taking cover, not dead. Lancer takes: walk 1, attack 1, hit 1, fall 1 (rejected).
- 18:14 DECISION cast: the door carrier's slab is drawn 0.64 m wide = 2 x FoeShield.SLAB_HALF_M (0.32), the shove's own
  hit width; target height ~2.0 m beside Rivet's 1.65. Brief 02 written (evidence/briefs/n24-cast-02-lancer.md).
- 18:22 ASTRA audit 54 accepted (commit da91b9083: docs/art/cast-audit.md, docs/art/cast-checklist.md, tools/art/cast_metrics.py;
  lineup dev scene left staged behind the debt ratchet: granted in brief 02). MILESTONE audit da91b9083.
- 18:22 ASTRA RUNNING lancer since 18:22 (pid 41084; brief evidence/briefs/n24-cast-02-lancer.md: fall retake + door carrier round, lancer cut + in-game cards behind one switch, stills).
- 18:25 checked the other four journals: no `NEED cast`.
NEXT: (session 2) check logs/cast/astra.lock + astra-calls.jsonl; if `lancer` is done, read its out file
  (evidence/briefs/n24-cast-02-lancer.out.txt) and diff; look at every lancer cell + gtai-masters/n24/cast/lancer_*.png
  yourself at 32/64 px/m; review the fall retake and the door-carrier sheets in gtai-art/foes-n24/out (slab 0.64 m wide,
  ~2.0 m tall, power-down death). Brief 03: lancer film in a gauntlet wave + beside cop/Rivet (walk, tell, fire, hit, death;
  32 and 64 px/m, ffprobe 15-40 s) and fixes; door carrier cut + wire through cast_cards.json (FoeShieldView plate and
  thug-rig scale go behind the switch); start the clamshell round (sentry-turret-a). Then pile-driver (war-machine-b, say
  its height in m beside Rivet; not a giant), then warden/Mulroney if time; item 5 = the standing-rule section in
  docs/art + a docs/decisions.md line. Last code commit by 00:00, gate `node tools/gate/run.mjs --rev=HEAD` by 00:15.
- 18:45 Astra lancer (still running) has committed 895cf34c1 (lineup dev scene + debt baseline) and 0c7c09e39 (lancer packed
  at both pitches); staged, not yet committed: cast_cards.json + schema, cast_cards.gd / cast_card_pose.gd / cast_far_card.gd,
  foe_cast_view.gd, tests test_cast_card(s|_pose).gd, one-line(?) edits in arena_rigs.gd, arena_wave_cards.gd,
  street_walker_cards.gd, street_walker_fall.gd, foe_launcher_view.gd (verify each is a call site only).
- 18:46 reviewed round 2: rocket_trooper_fall_70 take 2 ACCEPTED by eye (thrown back, tube dropped beside him, limp; 3 poses);
  RISK: the dropped tube is a separate blob in the cell, check the cutter kept it (no orphan tube cut away / no tube in the
  wrong cell). Astra also rejected rocket_trooper_hit_55 v1 (wrong back facing). shield_robot_armed_walk_70 take 1 ACCEPTED by
  eye: slab about shoulder width, edge-on in profile, engine pack on the back, amber slit eye. Not yet seen: shield_robot
  attack/hit/fall, the 55 sheets.
- 18:47 ASTRA RUNNING lancer since 18:22 (pid 41084). Session 1 ends.
NEXT: (session 2) wait for / read the `lancer` call result; review the staged diff (call sites only in shared files; the
  switch; no sim change: run `node tools/tests/run_unit.mjs --changed` and a scenarios run if arena_rigs changed); look at the
  lancer stills; then brief 03 as written above (lancer film in a wave + door carrier cut/wire + clamshell round).
- 18:51 session 1 end: ASTRA RUNNING lancer since 18:22 (pid 41084), its hard stop is 75 min from its start (~19:37). HEAD 0c7c09e39.

## Session 2 (18:52)
- 18:52 start. ASTRA lancer (pid 41084) still running; it committed f61bf1e09 (lancer combat cards behind cast_cards.json).
  Reviewed the staged/committed shared-file edits: arena_rigs (ReactLink.make moved into FoeCastView.attach, FoeRocketPose
  call -> _cast.feed), arena_wave_cards (skip covered), street_walker_cards (strip/row via CastCardPose), street_walker_fall
  (rest_row), foe_launcher_view (draws_launcher): all render-side call sites. No `NEED cast` lines (checked at 18:25).
- 18:58 reviewed the packed lancer sheets: walk p70/p55 accepted. ATTACK FAILS facings: column 4 (up-right) shows his face
  and aims right, column 5 (up) aims right (both pitches, p70 worst). Retake in round 03. Dead lancer at 64 ppm lies ~155 px
  (~2.4 m) in lancer_64ppm_tilt70.png: measure against a dead cop. Hit sheet ok. Lancer takes: attack 2 (retake ordered).
- 18:59 door carrier sheets (round 02, 8 sheets) reviewed on door-v1.jpg: accepted at sheet level; hit sheets have small
  yellow-green spark ticks (cutter risk). Brief 03 written (evidence/briefs/n24-cast-03-film-door.md).
- 19:34 ASTRA lancer 72 accepted (commits 895cf34c1, 0c7c09e39, f61bf1e09, 4c874cc89, 01defddab; mutate cast_card_pose
  16/20). Open from it: a deferred `_kneel` error at placeholder teardown, full unit run timed out (both in brief 03), and it
  accepted attack columns 4-5 the director rejects. MILESTONE lancer-cards 01defddab (behind cast_cards.json enabled).
- 19:37 ASTRA RUNNING film-door since 19:37 (pid 51876; brief evidence/briefs/n24-cast-03-film-door.md: round 03 =
  lancer attack retake + clamshell + pile-driver sheets; _kneel error; lancer film 32/64; door carrier cut + wire + stills).
- 19:51 round 03 review (foes-n24/incoming): lancer attack v2 cols 4-5 facings RIGHT (accept for splice; v2 rows 1/2/4 near
  identical so keep the old cols 1-3). Clamshell take 1 REJECTED (base plate rotates to a diamond in diagonals; translucent
  green-grey smoke; fall col 4 aims left): retake as dome-only cells + one still base-plate sheet. Pile-driver fall_70 take 1
  REJECTED (col 1 plan view, col 2 shows the back, col 4 cannon left, smoke). Notes are in brief 04 draft
  (evidence/briefs/n24-cast-04-clamshell.draft.md). Takes: lancer attack 2, clamshell 1 (rej), pile-driver fall 1 (rej).
  FRICTION: image gen keeps mixing up the diagonal facings for machines; per-column "what faces the viewer" wording next.
- 20:05 Astra retook the clamshell itself (out/sentry_turret_*_v2): attack_70_v2 ACCEPTED at sheet level (plate square and
  still in every cell, no smoke, facings right; row order to verify). war_machine_walk_70 take 1 REJECTED too (col 1 shows
  the back, col 5 plan view, cols 2-4 back-left). Pile-driver needs per-column facing prompts (in the brief 04 draft).
  Takes: clamshell attack 2 (v2 accepted), pile-driver walk 1 (rej), fall 1 (rej).
- 20:06 ASTRA RUNNING film-door since 19:37 (pid 51876; hard stop 20:52). Its tree is mid-work (attack splice, door carrier
  in arena_robot_rigs/foe_shield_view, lancer film scene): do not commit its paths; commit director files with pathspec.
NEXT: (session 3) check logs/cast/astra.lock + astra-calls.jsonl; when film-door ends read
  evidence/briefs/n24-cast-03-film-door.out.txt, review every diff (call sites only in shared files: arena_robot_rigs.gd,
  foe_shield_view.gd; switch off = main), run `node tools/tests/run_unit.mjs --changed`, watch the lancer films
  (gtai-masters/n24/cast/lancer_wave_32.mp4, lancer_close_64.mp4: ffprobe 15-40 s, extract stills and look), check the
  spliced attack cols 4-5 in-game and the door stills (slab ~41 px wide at 64 ppm, ~2.0 m tall). Then finish brief 04 from
  evidence/briefs/n24-cast-04-clamshell.draft.md (pile-driver retake with per-column facing words; clamshell v2 cut + wire;
  standing-rule docs) and launch it detached. Last code commit by 00:00, gate `node tools/gate/run.mjs --rev=HEAD` by 00:15.
