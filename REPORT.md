# REPORT - n24 lane `ghost` (branch `n24-ghost`, worktree n23-moves) - DRAFT, filled at 01:40

Owner's note 7: "Ghost powers: First level ability would be to hold 'Q' key for ghost deployment range. Player remains as Rivet, ghost is deployed, performs signature attack and disappears. Ghost full transition would be evolutionary level mastering the ghost skill."

## What works
(item, evidence, number: filled at the end)

- Hold Q / LB: the range ring and the form's target mark on the ground, in soul teal over an ink rim. Release: the loaded ghost appears at the spot, strikes once, fades. Rivet keeps walking, guarding and firing in his own body. Input `ghost_deploy` bit 19 / wire bit 32; old tapes carry no bit >= 31.
- Which ghost: G (power_gearbox, unchanged) cycles the loaded ghost; the HUD chevron marks it with the Q hint and the next chip carries the G hint; a cooling ghost shows the deploy cooldown arc.
- Cost: cooldown only, per form (`ghost_attacks.json` `deploy.<form>.cooldown_ticks`: 480, Kerf 600).
- Mastery: the transformation is kept behind `ghost_forms.json` `transform_unlocked` (false), on key T; story mode keeps it for quest 1's beats.

## What does not

## What blocked or slowed me

## Calls for the owner

## How the player could earn the full transformation (proposal, not built)
Each ghost earns its own mastery, so the transformation arrives one ghost at a time and the first-level deploy stays the everyday tool:
1. A per-ghost **bond** counter fills on that ghost's deploys that do their job: a kill or a stun by `deploy_<form>` (the gauntlet already tallies `deploy_kills` and `deploy_stun_s` per form). Empty releases earn nothing, so mastery rewards aim, not spam.
2. At a threshold (start: 25 effective deploys; one table value per form), the ghost's chip in the HUD gains a ring and a story-free line from the ghost; the next quest checkpoint offers "Master <ghost>", which sets that ghost's `transform_unlocked` (the table value becomes per form).
3. In the gauntlet, mastery is a rare late card (wave 12+), one ghost per card, so a run can show the evolution without the campaign.
4. After mastery: Q still deploys; T transforms into that mastered ghost only. The transformation keeps its Madness cost and cooldown, the deploy keeps its own.

## Merge notes

## Next steps

## Astra ledger
| call | minutes | verdict | note |
|---|---|---|---|
| g1-deploy-sim | 71 | accepted | 8 commits d07607db6..8d1d6fef1 |
| g2-deploy-views | 73 | accepted, partly | 5 commits 1608d8bce..f2a54bdb7; leftovers carried into g3 part 0 |
