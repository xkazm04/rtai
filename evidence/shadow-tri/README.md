# Seed-5 city contact shadows

At tick 900 the original and corrected arena runs had submitted 47,064 standing contact rings. The renderer rejected two inner rings before the change and zero afterward. The observer independently triangulated each input with Geometry2D. It also evaluated the eight-vertex figure at the exact feet, cast direction and hip height of every rig, including the rigs using contact ink. At the short cast length 312 of 16,282 hypothetical figure outlines failed at absolute coordinates and zero failed at local zero. In the actual long-cast combo_ease12 control all 16,282 original figure submissions triangulated.

The new unit test intercepted the three polygon submissions at the first failing centre. Before localization it failed twice (initial run and isolated retry) with 0 indices instead of 54. After localization all rings gave 18 triangles. The input uses the full precision of the reported centre and hip.

The 64 px/m pair shows the standing pistol cop at arena tick 1. The same 103 by 147 crop starting at (721, 138) differs in **0 pixels**, and the full 1280 by 800 frames also differ in 0 pixels. [Before](<C:/Users/kazda/kiro/gtai-masters/n19/anim/shadow-tri/before-t1-64ppm.png>) and [after](<C:/Users/kazda/kiro/gtai-masters/n19/anim/shadow-tri/after-t1-64ppm.png>).

Run the arena scene at fixed 60 fps with D3D12, window position 0,1440 and game flags `--arena=city --bot=rivet --rigs --clean --seed=5 --view=tilt70 --ppm=32 --shot-tick=900 --shot=<absolute PNG>`. For the standing pair use 64 px/m and tick 1. The raw logs retain the common engine teardown diagnostics. The counts above cover triangulation errors.
