# Brief n24-pressure-05: the owner's films for lane pressure

You build for lane `pressure` of RTAI (Godot 4, internal id `gtai`) in this worktree, branch `n24-pressure`.
Read `AGENTS.md` and `tools/README.md` (the `tools/film/` section) before you start. STANDARDS.md binds.

**Wall clock: hard stop 01:25. Last commit by 01:15.** After the freeze (01:30) nothing is committed.
The code is frozen: this call makes films and evidence only. If a film needs a code change (a new dev shot, a probe),
it lives under `project/dev/gauntlet/**` only, and only if it is committed by 01:15; otherwise film with what exists.

**Godot is yours alone** (the director's gate has finished before your start).

## Machine rules, git law

As in `evidence/briefs/n24-pressure-02-deflect.md` sections "Machine rules" and "Git law" (read them: APPDATA and
GODOT_BIN exports, one Godot at a time, `--rendering-driver d3d12`, `--position 0,1440` on every windowed run, stage per
path, no stash / add -A / amend / rebase / merge, `node tools/gate/quick.mjs` before each commit, fix lint and format
findings in your own edit and go on). Film with `--rev=HEAD` (a snapshot), never from the live tree.

## Allowlist (any other path: stop and report `NEED <lane>: <file> <why>`)

`project/dev/gauntlet/**`, `evidence/n24-pressure/**`, `C:\Users\kazda\kiro\gtai-masters\n24\pressure\**`.
Forbidden: everything else (other lanes' files, tables, product code).

## Every film

32 px/m, tilt 70, 1920x1080, 60 fps, 15 to 40 s (check each with `ffprobe` and quote duration, size, fps). To
`C:\Users\kazda\kiro\gtai-masters\n24\pressure\`. Look at frames of every film yourself (extract 3 stills with ffmpeg and
read them): a film of the wrong thing, a black frame or a frozen Rivet is not delivered.

## Film 1 - an average fight where standing still is punished (the owner's main proof)

One gauntlet street wave at wave 6 to 8 (rifle cops + a rocket trooper), same seed, three takes side by side or in
sequence with a caption each: (a) Rivet stands still and only shoots, (b) Rivet runs in circles and shoots, (c) the
`average` test player. Each take shows Rivet's hp bar. Caption numbers per take: hp lost in the first 20 s, rounds that
hit him. Find the existing way to drive the gauntlet with a scripted Rivet (`tools/film/film.mjs` shots, the gauntlet's
`--bot`/profile flags, `project/dev/gauntlet/**`); a dev script that holds no input or circles is fine. If the side by
side cannot be made, three files `punish_still.mp4`, `punish_circle.mp4`, `punish_average.mp4`.

## Film 2 - deflect, half through

If brief 02 already delivered a deflect clip at 32 px/m (look in the masters folder and `evidence/n24-pressure/deflect/`),
check it against "Every film" and keep it; otherwise film Rivet guarding against a rifle squad for 15 to 25 s with the
passed rounds (their spark + Rivet's hit reaction) and the scattered returns readable, plus a 64 px/m close-up.

## Still 3 - the two rockets (for an owner call)

Rivet's rocket (after a5332156f: steel casing, amber exhaust) and the `rocket_trooper`'s rocket (enemy large round,
`EnemyRoundLook.LARGE_*` ice blue) in flight, same tick and zoom, at 32 and 64 px/m, as one side-by-side pair:
`rockets_rivet_vs_trooper-<ppm>.png`. The owner wrote "Blue rocket does not fit style of the weapon"; no blue was found on
Rivet's own rocket, so the owner may mean the trooper's. The pair lets the owner say which.

## frames.json

`C:\Users\kazda\kiro\gtai-masters\n24\pressure\frames.json`, 8 to 15 entries, best first:
`[{ "file", "title", "ppm", "before", "note" }]` covering: the punish film(s), the deflect film and close-up, the rocket
and nail before/after stills, the round-size list. Delete scratch renders it does not reference.

## Report

Per film: path, ffprobe line, what it shows, the caption numbers. Every NEED.
