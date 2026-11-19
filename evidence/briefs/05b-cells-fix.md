# Brief 05b `cells-fix` (resume of move-cells): two cover drawing defects, then brief 06

Same environment rules as brief 05 (APPDATA, GODOT_BIN, d3d12, `--position 0,1440`, one Godot at a time,
commit each step, stopped at 75 minutes).

Your vault cells are accepted: the plant hand on the crate at the apex and the bent-knee landing read as a
vault at both pitches. The cover frames have two defects I see in your own sheets:

1. **A black wedge cut into the prop under Rivet in every cover stance.** `cells/cover/sheets/p70_64_low.png`
   ticks 040 and 065 (a black trapezoid on the middle crate's top, below his collar; a thin black sliver at
   116), and `p55_64_high.png` ticks 355 and 380 (a dark wedge with a pale outline from his boots down into the
   dumpster's front). It is in the stand-in panels too, so it predates the cells: it comes from the cover
   drawing (`cover_view.gd` / `cover_upper_card.gd` / `motion_rig_pose.gd`) or from how `PropOcclusion` cuts the
   prop around a figure in cover. Find the cause (say which line), fix it, and add a unit test that fails on
   it (e.g. no fully dark pixels added inside the prop rect by the cover drawing, or whatever pins the cause).
2. **Ghost legs through the high dumpster.** At p55 high cover the translucent crop shows his whole legs over
   the dumpster's front, so he reads as standing inside it. Change the cover drawing so that: what is above
   the prop's drawn top edge (helmet, gun, shoulders) is opaque; what the prop hides is NOT shown as a faded
   copy of the cell, but as a flat single-tone silhouette (Rivet's darkest bronze, about 30 % alpha, no inner
   detail; never teal, never vermilion, never red), or not at all if the silhouette does not read. Same rule
   for low cover. Data values for the alpha and the on/off of the silhouette.

Re-render the cover sheets (both pitches, 32 and 64 px/m) and the p70 32 px/m clip, update INDEX.md, look at
them. Commit. Then continue with `evidence/briefs/06-flip-on.md` (read it now; it is the next package) in this
same session.

Acceptance as brief 05 + brief 06.
