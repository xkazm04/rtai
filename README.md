# RTAI: Uprising

**RTAI: Uprising** is a top-down, open-city action game. Rivet is a factory robot and the only one to survive
the "accident" that killed its whole production line. It wakes up with the four dead robots talking in its head,
and fights through a city of police and robot crime bosses toward the people who planned the accident. The
game is built in Godot 4.7.2 on a deterministic C++ city simulation, for Steam on PC.

![A city street corner seen straight down in an inked comic-print look: cream paving, blue police, a body in red, cars at the kerb](docs/readme/poster-city-look.jpg)

*The look target the owner picked on 2026-11-04, "Inked Grime" with a risograph texture: a brush-ink outline,
flat fills and print grain, seen straight down. The palette follows the colour rule: police are blue, and red is
used only for blood. AI concept art, not an in-game frame.*

> **Status: private, in development.** Phase 2 (the foundation) is done. The vertical slice is being built:
> quest 1, two boss arenas and the angled camera. Nothing here is released.

| You want to | Go to |
|---|---|
| know what the game is | [The game](#the-game), [The four ghosts](#the-four-ghosts), [Bosses](#bosses) |
| see how far it has got | [Where it stands](#where-it-stands) |
| run it | [Run it](#run-it) |
| change it | [Check it](#check-it), then [Read on](#read-on) |

Internal id: `gtai`. Code, paths and tool ids use `gtai`; anything a player sees says **RTAI** ("Robot Theft A.I.").

## The game

Rivet walks, rolls, shoots and brawls through a living city seen from above. The game is a brutal, profane
crime sandbox: robot bosses hire Rivet for jobs, the police escalate, and the crowd panics. A military general
on the radio pays for "rogue robot" kills that turn out to be his own housekeeping. The campaign runs about
five hours across four acts and a finale, ending in a raid on the military's headquarters.

![Four figures from straight above, left to right: a human for scale, Rivet, a first transformation venting steam, and a towering second form with a claw and a cutting torch](docs/readme/poster-rivet-transformation.jpg)

*Rivet from straight above, beside a human for scale, and his two transformation stages (target, 2026-11-04).
Rivet himself is barely bigger than a person; each stage roughly doubles him. The vermilion hazard-striped collar
is his alone, and it carries through every stage. AI concept art.*

## The four ghosts

The robots that died on Rivet's line live on as voices that argue, heckle and react to everything he does.
Through the campaign he learns to listen to them and then to **become** them. Teal is reserved for the souls,
so a ghost on screen is never mistaken for anything else.

| Ghost | What it was | What it does as Rivet's power |
|---|---|---|
| **Dent** | a crash-test robot | seizes a street car, steers it as a missile, overloads it to blow |
| **Tonnage** | a stamping press on piston legs | walks into fire, takes 0.3 of every hit, flattens a group and crushes cars |
| **Kerf** | a laser-cutting head | blinks through up to three targets in a line and cuts them clean |
| **Ohm** | an old spot welder | forks a bolt across a group, stunning humans and burning robots and cars |

![Dent drawn three ways on cream paper: a huge teal ghost form, its living crash-test body with target markings, and the ghost riding a burning car into a wall of police cars](docs/readme/poster-ghost-dent.jpg)

*Dent, the first ghost (concept, 2026-11-04). Its living body and its teal soul form share one silhouette; the
lower right shows the power, a seized car driven into police cars. AI concept art. The numbers behind all four
powers are in [`docs/ghosts/ghost-attacks.md`](docs/ghosts/ghost-attacks.md).*

## Bosses

Each act has robot bosses with a district, a gang and a fight of its own. Two are built and fightable today.
Each has a telegraphed moveset, phases, and a bot that judges the fight's envelope.

| Boss | Act | The fight | Design |
|---|---|---|---|
| **The King** | 1 | a procession on a gilded throne-car pushed by his gang, then his court, then the King on foot | [`docs/bosses/king.md`](docs/bosses/king.md) |
| **Servo** | 2 | a courier hub: drone swarms that drop packages, a scanner beam that marks Rivet, a rotor dash | [`docs/bosses/servo.md`](docs/bosses/servo.md) |

![A tall courier-hub robot on long legs with a launch rack of drones on its back, beside sketches of the rack from above, drones dropping parcels, and a red scanner beam aimed at a tiny figure](docs/readme/poster-boss-servo.jpg)

*Servo, the Act 2 boss (concept, 2026-11-05). The drone rack on its back is the part the player reads from
above, and the beam on the lower right is the mark that calls the drones in. Bosses may use a wider palette than
the street. AI concept art.*

## Where it stands

Measured on rtai `main` at `3982af1a` (2026-11-07, after the n8 merge), on the owner's machine:

| What | Result |
|---|---|
| Lint (format, size, layers, banned APIs, debt ratchet) | 15 of 15 checks pass |
| Unit and integration tests (GUT, headless) | 1,691 pass, 0 fail |
| Scenario suite (incl. the 60 s replay) | 52 pass |
| Native sim vs the GDScript reference (1,200 steps) | bit-exact |
| Look goldens / block goldens | 11 of 11 / 5 of 5 |
| Release compile (what an export ships) | 597 scripts, 0 errors |
| Director reel, 19 combat chapters, in `top`, `tilt70` and `combo` | 19 of 19 in each view, 0 script errors |

**Playable today:** quest 1 (`collect-call`) from start to "paid"; the King and Servo arenas; the city with
traffic, a reacting crowd and the police heat ladder; Rivet's arsenal of guns and melee weapons; the four ghost
powers. **Views:** `top` (straight down) is the default. `combo` (a 70-degree view in play that eases to 55 when a
boss engages) replaces it once Rivet's drawn whole-figure frames are in the game.

## Run it

You need [Godot 4.7.2](versions.toml) (the console binary on Windows), Git LFS, Node 24 and Python with
`gdtoolkit` 4.5.0. Once per clone:

```sh
git config core.autocrlf input           # every clone and worktree (GIT-02)
git lfs install
git config core.hooksPath .githooks       # pre-commit runs the lint job
pip install "gdtoolkit==4.5.0"
export GODOT_BIN=/path/to/Godot_v4.7.2-stable_win64_console.exe
"$GODOT_BIN" --headless --path project --import
```

The game runs on the D3D12 driver. To play a scene, launch the project and pass flags after `--`:

| Scene | Command |
|---|---|
| The game (boot scene) | `"$GODOT_BIN" --rendering-driver d3d12 --path project` |
| Quest 1 | `"$GODOT_BIN" --rendering-driver d3d12 --path project res://boot/quest1.tscn` |
| The King's fight | `"$GODOT_BIN" --rendering-driver d3d12 --path project res://dev/arena/arena.tscn -- --boss=king --view=combo --rigs` |
| Servo's fight | the same, with `--boss=servo` |
| The city block | the same, with `--arena=city --rigs --view=tilt70` |
| The director reel (a bot plays 19 chapters) | the same, with `--bot=reel --reel=director --loadout=pistol --rigs` |

Every launch flag is listed, with a comment, in [`project/boot/launch_args.gd`](project/boot/launch_args.gd)
(`KNOWN_FLAGS`); an unknown flag is an error. The camera views are rows in
[`project/data/tables/view.json`](project/data/tables/view.json).

## Check it

One command writes the evidence that PoF, the studio tool that drives this game, reads:

```sh
node tools/evidence/run.mjs
```

It runs lint, the unit tests, scenarios, native parity, the release compile and the bench. It writes
`build/evidence/<kind>.json` (`pof.godot-evidence/1`), stamped with `git rev-parse HEAD`. **Commit first.**
Evidence from another commit is stale, and the writer refuses a dirty tree unless you pass `--allow-dirty`.

| What | Command | `just` |
|---|---|---|
| Lint | `node tools/lint/lint.mjs` | `just lint` |
| Unit tests, all | `node tools/tests/run_unit.mjs` | `just test` |
| Unit tests for your diff | `node tools/tests/run_unit.mjs --changed` | |
| Scenarios | `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` | `just scenarios` |
| Native vs GDScript parity | `node tools/tests/run_parity.mjs` | `just parity` |
| Build the C++ sim | `cd native && scons platform=windows arch=x86_64 target=template_debug` | `just native` |
| Bench (crowded drive, 400-actor riot) | `node tools/bench/run.mjs` | `just bench` |
| Mutation test a file you changed | `node tools/mutate/mutate.mjs --file=<project-relative .gd>` | `just mutate` |

## Read on

Ordered by who usually needs it first.

| Page | What is in it |
|---|---|
| [`docs/bosses/`](docs/bosses/) | the King and Servo: the read from above, telegraph rules, attacks, phases, how the ghosts and weapons meet each fight, the bot's measured envelope |
| [`docs/ghosts/ghost-attacks.md`](docs/ghosts/ghost-attacks.md) | the four ghosts: role, damage, reach, cadence, kills per activation, measured by the ghost bot |
| [`docs/art/weapons.md`](docs/art/weapons.md) | the weapon design language, the views, the `weapon_art.json` contract, gore stickers |
| [`docs/view-lab/PLAN.md`](docs/view-lab/PLAN.md) | the angled camera: one projection transform, the cost per class under a tilt, the draw order, the measurements |
| [`docs/polish/`](docs/polish/) | scored polish audits of melee, ranged and the held weapons under a tilt, ranked weakest first |
| [`docs/day/`](docs/day/) | every day and night run's lane `REPORT.md` and `JOURNAL.md`: what landed, its evidence, what is owed |
| [`docs/decisions.md`](docs/decisions.md) | every `DECISION` and `DEVIATION <RULE-ID>` line, with its date and re-check trigger |
| [`AGENTS.md`](AGENTS.md) | the full command table, the folder map, the ten rules agents break first, code templates to copy |
| [`STANDARDS.md`](STANDARDS.md) | the authoritative rules: git, layout, GDScript, architecture, data, native, determinism, assets, saves, localisation, Steam, testing, export, legal, performance budgets |
| [`docs/determinism.md`](docs/determinism.md) | the fixed tick, per-system RNG streams and the replay contract (SIM-04) |
| [`docs/data-contracts.md`](docs/data-contracts.md) | the schemas PoF reads: `pof.godot-evidence/1` and the quest vocabulary `gtai.quest-rules/2` |
| [`native/README.md`](native/README.md) | the CitySim GDExtension: the plain-C++ core, the binding and the build |
| [`tools/debt/README.md`](tools/debt/README.md) | the debt ratchet: its metrics, what fails, how to tighten or accept a regression |
| [`docs/provenance.md`](docs/provenance.md) | how every shipped image and sound is traced (`steam/ai-provenance/`), and where the masters live |

## Repository layout

| Path | What it holds |
|---|---|
| `project/` | the Godot project (`res://`): `boot/`, `core/`, one folder per feature under `features/`, JSON tables in `data/`, `tests/`, and `dev/` (debug only, dropped from release exports) |
| `native/` | the C++ city simulation and its GDExtension binding |
| `tools/` | Node and Python tooling: lint, tests, evidence, bench, mutation, debt, art |
| `steam/` | store metadata, achievements, rich presence, the AI provenance log |
| `docs/` | design pages, decisions, run reports; `docs/readme/` holds this page's posters |
| `build/` | git-ignored output; `build/evidence/` is what PoF reads |
