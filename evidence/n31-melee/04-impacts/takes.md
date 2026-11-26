# n31 melee 04f: item 4's impacts in play, main | n31 impacts

Films (owner, `gtai-masters/n31/melee/`): `beside_impacts_<weapon>.mp4`, 1920x1080, 35.0 s, H.264. Each half is
the middle half of a 1080p60 take cropped round Rivet (03p5's composite): left "main" = a temp worktree at
`0f1e1ce95` (the audit commit; its play_take.mjs has no `--game-flags`, its defaults are the old rules: melee
sweep off, kill feed off), right "n31 impacts" = HEAD with `--game-flags=--melee-sweep=off,--kill-feed=off`.
Same seed 7, 2100 frames, 32 px/m, tilt 70, the average bot holding the weapon: the two halves are the same
fight frame for frame, only the view-only marks differ. Built by `tools/melee/impact_takes.sh`; the seconds
where the halves differ were found with `tools/melee/take_diff.py` on the two source takes (20 fps), then
looked at as stills.

Most bot strikes kill (the kill is generic on both sides: the feed is off), so a wound mark shows only on the
non-lethal hits listed here.

## katana

- 15.2 s: Rivet cuts a cop inside a black blast cloud: the right half draws cream-and-ink cut strokes across
  him; the left half shows only the cloud and the body.
- 16.8 s: two crossed cuts on the cop at the kerb above Rivet (right); left: the cop, no mark.
- 30.6 s: a cut stroke left of Rivet on the cop he swings at (right); left: the swing arc only.
- Hits in this take: 13.1, 15.15-15.35, 16.75-16.95, 29.95-30.15, 30.55-30.75 s (each about 0.3 s, the mark's
  21 ticks).
