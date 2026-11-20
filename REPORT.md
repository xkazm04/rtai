# n20 lane `flight`: what the four spectral ghosts share

Branch `n20-flight` (cut from `int-n20` a3eb0bf78), worktree `C:\Users\kazda\kiro\gtai-wt\n20-flight`.
Director: Claude Opus (four sessions); builder: GPT-6.2 Astra. Films and stills:
`C:\Users\kazda\kiro\gtai-masters\n20\flight\` (`frames.json` there, best first).
Gate: GATE_LINE_TBD

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

TBD

## What blocked or slowed you

- 50 min: package 3's Astra run died with my session 2 at 03:09 (a background Bash child dies with its
  session); its lock pid had been reused by an unrelated process, so my watcher waited on a stale lock until 04:02.
  From 04:03 every Astra run was launched detached through WMI and the lock pid checked by process name.
- Package 2 hit Astra's 75-min cap (work committed in six pieces, nothing lost).

## Calls for the owner

TBD

## Merge notes

- `project/data/tables/ghost_hover.json`: each ghost lane tunes its OWN row on its branch (tonnage, dent, kerf,
  ohm all did). Rule: each lane's own row wins; flight's schema, new fields and defaults win.
  Ohm's `tail.fade_from` is 0.18 on flight; ohm's row wins if it differs.
- Root `JOURNAL.md` and `evidence/briefs/` travel into every lane that merged `n20-flight` (dent's FRICTION
  01:48): keep each lane's own JOURNAL.md at the merge, not flight's.
- Flight's own tests that other lanes guarded on their branches (their version wins):
  `project/tests/unit/test_ghost_hitback.gd` Ohm windup test pinned to `GhostLook.LEGACY` (n20-ohm);
  `project/tests/unit/test_ghost_flight_hosts.gd` null-sprite guard for `own_body` rigs (n20-dent);
  `project/tests/unit/test_ghost_card.gd` Tonnage crown/hose cases pinned to legacy (n20-tonnage).
- Ohm and Dent rows flip to `look: spectral` on their branches: after merging all five, run the FULL unit suite;
  any flight test that asserts a legacy sheet without selecting a look goes red the same way (fix: `override_for_test`).
- Pending one-liners in lane files after the merge: dent `dent_body.gd` `_aura.form_id = &"dent"` (uses `fa2b4dac7`);
  ohm switches `drawn._fade` / `drawn._hurt` to `release_fade()` / `hurt_tick()` (`51a905763`).
- One-line call sites other lanes made in flight's files, accepted: kerf `ghost_form_view.gd`
  (`v._bodies.kerf.stage = stage`), ohm `GhostActs.prepare_ohm` (`rig.ohm = o`).

## Next steps

TBD

## Astra ledger

| Tag | Minutes | Result | Note |
|---|---|---|---|
| interface | 68 | accepted | contract + stubs, 00:37 commit |
| sheets | 14 | accepted | lane NEEDs (ohm, dent, tonnage) |
| real | 75 (cap) | accepted | own_body, hover, tail, fade, film tool |
| effects | 12 | abandoned | killed with my session at 03:09 |
| effects-resume | TBD | TBD | tail 0b+7a, zero-foot test, morph |
| reel | TBD | TBD | |

What I would brief differently: TBD
