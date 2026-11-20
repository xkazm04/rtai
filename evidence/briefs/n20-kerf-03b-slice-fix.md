# n20-kerf brief 03b (resume of the slice session): three fixes on the press-tick read, and Kerf's hover row

Same lane, worktree, branch and rules as brief 03. Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/kerf`. One Godot process at a time, `--rendering-driver d3d12`,
`--position 0,1440` on windowed runs, kill only your own PIDs. Visual only: no sim, replay, parity or bake
digest moves; prove it as you did in brief 03 (20 s city + 60 s replay byte-identical vs `f36c0a161`).

I looked at `slice_strip_top_32.png`. Was, cut and is all read from above at +0: good. Three things are wrong.

## Fix 1: two Kerfs at +0
The after-image is nearly as opaque as the live body, so the press frame reads as two Kerfs. It must read as
a ghost of where he WAS: alpha about 0.35 at the press tick (fading out over its existing life), and washed
toward flat teal (`#2EC4B6`; mix about 60 % toward it so the lens, hazard stripes and steel lose their
contrast), no beams on the after-image. Keep the pose snapshot. Put the alpha and wash amounts as named
constants (or a view-only field in Kerf's own data if one already exists). Test: the after-image's modulate
alpha at the press tick is below 0.45 and the live body's is 1.

## Fix 2: the red/vermilion speck near the victim at +3
In the top strip at +3 there is a small red or vermilion speck next to the guard. Red is blood only, vermilion
only for danger/objectives/Rivet's collar, and `kerf_split` is a dry, cauterised kill. Find what draws it
(render that frame, crop it x4, sample the colour, trace the drawer). If it is a Kerf-owned file, fix it there
(teal-white or ink). If it is a combat/kills file, do not edit it: write the exact `NEED` line (file, what,
why) in your final message.

## Fix 3: the slash on the victim on the press tick
`ghost_attacks.json` `kerf.cut_flare_s` is documented as Kerf's own view-only "ink-and-cream slash flare across
the target" (n7-melee). If that diagonal slash is drawn by a Kerf-owned file (`kerf_*.gd`), then under the
spectral look skip it (the slot IS the mark; the legacy look keeps it byte-identical). Do not change the table
value. The cream star from `kill_marks.gd` / `kill_split_fx.gd` stays a NEED (already logged); do not edit those.
Say in the final message which of the marks on the victim at +0 remain and which file draws each.

## Fix 4: Kerf's hover row (his flight character)
Flight decided (01:27) that each ghost lane owns its own row in `project/data/tables/ghost_hover.json`.
`kerf` row only: `lag_ticks` 3 -> 1 and `bank_deg` 24 -> 12 ("hard turns are sharp, almost no bank lag: he
is the one ghost with no weight"). Sorted keys, schema-valid, run the tests that read the table
(`--changed`). Commit on its own.

## Then
- `node tools/gate/quick.mjs` before each commit; one commit per fix (staged per path).
- Re-shoot `slice_strip_top_32.png`, `slice_strip_70_32.png`, `slice_strip_64.png` in
  `C:\Users\kazda\kiro\gtai-masters\n20\kerf\` (same ticks, same layout), and look at them yourself.
- `node tools/mutate/mutate.mjs --file=project/features/souls/kerf_echo.gd` (or whichever file holds the
  after-image) and quote the score.

## Final message
Commits, the test/scenario/digest lines, mutate score, what you saw in each re-shot strip, the speck's
source, the marks that remain on the victim at +0 with their files, and any NEED line.
