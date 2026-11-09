# Builder tools

Tools a builder reaches for without being told. Each section has one example you can paste, and says
what the tool refuses. Every evidence tool here reports three outcomes, not two: **pass**, **fail**
and **unverifiable**. Unverifiable means it ran but could not observe the thing, and it is never a pass.

Run these from the root of your worktree. Exit codes are shared: `0` pass, `1` fail, `2` usage
(nothing launched), `3` unverifiable.

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

The ledger keeps measured and estimated apart. Measured: Codex seconds, machine results, verdicts,
lines review changed, the dollars of the sessions that reviewed. Estimated, and labelled so: one
session's cost split across the tasks it reviewed. Unmeasured until a control run exists: the Claude
cost of writing the same tests without Codex.

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
A conflict only on a lane's `JOURNAL.md` or `REPORT.md` takes the lane's copy; any other conflict stops.
