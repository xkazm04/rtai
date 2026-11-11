# Builder tools

Tools a builder reaches for without being told. Each section has one example you can paste, and says
what the tool refuses. Every evidence tool here reports three outcomes, not two: **pass**, **fail**
and **unverifiable**. Unverifiable means it ran but could not observe the thing, and it is never a pass.

Run these from the root of your worktree. Exit codes are shared: `0` pass, `1` fail, `2` usage
(nothing launched), `3` unverifiable.

| When you want to | Run |
|---|---|
| film or still a named shot (arena, street, quest 1, a chapter, a weapon) | `node tools/film/film.mjs <shot>` |
| show before and after at the same tick | `node tools/film/compare.mjs <shot> --a=<commit> --b=<commit>` |
| the old bytes of a file at a commit (LFS assets smudged, not the pointer `git show` writes) | `node tools/film/blob.mjs <rev>:<path> [--out=<file>]` |
| one sheet of a film's stills, labelled | `node tools/film/sheet.mjs <film dir> --out=<file.png>` |
| read head, feet, facing or body size per tick | `node tools/film/numbers.mjs <film dir>` |
| catch the lint you keep tripping, before the commit | `node tools/gate/quick.mjs` |
| commit a journal without waiting for lint | (automatic: the hook skips lint when only inert paths are staged) |
| check one script or scene parses, in seconds | `node tools/godot/check.mjs <res://path>` |
| run every gate while you keep editing | `node tools/gate/run.mjs` |
| run a dev scene with its flags checked | `node tools/dev/run.mjs <entry>` |
| make a new worktree able to run the game | `node tools/dev/wt_init.mjs <worktree>` |
| have Codex write tests for an untested module | `node tools/codex/factory.mjs pick`, then `run --stems=<stem>` |
| do the morning merge | `node tools/merge/morning.mjs --worktree=<integration> --lanes=<a,b> --date=<yyyy-mm-dd>` |
| see what the morning merge will meet (no worktree, no ref written; does my change clash with a lane?) | `node tools/merge/preview.mjs --lanes=<a,b,c> [--base=main]` |

## tools/film/film.mjs: one film or still of the real game

```
export APPDATA=<your lane's appdata>
node tools/film/film.mjs weapon:gatling --out=build/film/gatling --stills=300,500
```

| Shot | What it runs |
|---|---|
| `arena` | the arena fight (showcase reel, pistol) |
| `city` | a city street fight with a crowd |
| `chapter:<id>` | one director chapter (`chapter:pistol`, `chapter:katana`, ...) |
| `weapon:<id>` | one lone kill with a table weapon (`weapon:gatling`) |
| `quest1` | quest 1 through its scripted pad (needs `--stills=<even ticks>`) |

It always passes the scene, the bot, the loadout, a fixed seed and a fixed 60 Hz step. You get
`t<tick>.png` (lossless, saved after that tick's own draw), `probe.json` (numbers for every tick and
every fighter), `film.json` and `film.log`. An mp4 only comes when you give `--movie` or ask for no
stills, because `--write-movie` is slow (about 1.5 fps with other lanes running).

**Queue films while you edit: `--rev=<commit>`.** A film reads the tree as it stands when Godot loads
each script, so an edit during a queue breaks the films after it (n15 combat: 4 films died with SCRIPT
ERROR). `--rev=HEAD` films that commit in compare's snapshot (`%TEMP%/gtai-film-<sha>`, probe injected,
kept for the next film of it; `--native=donor` as in compare). A live-tree film with uncommitted
`project/` paths prints them before it runs. Example (a parse error planted in the live tree):
`film.mjs arena --rev=HEAD --stills=300` PASS, `film.mjs arena --stills=300` FAIL with the warning.

The camera: `--lock=auto` (the default) holds it at Rivet's spawn, except on the street shots, where
it follows him and freezes at your first still. `--lock=at:<tick>`, `--lock=<x,y>` and `--lock=off`
are there when you need them. A locked camera also turns the hit-feel shake off, so a frame
difference means the world changed.

`probe.json` per tick and fighter: `pos` (m), `screen` (px), `on_screen`, `draw` (opaque size in px,
`-1` means no card), `feet_y` (the screen row of the lowest opaque pixel), `facing_off` (degrees
between the drawn facing and the sim's aim; `999` means no rig), `alive`, `hp`.

Frames by range or by what happened, in one run (no guessing a tick and relaunching):

```
node tools/film/film.mjs weapon:pistol --out=build/film/pistol --stills=330-340
node tools/film/film.mjs weapon:pistol --out=build/film/pistol --on=fire:1+4,kill:1+3
```

`fire:<n>[+<k>]` saves the frame of Rivet's nth firing tick (1 is the first) and the k frames after
it; `kill:<n>[+<k>]` does the same for the nth hostile death. Every film also prints and records
`fire at 333; kill at 337` (`events` in `probe.json`), so one run says when things happened. Crowd
deaths are not kills here: only `hostiles`. On the street shots the lock becomes `--lock=trigger`: it
freezes on the first frame `--on` saves, and that first frame is still following (a few px), because
the view has already read it. `--lock=at:<tick>` has no such frame.

A film whose assets changed since the last import runs `--import` first and says which: Godot does
not re-import on its own, so a film after a PNG swap drew the old pixels and looked like a result.
The check is the source's MD5 against the one recorded at import, not its date: a Windows or `cp -p`
copy keeps an old date, and Godot's own `--import` trusts the date and skips it. So film gives every
stale source a new date before importing, checks again afterwards, and calls the film
**unverifiable** if anything still does not match. The first film in a tree hashes every asset once
(it says so; under a minute), later ones only what changed.

A chosen victim on the weapon shot (combat n11 REQUEST line 225), so a thug's or a SWAT's fall is
filmed rather than judged from a packed sheet:

```
node tools/film/film.mjs weapon:machine_pistol --victim=cop/head_swat --out=build/film/swat --on=kill:1+30
```

The kinds are the card rows of the filmed tree's `StreetDeadPlan.CLASS_OF` (did-you-mean on a typo).
The kind is the game's choice, so it needs a dev-only hook in `gunplay_hook.gd` `lone()` that reads
`--victim` and logs `gunplay: lone victim <kind>`. Until a tree has it, film refuses and says so;
with it, a run that never logs the line, or logs another kind, is **unverifiable**, never a pass.

The director's run-by-name extras are chapters too (combat n15 REQUEST): `chapter:electro_baton_left`,
`chapter:katana_cam` and the rest of `ReelChapters.extras()`, read from the loop that builds them.
Camera feel (combat n15 REQUEST): `--feel=auto` (default: off whenever the camera is locked, since a
shake moves the frame), `--feel=on` or `--feel=off` outright; `compare.mjs` passes it to both sides.
Give it before the `--`: the game reads the FIRST `--feel=`, so a trailing one is refused.

```
node tools/film/film.mjs chapter:electro_baton_left --feel=on --stills=60-70 --out=build/film/baton
```

To compare the frame something happened on, learn the tick once with `--on`, then compare it:
`node tools/film/compare.mjs ... --at=333`. The tick is the same on both sides as long as the change
under test is visual, because the sim is deterministic; if the shot moved, the verdict's numbers show
a different subject position.

**Refuses, launching nothing:** an unknown shot; a weapon, chapter or view id that tree does not have
(with a did-you-mean); a game flag no script in that tree reads; stills past the end.
**Unverifiable:** no fresh `probe.json`, a still that was not saved, a drawn size other than the one
asked for, a subject (`--subject=rivet|hostile|dead|id:<n>`) off screen at a still, or an `--on` event
that never happened (`--on fire:3 never happened: 1 fire event(s) in 900 ticks`).
Quest 1 has no numbers and no locked camera; a still that exists is all it can claim.

## tools/film/sheet.mjs: one labelled contact sheet of a film's stills

```
node tools/film/sheet.mjs build/film/pistol --out=build/film/pistol/sheet.png --crop=540,290,260,170 --cols=4
```

Stops the hand-built PIL frame sheet: every cell has its tick written above it (the frame itself is
never covered) and the same input always makes the same file. `--ticks=<a,b-c>` picks frames,
`--shrink=<n>` keeps every nth pixel. Written by Codex (`n11t-exec-sheet`) against a contract and
hidden tests.

**Refuses (exit 2):** an `--out` that is not a `.png` or that names one of the film's own frames (it
deletes `--out` first), a bad flag, a crop outside the frame, a sheet over 16384 px a side.
**Unverifiable (exit 3), and it still writes what it could read:** no frames, a requested tick with
no file, a damaged PNG, frames of different sizes (nothing is written then), every frame identical
("nothing moved"), or a `film.json` that is not a pass.

## tools/film/numbers.mjs: read a film's numbers without pasting Python

```
node tools/film/numbers.mjs build/film/arena --ticks=60-200 --subject=rivet
```

Prints min, max and range of `feet_y`, `head_y`, `draw_h`, `draw_w`, `screen_x`, `screen_y` and
`facing_off` over the window (`--json` for the same numbers). `-1` (no card that tick) and `999` (no
rig) are excluded and counted, never measured. **Unverifiable (exit 3):** no readable `probe.json`,
no ticks in that window, no such subject, or no card drawn at all.

## tools/film/compare.mjs: before/after at the same tick

```
node tools/film/compare.mjs chapter:pistol --a=main --b=n11-combat --at=240,330 --clip=200-340 --subject=dead --out=build/film/cmp
```

`--a` and `--b` are a commit or a worktree path. A commit gets a throwaway checkout in the temp dir
(your tree is not touched and you can keep editing while it films), and when the commit is older than
this kit the probe is injected there. You get `compare-t<tick>.png` with a label on each side, a side
by side clip with `--clip`, and `comparison.json`.

**Unverifiable:** the two sides are the same picture (under 0.005 % of pixels differ), or the subject
is missing or off screen on either side. The composite is still written, with UNVERIFIABLE on it.
A note, not a verdict: if the subject has moved more than 5 cm between sides, the timelines differ.
**Refuses:** a side that is neither a worktree nor a commit git knows; a worktree with no probe
(it says to film a commit instead).
A commit whose `native/` differs from this tree's HEAD (n15): its checkout would run THIS tree's DLLs,
so it would not be that commit's sim. Film a worktree at that commit with its own DLLs as the side, or
pass `--native=donor` when the change under test is view-only.

**A before of an art change:** commit the new sheet, then compare that commit with its parent
(`--a=HEAD~1 --b=HEAD`). Do not move the sheet aside by hand: its `.import` stays, `ResourceLoader`
still finds the cached texture, and the "before" is the after (hero n11, `JOURNAL.md` line 170). If you
did, compare says UNVERIFIABLE (the same picture) rather than letting it pass as a before.

**Not committed yet:** `--a=HEAD --b=.` films HEAD in a throwaway checkout (git's LFS filter gives the
real PNGs there) against your tree as it stands, re-importing what you changed. Never write
`git show HEAD:<png>` into your tree: that is the LFS pointer, and the broken import outlives it (combat n11,
line 201). An UNVERIFIABLE "identical" here often means the view does not draw the file you edited:
city props are drawn from `features/city/art/view/<p55|p70>/prop_*.png` strips, not `art/props/*.png`.

**Disk:** each commit side's temp checkout carries a copied import cache (about 1.7 GB). It is kept so
the next compare of that commit starts at once, and the last lines say where it is; `--clean` removes
it after the run. Do not `--clean` a commit another lane may be comparing right now (same path).

## tools/gate/precommit.mjs: the hook skips lint for a journal-only commit

Nothing to run: `.githooks/pre-commit` calls it. A commit that stages only inert paths (`docs/**`,
`evidence/**`, root `JOURNAL.md`, `REPORT.md`, `ASSETS-REPLIES.md`, the set in
`tools/evidence/scope.mjs`) prints `pre-commit: 1 staged path(s), all inert ...: lint skipped` and
lands in under a second (measured 0.6 s, against 51 s for a full-lint commit on an idle machine and up
to 8 min contended). **Never skips** a commit with any other path, root `AGENTS.md` included, or one
where git cannot list what is staged. Lint's tool tests run with every `GIT_*` variable stripped:
inside a hook git points `GIT_DIR` at your repo, and a test's `git -C <tmp>` once committed into it.

**It lints the commit, not your tree** (`tools/gate/staged_tree.mjs`). When a path lint could read has
an unstaged edit, or an untracked file sits in the tree, the hook writes the index out to
`%TEMP%/gtai-precommit-*` (text files only, about 2 s) and lints that, then removes it:
`pre-commit: 2 path(s) in your tree differ from what you commit (project/x.gd, project/y.gd): linting
the staged snapshot (5064 files) in ...`. So a half-edited file you did not stage no longer blocks
the commit, and a broken staged file no longer passes because its fixed copy is unstaged. A clean tree
lints in place as before. It follows `GIT_INDEX_FILE`, so `git commit -a` and `git commit <paths>`
lint what they commit; an entry marked `--assume-unchanged` or `--skip-worktree` counts as differing,
because git does not compare it, and is exported with its index bytes (so a film probe patched in under
`--skip-worktree`, as combat's `probe.sh on` does, stays out of what lint reads). The export is a checkout of the index, so the commit's
`.gitattributes` apply (LF here). **Refuses** to pretend: if git cannot list the drift or the export fails, it
lints the working tree and says `linting the WORKING TREE, which is not exactly what you commit`. It
removes only a `gtai-precommit-*` dir directly in the temp dir.

**A commit wholly under `project/` lints its own `.gd` files** (n15; `tools/lint/scope.mjs`, `lint.mjs
--scope=<file>`). The hook hands lint the staged list; when every non-inert staged path is under
`project/`, gdformat and gdlint run over the staged `.gd` only (both are per-file: an unstaged file
cannot change their verdict on it), and the Node tool tests run only when a staged path is a file a tool
test reads from the real tree: each `join(ROOT, '<path>')` literal in a lint-run test, and anything under
`project/dev/`, `project/data/` or `project/project.godot` (what `tools/lint/fs_trace.mjs` saw film,
native_side and factory tests read through tool code; re-run it when a tool test changes:
`TRACE_ROOT=$PWD TRACE_OUT=<file> node --import ./tools/lint/fs_trace.mjs --test "tools/film/*.test.mjs" ...`). Every
whole-tree check still runs in full. Measured: `lint: all 15 checks pass over 1 staged of 1428 GDScript
files` in 3.6 s, against 88 s for the full lint on the same tree. Any staged path outside `project/`
(`tools/`, `gdlintrc`, `gdformatrc`, `versions.toml`, `native/`, `AGENTS.md`) gives the full lint, and
every gate (`tools/gate/run.mjs`, `tools/evidence/run.mjs`) always lints everything. An empty commit
skips lint only when git says the index tree is the HEAD tree (`git write-tree` = `HEAD^{tree}`); an
empty path list alone still runs lint.

**It warns when the commit makes a NEW conflict with a sibling lane** (n15; `tools/merge/clash.mjs`).
Every commit, inert ones too (`docs/decisions.md` stops the morning merge as well), turns the staged
index into a dangling commit on HEAD and merges each sibling lane with HEAD and with it (`git
merge-tree --write-tree`, about 0.4 s for two lanes). A conflict on a file `morning.mjs` cannot
resolve (anything but the root JOURNAL/REPORT and the debt baseline) that only the commit has is named:

```
merge-clash: WARNING this commit makes project/features/characters/cast_flags.gd conflict with n15-combat (git merge-tree; morning.mjs would stop on it). Move your lines off theirs, or say so in JOURNAL
merge-clash: no new code conflict with n15-combat, n15-hero (2 known, unchanged)
```

It never blocks (the other lane's lines are not yours to refuse). Siblings are the branches checked out
in this repo's worktrees that share your branch's prefix up to its first `-` (`n15-tools` ->
`n15-hero`, `n15-combat`); `GTAI_MERGE_LANES=<a,b>` names them, `GTAI_MERGE_LANES=off` skips the
check. It writes git objects only: no ref, index or worktree. By hand: `node tools/merge/clash.mjs`.

## tools/gate/quick.mjs: the lint rules you keep tripping, on your changed files, before the commit

```
node tools/gate/quick.mjs          # every changed, staged or untracked .gd
node tools/gate/quick.mjs --fix    # gdformat and strip CRLF first, then check
```

CRLF (gdformat on Windows and Python text-mode writes), gdformat, line length and the other gdlint
rules, the 40-line function and 300-line file caps, banned APIs, and the engine's own parse check,
which is the only one that sees a warning-as-error such as `float(Variant)`. A file crossing 200
lines fails here because the debt ratchet stops the commit for it. Seconds, against about 40 s for
the full lint in the commit hook, and it shows every problem at once. `--no-godot` skips the parse
check, and `--files=<a,b>` names the files yourself.

**Refuses:** a file that does not exist, an unknown flag.
**Unverifiable (exit 3):** gdformat, gdlint or Godot could not run. A checker that failed without
naming a file counts as not run, so a missing tool can never read as "ok".

## tools/godot/check.mjs: does this script or scene parse, in about 3 s

```
node tools/godot/check.mjs res://features/combat/react/human_react.gd project/dev/my_scene.tscn
```

A `.gd` gets Godot's `--check-only`; a `.tscn`/`.tres` is `load()`ed by a throwaway script in the OS
temp dir. Warnings count as errors, as in the game. `--check-only` does not register autoloads, so
`Identifier not found: Log` (and the "Failed to compile depended scripts" cascade it causes in the
same run) is not reported. `quick.mjs` calls this check.

**Refuses (exit 2):** a path outside `project/`, a missing file, no Godot.
**Unverifiable (exit 3):** Godot printed only "Failed to compile depended scripts" cascades and no
cause. That is neither a pass nor a FAIL: the run says so, shows up to 6 other lines Godot printed,
and asks you to check the dependencies one by one or run the unit tests that load the file (hero n11,
an unchanged file the tests load fine). A real FAIL in the same run still exits 1.
**Never a pass:** that cascade; a run killed at its 60 s budget.

## tools/gate/run.mjs: the gates on a snapshot, so you can keep editing

```
export APPDATA=<your lane's appdata>
node tools/gate/run.mjs --rev=HEAD
```

A detached checkout of that commit goes in the temp dir with the DLLs, the baked city and the import
cache copied in, and that commit's own `tools/evidence/run.mjs` runs there. You can keep editing and
no log lands in your tree. Results are in `build/gate/<sha>/` (`gate.json` plus one file per kind).
`--reels` adds the reel gate, `--bench` the bench, `--no-parity` and `--no-selftest` skip those;
`--clean` removes the snapshot afterwards.

**Refuses:** a revision git does not know, an unknown flag.
**Unverifiable:** a kind wrote no result, or wrote a result naming another commit.
A wall-clock scenario can go red because other lanes are filming; read the failing line first.

## tools/codex/factory.mjs: Codex writes tests, a machine grades them, Claude decides

```
node tools/codex/factory.mjs pick                                 # what may go, and why
node tools/codex/factory.mjs pick --explain=features/combat/fighter.gd
node tools/codex/factory.mjs run --stems=oil_leak --ledger=<file>
node tools/codex/factory.mjs queue --ledger=<file>                # what is waiting for review
node tools/codex/factory.mjs review n11t-fac-oil-leak --verdict=accepted-after-revision --changed=4 --iteration=7 --ledger=<file>
node tools/codex/factory.mjs ledger --state=<lane logs/state.json> --ledger=<file>
```

It picks pure RefCounted rule modules with no test yet, writes the task with the laws that forbid
pinning accidental behaviour, dispatches through PoF's `scripts/codex/dispatch.ts`, then grades:
tests green on the real code, inside the scope, lint clean, mutation score. It allows one repair round
and leaves a review queue. **It never lands a file:** the score can only reject, and at or above the bar it
means "Claude should read this", nothing more. After your review, copy the test from the task's worktree
yourself and `discard` the task.

A reject under the bar ends with `likely equivalent survivors, member initialisers _init reassigns:
line N` when some survivors are initialisers `_init` always overwrites (no test can kill those). Check
them in the module before you judge the tests; the reject stands either way. Each phase prints a line
as it starts (Codex round done, unit grading, mutation running, repair round).

Every run writes a `started` line first, so a run killed from outside (a timeout of yours shorter than
the factory's own, a session that ended) shows in `queue` as STARTED AND NEVER FINISHED instead of
vanishing from the count. Running a discarded task again gets a new id (`-r2`), because the dispatcher
keeps the old run's record and refuses that id. Give the factory no outer timeout shorter than about
45 min: Codex, then the unit run, then mutation.

The ledger keeps measured and estimated apart. Measured: Codex seconds, machine results, verdicts,
lines review changed, the dollars of the sessions that reviewed. Estimated, and labelled so: one
session's cost split across the tasks it reviewed, which is an upper bound, since a session also
builds other things.

**A control run** is how the saving gets measured: a Claude subagent writes the same module's tests
from the factory's own goal and laws, in a scratch worktree cut from the same base (so the landed test
is not visible), and is graded the same way (commit, lint, the same 15 mutants, which are picked in
file order). Record what the harness reported, never an estimate:
`node tools/codex/factory.mjs control oil_leak --tokens=50249 --secs=309 --tests=12 --killed=<n> --mutants=15 --changed=0 --ledger=<file>`.
A control is never counted as a Codex task, and its saving holds for that module only.

To measure the other side, have a **subagent** do the review (it reads every line of Codex's test
against the laws and returns its edits; you check its diff) and record what the harness reported:
`factory review <id> --verdict=... --changed=<n> --review-tokens=<n> --review-secs=<n>`. A module with
both a control and a measured review shows in `ledger`'s `paired`: Claude tokens alone against Claude
tokens with Codex, measured both sides, Codex's seconds beside them. Your own check of the subagent's
diff is not in that number; say so when you quote it.

**Refuses to pick:** generators, tuned tables, drawing code, anything touching a scene or the disk,
anything already tested (ask `--explain` for the reason).
**Exit 3:** the weekly meter refused the dispatch; nothing was built, and the meter is never worked around.

## tools/merge/morning.mjs: the morning merge in one command

```
node tools/merge/morning.mjs --worktree=../gtai-wt/int-day --lanes=n11-tools,n11-hero,n11-combat --date=2026-11-10 --debt-reason="n11: film kit and combat polish"
```

Lanes merge in the order given, each lane's `JOURNAL.md` and `REPORT.md` go to `docs/day/<date>/<lane>/`,
then the debt ratchet with your reason, both DLLs, the bake, the gates, the three reel views, the
checked export. It stops at the first red and prints what to do; `--resume` carries on from there.
`--steps=merge,debt` runs a part, `--dry-run` only lists them.

**Refuses:** a worktree on `main`, `master`, a lane being merged or a detached head; a dirty tree; a
merge in progress; a lane that does not exist. **It cannot push:** every git call goes through a short
list of verbs, and `push`, `checkout`, `reset` and `branch` throw before git is called.
A conflict only on a lane's `JOURNAL.md` or `REPORT.md` takes the lane's copy. A conflict on
`tools/debt/baseline.json` (alone or beside those) takes the looser of both sides per metric and file,
keeps both sides' accepted reasons (`tools/debt/merge_baseline.mjs`), says so in the output, and the
debt step re-ratchets it to the merged tree. Any other conflict stops.

Each step's output goes to `build/merge/logs/<step>.log` while it runs (tail it). A step past its limit
(`--timeout`, at least 65 min for reels and 90 for gates) has its whole process tree killed by
`step_guard.mjs`, Godot included, and its log ends `morning: <step>: timed out after N min`.
After the gates (green or red) it prints one line per evidence kind of that run (`tools/merge/gate_lines.mjs`),
and names any kind written for another commit STALE. Its lines for the n15 scratch integration's real evidence
(read after that run; the run itself predates this print):

```
morning: gates: lint pass: lint: all 16 checks pass over 1428 GDScript files
morning: gates: unit-tests pass: unit-tests: 2529 passed, 0 failed, 2 skipped (GUT, headless)
morning: gates: green
```

## tools/dev/wt_init.mjs: make a fresh worktree able to run the game

```
git worktree add ../gtai-wt/my-lane -b my-lane main
node tools/dev/wt_init.mjs ../gtai-wt/my-lane
```

Copies what a checkout lacks (native DLLs, the baked city, `.godot`, `native/godot-cpp`) from a sibling
worktree and sets `core.hooksPath`, in about 16 s. `--dry-run` shows the plan, `--donor=<worktree>`
picks where from. It never overwrites anything, and it says when a DLL or bake came from different
code than your branch, by comparing the git objects: a stale DLL does not look like yours.

**Refuses (exit 2):** a path that is not a checkout of this game, a donor that does not exist, an
unknown flag. **Unverifiable (exit 3):** no donor has something it needs, or the tree still is not
usable after the copy (judged on your tree afterwards: a donor's bake can be whole for its own chunk
list and short for yours).

## tools/export/export_checked.mjs: a release export that proves its exe

```
node tools/export/export_checked.mjs                       # build/export/windows/RTAI.exe
node tools/export/export_checked.mjs --out=../build/export/try/RTAI.exe
```

Checks every baked chunk against `city_chunks.sha256` first, makes the output folder (a fresh worktree
has none), exports `windows-showcase`. **Refuses:** a missing or mismatched chunk (it names them; run
the bake, or `node tools/dev/wt_init.mjs .` to copy one), before Godot starts. **Never ok on exit 0
alone:** the exe must exist, be non-empty and be written by this run, or it says `wrote no`, `empty`
or `did not rewrite`.

## Stop at the first script error (`tools/dev/run.mjs`, `tools/film/film.mjs`)

```
node tools/dev/run.mjs res://dev/my_scene.tscn --timeout=150
# FAIL stopped at the first script error after 4.5 s (--keep-going to wait it out); SCRIPT ERROR 3 (first res://dev/my_scene.gd:5); ...
```

A dev scene whose script does not parse used to leave the engine idling until the timeout: the
verdict was FAIL anyway, but only after 150 s. Both front doors now kill the run 1.5 s after the first
`SCRIPT ERROR`, `Parse Error`, `Compile Error` or `Failed to load script` line, keeping the lines under
it so the verdict still names the file and line. `--keep-going` waits for the entry to end or time out
(for a run whose later errors you want in the log). Built on `runProcess`'s `stopOn` option in
`tools/lib/godot.mjs`; the gates do not use it, they report every error.

## A flag nothing reads is refused (`tools/dev/run.mjs`, `tools/dev/flag_index.mjs`)

```
node tools/dev/run.mjs cursor_sweep --dry-run -- --rigs --rivet-windup=of
# run: unknown flag --rivet-windup=of for res://dev/rivet_motion/cursor_sweep.tscn (did you mean --rivet-windup=off?)
# run: refused before launch; flags checked against the project's flag literals (no declared spec): 2 (--any-flag launches it unchecked)
```

An entry with its own `const KNOWN_FLAGS` is checked against that list, as before. An entry without
one used to launch "flags unchecked", so hero's `--ohm-hand=sim` (CastFlags reads
`--ghost-ohm-hand=sim`) ran and gave a 0.0 % before/after. Now every flag is checked against the
string literals of our GDScript (not unit/integration tests, not addons): the name must be read
somewhere (`"--x"`, `"--x="` or `"--x=<v>"`), and when it is only read as exact values
(`arg == "--x=sim"`), the value must be one of them. A family prefix (`begins_with("--ghost-")`)
does not make a longer name known. The suggestion is the nearest literal (a swap of two letters is
one edit) or the one known name that ends in the passed one (`--ohm-hand` -> `--ghost-ohm-hand`).
`--any-flag` skips the check (a flag built at run time; none existed on 2026-11-11) and the verdict
says `flags unchecked: no declared spec`. `tools/film/film.mjs` checks the game flags after its `--`
with the same index (it used to check names only, so a wrong value of an exact read passed).

## A dev run draws the current pixels at a fixed step (`tools/dev/run.mjs`)

```
node tools/dev/run.mjs stride_film -- --rigs --ppm=64 --film-out=C:/tmp/walk
# run: 1 asset(s) changed since the last import (res://.../tonnage_walk8.png): running --import first, ...
```

A plain `--path project <scene>` run does not re-import a PNG you just repacked, so a before/after can
be pixel-identical. `dev/run.mjs` now re-imports any asset whose source no longer matches its import
(as `film.mjs` does) before it launches. An entry that films every tick declares
`const FIXED_FPS: int = 60` and always gets `--fixed-fps 60`: under contention real-time frames skip
ticks (hero dropped 28 of 64 grabs). It is not the default, because the arena and the benches quit by
themselves too, and a fixed step would distort a bench or speed up a windowed scene. `--fixed-fps=<n>`
on the command line still wins.

**Unverifiable (exit 3):** an asset still does not match its import after `--import`; nothing is launched.

**Refuses (exit 1, `film.mjs` too):** a changed asset that is a Git LFS pointer (`git show HEAD:<png> > <png>`
writes one; restore with `git checkout -- <png> <png>.import`), before anything imports it, so its `.import`
is not rewritten `valid=false`; and an `--import` that exits 0 but prints `Error importing` or
`ERR_FILE_CORRUPT`, with those lines. Godot alone would film without the texture and report 0 SCRIPT ERROR.

## A misspelled `--select` name no longer costs the run (`tools/tests/run_unit.mjs`)

```
node tools/tests/run_unit.mjs --select=test_sim_clock,test_sim_clok
# note: --select=test_sim_clok matches no test file (did you mean test_sim_clock?): the other 1 file(s) run, and this run cannot pass
# unit-tests: UNVERIFIABLE: --select=test_sim_clok matched no test file and never ran (5 passed, 0 failed, 0 skipped in the rest)
```

One wrong name in a `--select` list used to exit 2 and run nothing, which cost a gate slot on a busy
machine. Now the names that match run, the one that does not is named with the nearest test file,
and a green run exits **3 (unverifiable)**, never 0: the file you asked for did not run, so the run
cannot vouch for it. A failure in the files that ran still exits 1. When no name matches at all it is
still exit 2 before Godot starts, now with the suggestion. A glob gets no substring guess.

## Scenario progress (`run_scenarios.gd`, `tools/tests/run_scenarios.mjs`)

```
node tools/tests/run_scenarios.mjs --only=autosave_input,arena_range
# run_scenarios: [1/2] arena_range ok, 3.5 s
# run_scenarios: [2/2] autosave_input ok, 10.8 s
# scenario-tests: 2 passed (headless)
```

The suite prints one line per scenario as it finishes, live through the tools runner and on stderr
when you run Godot directly, so a ten-minute run on a shared machine shows where it is. Send the run
to a file rather than through `tail`: the verdict is the last `run_scenarios: N ran, M failed` line.
`--only` takes exact names; an unknown name exits 2 before anything runs.

## Reel progress (`tools/reel/run_reels.mjs`)

```
node tools/reel/run_reels.mjs --out=build/reels --views=top
# run_reels: top chapter 1 <name> 3/3 down        (one per finished chapter, on stderr)
# run_reels: [1/1] top OK, 640 s; log build/reels/1-top.log
# top: OK; code 0; log build/reels/1-top.log
```

Each view's verdict prints the moment that view ends, and its log is written line by line as Godot
runs, so a wrapper killed at a tool's background limit still leaves the partial log of the view it
was in and the verdicts of the views before it. Three views take 30 min or more on a shared
machine: run one `--views=<view>` per command when your shell has a shorter limit. It refuses an
unknown view name or a non-integer `--expect` (exit 2) before anything launches.

## The night runner's live control (PoF `games/gtai/night/night.mjs`, branch `n11-runner`)

```
node games/gtai/night/night.mjs stop --root C:/Users/kazda/kiro/gtai-n11 --lane hero --now
node games/gtai/night/night.mjs schedule --root C:/Users/kazda/kiro/gtai-n11 --until 07:00 --freeze 06:30 --report-at 06:40
node games/gtai/night/night.mjs status --root C:/Users/kazda/kiro/gtai-n11 --siblings C:/Users/kazda/kiro/gtai-n11t
```

Run from the PoF checkout. A running night re-reads `<root>/control.json` at each lane's next step:
`stop` ends the night or the named lanes (the session in flight ends first; `--now` kills only those
lanes' sessions), `schedule` moves the times and checks the change against the running night's own
`<root>/times.json`, `status --siblings` flags a loop gone silent or a launch that never started.
`--reserve-min 90` on `run` keeps the last open billing path for the freeze and report sessions.
**Refuses:** a bad time, freeze after report-at, report-at not before until, a time already passed,
and an earlier `--until` alone when it would move the freeze or report into the past (name all three).

## A test that kills a child on a timer (`tools/lib/node_start.mjs`)

```
import { budgetMs } from '../lib/node_start.mjs';
const limit = budgetMs(1800, 1); // what you mean (1.8 s) + one cold node start, measured now
```

The timer starts before the child's first line runs, and a cold `node` start is 0.1 s on a quiet machine
and seconds beside two Godot runs. A fixed budget that holds a node start is a flake (n15: morning_run and
step_guard.break). `budgetMs(base, starts)` adds 3x the measured start per start. Prove a timer test with
every node start delayed: `SLOW_MS=2500 NODE_OPTIONS="--require <a file with
Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, Number(process.env.SLOW_MS))>" node --test <file>`.

`node tools/lint/lint.mjs` names every failing tool test (`FAILED <file:line:col> <name>`); a check's issue
lines past 40 go to `build/lint/<check>.txt`, and the last line printed says where and how many.
