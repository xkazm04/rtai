# Bare hands prologue comparison

Each pair runs from the original claw to the quick one-shot rake.

The title-menu pilot ran at 60 simulation ticks/s. Patrol time covers the hands encounter from Dale falling through the patrol clear. Squad time counts the ranged fight from Mulroney’s shoot order through the squad clear. The full encounter boundaries, including the briefing, are in the JSON. Lowest HP is sampled after every tick. Quest 1 time ends on the first subtitle.

| Seed | Patrol (s) | Squad (s) | Fighting (s) | Lowest HP | Quest 1 (s) | Deaths | Outcome |
|---:|---:|---:|---:|---:|---:|---:|---|
| 1 | 31.27 → 31.27 | 34.95 → 34.95 | 66.22 → 66.22 | 0.00 → 0.00 | 175.97 → 175.97 | 1 → 1 | quest1 → quest1 |
| 2 | 30.85 → 30.85 | 44.10 → 44.10 | 74.95 → 74.95 | 52.00 → 52.00 | 169.68 → 169.68 | 0 → 0 | quest1 → quest1 |
| 3 | 31.27 → 31.27 | 57.83 → 57.83 | 89.10 → 89.10 | 0.00 → 0.00 | 198.85 → 198.85 | 1 → 1 | quest1 → quest1 |
| 4 | 31.23 → 31.23 | 48.20 → 48.20 | 79.43 → 79.43 | 68.67 → 68.67 | 174.17 → 174.17 | 0 → 0 | quest1 → quest1 |
| 5 | 31.27 → 31.27 | 53.85 → 53.85 | 85.12 → 85.12 | 0.00 → 0.00 | 194.87 → 194.87 | 1 → 1 | quest1 → quest1 |

## Reproducing the sample

Copy the three files in [pilot](pilot/) into `project/dev/melee/` in a measurement checkout, then run the normal Godot import. For each seed from 1 through 5 run `node tools/dev/run.mjs hand_pilot_probe --bot --seed=N --result=<absolute-json-path>`. The probe steps the title-menu pilot and samples Rivet after each simulation tick. Its seed-one result also runs the arena mash tape and records its digest. The stock new-game pilot produced the same baseline outcome and time on every seed.

## Yard integration

No measured seed needs a difficulty retune. The three appliance wardens are wave-one catchers, and their roster ID retains ordinary claw damage. Mulroney is the named commander and has the same protection.

Dale Winnick is spawned with the ordinary patrol-cop ID. The yard spawner can mark that specific fighter with `set_meta(MeleeLethal.NAMED, true)` to exempt him from the generic finisher. The arena owns the signature-death renderer used in the captures. The yard needs to connect that renderer to show the same drawn deaths in the prologue.
