# REPORT - lane `controls` (n23, 2026-11-22)

Branch `n23-controls`, cut from `main` `76111adec`. Director: Opus; builder: Astra (all product edits).
DRAFT (05:25): sections marked PENDING are filled after b4 (guard pose), b5 (films) and the final gate.

## What works

| Item | Evidence | Number |
|---|---|---|
| Runners take `--controls=wheel\|legacy` | `c9499ca02`, `f1d5e915f`; `tools/tests/run_unit_controls.test.mjs`; GUT gets the mode through env `GTAI_CONTROLS` + `project/tests/support/gut_pre_run.gd` (vendored GUT untouched) | Node parser test green |
| Wheel is the default, opens on slot 0 `hands` | `a01c1e530`; `evidence/controls-flip/counts.md` | scenarios wheel 49 -> 65/65, legacy 65/65, no flag 65/65; unit+integration 3,641/0/2 in both modes |
| Pinned, twinned and re-selected tests | `evidence/controls-flip/tests.md` (every fixture with its reason) | 2 legacy contracts twinned (`rivet_pickup`, `rifle_rack`), 17 weapon fixtures re-selected, tapes replay on their recorded mode |
| Replays on their recorded mode, not re-recorded | tape header gains optional `controls`; a tape without it replays on legacy (`docs/decisions.md` 2026-11-22 controls) | 60 s replay `cbeb734f...` and quest 1 `37bf8dea...` unchanged in both modes |
| Quest 1 help card follows the mode | `b8ed9d480`, `project/boot/quest1_controls_text.gd`; stills `card_wheel.png`, `card_legacy.png` | 12/12 card tests per mode |
| Swing telemetry: a held primary counts one combo start | `f14c7cc13` | not in replay state |
| Blast ring stamped with the impact tick | `b0bdcdc2e` | 6 replay artifacts / 34 digest fields unchanged in both modes |
| Rivet's own blasts hurt him | `12d548bf6`, `93d0d5b49`, `4f175c24a`, `b765422a1`; `project/features/combat/rivet_self_blast.gd`; `evidence/controls-flip/self-blast-radii.md` | own rocket 22 HP at point blank, 0 at 3.5 m; nuke lethal within 4.0 m of the body edge; film 100 -> 88.2 in the open, 100 -> 100 behind a high wall; mutate 15/17 (88.2%) |
| Per-wave `self_damage` in the gauntlet result | `gauntlet_run.schema.json` (own optional field) | seed 7 average: 0.0 x5 (measured, the bot did not self-hit) |
| Guard pose reads without the spark | `5b46a21f1`: painted `rivet_guard.png` per pitch (p70, p55), cut by `tools/art/rivet_guard.py`; `project/features/player/player_guard_pose.gd`; stills `guard_pose_32.png`, `guard_pose_64.png` (old beside new, 8 facings, both pitches, no spark), `guard_phases_64.png`, film `guard_pose.mp4` | 2 in-betweens of 3 ticks + held + stagger held while broken; flat rig lowers its body; replay_60s, quest1_input, rivet_deflect byte-identical; mutate 19/20 (95%) |
| Quest 1 and arena films on hands with the wheel | PENDING b5 | |

## What does not
- The painted held guard figure is about 10 to 15% smaller than the rig rest pose (head and shoulders at 32 px/m, `guard_pose_32.png`), so Rivet visibly shrinks as the guard rises; the crouch explains part of it, not all. A scale pass in `tools/art/rivet_guard.py` (cut scale) is the fix.
- Quest checkpoints (`gtai.checkpoint/1`) do not store the controls mode; a checkpoint saved on legacy and resumed on wheel replays its input history on the launch mode. Same-mode resume and tamper tests pass. Needs a save-format change outside this lane.
- `rig_stress` p50 1 ms budget misses now and then on the 5-lane machine (1.035 ms once), passes alone; PENDING a run under the bench lock.

## Moved digests
- `brutality_kills` rocket replay (in-memory tape, not a golden): Rivet's own splash at ticks 66 and 396 now takes 10.06 HP instead of 1.006, so 8 intermediate checkpoints per mode moved; the tick-700 finals are identical. Listed in `evidence/controls-flip/self-blast-digests.md`.
- Nothing else: `replay_60s`, quest 1 input, 6 tapes, 61 archived digest fields identical in both modes.

## What blocked or slowed you
- b1 edited the vendored GUT addon to forward the flag; bounced and reverted in b2 (about 20 min).
- b3: Rivet's splash first used the hostile 0.01 HP conversion (own rocket 2.2 HP, invisible); a resume (b3b, 46 min) added the conversion knob and refilmed.
- A director journal commit swept Astra's staged files once; undone with a soft reset at once (5 min). Lesson: commit with a pathspec while Astra runs.

## Calls for the owner
1. **How much Rivet's own rocket hurts.** Shipped: `combat.json` `blast.rivet_hp_per_table_hp` 0.1 (own rocket 22 HP at point blank, close to an enemy lancer rocket's 24). The alternative is 0.01 (2.2 HP, which you would not notice). `self_k` 1.0 stays as the knob for "how much his own blasts count". Film `self_blast.mp4`, stills `self_blast_hit.png` / `self_blast_wall.png`.
2. Self damage can kill (you said "hurt", not "spared"). A mini-nuke kills a full-health Rivet within 4 m of his body.
3. A pickup under the wheel does not auto-select the new weapon (as last night); scroll or the grip key draws it.

## Merge notes
- `combat.json`: only the new `blast` block (moves adds `moves`; both are new top-level keys, sorted).
- One-line call site in `project/features/combat/weapons/fight_areas.gd` (`RivetSelfBlast.land`).
- `loop` must expect `self_damage` per wave and that the bot can now kill itself with rockets (`NEED loop` in JOURNAL 04:32).
- Root `JOURNAL.md` / `REPORT.md`: keep each lane's own.

## Next steps
- Scale pass on the painted guard strips (`tools/art/rivet_guard.py` cut scale) so the held figure matches the rig rest pose height.
- Store the controls mode in quest checkpoints (`gtai.checkpoint/1` -> an optional field, as the replay tape got) so a cross-mode resume replays on the mode it was saved in.
- Loop lane: teach the test player to keep rockets >= 3.5 m and the nuke >= 12 m from Rivet now that his splash hurts him; re-measure with `self_damage` per wave.
- Owner verdict on `blast.rivet_hp_per_table_hp` (0.1 shipped, 0.01 the alternative) after watching `self_blast.mp4`.

## Astra ledger
| Call | Minutes | Verdict | Note |
|---|---:|---|---|
| b1-flip | 74 | accepted | runner flag + default flip; bounced the GUT addon edit into b2 |
| b2-card | 69 | accepted | addon revert, quest card, swing count, ring tick |
| b3-selfblast | 69 | bounced (partly accepted) | debt ratchet stopped the call-site commit; HP conversion too small |
| b3b-selfblast-scale | 46 | accepted | conversion 0.1, refilm with target, HP bar and wall |
| b4-guard-pose | 46 | accepted | painted strips at both pitches, 2 rerolls on p70 front facings; film driver left staged (dev-line debt), committed in b5 Part 0 |
