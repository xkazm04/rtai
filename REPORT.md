# REPORT - n24 lane `ghost` (branch `n24-ghost`, worktree n23-moves) - DRAFT, filled at 01:40

Owner's note 7: "Ghost powers: First level ability would be to hold 'Q' key for ghost deployment range. Player remains as Rivet, ghost is deployed, performs signature attack and disappears. Ghost full transition would be evolutionary level mastering the ghost skill."

## What works
(item, evidence, number: filled at the end)

- Hold Q / LB: the range ring and the form's target mark on the ground, in soul teal over an ink rim. Release: the loaded ghost appears at the spot, strikes once, fades. Rivet keeps walking, guarding and firing in his own body. Input `ghost_deploy` bit 19 / wire bit 32; old tapes carry no bit >= 31.
- Which ghost: G (power_gearbox, unchanged) cycles the loaded ghost; the HUD chevron marks it with the Q hint and the next chip carries the G hint; a cooling ghost shows the deploy cooldown arc.
- Cost: cooldown only, per form (`ghost_attacks.json` `deploy.<form>.cooldown_ticks`: 480, Kerf 600).
- Mastery: the transformation is kept behind `ghost_forms.json` `transform_unlocked` (false), on key T; story mode keeps it for quest 1's beats.

### What one deploy is worth (`evidence/ghost/deploy-worth.md`, probe `project/dev/ghost-forms/deploy_worth_run.gd`)
Pistol Rivet on a 5.5 m strafe circle, seeds 1..10, 30 s budget, `off` (no deploy) vs `on` (deploy whenever off cooldown and a target fits). 60 releases, 0 empty.

| ghost | encounter | kills / use | stun body-s / use | damage / use | clear time on - off (CI95) | seeds faster | Rivet HP lost off -> on |
|---|---|---:|---:|---:|---:|---:|---:|
| Ohm | sentry turret, shield robot, 2 SWAT | 1.50 | 2.00 | 3.62 | -12.98 s [-13.07, -12.88] | 10/10 | 11.7 -> 0.0 |
| Kerf | shield robot, 3 patrol cops | 1.00 | 0 | 2.30 | -6.47 s | 10/10 | 11.4 -> 7.1 |
| Tonnage | war machine | 0 | 0 | 3.00 | -3.60 s [-3.77, -3.44] | 10/10 | 26.6 -> 12.9 |
| Dent | 5 patrol cops in a line | 5.00 | 0 | 5.00 | -1.13 s | 10/10 | 0.5 -> 0.0 |

Caveat: in this run every seed starts from the same formation (the seed reaches only the RNG context), so the ten pairs are near copies and the Kerf and Dent intervals collapse to one value. Dent's encounter is trivial (pistol alone clears it in 1.17 s).

### What the deploy does in the gauntlet (`evidence/ghost/gauntlet-deploys.md`, test player `GhostDeployBot`)
8-wave street gauntlet, greedy picks, wheel controls, seeds 1-3, paired: before = the bot without deploys (parent of a3ebfcd2d), after = the bot deploying the loaded ghost.

| profile | ghost | uses | kills | kills / use | machine-s stunned |
|---|---|---:|---:|---:|---:|
| average | Tonnage | 20 | 45 | 2.25 | - |
| average | Ohm | 5 | 3 | 0.60 | 9.38 |
| expert | Tonnage | 19 | 37 | 1.95 | - |

Kerf and Dent: 0 uses (picked only at wave 4 or 8 and no fitting target before the run ended). Outcomes: average seed 2 died on wave 7 -> cleared 8; expert seed 1 tick cap on wave 8 -> cleared 8; the other four pairs unchanged (expert seed 2 dies on 5 in both).

## What does not
- The bot never deploys Kerf or Dent in 8 waves: it picks Dent after wave 4 and Kerf after the last fight, and a Dent ram needs 2 or more hostiles on one line within 8 m, which the bot never set up (`evidence/ghost/gauntlet-deploys.md`). Their worth comes from the probe only. Novice was not measured (two profiles, three seeds).
- The worth probe starts every seed from one formation (the seed reaches only the RNG context), so the Kerf and Dent confidence intervals collapse to a single value. The formation jitter that would fix it was dropped in g4.
- Mastery is switched on by launch args read inside a souls class (`GhostPilot.shipped()` parses `--film-form`, `--sweep-form`, `--bot=boss --ghost`) and through the private `stage._quest`. Tests and tapes are green, but it belongs to the caller (StagePilot / the dev entries).
- Before g6 a ghost was on screen for only 0.25 to 0.5 s (`life_ticks` 15 to 30), a teal streak at real speed. g6 lengthens it (see below).

## What blocked or slowed me
- 10 min: my g2 brief named a `project/dev/ghost-deploy/` folder; lint LAY-02 rejects new hyphenated dirs, so g3 moved the film entry into `project/dev/ghost-forms/`.
- 15 min: in g3 and g4 the pre-commit hook ran full lint under five-lane load and held the index lock (the g3 probe was left staged at the hard stop and committed in g4).
- 10 min: the g3 to g4 handover (the probe left staged, mastery cleanup outside the allowlist).
- 0 min blocked on other lanes: motion's `NEED ghost` (`put_32`) was answered with no change; pressure accepted ghost's 3-line bot call site.

## Calls for the owner
Each with its still or clip in `C:/Users/kazda/kiro/gtai-masters/n24/ghost/`.
1. **Cost: cooldown only** (8 s, Kerf 10 s), no soul or Madness charge, because you named range and nothing else. Alternative, one table value away: a Madness charge per deploy. Clip: `deploy_all.mp4`.
2. **Which ghost: G cycles, Q holds and releases.** I rejected tap-Q-to-cycle because a tap and a hold on one key need a timing threshold and misfire. Still: `deploy_hud-after-64-f0121.png` (Q under the loaded chip, G on the next).
3. **The full transformation moved from Q to T** and acts only when `transform_unlocked` is true (false tonight; story mode keeps it for quest 1's beats). Pad LB now belongs to the deploy.
4. **How long a ghost stays on screen**: before 0.25 to 0.5 s; after g6 0.7 to 0.9 s with a fade-in, with the strike still on the release tick. Before/after: `deploy_kerf-64-before-linger.mp4` beside `deploy_kerf-64.mp4`.
5. **Kerf one-shots everything, the war machine included**, now on a 10 s cooldown at 9 m range. You accepted him as the boss answer last night; as a deploy he is the strongest single-target tool (1.00 kill per use). Keep it, or cap his deploy cut's damage on bosses (one value).

## How the player could earn the full transformation (proposal, not built)
Each ghost earns its own mastery, so the transformation arrives one ghost at a time and the first-level deploy stays the everyday tool:
1. A per-ghost **bond** counter fills on that ghost's deploys that do their job: a kill or a stun by `deploy_<form>` (the gauntlet already tallies `deploy_kills` and `deploy_stun_s` per form). Empty releases earn nothing, so mastery rewards aim, not spam.
2. At a threshold (start: 25 effective deploys; one table value per form), the ghost's chip in the HUD gains a ring and a story-free line from the ghost; the next quest checkpoint offers "Master <ghost>", which sets that ghost's `transform_unlocked` (the table value becomes per form).
3. In the gauntlet, mastery is a rare late card (wave 12+), one ghost per card, so a run can show the evolution without the campaign.
4. After mastery: Q still deploys; T transforms into that mastered ghost only. The transformation keeps its Madness cost and cooldown, the deploy keeps its own.

## Merge notes
- `merge-tree` HEAD vs each lane (21:12): n24-motion and n24-pressure conflict in `project/data/tables/input_actions.json` (keep BOTH new rows: `dash` bit 18 / wire 31, then `ghost_deploy` bit 19 / wire 32; keep ghost's `power_hauler` on key T with no pad button, LB belongs to `ghost_deploy`) and `project/data/schemas/gauntlet_run.schema.json` (keep motion's `dashes` and ghost's `deploys` / `deploy_kills` / `deploy_stun_s`, sorted). `tools/debt/baseline.json`: `node tools/debt/merge_baseline.mjs`, then `--update`. JOURNAL.md / REPORT.md add/add: keep each lane's own.
- The schema maxima for `input_actions` rows are 19 / 32 on both ghost and motion (identical edits). TickInput's mask is 48 bits on both.
- `stage_pilot.gd:134` hashes the previous button word with `put_32`; wire bit 32 is not in it, but `GhostDeploy.write_state` hashes the hold every tick, so no widening (it would move every shipped digest).

## Next steps
- Move the mastery switch out of `GhostPilot.shipped()` into the caller (StagePilot / dev entries set `ghosts.transform_unlocked`), and give the story check a public accessor.
- Formation jitter in the worth probe so the seeds differ; measure novice.
- A bot rule that sets up Dent's line and uses Kerf on armoured targets, so the gauntlet numbers cover all four ghosts.
- Earn the transformation per ghost (proposal above).

## Astra ledger
| call | minutes | verdict | note |
|---|---|---|---|
| g1-deploy-sim | 71 | accepted | 8 commits d07607db6..8d1d6fef1 |
| g2-deploy-views | 73 | accepted, partly | 5 commits 1608d8bce..f2a54bdb7; leftovers carried into g3 part 0 |
| g3-deploy-worth | 73 | accepted, partly | 3 commits f04829845..82dd30c77 (Ohm view, film entry, worth evidence); probe left staged at the hard stop, committed in g4 |
| g4-deploy-polish | 74 | accepted | 7 commits 850233008..a671deded (probe, Ohm placement, HUD plate, cost decision, tests, live fire in the film); formation jitter dropped |
| g5-deploy-bot | 47 | accepted | 5 commits c84deef09..a4503612a (GhostDeployBot, 3-line `bot_brain.gd` call site, tests, paired gauntlet evidence); mutate 18/20 |
