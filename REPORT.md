# n16 lane tools: REPORT (DRAFT, updated 17:50 in session 6; the 19:40 session finalises it)

Branch `n16-tools` from main `5843f5a28`. Memory: `JOURNAL.md`. Evidence: `gtai-masters/n16/tools/frames.json`
(15 entries) and `evidence/n16-tools/`.

## What works, with its proof

### 1. The kill reel (`tools/film/kill_reel.mjs`, README section "every signature death, one command")
One command films every signature death in the KillLab on the city block, for weapons x victim kinds x directions
(`--dirs=0,90,...,wall`) x zooms, same seed and tick, a contact sheet per weapon and zoom, clips, and before/after
(`--before=<sha> [--rev=<sha>] [--native=donor]`) from any lane's tree.
- v1 11:31 (afe581336); `all` reads the filmed tree's table; the victim is judged on the DRAWN card row (748aa7332).
- `--dirs=wall` / `--sig-wall` (Gloria's pin case, bbee28a9c); the kill shot stands Rivet 10 m west of the station
  dummies so every direction draws the guard.
- `--gore-check` (c6191736b): every death filmed with `--gore=reduced` must lie as one drawn card at kill+20.
  Proof s2gore: katana + rocket `whole: true`; the control without it is undrawn at kill+20 (FAIL), so it discriminates.
  s4, over BOTH kill lanes' whole tables (run from each lane's worktree on its committed tip): kills-new 8f7fe6e6e
  17/17 `whole: true` (evidence/n16-tools/reel_s4gore_new.md), kills-polish a56501ee5 12/12 (`--dirs=0`: that tree
  has no kill-lab turn; reel_s4gore_polish.md). Sheets looked at: gatling, katana, chainsaw, rocket lie whole.
- Beat readout: per film `hit-stop N frames` (measured from the probe rows' frame gaps; `off` when the film ran with
  the feel off), window still, settled, aftermath share and curve; per weapon the row's timings and the street clock
  (corpse_decay.json: bodies 7.2 s, stains 16 s; the KillMarks ring of 12 kills sooner).
- s6: the aftermath LIFETIME is measured (416cbe69d, 822d5bdc5): `--after` up to 1200 ticks without `--clips`, beats
  +150/+300/+600, a curve per film. Proof on kills-new 76ae91d45 (`--weapons=claw_shock,rocket_launcher --after=600`,
  PASS): claw +20 4.8 / +300 2.1 / +600 0.9 %: the thrown cop lies at +300 and is gone at +600; rocket gibs gone by
  +600, scorch and spray stay; `--after=1000` rocket 1.6 %: scorch and spray gone, the dropped rifle stays. The old data
  line ("until 12 later kills, no timer") was wrong on the street. `--feel=on`: freezes 6 (claw), 8 (rocket) frames.
  (evidence/n16-tools/kill-reel-aftermath-life-*.png, reel_s6feel.md, reel_s6long.md)
  41bb70e36: the curve leaves out where the victim stood at the trigger frame (his empty spot is not a mark), so
  `gone by +N` fires: claw `+600 0.0 %, gone by +600`, rocket `gone by +1000` (0.4 %); the mask drawn on the frames:
  evidence/n16-tools/kill-reel-stand-mask-claw-t60-vs-t727-32ppm.png.
- s3: `--quick` (32 px/m, dir 90), sheet cells labelled (weapon/film, offset, `KILL HS6`), `--clips --feel=on` cut
  from the game's movie so the hit-stop PLAYS (calibrated: movie index = probe frame), the all-weapon overview
  `reel_<ppm>.png` + `reel.md`, `--resheet` (no Godot), the death judged on screen (`--subject=kill`), a far victim
  gets the window, and every cell is anchored to the street by the probe's camera shift.
- s4: the reel SCOUTS the kill tick, then films only the beats + the hold run (~20 PNGs, not ~165; PNG writes were
  ~45 s of a ~65 s film) (7a16ac85d); a live-tree reel names its uncommitted project/ paths and any film whose tree
  moved mid-reel (469298728, 7c0e91fcd; kills-new FRICTION 15:15); a tree older than the kill-lab turn is told to
  film `--dirs=0` (613b488e0). Scout timing: 17 films in 12.7 min (s3: 12 films ~25 min). Decision tools/kill-reel-scout.
- s5: a film is timed by the stills it saves (120 s + 2.5 s a still, at least 300; b74d9d007) and film.json records
  `timeout_s` (3ca83cd2a): kills-new's `--before --clips` Gatling films died at the flat 300 s on t239 of ~245 while a
  gate ran (their polygon-error flood was one line a frame, not the cause). Proof: the same film at 590902959,
  `timeout_s: 540`, PASS in 46 s. `kill:claw_shock` (Rivet's charged claw, `PlayerShock.WEAPON`, which no weapon table
  lists) is a lab weapon and `all` films it (8784c592b). Proof on kills-new 9ac925431: PASS at 32 and 64, kill 127, row
  `claw_throw` (evidence/n16-tools/kill-reel-claw-shock-kills-new-9ac925431-64ppm.png).
- Full coverage proof (s3all, `--weapons=all --quick --feel=on`): all 12 signature weapons kill in the lab (11 PASS,
  the nuke then UNVERIFIABLE on Rivet off screen; after the subject + window fix s3nuke / s3anchor PASS).

### 2. c-2: `CAR_DEAD_END_TILES` 65 (7850111df)
Regenerated, NATIVE REBUILT 11:46-11:47 (debug + release). Parity bit for bit 1200 steps (planted fault caught at
629), final digest `94b2865f7f17d778` unchanged from n15 (no re-bless). Route tests 21/0. Hand-made map tier A: no
car dies (n15 at 1: car 0 died); tier B no deaths. Stills in frames.json (tier A after / n15 before).

### 3. `test_quest_blade` under `--select`
Nothing to fix on main: `run_unit.mjs --select=test_kill_lab_turn,test_quest_blade` 5/5. The n15 fix 5e41c66bc never
reached the n15-combat branch whose FRICTION reported it (not an ancestor of 4df42554a).

### 4. Merge-clash warning in `tools/gate/quick.mjs`
Done in n15 (6d77d2204); seen working all day (`merge-clash: no new code conflict with ...`; it caught kills-polish's
`topple_deg` vs kills-new's schema key).

### 5. Builders served
kills-new REQUEST 1 (`--subject=kill`), 2 (`--sig-wall`), 3 (the Gatling never spun up in the lab: kill_lab holds a
spun gun, 0b5c55fc7); kills-polish's step_guard flake (8cb956f7e); kills-new FRICTION 15:15 (a live-tree reel broke on a half-edited tree:
the reel now stamps the tree and names the film where it moved); s4 kills-new REQUEST (molotov row via KillFireSource,
a7369529f); s5 kills-new FRICTION 15:30 (Gatling film timeouts, b74d9d007 + 3ca83cd2a), kills-new REQUEST 16:28
(`kill:claw_shock`, 8784c592b), kills-polish FRICTION 14:20 (a commit's lint read an unstaged schema edit: reproduced, the
hook IS right when its index export works; it now retries a failed export once and the tree fallback names the unstaged
paths it reads, 826b4035a); s6 kills-polish FRICTION :361 (an art commit staging provenance or tools/art waited ~2 min
for the full lint: those paths are lint-neutral now, 106 s -> 3 s, ed4a13db0). Each with a SERVED line in JOURNAL.

### 6. Pre-commit hook (`tools/gate/precommit.mjs`)
826b4035a: a failed index export is retried once; the tree fallback ends `it reads your unstaged <paths>: a failure
there is not in the commit`. Proof: real git, TMP pointed at a missing dir, the line named
`project/data/tables/signature_kills.json`; with TMP intact the same setup linted a 5530-file export, 19/19.

### 7. Gate timing and partial reels (`tools/gate/run.mjs`, 09b23b523)
gate.json keeps `timing` (evidence and each reel view) and `reels`; the next gate prints the last one as an ETA;
`--reels=<views>` runs only those views, labelled `not the full reel gate`. (Both kill lanes' FRICTION: the gate holds
the lane's one Godot for 30-40 min.) Proof: the gate on 09b23b523 with `--reels=combo` wrote `"reels":["combo"]`,
`"timing":{"evidence_s":964,"reels":{"combo":301}}`, said `PASS reels (combo only: not the full reel gate)`, and
the next gate's ETA reads `took evidence 16.1 min + reels 5.0 min (combo 301 s)`. Codex n16t-break-gate-timing:
13 tests, 2 fixes (the last `--reels` form wins; decimal seconds).
s6 (c47f8bc2f, kills-new REQUEST 17:4x): the gate works from the CALLER's game tree: results, ETA, dirty check and the
snapshot's DLL donor. Before, `node ../n16-tools/tools/gate/run.mjs` from a lane wrote into n16-tools/build/gate AND
gave the snapshot the tools lane's c-2 DLLs (kills-new's 17:41 gate on b9dba1da8 ran them: sha1 b2dc0392 vs their
3faf6079). A gated commit whose native/ differs from that tree's HEAD now prints `gate: WARNING native/ ...`. Proof:
front half from a throwaway worktree at 76ae91d45, results under it, none in the kit; the warning for a differing
commit; both stopped before Godot.

### 8. Lint-neutral paths in the pre-commit scope (`tools/lint/scope.mjs`, ed4a13db0)
A project/ commit that also stages `steam/ai-provenance/**`, top-level `tools/art/*.py` or root `KILLS.md` /
`DEFECTS.md` keeps the scoped lint (no tool code reads them; a guard test fails if one starts: planted, caught).
Proof: `node tools/lint/lint.mjs --scope=<kill_lab.gd + .uid + provenance + gib_pieces.py + KILLS.md>` -> `scoped to
the commit (2 staged path(s), all under project/ + 3 lint-neutral ...)`, 18/18 in 3 s; the full lint it replaces 106 s.

## Findings for the kill lanes
- Measured on the street (s6): a body and its pieces are gone ~7 s after the kill, the scorch and spray ~16 s
  (corpse_decay.json), the dropped rifle stays past 16.7 s. A death's aftermath that should outlive that needs a
  corpse_decay change, not a signature row.
- A signature row's `hitstop_ticks` does NOT freeze the screen: SignatureKills.hold makes the pieces wait. The freeze
  is hit_feel.json's `kill_hitstop` (camera.json `kill`, 6) or the class's bigger stop (blast = `boss_hit` 8).
- Default reels have the feel OFF (locked camera); judge pacing on `--feel=on` reels and their clips.
- At 32 px/m the flamethrower and electro gun deaths read weakly (a small dark figure) in the s3all overview.
- Before caccc825d every film read the DESK MOUSE for Rivet's live aim: two films of one commit differed in Rivet's
  facing and pose (sim identical). Films are now pinned (0.00 % apart run to run); re-film any before/after whose
  difference is Rivet's aim or pose. (The `settled` +80/+150 and aftermath 5.8/3.2 % run-to-run spreads came from it.)

## Gates
s5: GATE PASS on 09b23b523 (`--reels=combo`, build/gate/09b23b52349b/gate.json): lint 19/19, unit 2645/0/2,
scenarios 55, parity bit for bit (planted fault at 629), look goldens 11/11 worst 0.00, release-compile 683/0, reels
combo exit 0. Its project/ tree equals caccc825d's, whose gate ran all three reel views.
FULL GATE WITH REELS PASS on caccc825d, the last project/ commit (s4, `gate exit 0`, build/gate/caccc825d4a8/gate.json):
lint, unit 2645/0/2, scenarios 55, parity bit for bit 1200 steps (planted fault at 629), look goldens 11/11 worst
0.00, release-compile 683/0, reels exit 0. Every later commit is tools/docs/evidence/JOURNAL. Before that: gate PASS on 0b5c55fc7 (lint 19/19, unit 2645/0/2, scenarios 55, parity bit for
bit, look goldens 11/11, release-compile 683/0, reels top/tilt70/combo OK). Every later commit is tools/docs/evidence
(lint 19/19 incl. tool-tests in each commit's hook).

## Codex ledger
6 tasks, all gpt-5.6-sol, 1 round each, discarded after landing: n16t-break-film-root (119 s, 10 tests, accepted
after revision: the cwd-below-a-tree promise was a weakness, fixed), n16t-break-reel-movie (188 s, 10 tests, 3 kept
red, all 3 accepted and fixed in code), n16t-break-live-tree (196 s, 8 tests, 1 kept red: CRLF porcelain, accepted and
fixed; review found a second real defect the tests missed, C-quoted non-ASCII paths, fixed with a first-author test),
n16t-break-reel-scout (743 s, 9 tests, 1 kept red: rejected as a defect, tick 60 is the lab's trigger column by design
and my task text was looser than the design; the test exempts it, and 7f9e92c81 makes a kill at or before tick 60
unverifiable in code; accepted after revision), n16t-break-gate-timing (485 s, 13 tests, 2 kept red, both accepted and
fixed in run.mjs), n16t-break-aftermath (313 s, 13 tests, 2 kept red, both accepted and fixed: a stain lifetime alone
was dropped, `tools/art/.py` read as neutral; review flipped one expectation that pinned the weak side; accepted after
revision). Total 6 tasks, 1 round each.

## Calls for the owner
- The kill reel's default is feel OFF (stable sheets, clean A/B); pacing is judged with `--feel=on`. Alternative:
  feel on by default. (decisions: tools/kill-reel-feel)
- The kill shot stands Rivet 10 m west of his city start (station dummies took every full rig at the start).
- The reel judges the death, not Rivet, on screen; a far victim (the nuke) gets the window.
- A film never reads the desk mouse (FilmProbe pins the cursor; decisions tools/film-cursor). Dev only.
- Gloria's pin counts parked cars as walls (the lab's nearest "wall" is a car): kill lanes' call, raised here.

## Merge notes
Merge tools FIRST: native changed (c-2, CAR_DEAD_END_TILES 65; view lanes keep their DLLs). The kill lanes cherry-
picked the game side of afe581336, bbee28a9c and 0b5c55fc7 with identical content: expect clean merges there.

## Next steps
- Kill lanes: drop the `-- --sig-gun=claw_shock` workaround (`--weapons=claw_shock` films it on its own row); use
  `gate --reels=<view>` mid-session and plain `--reels` on the final commit; read the ETA line before starting a gate.
- The aftermath curve leaves out the victim's standing rect (41bb70e36), so a mark left exactly where he stood (a pool
  under a man killed in place, a gun dropped there) is not counted: a victim-free twin film would close that.
- The KillMarks ring (12 later kills recycle the marks) is still not filmed: it needs a lab with many kills.
- A kill earlier than the lab's trigger tick (60) would make the trigger column a post-kill frame (no lab kill does:
  63+); if a lab ever kills sooner, pickBeats should take kill-8 instead of 60.
- The pre-commit export failure that made kills-polish's 14:20 commit lint the tree was not reproduced (only the
  fallback is now loud and retried): if it recurs, the line now names the cause (`no staged snapshot (<error>)`).
- (the 19:40 session completes this list)
