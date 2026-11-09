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
every fighter), `film.json`, `film.log` and, without `--no-movie`, an mp4.

The camera: `--lock=auto` (the default) holds it at Rivet's spawn, except on the street shots, where
it follows him and freezes at your first still. `--lock=at:<tick>`, `--lock=<x,y>` and `--lock=off`
are there when you need them. A locked camera also turns the hit-feel shake off, so a frame
difference means the world changed.

`probe.json` per tick and fighter: `pos` (m), `screen` (px), `on_screen`, `draw` (opaque size in px,
`-1` means no card), `feet_y` (the screen row of the lowest opaque pixel), `facing_off` (degrees
between the drawn facing and the sim's aim; `999` means no rig), `alive`, `hp`.

**Refuses, launching nothing:** an unknown shot; a weapon, chapter or view id that tree does not have
(with a did-you-mean); a game flag no script in that tree reads; stills past the end.
**Unverifiable:** no fresh `probe.json`, a still that was not saved, a drawn size other than the one
asked for, or a subject (`--subject=rivet|hostile|dead|id:<n>`) off screen at a still.
Quest 1 has no numbers and no locked camera; a still that exists is all it can claim.

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
