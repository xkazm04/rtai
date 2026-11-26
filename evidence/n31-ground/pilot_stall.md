# n31-23 pilot stall: does the n31-19 yard trap the seed 7 pilot?

Verdict: **not a trap.** Seed 7's +100 s on `428511fc3` is three deaths and their checkpoint
replays (two in the hands fight, one in beat two), not Rivet or a cop standing against a new
footprint. The parent `db132bf0c` (old footprints) dies 0 times. Nothing in
`prologue_yard_dressings.json` changes.

## How measured

`project/dev/ground_n31/pilot_stall_probe.tscn` runs the pilot exactly as
`scenario_prologue_pilot` does (boot, `dev/bots/prologue_bot.gd` as input, no render) and logs
every 30 ticks: Rivet's position and hp, every live foe, the solid box nearest Rivet. HEAD
(`10c770a63`, yard as `428511fc3`) and a snapshot of `db132bf0c` (probe copied in), headless:

- HEAD: `pilot-stall: end ticks 17712 ended true sha eb040b06699ea72aa14f0b0283f26e6f6a46ae33faf607da89f8244086ca9068` (= the scenario pin)
- db132bf0c: `pilot-stall: end ticks 11701 ended true sha 993e5b7f080f30c0fa8f1def74e274f6762e6a05a757859e354d41e45083eeba` (= the old pin)

Logs: `evidence/n31-ground/pilot_stall_head_s7.jsonl`, `evidence/n31-ground/pilot_stall_parent_s7.jsonl`
(`t` tick, `ph` encounter phase 0 talk / 1 hands / 2 beat two / 3 street, `r` Rivet m, `near`
[box index, gap m], `foes` [id, archetype, x, y, hp]).

## Where the time goes (seed 7)

| phase | db132bf0c | HEAD | delta |
|---|---|---|---|
| talk 0-2220 | 2220 | 2220 | 0 |
| hands | 2220-5220 (3000) | 2220-10770 (8550) | +5550 |
| beat two | 5220-9300 (4080) | 10770-15390 (4620) | +540 |
| street to end | 9300-11701 (2401) | 15390-17712 (2322) | -79 |

Deaths (hp 0): db132bf0c none; HEAD t~4800 hands at (9.0, 6.0) with patrol cop 5 at 1.6 m,
t~7800 hands at (55.8, 6.3) with cop 16 at 4.2 m, t~12600 beat two at (33.7, 24.1) with
riot_cop 32 at 1.8 m. Each restarts its checkpoint (hands: Rivet back at hp 100 by t 5100 and 8100; beat two: back at
its opening stand at (53.1, 32.6)). The hands fight is the same in both runs: the patrol flees
around the yard perimeter and the pilot chases it; on HEAD Rivet takes more hits on that chase
(hp 45.8 at t 3600 vs 89.7 on the parent) most likely because the new boxes and supports change the
cops' routes and shot lines (the log shows the hits, not their cause).

## Windows of < 1 m motion over 300 ticks, t 5000-17712

HEAD:

| ticks | Rivet at | phase | nearest solid, gap | nearest foe | what |
|---|---|---|---|---|---|
| 8130-9510 (1380) | (35.99, 33.40) | hands, 3rd try | fence `wall_high#4` (south fence west of the gate), 2.99 m | 3.1 m (cops 25-27 at (36.0, 36.5) outside the gate) | the pilot targets the nearest foe, a reserve standing outside the still-closed gate; `PrologueStage.step` clamps Rivet to gate.y - radius = 33.40 until the exit opens. Ends at 9480 when the reserves walk in. No yard footprint within 2.9 m |
| 10770-11640 (870) | (52.60, 32.60) | beat two, 1st | fence `wall_high#5`, 0.75 m | 3.7 m | beat two's opening (the bot stands, span 0.00, until `battle.ranged`); the parent has the same stand at 5220-6120 (900) |
| 12660-13530 (870) | (53.12, 32.55) | beat two, replay | fence `wall_high#5`, 0.80 m | 3.7 m | the same opening after the 12600 death |
| 15630-17490 (1860) | (42.43, 36.29) | street phone | fence `wall_high#5`, 2.25 m | none | the phone call; the parent has it at 9630-11460 (1830) |

db132bf0c: 5220-6120 (beat two opening) and 9630-11460 (phone), the same two scripted stands.

Footprint checks on both logs (`build/n31/n31-23/foes.py`, scratch): no 300-tick window where
Rivet moves < 1 m within 0.8 m of a yard footprint (conveyor box, arch support, wreck); no
30-tick step < 0.3 m within 0.6 m of one during the fights (0 on HEAD, 0 on the parent); no foe
moving < 0.3 m over 300 ticks within 0.6 m of one. No blocking rect id: nobody presses against a
conveyor box or a `leg_*` support.

## Against the bar

- No window of < 1 m over 300 ticks that is not a fight or a scripted stand: the gate window has
  foes at 3.1 m (within 8 m), but it is the pilot standing, not fighting: the bot picks a reserve
  behind the closed gate. It is bot target choice plus the gate clamp, not a footprint, and only
  shows on HEAD because the second hands replay leaves Rivet by the gate. A player sees the gate
  shut and the cops outside.
- Seed 7 end 17712 is +51 % over 11701; the log puts the extra time in death replays (+5550 hands,
  +540 beat two), with 1380 ticks of that at the gate.

NEED (bots, not ground's path `project/dev/bots/prologue_bot.gd`): `_fight` should skip foes the
pilot cannot reach (beyond the gate while `exit_open` is false), or the 1380-tick gate stand comes
back on any seed whose replay ends near the gate.
