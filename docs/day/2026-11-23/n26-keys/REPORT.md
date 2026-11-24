# REPORT - lane keys (n26, 2026-11-23)

Branch `n26-keys`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, cut from `main` `0779185ac`. Code head `e6db0a319`; frozen and gated at `8d6a78c07` (later commits touch only `JOURNAL.md` and `REPORT.md`).
Gate: `node tools/gate/run.mjs --rev=HEAD --reels` at 8d6a78c07, 16:21 to 17:25: `gate: PASS; C:\Users\kazda\kiro\gtai-wt\n23-controls\build\gate\8d6a78c07e71\gate.json`
(lint 19/19 over 2154 files; unit 4018 passed / 0 failed / 2 skipped; scenarios 68 ran, rig_stress p50 1.172 ms > 1.000 ms
CONTENDED with 3 other runs, budget not judged; parity bit for bit with the planted mutation caught at step 629; selftest pass;
release compile 968/0; reels exit 0).
Films and stills: `C:\Users\kazda\kiro\gtai-masters\n26\keys\` (`frames.json`, best first).

## What works

### 1. The keys (owner: "Lets make Sprint on Space bar" ...)
- Layout (8ee4e085b, by key only, no bit moved): **Space** sprint (hold) on foot / handbrake in a car; **Shift** dash burst only
  (`rivet_motion.json` `dash.hold_sprints` false); **F** quick claw (mouse binding kept); **1 2 3 4** = `ghost_deploy_1..4`
  (new bits 20-23, wire 33-36): hold shows the range, release deploys. **Slot order: 1 Dent, 2 Kerf, 3 Ohm, 4 Tonnage**
  (the `forms` order of `ghost_forms.json`). Key 1 beside an enterable car enters it, inside a car it leaves; a slot-1 hold
  that starts on a tick the car takes never deploys Dent (974647488). A ghost not owned does nothing on its key.
  Q, G and the number keys for weapon slots are unbound (bits kept for old tapes).
- Deploy HUD (84d4bd0f2): the strip reads 1 Dent, 2 Kerf, 3 Ohm, 4 Tonnage left to right whatever is selected; the cycle
  chevron and cycle hint for the freed G are gone. Each chip shows its number.
- Prompts follow the table, not literals: ghost chips and quest weapon hints from live bindings (e75e90ce1), quick claw prompt
  pinned (8d8bb3787), Quest 1 desktop cards read the live claw/car keys (61dc79c3c, f1e8c0e1c).
- Test players press actions: gauntlet bot presses the per-ghost deploy actions (c32d97d47); gauntlet seed 7 pilot identity
  exact (11 deploys, same forms, same ticks, 9-wave result JSON byte-identical); scenarios 68/68 incl. the 60 s replay at its
  pinned hash; four replays byte-identical.
- Unit tests: each number deploys its own ghost, 1 beside a car enters and does not deploy, a ghost not owned does nothing
  (974647488); interrupted sprint/deploy inputs (5d848ecd2); strip order whatever the selected ghost, no cycle hint (84d4bd0f2).
- Film `keys_overlay_32.mp4` (39.73 s, 1920x1080, 60/1) with on-screen key caps, every key pressed through its installed
  InputMap event: Space sprint 66-186, Shift dash 200, F claw hits by 282, 1/2/3/4 deploy Dent/Kerf/Ohm/Tonnage at
  394/874/1474/1954, 1 beside the sedan seats at 2117 (Dent count unchanged), 1 leaves at 2357 after 24.24 m.
  Still `keys_overlay_64.png` (Dent's range held on 1). Scene: `project/dev/controls/keys_film.gd`.
- Mutate: `ghost_deploy.gd` 14/(14+6); `ghost_form_hud.gd` partial 4/(4+1) of 13 (survivor: name gap 72 -> 73 px).

### 2. Bare hands cadence
- Each bare walk8/run8 boot is calibrated to its measured drawn travel (869642e12 moves the strides into
  `rivet_motion.json` `grid_stride`, fba046f21, a78c5f4c9: boots with no drawn travel keep the old cycle, `bare_min_travel` 0.4,
  `bare_max_cycles_s` 3.75). Profile drift at 32 px/m (mean of both profiles, `evidence/n26-keys/hands_after.md`):
  p70 walk 6.04 -> 1.93 cm, p70 sprint 5.25 -> 2.44 cm; p55 walk 11.87 -> 2.29 cm. Front/back hold 6-7 ticks at walk,
  4-5 at sprint (no one-tick flicker).
- Film `hands_before_after_32.mp4` (16.0 s, before | after with a 3x foot detail), still `hands_after_64.png`.
- Mutate `rivet_walk.gd` 15/(15+5), `rivet_grid_stride.gd` 1/(1+0).

### 3. Six weapons at p70: not shipped (see What does not).

### 5. Gloria beside the pistol (owner question, no change)
`gloria_vs_pistol_64.png`: at 64 px/m Gloria is about 80 px against the pistol's 54 at 70 degrees and 60 against 38 at
55 degrees, held long in both claws. See Calls for the owner.

## What does not
- **3. The six p70 weapon grids: none shipped.** The grids call (16:00) reached electro_gun's first build (14 of 16 rows
  generated and cut under `C:/Users/kazda/kiro/gtai-art/library/rounds/20261123-1559-n26keys/`, donor family plasma_rifle)
  when the builder hit its usage limit at 16:13 ("try again at Nov 28th"). No repo file changed; the six weapons stay on the
  fallback legs. The round dir keeps the generated rows for the next run.
- p55 bare sprint profile drift 11.31 -> 8.53 cm, over the 7 cm bar (p55 walk and both p70 rows meet it).
- Front/back bare rows have no drawn stride along the run: a held drawing slides ~55-60 cm over its 4-7 tick hold. Fixing
  that needs new drawn front/back run rows, not cadence.
  Stills of what still ships: `p70_electro_gun_stopgap_64.png`, `p70_homing_shard_stopgap_64.png` (the shared fallback body
  with only the held weapon swapped).
- **4. The 55 degree camera grids: not started** (it was queued behind item 3 and the builder limit came first). What I would
  do differently from last run's drifting Gloria attempt is written as a ready brief, `evidence/briefs/n26-04-grids-p55.md`:
  reference frames from the shipped p55 rows (never p70); a per-facing check of each generated row against the p55 pistol row
  before any packing (dome width within 3 %, sole line within 2 px, stride travel ratio within 0.05, same leading boot, no
  extra limb), a row that fails is regenerated alone; per-row p55 stride calibration measured in the game; stop after Gloria
  and judge her against the p55 pistol grid before a second weapon.
- The per-chip numbers on the deploy strip are small (about 10 px at 1080p).

## What blocked or slowed you
- **BLOCKED from 16:13: the Astra builder's usage limit** (no call possible until Nov 28). Items 3 and 4 lost (2 h 27 min to
  the freeze). The director does not edit product files, so the lane froze at 8d6a78c07 and ran the final gate there.
- Brief 01 too big for one 75 min call (verification tail cut by the cap): ~20 min of re-checks in the next call.
- First hands cadence gamed the drift number with one-tick depth rows: one resume (~70 min).
- The deploy strip order (4 1 2 3 with a cycle chevron) was only found by the keys film, not by brief 01's checks: ~42 min call.
- The keys film call stopped on a `dev_loc` debt rise not in its allowlist: one resume.

## Calls for the owner
1. **Gloria**: a long two-handed gun as the first pistol-class weapon (`gloria_vs_pistol_64.png`). Redraw as a one-hand
   pistol, or keep and move her class?
2. **Pad for the four deploys**: the pad keeps LB = deploy the selected ghost, RB = cycle. The alternative (d-pad as 1-4)
   is one table edit but takes the d-pad off movement. No film: the keys film drives the keyboard only.
3. **Key 1 at a car**: entering is taken before Dent's deploy whenever an enterable car is in reach. Alternative: hold 1 deploys,
   tap 1 enters (not built). Still: `keys_car_one_32.png` (the 1 cap reads Car, Dent's deploy count unchanged).

## Merge notes
- Wire ids: `ghost_deploy_1..4` bits 20-23 (wire 33-36); no existing bit moved. Melee lane owns souls except
  `ghost_form_hud.gd`, `ghost_hud_hints.gd` (changed here, 84d4bd0f2) and the deploy input files.
- Yard lane: re-take prologue films after merging `n26-keys` at 84d4bd0f2 or later (MILESTONE keys 8d8bb3787 for the bindings).
- `tools/debt/baseline.json`: `dev_loc` rise accepted for the keys film scene (02fce44db).
- Root `JOURNAL.md`/`REPORT.md`: keep this lane's on add/add conflicts.
- Temp: this lane's `gtai-gate-f223380ab3d2` in `%LOCALAPPDATA%\Temp` would not delete ("device busy" at 17:35 and 18:42);
  remove it in the post-merge Temp cleanup.

## Next steps
1. Item 3 resumed from the electro gun round (`C:/Users/kazda/kiro/gtai-art/library/rounds/20261123-1559-n26keys/`: 14 of
   16 rows cut, two to generate), then homing shard, mini-nuke, molotov, plasma sword, ray gun with brief
   `evidence/briefs/n26-03-grids-p70.md` (two weapons per 75 min call is the realistic rate).
2. Item 4 with `evidence/briefs/n26-04-grids-p55.md`, Gloria first and alone; it waits on the owner's Gloria call (a redraw
   as a one-hand pistol changes which reference rows she borrows).
3. p55 bare sprint drift 8.53 cm: a p55 run8 profile row factor of its own, measured as in `evidence/n26-keys/hands_after.md`.
4. Drawn front/back bare run rows with stride travel along the run (cadence cannot remove that slide).
5. Larger per-chip numbers on the deploy strip (about 10 px today), after the owner has played the keys.

## Astra ledger
| call | minutes | result | brief differently |
|---|---:|---|---|
| keys | 75 | accepted (cap hit in mutate) | split the verification tail into its own resume |
| hands | 72 | accepted with follow-up | name "no one-tick rows" as an acceptance check |
| hands-b | 70 | accepted | - |
| keys-film | 29 | accepted with follow-up | pre-authorise the debt update for dev scenes; a HUD still in brief 01 |
| keys-film-b | 42 | accepted | - |
| grids-p70 | 15 | abandoned (usage limit) | brief art rounds with a resumable state file so another builder can pick them up |
