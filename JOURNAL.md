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
