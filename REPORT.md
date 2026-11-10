# n11 tools lane: REPORT (DRAFT, written 01:40 in iteration 25; the report session finalizes it)

Branch `n11-tools`, cut from main `812a0b06`. Every tool below has a section in `tools/README.md`
with one example and what it refuses. Every evidence tool reports pass, fail or **unverifiable**
(it ran but could not observe the thing; never a pass). Proofs are real runs, named in `JOURNAL.md`.

## Tools built, one example each

| Tool | Example | Proven on a real run (JOURNAL) |
|---|---|---|
| `tools/film/film.mjs` named shots, fixed seed/step, locked camera, probe numbers | `node tools/film/film.mjs weapon:pistol --out=build/film/pistol --on=fire:1+4,kill:1+3` | 20:15 (arena PASS 11 s; a street shot walking out of frame is now unverifiable) |
| `--victim=<kind>` on the weapon shot (combat request) | `node tools/film/film.mjs weapon:machine_pistol --victim=cop/head_swat --out=build/film/swat --on=kill:1+30` | 01:32, refusal only: no tree has the game hook yet |
| `tools/film/compare.mjs` before/after at the same tick, two commits or worktrees | `node tools/film/compare.mjs chapter:pistol --a=main --b=n11-combat --at=240,330 --subject=dead --out=build/film/cmp` | 20:15 (PASS on a real corpse change; same commit both sides -> UNVERIFIABLE, 0 px differ) |
| `tools/film/sheet.mjs` labelled contact sheet | `node tools/film/sheet.mjs build/film/pistol --out=build/film/pistol/sheet.png --cols=4` | iteration 7-8 |
| `tools/film/numbers.mjs` per-tick draw size, feet, rest, facing vs aim | `node tools/film/numbers.mjs build/film/arena --ticks=60-200 --subject=rivet` | iteration 7-8 |
| film runs `--import` when an asset really changed (MD5, not date) | (automatic) | 22:15 (found that Godot's own scan trusted the date and drew old pixels) |
| `tools/gate/quick.mjs` the lint rules builders trip, changed files only | `node tools/gate/quick.mjs` | 20:36 (planted file: CRLF, gdformat, print, float(Variant) in 7.0 s) |
| `tools/gate/run.mjs` the gates on a snapshot of the commit | `node tools/gate/run.mjs` | 20:46 (8m35, tree edited throughout, no log landed in it) |
| stale-count honesty with Godot absent | `GODOT_BIN=/nonexistent node tools/tests/run_unit.mjs` | 20:33 (reproduced first; parity/scenarios messages fixed, eaf17694) |
| stop at the first script error (`dev/run.mjs`, `film.mjs`) | `node tools/dev/run.mjs res://dev/my_scene.tscn --timeout=150` | 23:07 |
| scenario and reel progress lines, logs written as they go | `node tools/reel/run_reels.mjs --out=build/reels --views=top` | 00:16 (19 chapter lines live, partial log on disk mid-run) |
| `tools/dev/wt_init.mjs` a fresh worktree that can run the game | `node tools/dev/wt_init.mjs ../gtai-wt/my-lane` | 21:44 (16 s) |
| `tools/codex/factory.mjs` Codex test factory with a review queue and a ledger | `node tools/codex/factory.mjs pick`, then `run --stems=<stem>` | 21:01 onward, 3 paired modules |
| `tools/merge/morning.mjs` one-command morning merge on a named integration worktree | `node tools/merge/morning.mjs --worktree=../gtai-wt/int-day --lanes=n11-tools,n11-hero,n11-combat --date=2026-11-10 --debt-reason="..."` | 20:45, 00:26, 00:45 (scratch branches; a timed-out step's whole tree killed, Godot included) |
| `export_checked.mjs` makes its output folder (hero request) | `node tools/export/export_checked.mjs` | 01:23 (fresh worktree, RTAI.exe 555 MB) |
| PoF night runner: `stop`, live `schedule`, `--reserve-min`, `status --siblings` | `node games/gtai/night/night.mjs stop --root <night> --lane hero` | 20:48, 00:22 (scratch roots) |

## Time saved

Unmeasured, except where a run timed it: quick.mjs 7.0 s against about 40 s for the hook's full lint
(one problem at a time there); wt_init 16 s against the hand copy builders journal; a dev scene's
parse error now stops at 1.5 s instead of the 150 s timeout (hero lost about 8 min to it on four forms).

## Codex ledger (`factory ledger --state=... --ledger=gtai-masters/n11/tools/codex-ledger.jsonl`, at 01:40)

15 tasks, 4,002 s of Codex, 13 machine pass, 2 machine fail, 7 accepted, 7 accepted after revision,
0 rejected, 43 lines changed by review, 0 refused by the meter. Review sessions measured $54.20 over
6 sessions; per task $3.87 is an ESTIMATE and an upper bound (a session also builds other things).
Codex as tester: every failing test it wrote tonight was a real defect, 78 of them, 0 thrown away.

**Paired measurement of the Claude saving** (both sides harness-measured, same goal and laws, same 15
mutants): quest_beat_validator alone 67,154 tokens / 674 s vs review 61,665 / 114 s + 436 s Codex
(8 % fewer tokens); city_spawn_plan alone 49,655 / 210 s vs review 48,638 / 69 s + 224 s Codex (2 %).
Reading: on small pure-rule modules a Claude review of Codex's tests costs about what writing them
costs, because the review must understand the module either way. A third, larger module
(sim_car_route, 136 lines) is in flight at 01:40: see JOURNAL.

## Calls for the owner

1. `CitySpawnPlan.next()` uneven turns (`city_spawn_plan.gd:41`, `_turn += 1`): found by Codex, the
   review and the control independently; likely fix `_turn += q + 1`.
2. Land `test_city_spawn_plan.gd` or not: machine-rejected at 60 % on 6 survivors that both writers left
   (initialisers `_init` reassigns, and a rioter branch never reached), review accepts it unchanged.
   Overriding a machine reject is a rule change, so it is yours.
3. QuestBeatValidator suspects: `str()` coercion, a `1e999` INF duration passes, an unknown line id is
   marked used, an invalid beat's encounter still counts at "".

## Proposals for the Director (not applied to the rules builders read)

- quick.mjs before commit and in the hook; wt_init after every `git worktree add`; film first in lane briefs.
- AGENTS.md says "two wall-clock budgets": there are three.
- Use PoF `n11-runner` before anyone runs `stop --lane --now` or an earlier `--until` (bugs fixed there).

## Merge notes

- PoF runner commits on `n11-runner`, not pushed: 32da7878, 410c035d, b4294c1b (and any later).
- This branch's step guard (b2fc4d7d, c4533f7d) changes how the morning merge runs every step.
- `film --victim` needs combat's dev hook (`gunplay_hook.gd`) to be useful; until then it refuses.
- Combat's `probe.sh` toggles `dev/frames/film_card.gd` in and out of their tree, which re-imports
  the class cache on every film (about 8 s each); it ends when the film probe lands on main.
