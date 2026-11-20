# n20 lane `flight`: what the four spectral ghosts share

Branch `n20-flight` (cut from `int-n20` a3eb0bf78), worktree `C:\Users\kazda\kiro\gtai-wt\n20-flight`.
Director: Claude Opus (four sessions); builder: GPT-6.2 Astra. Films and stills:
`C:\Users\kazda\kiro\gtai-masters\n20\flight\` (`frames.json` there, best first).
Gate (05:40-05:49, on `aa9ff166e`, the last commit with code; later commits are docs only):
`gate: PASS; C:\Users\kazda\kiro\gtai-wt\n20-flight\build\gate\aa9ff166eaa2\gate.json`
(lint 19/19 over 1741 files; unit 3238 passed, 0 failed, 2 skipped; scenarios 65 passed; parity bit-exact over 1200
steps + planted mutation caught at step 629; selftest look goldens 11/11; release-compile 776 loaded, 0 failed).

## What works

| Item | Evidence | Number |
|---|---|---|
| Interface (look switch, hover, tail, shadow, feet off), committed 00:37 | `0e7d91e46`, `project/features/souls/README.md` "Spectral look" | committed 67 min after start; names unchanged since |
| `--ghost-look=legacy\|spectral` + per-form `look` in `ghost_forms.json` | `GhostLook.of()`, `project/data/tables/ghost_forms.json` | legacy frames pixel-identical (370 frames, Astra's check at 01:24) |
| Pose / act sheets and opt-out for lanes with their own body | `d2a44407e` (spec_hover/spec_act, `sprite()`, `instant_windup`), `12ec7bffa` (`drawn.own_body`) | used by ohm, tonnage, dent |
| Hover weight, bank, lag + breathing teal ground pool | `7948f3382`, `project/data/tables/ghost_hover.json` | heavy (tonnage) vs fast (kerf) rows separate by default |
| Tick-driven ragged vapour tail, bright root aft of the body, soft puffs at the tip | `f183e88a1`, `5e906fd53`; stills `flight_tail_*_64_t163.png` vs `package2/` | stepped on the 60 Hz tick, no frame delta |
| Legacy legs dissolve into the belt plume (bridge until each lane's body lands) | `81a78a5e8` | |
| Zero foot contact under spectral, real arena inputs per gait + a legacy control | `b0f2629c1`, `project/tests/unit/test_ghost_flight_hosts.gd` | 0 stamps / 0 strides spectral; legacy control > 0 |
| Spectral HUD chip face | `4362c8109` (`ghost_chips/<id>_spectral.png` when present) | kerf, ohm, tonnage chips use it |
| Review films: matched spectral/legacy two-panel at native scale | `95d914ab8`, `073237b56`, `tools/film/ghost_films.mjs` | used by all four lanes |

| Transformation take + body/tail/pool rise and retract with the real stages | `8589b0294`, `ff370f539` (`GhostFlight.set_emerge`); `flight_kerf_morph_32.mp4`, `flight_tonnage_morph_32.mp4`, `flight_morph_kerf_tilt70_64_t84.png` vs `before/` | burst stays on the ground, body lifts out of it |
| Soul line follows the hovering body's fade | `5707d7198`, `project/tests/unit/test_ghost_soul_line.gd` | all 8 outline copies |
| Public accessors for lanes (ohm NEED) | `51a905763` (`GhostDrawn.release_fade()`, `GhostDrawnActs.hurt_tick()`) | |
| Aura yields its ground rings to the flight pool (dent NEED) | `fa2b4dac7` (`GhostAura.form_id`, `draws_pool()`) | |
| Tail rise sign + curl at speed | `6ef44908f` (negative `rise_m` clamps at the street), `696862ee0` (curl grows with speed stretch) | both unit-tested |
| All-ghosts reel | `24936ad1a` (`ghost_films.mjs --all`); `all_ghosts_32.mp4` + `.jpg` | 40.0 s, 4 ghosts x (move, attack) x 5 s, tilt 70 above, top below |

Checks (Astra, package 3 end): GUT 3216 passed, 0 failed, 2 skipped; 60 s replay 60/60 checkpoints; legacy look
0 of 1,036,800 pixels differ at a fixed tick. Mutation `ghost_flight.gd`: 18/29 killed (62.1%), 11 of 40 unrun at the cap.

## What does not

- On `n20-flight` the four bodies are still the legacy art with the legs dissolved into the belt plume (the bridge);
  the new bodies live on the ghost lanes' branches. The reel and `flight_*` films therefore show legacy bodies
  with the shared motion, tail and pool. At 64 px/m the bridge leaves Ohm as a fragment in tilt 70.
- `all_ghosts_32.mp4` was cut at 05:19, before the curl-at-speed, rise-clamp and frontal-plume commits; package 5
  re-cuts it after the gate.
- Mutation of `ghost_flight.gd` is 18/29 (62.1%) with 11 of 40 unrun: the surviving shadow-child deletion and
  overhead size mutants name gaps in the tests.
- The double ground light (flight's pool + each rig's own ground glow) is still drawn on tonnage and ohm until
  their lanes drop theirs; dent needs its one-liner `_aura.form_id` after the merge.

## What blocked or slowed you

- 50 min: package 3's Astra run died with my session 2 at 03:09 (a background Bash child dies with its
  session); its lock pid had been reused by an unrelated process, so my watcher waited on a stale lock until 04:02.
  From 04:03 every Astra run was launched detached through WMI and the lock pid checked by process name.
- Package 2 hit Astra's 75-min cap (work committed in six pieces, nothing lost).

## Calls for the owner

1. **Ground under a hovering ghost: a teal light pool, not a dark shadow.** Every winning plate lights the wet street
   teal under the ghost, so the shared `GhostShadow` draws a small dark core inside a breathing teal pool. Alternative
   is one value per form (`shadow.alpha` up, pool off). Still: `flight_tail_kerf_top_64_t163.png` (pool) beside
   `before/flight_kerf_turn_64_t163.png` (legacy, ring under feet). Pick: keep the pool, or a plain dark shadow.
2. **Legacy-body bridge.** A ghost whose lane has not flipped its row still shows the old body with its legs dissolved into
   the tail (`81a78a5e8`); at 64 px/m Ohm reads as a fragment (`flight_tail_ohm_tilt70_64_t163.png`). Alternative: show
   the full legacy body (legs and all) floating. Only matters for ghosts left legacy-default after the merge.

## Merge notes

- `project/data/tables/ghost_hover.json`: each ghost lane tunes its OWN row on its branch (tonnage, dent, kerf,
  ohm all did). Rule: each lane's own row wins; flight's schema, new fields and defaults win.
  Ohm's `tail.fade_from` is 0.18 on flight; ohm's row wins if it differs.
- Root `JOURNAL.md` and `evidence/briefs/` travel into every lane that merged `n20-flight` (dent's FRICTION
  01:48): keep each lane's own JOURNAL.md at the merge, not flight's.
- Flight's own tests that other lanes guarded on their branches (their version wins):
  `project/tests/unit/test_ghost_hitback.gd` Ohm windup test pinned to `GhostLook.LEGACY` (n20-ohm);
  `project/tests/unit/test_ghost_flight_hosts.gd` null-sprite guard for `own_body` rigs (n20-dent and n20-tonnage, the same guard; it also covers Kerf's own body, kerf's NEED);
  `project/tests/unit/test_ghost_card.gd` Tonnage crown/hose cases pinned to legacy (n20-tonnage);
  `project/tests/unit/test_ghost_apparition.gd:100` skips the voice-cut assert when `own_body` leaves no sprite (n20-tonnage).
- Ohm and Dent rows flip to `look: spectral` on their branches: after merging all five, run the FULL unit suite;
  any flight test that asserts a legacy sheet without selecting a look goes red the same way (fix: `override_for_test`);
  known one left: `project/tests/unit/test_ghost_card.gd:92` assumes Kerf's legacy default (fires only if Kerf's row flips).
- Pending one-liners in lane files after the merge: dent `dent_body.gd` `_aura.form_id = &"dent"` (uses `fa2b4dac7`);
  ohm switches `drawn._fade` / `drawn._hurt` to `release_fade()` / `hurt_tick()` (`51a905763`).
- One-line call sites other lanes made in flight's files, accepted: kerf `ghost_form_view.gd`
  (`v._bodies.kerf.stage = stage`), ohm `GhostActs.prepare_ohm` (`rig.ohm = o`).

## Next steps

1. Morning merge: run the FULL unit suite after all five merge (look flips meet flight's legacy tests), then re-cut
   `all_ghosts_32` from the merged tree so the reel shows the new bodies.
2. Kill the 11 surviving `ghost_flight.gd` mutants (shadow child, overhead scale).
3. `tools/film/ghost_films.mjs` should encode limited-range `yuv420p` (it writes full-range `yuvj420p`; tonnage's
   finding; tonight's films were re-encoded after the fact).
4. The speaking-apparition voice wash (`GhostBridgeFade.voice`) does nothing for `own_body` forms (no shared sprite):
   give rigs a hook to wash their own parts, then restore the assert in `test_ghost_apparition.gd`.
5. Shared tail per-form texture variants (tonnage's smoke column, ohm's robe tatters) if the lanes' own second tails
   do not reach the plates.

## Astra ledger

| Tag | Minutes | Result | Note |
|---|---|---|---|
| interface | 68 | accepted | contract + stubs, 00:37 commit |
| sheets | 14 | accepted | lane NEEDs (ohm, dent, tonnage) |
| real | 75 (cap) | accepted | own_body, hover, tail, fade, film tool |
| effects | 12 | abandoned | killed with my session at 03:09 |
| effects-resume | 65 | accepted | tail 0b+7a, zero-foot test, morph take, set_emerge, soul line, mutate (cap cut it at 29/40) |
| reel | 29 | accepted | ohm accessors, reel, aura opt-out, rise clamp, curl at speed, frontal plume, apparition (7 commits, time-boxed to 05:58) |
| films | TBD | TBD | post-gate films + frames.json (package 5, no repo changes) |

What I would brief differently: a hard time box with an explicit commit deadline in every brief (package 4 had
one and finished 20 minutes early with 7 clean commits; package 2 without one hit the 75-min cap). Launch every
run detached from the first call (the 50-minute loss). And a standing "shared test hygiene" item in the
interface package: every flight test that asserts legacy art must select `GhostLook.LEGACY` itself, so a lane's
look flip never turns flight's tests red (three lanes hit this at 05:20-05:40).
