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
- 18:41 NEED pressure: test player melee (`n24-melee` 5e4b69c76): one click = one swing now, no chained 2nd hit; a held
  fire repeats only after recovery. Single swing per weapon (windup/active/recovery ticks, reach, cone_dot): claw
  5/3/13 1.40 m 0.5; chainsaw 12/4/18 1.65 m 0.8 (grind while held, bite every 8); electro_baton 4/3/14 1.55 m 0.6;
  katana 7/4/16 2.10 m 0.32 (lunge 0.55 m); plasma_sword 8/6/19 2.20 m (cone being narrowed from -1 to ~-0.2 in P2).
  Coming in P2: a melee weapon (not the claw) kills any human in one landed swing (not Mulroney/bosses; katana is
  blocked by a raised riot shield from the front). Expect melee to clear humans much faster: re-measure.
- 18:45 LOOKED after-study-64.jpg (n24/melee/compare): five swings read as five different motions; hands kill with
  blood, katana cut leaves the cop standing hurt (P2), baton stuns. Doubt: the chainsaw's grind draws white
  crackle marks like the shock arcs at t42-t57: check in P2's films whether that is saw spark or a misplaced shock
  arc (sparks should be warm/amber, not the electric white). 
NEXT (session 2): see the NEXT above; P2 running since 18:39 (pid 70312).
