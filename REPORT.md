# n11 tools lane: REPORT (DRAFT, written 01:40 in iteration 25; the report session finalizes it)

Branch `n11-tools`, cut from main `812a0b06`. Every tool below has a section in `tools/README.md`
with one example and what it refuses. Every evidence tool reports pass, fail or **unverifiable**
(it ran but could not observe the thing; never a pass). Proofs are real runs, named in `JOURNAL.md`.

## Tools built, one example each

| Tool | Example | Proven on a real run (JOURNAL) |
|---|---|---|
| `tools/film/film.mjs` named shots, fixed seed/step, locked camera, probe numbers | `node tools/film/film.mjs weapon:pistol --out=build/film/pistol --on=fire:1+4,kill:1+3` | 20:15 (arena PASS 11 s; a street shot walking out of frame is now unverifiable) |
| `--victim=<kind>` on the weapon shot (combat request) | `node tools/film/film.mjs weapon:machine_pistol --victim=cop/head_swat --out=build/film/swat --on=kill:1+30` | 01:32 refusals; combat's hook 1183a323 landed 02:00 and combat filmed `thug`, `cop/head_helmet`, `cop/head_swat`, `ped/head_hood`: all PASS (their JOURNAL line 270) |
| `tools/film/compare.mjs` before/after at the same tick, two commits or worktrees | `node tools/film/compare.mjs chapter:pistol --a=main --b=n11-combat --at=240,330 --subject=dead --out=build/film/cmp` | 20:15 (PASS on a real corpse change; same commit both sides -> UNVERIFIABLE, 0 px differ) |
| `tools/film/sheet.mjs` labelled contact sheet | `node tools/film/sheet.mjs build/film/pistol --out=build/film/pistol/sheet.png --cols=4` | iteration 7-8 |
| `tools/film/numbers.mjs` per-tick draw size, feet, rest, facing vs aim | `node tools/film/numbers.mjs build/film/arena --ticks=60-200 --subject=rivet` | iteration 7-8 |
| film runs `--import` when an asset really changed (MD5, not date) | (automatic) | 22:15 (found that Godot's own scan trusted the date and drew old pixels) |
| `tools/gate/quick.mjs` the lint rules builders trip, changed files only | `node tools/gate/quick.mjs` | 20:36 (planted file: CRLF, gdformat, print, float(Variant) in 7.0 s) |
| `tools/gate/precommit.mjs` the hook skips lint when only inert paths are staged | (automatic, from `.githooks/pre-commit`) | 01:44 (JOURNAL-only commit 0.6 s; the full-lint commit before it 51 s) |
| the hook lints the STAGED SNAPSHOT when the tree differs (`tools/gate/staged_tree.mjs`) | (automatic) | 02:14 (an untracked over-long .gd: lint on the tree 3 of 16 FAIL; the commit through the hook linted the index, 16/16, 64 s; nothing left in Temp) |
| `tools/godot/check.mjs`: autoload names are not false FAILs (c01afd2a); a cascade with no cause seen is not a pass (ec83154e) | `node tools/godot/check.mjs res://features/combat/react/human_react.gd` | 20:53 (`human_react.gd` FAIL -> ok, a planted float(Variant) still FAILs); 05:11 (planted missing-script .tscn, extends- and preload-broken deps all FAIL with their cause; `human_react.gd` still ok) |
| skip-worktree entries in the staged snapshot (4d6d8232) | (automatic) | 05:04 (combat's probe shape: tree `quick.mjs` FAIL 4 issues, commit through the hook 16/16) |
| `tools/gate/run.mjs` the gates on a snapshot of the commit | `node tools/gate/run.mjs` | 20:46 (8m35, tree edited throughout, no log landed in it) |
| stale-count honesty with Godot absent | `GODOT_BIN=/nonexistent node tools/tests/run_unit.mjs` | 20:33 (reproduced first; parity/scenarios messages fixed, eaf17694) |
| stop at the first script error (`dev/run.mjs`, `film.mjs`) | `node tools/dev/run.mjs res://dev/my_scene.tscn --timeout=150` | 23:07 |
| scenario and reel progress lines, logs written as they go | `node tools/reel/run_reels.mjs --out=build/reels --views=top` | 00:16 (19 chapter lines live, partial log on disk mid-run) |
| `tools/dev/wt_init.mjs` a fresh worktree that can run the game | `node tools/dev/wt_init.mjs ../gtai-wt/my-lane` | 21:44 (16 s) |
| `tools/codex/factory.mjs` Codex test factory with a review queue and a ledger | `node tools/codex/factory.mjs pick`, then `run --stems=<stem>` | 21:01 onward, 3 paired modules |
| `tools/merge/morning.mjs` one-command morning merge on a named integration worktree | `node tools/merge/morning.mjs --worktree=../gtai-wt/int-day --lanes=n11-tools,n11-hero,n11-combat --date=2026-11-10 --debt-reason="..."` | 20:45, 00:26, 00:45 (scratch branches; a timed-out step's whole tree killed, Godot included); 02:21 REAL bake (256 chunks, 89 s) and export (555 MB exe, 14 s) on a scratch worktree, and a tampered chunk STOPPED the export with the right advice. 05:27 the bake step checks the chunks itself (a tampered copy STOPS at the bake, naming c_03_07.bin). Never run for real: native, gates, reels |
| `export_checked.mjs` makes its output folder (hero request); ok only when this run wrote the exe (c23c7d84) | `node tools/export/export_checked.mjs` | 01:23 (fresh worktree, RTAI.exe 555 MB); 05:22 (real export accepted, 553,948,392 bytes; the same file judged against a later start says `did not rewrite`) |
| PoF night runner: `stop`, live `schedule`, `--reserve-min`, `status --siblings` | `node games/gtai/night/night.mjs stop --root <night> --lane hero` | 20:48, 00:22 (scratch roots) |

## Builders' requests and FRICTION served tonight (lane JOURNAL line -> commit)

- hero 70 (bounce numbers without Python): probe `head_y` + `numbers.mjs` ranges; per-leg rows stay in hero's `stride_film`.
- hero 95 (stop a dev run at the first SCRIPT ERROR): 8f6f079f. hero 143 (`ASSETS-REPLIES.md` inert): b083b075.
  hero 170 (README: an art change's before film from the parent commit): 674addc9. hero 219 (export output folder): c26ab875.
- hero and combat (`check.mjs` false FAILs on autoload names): c01afd2a.
- combat iteration 2 (film on fire/kill events): 21:17. combat 116 (scenario progress lines): f22446ed, 4ab7e28c.
  combat 132 (reel progress, partial log): 09b30ff8. combat 225 (`--victim=<kind>`): c548fc94 + their 1183a323, PASS in their tree.
- combat 117 (probe by hand, then the ratchet fails the commit): served by the staged-snapshot hook, working
  with their skip-worktree probe only from 4d6d8232; reaches their tree at the merge.
- Not served: combat 226 (about 8 s re-import per film because `probe.sh` adds and removes `film_card.gd`):
  ends when the film probe is on main, i.e. at this merge.

## Time saved

Unmeasured, except where a run timed it: a journal or report commit 0.6 s instead of 51 s idle (up to 8 min
contended, per past FRICTION lines; this lane alone made about 40 such commits tonight); quick.mjs 7.0 s against about 40 s for the hook's full lint
(one problem at a time there); wt_init 16 s against the hand copy builders journal; a dev scene's
parse error now stops at 1.5 s instead of the 150 s timeout (hero lost about 8 min to it on four forms).

## Codex ledger (`factory ledger --state=C:/Users/kazda/kiro/gtai-n11t/logs/tools/state.json --ledger=C:/Users/kazda/kiro/gtai-masters/n11/tools/codex-ledger.jsonl`; RE-RUN at report time)

At 05:19 (re-run with `--state`): 19 tasks, 5,089 s of Codex, 17 machine pass, 2 machine fail, 8 accepted,
10 accepted after revision, 0 rejected, 88 lines changed by review, 0 refused by the meter. Dollars: $68.10
measured over the 8 review sessions to iteration 26 (per task $4.01, an ESTIMATE and an upper bound: a session
also builds other things); with iteration 39 counted the total prints null until its cost is in state.json
(one unknown session makes it unknown, by design). The report session re-runs it.
Codex as tester (12 tasks, counted from the ledger's per-task lines): 108 failing tests, 95 real defects fixed
with the tests kept, 13 thrown away with their reason: 9 in `n11t-break-tools` (a table that assumed plain
porcelain, obsolete once quick read `--porcelain -z`, which never quotes a path; JOURNAL 20:5x), 1 in
`n11t-break-staged` (it asked the staged export to ignore the commit's eol attributes, JOURNAL 02:24), 3 in
`n11t-break-check` (where a detached `at:` context line goes; such a line never decides the verdict, 05:19).
The journal's running count ("82 real, 0 thrown away" at 01:52) had dropped the first task's 9; corrected 05:07.

**Paired measurement of the Claude saving** (both sides harness-measured, same goal and laws, same 15
mutants; the Director's own check is outside both sides):

| Module | Claude alone | Claude reviewing Codex | Review changed | Mutation |
|---|---|---|---|---|
| quest_beat_validator | 67,154 tok / 674 s | 61,665 tok / 114 s + 436 s Codex | 12 lines | 11/11 both |
| city_spawn_plan (49 lines) | 49,655 tok / 210 s | 48,638 tok / 69 s + 224 s Codex | 0 | 9/15 both |
| sim_car_route (136 lines) | 99,000 tok / 524 s | 69,496 tok / 216 s + 617 s Codex | 24 lines (control: 10 by the same standard) | 12/15 both (80 %) |

Reading: on the two small modules the review cost about what writing cost (2-8 % fewer tokens). On the
module three times their size, reviewing Codex's tests took 30 % fewer Claude tokens than writing them
(29,504 fewer), and the control pinned the same private literals (2.5 m, 13 m) that the review removed
from Codex's file. Three modules is still not a rate, and wall time with Codex is longer, not shorter.

## Incident (mine, repaired)

At 01:39 a tool test of mine ran inside the pre-commit hook, where git sets `GIT_DIR`, and its
`git -C <tmp>` acted on the real repo: a stray commit on `n11-tools`, `user.email=t@t` and
`core.bare=true` in the shared `gtai/.git/config` (the main checkout said `must be run in a work tree`
until 01:45). Repaired by hand within minutes; no lane commit got the wrong identity. Fixed for good in
607f4171: lint's tool tests run with every `GIT_*` variable stripped (reproduced on a scratch repo).

## Calls for the owner

1. `CitySpawnPlan.next()` uneven turns (`city_spawn_plan.gd:41`, `_turn += 1`): found by Codex, the
   review and the control independently; likely fix `_turn += q + 1`.
2. Land `test_city_spawn_plan.gd` or not: machine-rejected at 60 % on 6 survivors that both writers left
   (initialisers `_init` reassigns, and a rioter branch never reached), review accepts it unchanged.
   Overriding a machine reject is a rule change, so it is yours.
3. QuestBeatValidator suspects: `str()` coercion, a `1e999` INF duration passes, an unknown line id is
   marked used, an invalid beat's encounter still counts at "".
4. CitySimCarRoute suspects (the parity reference sim: a change here moves the native sim too, NAT-06),
   found by the review and the control, read again on main at 05:08: `sim_car_route.gd:37` U-turns before
   any tile that is not road (kerb, building, plaza) where its comment says "city edge or unloaded";
   `:90` and `:118` accept `T_ROAD_H` and `T_ROAD_V` in any direction, so road orientation is ignored;
   the tuned numbers 18 m (`:27`), 2.5 m (`:53`), 13 m (`:62`) and 16 m (`:89`) are inline literals tests
   cannot read, so the landed test states relations instead of pinning them.

## Proposals for the Director (not applied to the rules builders read)

- quick.mjs before commit and in the hook; wt_init after every `git worktree add`; film first in lane briefs.
- AGENTS.md says "two wall-clock budgets": there are three.
- Use PoF `n11-runner` before anyone runs `stop --lane --now` or an earlier `--until` (bugs fixed there).

## Merge notes

- PoF runner commits on `n11-runner`, not pushed: 32da7878, 410c035d, b4294c1b (and any later).
- This branch's step guard (b2fc4d7d, c4533f7d) changes how the morning merge runs every step.
- `film --victim` works with combat's hook (1183a323 on n11-combat): merge both.
- The staged-snapshot hook (d13b9849, 1e5fa267, 3ee0c085, 4d6d8232) changes what every commit's lint reads. It also ends combat's FRICTION 117: their `probe.sh` marks `arena_game.gd` `--skip-worktree` and copies untracked probe files in; the hook lints the index, so a commit no longer needs `probe.sh off` first. That held only from 4d6d8232 (05:02): before it, `checkout-index` refused the skip-worktree entry and the hook failed. Proven 05:04 on a scratch worktree with the probe's shape (skip-worktree `arena_game.gd` + an untracked .gd, both over the line cap): `quick.mjs` on the tree FAIL 4 issues, the commit through the hook `lint: all 16 checks pass`, 56 s.
- Combat's `probe.sh` toggles `dev/frames/film_card.gd` in and out of their tree, which re-imports
  the class cache on every film (about 8 s each); it ends when the film probe lands on main.
