# JOURNAL lane melee (n24, branch n24-melee, worktree n23-street)

## Session 1 (17:22 to 18:52)

- 17:22 start. main b3f4727c0, tree clean. No astra.lock, no prior calls. No `NEED melee` in the other four journals.
- 17:24 CAUSE (read, to be confirmed by film/telemetry in P1): with a melee weapon selected the swing
  press is LEVEL, not edge. `RivetWheel.swing_pressed` (`project/features/player/rivet_wheel.gd:81-85`)
  and the non-wheel `StagePilot._melee_press` (`project/boot/collect_call/stage_pilot.gd`, "a held fire
  swings too (held = the combo chains, as a mash does)") return true on every tick the fire button is
  held. `MeleeCombo.press()` (`project/features/player/melee_combo.gd:35`) sets `buffered = true`
  when a hit is playing, and `step()` starts hit 2 at `windup + active + cancel_ticks`. A mouse click
  is held for several ticks, longer than one tick of the first hit, so every click buffers and chains
  a second hit (katana_1 -> katana_2, baton_1 -> baton_2, plasma_1 -> plasma_2, chainsaw thrust -> rip).
  Fix lives in melee files only: the combo ignores a press that is a continuation of a held press
  (no buffer from a held button), and a held button restarts only after the recovery.
- 17:25 DECISION melee plan: P1 = items 1+2 (see it, one swing per weapon; then item 5 cursor if time),
  P2 = item 3 (one-shot humans per type x weapon class, shield rule), P3 = item 4 (electric finisher on
  machines). Hands (claw): one claw strike per click, NOT a one-shot (owner said "melee weapons"; hands
  are the quick claw) - one table value away.
- 17:25 ASTRA RUNNING p1-one-swing since 17:25 (pid lock 64828, brief evidence/briefs/n24-p1-one-swing.md, out .out.txt)
- 17:57 Astra P1: `ff5b5f2eb` film shot (tools/film/melee_click.gd, shot `melee:<id>`), `5e4b69c76` single swing
  (table value `single_swing` true in melee_weapons.json + rivet_melee.json; per-weapon `swing` row + `swing_style`
  rake/drive/crack/cut/sweep; old chains kept for `single_swing:false` and the historical pilot byte tests).
  CAUSE CONFIRMED on film: before = 2 hit starts per 6-tick click for hands, katana, baton (katana starts t31 and t42,
  fire already up at the second). Unit 3773 pass / 0 fail. Scenarios rivet_claw/chainsaw/katana expectations moved
  (decision line in docs/decisions.md). Director review: rule correct; plasma sweep cone_dot -1 is a 360 spin, too
  wide once it one-shots: send back in P2 (-> about -0.2, ~200 deg).
- FRICTION Godot movie writer encoded 1280x800 despite 1080p request; Astra rebuilt mp4s from native 1080p frames.
- 18:38 ASTRA p1-one-swing 73 accepted. Commits ff5b5f2eb (film shot), 5e4b69c76 (single swing), 5a40e1370 (melee
  cursor -> system arrow, PLAIN_DOT one const away). Swings per click after: 1.0 for hands, chainsaw, baton, katana,
  plasma (before 2/1/2/2/2) at 32 and 64 px/m (`C:\Users\kazda\kiro\gtai-masters\n24\melee\compare\starts.json`).
  GUT 3774/0 fail, 67 scenarios pass, parity 1200 exact, bake + pinned 60 s replay held, mutate melee_combo 4/4.
  quick gate red on 474 engine lines that are IDENTICAL on untouched b3f4727c0 (PagedAllocator shutdown): pre-existing,
  check again at final gate. Seven archived quest tapes diverge at tick 60 on BOTH revisions (pre-existing).
  Looked: cursor compare.png (crescent melee cursor -> plain arrow) ok; katana before t42 second swing on a dead cop.
- 18:38 DECISION melee cursor: hands and melee weapons show the system arrow (keeps a pointer for aim), plain dot is
  `WeaponCursor.PLAIN_DOT` away.
- 18:39 ASTRA RUNNING p2-one-shot since 18:39 (lock pid 70312; brief evidence/briefs/n24-p2-one-shot.md, hard stop
  19:50; first commit = plasma cone_dot -1 -> ~-0.2). Then P3 = evidence/briefs/n24-p3-electric.md (fill HARDSTOP/COMMITBY).

NEXT: next session: check astra.lock (pid 70312) and logs/melee/astra-calls.jsonl; when p2 ends read its report +
diff, look at the kill reel sheets yourself (n24/melee/kills), write `NEED pressure` with the new reach/ticks per
weapon (P1 table: claw 5/3/13 1.40 m, chainsaw 12/4/18 1.65 m, baton 4/3/14 1.55 m, katana 7/4/16 2.10 m, plasma
8/6/19 2.20 m) into this JOURNAL, then launch P3. Commit JOURNAL + briefs (per path) at a quiet moment.
- 18:39 NEED pressure: test player melee (`n24-melee` 5e4b69c76): one click = one swing now, no chained 2nd hit; a held
  fire repeats only after recovery. Single swing per weapon (windup/active/recovery ticks, reach, cone_dot): claw
  5/3/13 1.40 m 0.5; chainsaw 12/4/18 1.65 m 0.8 (grind while held, bite every 8); electro_baton 4/3/14 1.55 m 0.6;
  katana 7/4/16 2.10 m 0.32 (lunge 0.55 m); plasma_sword 8/6/19 2.20 m (cone being narrowed from -1 to ~-0.2 in P2).
  Coming in P2: a melee weapon (not the claw) kills any human in one landed swing (not Mulroney/bosses; katana is
  blocked by a raised riot shield from the front). Expect melee to clear humans much faster: re-measure.
- 18:39 LOOKED after-study-64.jpg (n24/melee/compare): five swings read as five different motions; hands kill with
  blood, katana cut leaves the cop standing hurt (P2), baton stuns. Doubt: the chainsaw's grind draws white
  crackle marks like the shock arcs at t42-t57: check in P2's films whether that is saw spark or a misplaced shock
  arc (sparks should be warm/amber, not the electric white). 
NEXT (session 2): see the NEXT above; P2 running since 18:39 (pid 70312).

## Session 2 (18:40 to 20:10)

- 18:40 start. astra.lock pid 70312 alive (node, p2-one-shot since 18:39). Uncommitted Astra edits in progress
  (melee_weapons.json, melee_swing.gd, two tests: the plasma cone follow-up). grep `NEED melee`: one, pressure 18:30.
- 18:43 DECISION melee (answers pressure NEED 18:30): `combat.json` `robo_tazer.damage` 46 is NOT doubled. It is
  Quartermaster Mertz's enemy-only boss weapon (`robo_tazer.gd` header; quest 1 / collect call), not a wave enemy:
  boss designs and quest 1's script do not change tonight. The owner's "double their damage" is served by pressure's
  wave numbers. One value away if the owner wants it (REPORT, Calls for the owner).
- 18:50 LOOKED compare/chainsaw/64/t46.png: the white zigzag between Rivet's chest and the cop during the grind is
  on main too (before = after), so not a P1 regression; the blade sparks themselves are warm yellow (ok). Still reads
  as a shock arc on a saw: a later quality package (find which mark draws it: melee_feel / melee_marks).
- 18:46 Astra P2 `e2f881f42`: plasma sweep cone_dot -1 -> -0.2 (203 deg front), drawn sweep shape +-1.0 of the
  cone (matches). Deflect active 6 kept. Reviewed: ok.
- 19:20 Astra P2 `2dfefbbc7`: `MeleeLethal` + `MeleeContact` (player/), `kills_human`/`vs_shield`/`shield_break_ticks`
  in weapon rows, per-victim kill variants in `signature_kills.json` (lookup weapon x archetype, falls back to the
  weapon row), hooks: `CombatArena.damage` + one-line `MeleeLethal.pit_damage(...)` in `EnemyPit.hurt`. Katana vs
  raised riot shield front: blocked, shoved, shield open 40 ticks, next cut kills; plasma/baton through; chainsaw
  through at the end of its committed grind. Claw, robots, machines, Mulroney, boss-owned: normal damage.
  GUT 3783 pass, 67 scenarios pass (rivet_katana 3 -> 6 kills, rivet_chainsaw 1 -> 5: expectation moves, decision
  line), no tape/parity/bake digest moved. Mutate melee_lethal 3/3 killed, INCOMPLETE (stopped for hard stop).
  Quick gate red on the pre-existing PagedAllocator shutdown lines only (as P1).
- 19:52 REVIEW P2: BOUNCED in part -> P3 follow-up 1: Astra rewrote the shared `combat_arena.gd` header doc
  (6 doc lines deleted to fit the cap) and added a 6-line branch in `damage()`; must be restored and reduced to
  one-line call sites (<= 2 changed lines vs b3f4727c0). The `kind = shot` on a FINISH matches the default kind
  (melee kills were already `shot`): fine. SWAT + rocket trooper variants of plasma/saw/baton unrendered -> P3 fu 3.
- 19:53 ASTRA p2-one-shot 71 accepted (with follow-ups carried into P3).
- 19:53 ASTRA RUNNING p3-electric since 19:53 (--resume of p2's thread; lock pid 41356; brief
  evidence/briefs/n24-p3-electric.md, hard stop 21:05, commit by 21:00; out evidence/briefs/n24-p3-electric.out.txt).
- 19:55 LOOKED kills/katana_64.png (patrol): cut flash at the kill tick, blood spray, halves fall apart and the cap
  flies; reads. variants/review_katana_32.png (contractor): reads as a cut, but at 32 px/m the halves are small and
  the "contractor" is drawn as a blue cop body (that is cast's art, not ours). Red only for blood: ok.

NEXT (session 3): check astra.lock (pid 41356) + out file; when P3 ends review its diff: combat_arena.gd net diff vs
b3f4727c0 <= 2 lines and header restored; robot rule (thug/gunner one swing, shield_robot overload 150 + execute,
war_machine never); LOOK at n24/melee/electric films + 64 close-ups (amber, no teal/red); mutate scores. Then a P4
quality package: the white zigzag on the chainsaw grind (18:50), the right-facing baton contact frame, telemetry of
swings per click in a live fight (1.0), films for the owner (each weapon's swing + kill per type, cursor before/after)
with frames.json. Commit last new work by 00:00, final gate by 00:15. REPORT: robo_tazer call (18:43), hands call.
- 19:58 LOOKED variants/review_electro_baton_32.png (contractor): WEAK. At the kill tick and +4 nothing shows the
  shock (no arcs, no seizure, no flash): the man is just standing, then at +16..+36 he is thrown back and lies as a
  charred body. For P4: the baton kill needs visible arcs and a tick-locked seizure on the victim over the first
  ~20 ticks (white/amber arcs, not teal), then the throw. Same check for the P3 robot shut-down.

## Session 3 (19:57 to 21:27)

- 19:58 start. astra.lock pid 41356 alive (node, p3-electric since 19:53, out file still empty). grep `NEED melee`
  in the four other journals: only pressure 18:30 (answered 18:43). Uncommitted combat_arena.gd / melee_lethal.gd =
  P3 follow-up 1 in progress (Astra's).
- 20:02 LOOKED kills/chainsaw_64.png (patrol): saw bites at the kill tick, blood fan, body down in pieces by +80;
  reads brutal. variants/review_plasma_sword_32.png (contractor): white flash at the kill tick, halves and gear fly
  apart, NO blood at all (cauterised?) and the burst is a cartoon star: weakest of the cuts at 32 px/m. P4 item.
- 20:05 REVIEW P3 fu1 `4832ca100`: combat_arena.gd net diff vs b3f4727c0 = 2 lines (damage_scale + death_kind call sites), header restored: ok. P4 brief written (evidence/briefs/n24-p4-kill-looks.md: baton shock on humans, plasma blood + cut streak, chainsaw zigzag, right-facing baton frame, three decision lines: cursor, claw, robo_tazer).
- 20:06 NOTE merge: P3 changes `project/features/combat/ai/enemy_pit.gd` hurt() (optional `melee` param + 2 call-site lines into MeleeShutdown); ai/** fire timing is pressure's: a conflict there is possible at merge, keep both.
- 21:05 Astra P3 `e04b93990`: `melee_shutdown.gd` (+ `robot_shutdown_fx.gd`): baton one-swing shut-down of
  robot_thug / robot_gunner; shield_robot + sentry_turret overloaded 150 ticks, second swing executes (through the
  front shield); war_machine normal damage + 30-tick stun; bosses never. Blades: normal robot damage. GUT 3792 pass,
  10 selected scenarios/replays pass, no tape moved. Mutate melee_shutdown 15/20 (75%), melee_lethal 8/12 (66.7%).
  Films n24/melee/electric (4 clips 1920x1080 60 fps 15.2 s). Astra proposes electro gun direct hit + the claw's full
  charge as the next electric weapons (REPORT).
- 21:05 LOOKED electric/shutdown-review.jpg: reads at 64 (arcs at contact, sensor dark, fold, charred heap for the
  shield robot); at 32 the arcs are tiny yellow ticks and the dead thug turns into a pale grey cut-out (64: a black
  silhouette). Good enough to keep; strengthen in P4 item 6.
- 21:06 CHECK `tools/godot/check.mjs` on kill_styles.gd / signature_kills.gd: FAIL, only "Failed to compile depended
  scripts" cascades (P3 quick gate red on these too). The game and GUT run them, so likely a standalone-load cycle;
  P4 item 0 compares with b3f4727c0 and fixes ours. Final gate must be green.
- 21:06 ASTRA p3-electric 72 accepted.
- 21:07 ASTRA RUNNING p4-kill-looks since 21:07 (--resume of the P3 thread; lock pid 68852; brief
  evidence/briefs/n24-p4-kill-looks.md, hard stop 22:22, commit by 22:15; out evidence/briefs/n24-p4-kill-looks.out.txt).

NEXT (session 4): check astra.lock (pid 68852) + its out file. When P4 ends: review the diff (no change to
combat_arena.gd, enemies/weapons/combat.json), confirm item 0 (check.mjs on kill_styles.gd + signature_kills.gd PASS,
or the same failure proven on b3f4727c0), LOOK at n24/melee/kills/p4 before/after (baton shock on humans, plasma
blood + streak, chainsaw sparks warm, robots at 32). Then launch P5 (evidence/briefs/n24-p5-films.md: fill HARDSTOP /
COMMITBY; product code closed by 00:00): live swings-per-click telemetry + owner films + frames.json. Final gate
`node tools/gate/run.mjs --rev=HEAD` by 00:15 (it needs the lane's one Godot: do not overlap with Astra). REPORT calls:
robo_tazer not doubled (18:43), claw not a one-shot, cursor = system arrow (PLAIN_DOT one const away), which weapons
count electric (electro gun direct hit, claw full charge), riot-shield rule per weapon (katana blocked + opens 40
ticks, others through). Merge note: enemy_pit.gd hurt() signature (pressure's ai/**).
- 21:08 NEED pressure: since `e04b93990` the electro_baton shuts down robot_thug / robot_gunner in one landed swing and overloads shield_robot / sentry_turret (150 ticks, no move or fire) with the second swing executing; war_machine only a 30-tick stun. A test player that carries the baton clears robot waves faster: re-measure. Blades on robots unchanged.

## Session 4 (21:10 to 22:39)

- 21:10 start. astra.lock pid 68852 alive (node, p4-kill-looks since 21:07, out file empty). grep `NEED melee` in the
  four other journals: only pressure 18:30 (answered 18:43). Worktree clean apart from the P4 out file.
- 21:15 REPORT.md drafted (P1-P3 rows, calls, merge notes, ledger); P5 brief filled (hard stop 23:35, commit by
  23:30; cursor before side: copy `project/native/bin/*.dll` into the temp worktree or fall back to P1's still;
  priority order kills films > telemetry > electric > cursor > close-ups).
- 21:20 REVIEW P4 `9f8d6c8f8` (baton shock on humans, kill_cook_art.gd): 20-tick seizure about the planted feet,
  3-tick contact flash, two white/blue/amber current paths (hash, not RNG), render only. Ok on read; frames pending.
- 21:31 REVIEW P4 `4bdda2843` (plasma kill): star flash off (flash_ticks 0), hot streak `kill_plasma_art.gd`, cut
  edges white-hot -> amber over 40 ticks, a view-only blood fan + pool (patterned drops, no combat RNG). Ok on read.
- 21:36 LOOKED kills/p4/electro_baton-64.png (contractor before/after): after shows the contact flash at +0 and
  white/blue/amber arcs over the body at +4 and +16 (before: nothing until the throw). Reads. The arcs are regular
  zigzag "icons" on both flanks; acceptable. Chainsaw-64 diagnostic: the white star/zigzag at t42-57 is a drawn
  sprite in the shipped path (shapes fallback draws zigzags); item 3 in progress.
- 21:37 `7144b8a1a` decision lines (cursor, claw, robo_tazer): match the director's calls. Ok.
- 21:41 REVIEW P4 `f6978fc2f` (item 6, robot wreck): on collapse the plates drop the printed sticker for their own
  gunmetal texture, halo hidden, chassis smoke-tinted; joint arcs white core + amber. Unit test added. Ok.
- 21:44 LOOKED kills/p4/plasma_sword-32.png (5 types before/after): star gone, hot streak along the cut, blood
  fan at +0/+4, pool by +16..+60; reads brutal on all five. Pool is a flat saturated blob (acceptable; red = blood).
  robot-shutdown-32.png: after = bigger amber/white arcs at 305/317, wreck dark gunmetal at 338/545 (before: pale
  cut-out). Reads.
- 22:16 P4 ended (4144 s, exit 0). Item 0 CONFIRMED pre-existing: `build/p4-base-check.log` (UTF-16) shows
  `check.mjs res://features/combat/kills/kill_styles.gd` FAIL on b3f4727c0 too, "Failed to compile depended scripts"
  at `rig_clips.gd:0`. The full gate is green regardless: `node tools/gate/run.mjs --rev=f6978fc2f` PASS
  (`build/gate/f6978fc2f8fe/gate.json`: lint 19/19, GUT 3811/0/2 skipped, 67 scenarios, parity 1200, selftest,
  release-compile 934/0). Mutate kill_plasma_art 1/19 (5.3%): weak, tests go into P5 item 3.
- 22:16 NEED director (unowned shared file, also on main): the chainsaw grind's white zigzag is the shared stun
  renderer `project/features/combat/weapons/fight_areas_art.gd` drawing `WeaponFxElectro.stun` sparks on any stunned
  victim, the grind's hold included. Fix: a non-electric stun look for a melee hold (or the grind holds without the
  stun flag; that half is ours, next session). Still: M/kills/p4/chainsaw-64.png.
- 22:16 NEED director: the right-facing baton contact frame needs `project/features/characters/rivet_windup.gd`
  routing (only the left-facing strike has its own sheet) or new base strip art. Still: M/kills/p4/baton_strike-64.png.
- 22:16 ASTRA p4-kill-looks 69 accepted (2 items stopped at the allowlist as asked).
- 22:17 ASTRA RUNNING p5-films since 22:16 (--resume of the P2-P4 thread; lock pid 55724; brief
  evidence/briefs/n24-p5-films.md, hard stop 23:35, commit by 23:30; out evidence/briefs/n24-p5-films.out.txt).
- 22:24 CORRECTION to 22:16 chainsaw NEED: the trigger is ours. `melee_weapons.json` `chainsaw_drive` (and
  `chainsaw_1`) carry `stun_ticks: 16`; `melee_contact.gd:24-25` applies it through `PlayerShock.stun_on`, which
  sets `FighterFx.stun_ticks`, and `fight_areas_art.gd:36` draws `WeaponFxElectro.stun` on any stunned hostile.
  Fix in our files: a non-electric hold (`mind.stun_until`, as `MeleeShutdown._hold` does). Brief written:
  `evidence/briefs/n24-p6-saw-hold.md` (fill HARDSTOP/COMMITBY). The NEED director stands only as a fallback.
- 22:25 REPORT.md updated with the P4 rows, the gate on f6978fc2f, what does not, the ledger.

NEXT (session 5): check astra.lock (pid 55724, p5-films since 22:16, hard stop 23:35) + its out file. Review P5:
`n24/melee/telemetry/swings.md` (1.0 per click at all three cadences after; before = single_swing false), each film
with ffprobe (1920x1080, 60 fps, 15-40 s) and 6 stills per film LOOKED by you, frames.json 8-15 entries, plasma
tests + mutate. If P5 ends by about 23:40: launch P6 (saw hold, brief ready; hard stop 00:05, commit by 23:59), and
review it. No product commit after 00:00. Final gate `node tools/gate/run.mjs --rev=HEAD` started by 00:15 (lane's
one Godot: Astra must be done). After the freeze (01:30): `--reels` once. REPORT final at 01:40: the gate line + path,
films, swings table, the P5/P6 ledger rows, `node tools/evidence/cites.mjs REPORT.md` clean, then commit
JOURNAL/REPORT/briefs per path with `git commit -- <paths>`.
- 22:23 LOOKED kills/p4/plasma_sword-64.png: the cut streak and the cooling edges read; the airborne blood at +0/+4
  is a chain of identical round beads (vector-trail look) and the +36 pool is one flat blob wider than the halves.
  Added as optional item 2 to the P6 brief.
- 22:33 P5 in progress (pid 55724 alive): uncommitted `project/dev/melee/swing_measure.*`, `owner_take.*`,
  `tools/film/swing_table.mjs`, `owner_cursor.*`, `owner_takes.mjs`, `owner_review.py`. First telemetry
  (`n24/melee/telemetry/swings.md`, not yet reviewed against its log): 40-tick clicks old -> shipped: hands 1.60 -> 1.00,
  baton 2.00 -> 1.00, katana 1.60 -> 1.00, plasma 2.00 -> 1.00, chainsaw 1.00 -> 0.60; held starts/s close to the
  row's 1/(w+a+r) (hands 3.00 vs 2.86, plasma 2.00 vs 1.82). CHECK for session 5: chainsaw 0.60 means 2 of 5 clicks
  start no swing (a click landing inside a still-running grind is dropped, never buffered). Confirm from swings.json
  that every dropped click fell inside a running swing (then it is the rule: no second hit; record a DECISION that
  a busy click is dropped, a one-press buffer after recovery is one value away if the owner finds it sluggish), and
  put it in REPORT Calls for the owner.
- 22:34 session 4 end. ASTRA RUNNING p5-films since 22:16 (lock pid 55724, hard stop 23:35). NEXT: see 22:25 NEXT above.
- 22:36 session 5 start. astra.lock pid 55724 alive (node, p5-films since 22:16, out file empty). grep `NEED melee`
  in the four other journals: only pressure 18:30 (served in session 2). CHECKED chainsaw 0.60 in swings.json: shipped
  trial starts 0/81/161 on clicks every 40-41 ticks, held starts 0/74/148 against row_ticks 34: a grind on the cop runs
  about 74 ticks (the contact hold), and the click at 41 falls inside it and is dropped, never buffered. Every dropped
  click lies inside a running swing, so 0.60 comes from the rule and is not a second hit. DECISION goes in with P5's
  review: a busy click is dropped; a one-press buffer after recovery is one value away (Calls for the owner).
- 22:36 LOOKED P5 draft films (still in progress; ffprobe: all six 1920x1080, 60/1, 16.0 s), review sheets
  `n24/melee/films/review/*.jpg`. katana, chainsaw, baton and plasma: one swing per type and the body down with its own
  look (cut + blood, saw grind + spray, charred black shock body, hot cut + blood). hands: the claw rakes, humans take
  ordinary damage (matches the 7144b8a1a decision), last tile shows the black void at the bottom right. electric_robots:
  BAD framing: from tick ~294 the war machine stands over Rivet, the gunner and the shield robot, so the shield
  overload and the shield robot's shutdown are hidden under its chassis. Follow-up to Astra if P5 does not fix it:
  stage each robot alone (war machine last, at its own spot), as the human films do.
- 22:48 REVIEW P5 commits so far: `314024a7d` (owner_take.gd + owner_takes.mjs + owner_review.py: live arena takes,
  review sheets) and `5a02c1ae7` (swing_measure: click edges against real swing starts, swing_table.mjs). Tools and dev
  only. LOOKED closeups/katana_64.png (star flash at contact, halves separate at +20 under the blade: reads) and
  closeups/chainsaw_64.png (grind spray at the kill, body opened at +20; the held cop is drawn over Rivet's chest
  with Rivet's striped collar painted over the cop: a draw-order read worth a REPORT "does not" line, not tonight).
- 22:59 LOOKED electric_robots.mp4 re-take (22:52, review sheet): the robots are now staged apart. Katana bounces off
  the thug at 115; baton shutdown of the thug at 324 and the gunner at 536; shield overload at 750 and the execute at
  804; war machine at 960 only stunned (amber/white arcs on its chassis). The war machine still fills the tile (its
  size is cast's and the owner's "few humongous" rule, not ours). Reads.
- 22:59 REVIEW `890c59a68` + LOOKED cursor_before_after.mp4 (1920x1080, 60/1, 16.0 s; stills at 2/6/10/14 s): left
  main, right this branch, an enlarged cursor inset at the top left of each half. Gun = crosshair on both sides; melee
  = the crescent claw cursor (before) against the system arrow (after). Reads. Weak: half of each half is black void
  below the street (framing, not a bug).
- 23:11 P5 ended (3289 s, exit 0). Final: swings per 40-tick click old -> shipped: hands 1.60 -> 1.00, chainsaw
  1.00 -> 0.60 (busy grind drops the click, checked 22:36), baton 2.00 -> 1.00, katana 1.60 -> 1.00, plasma 2.00 -> 1.00;
  reruns tick-identical. Seven films 1920x1080 60 fps (six 16 s, electric_robots 18 s). Plasma tests 5/5, mutate
  kill_plasma_art 1/19 -> 5/19 (26.3%, 14 drawing mutants survive). Scratch removed: 2112 PNGs (`build/p5-removed.json`).
  Commits 314024a7d 5a02c1ae7 890c59a68 d4904c1ab 6e7868bce 8387f4ed9 ed1332dae: tools/film, dev/melee, one test.
  Astra's own "does not": the white zigzag on the saw (P6 item 1), the baton's right-facing strike looks horizontal
  (NEED director 22:16), plasma contractor reads like a patrol cop (cast's art).
- 23:11 ASTRA p5-films 55 accepted.
- 23:12 DECISION n24 melee: a click that lands while a swing (or a chainsaw grind) is still running is dropped, not
  buffered: one click never yields a later automatic swing. A one-press buffer after recovery stays a Call for the owner.
- 23:12 ASTRA RUNNING p6-saw-hold since 23:12 (--resume; Start-Process pid 17452; out evidence/briefs/n24-p6-saw-hold.out.txt;
  hard stop 00:05, commit by 23:59).
- 23:16 LOOKED closeups/electro_baton_64.png: the contact flash + white/blue bolts on the cop at the kill tick, the
  seizure with current at +20; Rivet's baton points away from the cop (the right-facing strike frame, NEED director
  22:16), so the hit reads by the flash, not by the arm. closeups/plasma_sword_64.png: the glowing blade, the pale hot
  streak across the cop, blood under; at +20 the halves part. Reads.
- 23:16 REPORT P5 rows `ff9b42cda`; M/ paths in REPORT all exist (checked by hand: cites.mjs reads only backticked repo paths).
- 23:19 P6 ended (415 s): Astra stopped at the allowlist with a NEED: the filmed cop runs `GuardBrain` (no squad
  mind), so `mind.stun_until` would not hold it; its proposal was a new physical hold timer in `fighter_fx.gd` + a
  movement check in `fight_areas.gd:97` (sim change). Before frames made: M/kills/p6/chainsaw-{32,64}-before.png,
  electro_baton-{32,64}-before.png. Probe `build/p6-hold-probe.log`: the shipped stun holds the cop all 16 ticks.
- 23:19 ASTRA p6-saw-hold 7 accepted (a correct NEED stop, no commit).
- 23:20 DECISION n24 melee: the saw's hold keeps its shipped `stun_ticks` (sim byte-identical); only the look
  changes: a view-only `FighterFx.hold_look_until` (NOT in write_state) set by our melee contact from a row value
  `stun_look: "hold"`, read by a one-line call site at `fight_areas_art.gd:36` and our own react views. Rejected
  Astra's physical timer (moves the sim and two unowned files for a look defect). Plasma blood item cancelled tonight.
- 23:20 ASTRA RUNNING p6b-saw-look since 23:20 (--resume; pid 36424; brief evidence/briefs/n24-p6b-saw-look.md;
  hard stop 00:05, commit by 23:59).
- 23:37 P6b ended (1005 s, exit 0). REVIEW `22654f6d3`: row `stun_look: "hold"` on both saw hits (+ schema), MeleeHit/
  MeleeTable read it, `melee_contact.gd` passes `arena.tick + stun_ticks` to `PlayerShock.stun_on(..., hold_look_until)`
  (an electric stun resets it to -1), `StunCrowd.electric(e, tick)` used by the renderer and our shock views. Shared
  lines: `fighter_fx.gd:18` (view-only field, not in write_state) and `fight_areas_art.gd:36` (one-line call site).
  Stun ticks unchanged (16), telemetry + parity + bake + 60 s replay identical per Astra; unit --changed 3805/0;
  mutate melee_contact 24-27 8/8 (100%). `9da9442bb` decisions.md line (busy click dropped; saw look). ACCEPTED.
- 23:37 LOOKED kills/p6/chainsaw-64-after.png: white stars gone at 42/46/50/57, warm sparks at the teeth stay.
  Still weak (pre-existing, before too): at 46/50 the held cop is drawn standing in his aim pose a step off the bar,
  so the hold reads as a miss; the kill lands at 62. electro_baton-32-after.png: flash at 34, arcs to 50: unchanged.
- 23:37 ASTRA p6b-saw-look 17 accepted.
- 23:38 FINAL GATE started on 9da9442bb: `node tools/gate/run.mjs --rev=HEAD` detached (Start-Process pid 74924,
  out build/final-gate.out.txt). No product commit after this (it is 23:38; the 00:00 cut holds).
- 23:40 REPORT P6 rows + Next steps; frames.json now 13 entries (the p6 saw pair at #3).

NEXT (session 6, from about 00:05): no Astra running (P6b done 23:37, lock gone). FINAL GATE on 9da9442bb running
(pid 74924, out `build/final-gate.out.txt`, gate dir `build/gate/9da9442bb509/`, about 21 min, so done about 00:00).
Read its PASS/FAIL line + `build/gate/9da9442bb509/gate.json` and put both in REPORT (replace the f6978fc2f gate row,
drop the DRAFT header line). If it FAILS on our code: say so in REPORT with the line; a fix needs a commit after
00:00, which the run forbids: report it, do not fix. After 01:30 (freeze): `node tools/gate/run.mjs --rev=HEAD --reels`
once (lane's one Godot). Optional, before 01:30, films only (no product code): a 32 px/m clip of the saw hold after
P6b (`tools/film/owner_take.gd` via Astra or by hand with the kill_reel tools), only if time and one Godot allow.
REPORT final at 01:40: `node tools/evidence/cites.mjs REPORT.md` clean, commit JOURNAL/REPORT per path with
`git commit -- <paths>`. Clean Temp: `gtai-gate-9da9442bb509` after the gate (memory: clean Temp after merge).

- 01:30 session 6 start (STABILIZE, past freeze). No astra.lock; last call p6b-saw-look ended 23:37. grep `NEED melee`
  in the four other journals: only pressure 18:30 (robo_tazer), answered in REPORT Call 3.
- 01:31 FINAL GATE on `9da9442bb` (HEAD's only later changes: JOURNAL.md, REPORT.md): `gate: PASS;
  build/gate/9da9442bb509/gate.json`. lint 19/19, GUT 3821/0/2 skipped, 67 scenarios (rig_stress CONTENDED), parity
  1200, release-compile 934/0.
- 01:33 DECISION n24 melee: no `--reels` gate: about 21 min, the session ends at 01:40; recorded in REPORT.
- 01:34 REPORT final (DRAFT line gone, gate row on 9da9442bb). cites 5/5 ok; M/ films, frames.json (13) checked by
  hand. Temp gtai-gate-9da9442bb509 removed (pid 74924 gone). Removed the two Astra stderr scratch files
  (n24-p6*-err.txt, untracked); committed n24-p6b-saw-look.out.txt with the briefs.

NEXT: lane done. For the Director: merge `n24-melee` at this commit; merge notes in REPORT (enemy_pit.gd hurt() call
with pressure's ai/** timing, fighter_fx.gd:18, fight_areas_art.gd:36, combat_arena.gd 2 lines). Reels gate not run.
