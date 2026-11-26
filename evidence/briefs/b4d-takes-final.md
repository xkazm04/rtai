# Brief b4d-takes-final (lane foes, run n31): item 4 play takes main | HEAD + 64 px/m gait clip

This is `evidence/briefs/b3b-takes.md` with step 1 DONE (e49d93b91: crf 28 slow, maxrate 6M, <= 25 MB / 30 s).
Read b3b-takes.md for the Godot, owned files and repo law sections: they bind unchanged.
**Hard stop: 50 minutes after launch, report and END.** Commit each finished take's JSON as soon as it is checked.

HEAD = the final item 3 setting (the director names the commit in the launch message; use `--right=rev:<that commit>`
if the tool supports rev on the right, else HEAD with a clean tree). main = `rev:ba8e470b0`.

## Do
1. Re-shoot `wave1_side` (seed 3, average, 30 s): HEAD changed since the 22:26 take (lever 1 + item 3 levers).
2. `wave3_side`, `wave6_side` (seed 3, average, 30 s).
3. `gait64_patrol`: HEAD only, `--ppm=64 --follow=patrol_cop`, 15-20 s: one patrol cop walking backwards slowly
   while firing, then turning and running when Rivet closes inside 4 m. Scout for the window first.
4. ffprobe each (1920x1080, 60 fps, 15-40 s, <= 25 MB per 30 s). Extract 4 stills per clip and Read them; one
   sentence per take per side: how many fire, from how far, slow walk while firing, run without firing; quote
   the take JSON's mean alive / fired per second per side.
5. Upsert `C:\Users\kazda\kiro\gtai-masters\n31\foes\frames.json` (best first; delete only scratch you made).
   Commit take JSONs under `evidence/n31/foes/takes/`.
