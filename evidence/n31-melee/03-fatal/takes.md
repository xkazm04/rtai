# n31 melee 03p4: fatality play takes (main | n31 fatality)

Films in `C:/Users/kazda/kiro/gtai-masters/n31/melee/` (not in git). Both arms rendered at 02:08-02:13 from
the same tree (HEAD 498568a41 plus the 04d builder's then uncommitted blade-mark edits in
`blade_marks.gd`, in both arms), so the blade marks match and only the rules differ: before = `--melee-sweep=off --kill-feed=off` (main), after = HEAD defaults.
`build/n31/03p4/takes.sh <weapons>` drives `tools/melee/play_take.mjs --seed=7 --frames=2100 --ppm=32
--tag=03p4` (tilt 70, Movie Maker 60 fps; frames come out 1280x800, the window size) and the ffmpeg hstack
(each half 960x540, labels "main" / "n31 fatality").

| film | length | where the fatality shows (film seconds; looked at stills) |
|---|---|---|
| `beside_fatal_chainsaw.mp4` (+ `fatal_play_chainsaw_before/_after.mp4`) | 35.0 s | after: 13.5-15 s Rivet holds a cop on the saw at the south kerb (white contact star, red spray); 18 s the cops ground there lie in torn pieces with ragged red edges (main at 18 s: whole bodies on small pools); 30 s a fresh red burst at the left edge in wave 2. The arms drift apart after the first grind (it holds Rivet). |
| `still_grind_chainsaw_64.png` | still | 64 px/m take (`--label=zoom64 --ppm=64 --frames=1260`, HEAD defaults), frame at 13.2 s: the saw in a patrol cop's chest, sparks and spray; the previous victim on a pool beside Rivet. |

Kill ticks: the take scene logs no kill ticks (the probe line 03p3 mentioned is not in `play_baseline_take`),
so the window is the whole 35 s from the start; the first grind lands at about 13.5 s in both 32 and 64 px/m.

Not filmed: katana, plasma_sword, electro_baton, claw. From 02:29 every take launch stopped on a parse error
in the shared tree that is not this lane's 03p4 work (`Casting "Variant" to "CombatBlood" is unsafe`, the
04d builder's uncommitted `combat_blood.gd` / `gun_fx_wound.gd` edits); the 02:07 first attempt failed the
same way for a moment. 04d fixed it at 02:32; the retry then waited on the lane lock (held by `04e` from
02:31:40 past 02:42) and 03p4 stopped its own waiting take at 02:43 (no Godot had started) to end on time. Next: `build/n31/03p4/takes.sh katana plasma_sword electro_baton claw` once the tree
parses (about 5 min per weapon, both arms).

Scenarios: `node tools/tests/run_scenarios.mjs --quiet-wait=1` at 02:22-02:29 (HEAD 9a3268812 + 04d's
then uncommitted view edits): `scenario-tests: 68 passed (headless)`, exit 0; quest1_input ok, city_parity_ref
ok, rig_stress and city_chase ok (no CONTENDED). Part 0 (deploy_ohm / deploy_kerf) moved no pinned digest:
no re-pin, no decisions line.

## 03p5 (02:45-03:15)

`tools/melee/fatal_takes.sh [--compose-only] <weapons>` (tag 03p5) replaces `build/n31/03p4/takes.sh`: each raw take is
cropped to its middle half (`crop=iw/2:ih:iw/4:0`, follows Rivet), scaled to 1080 lines, hstacked, padded to 1920x1080,
labels "main" / "n31 fatality" 34 px. `beside_fatal_chainsaw.mp4` re-composed with `--compose-only` (no Godot):
1920x1080, 35.0 s. Looked at 14 s (after: Rivet with a cop on the saw at the south kerb, red spray, the figures now
about 3x larger than the 960x540 cut) and 18 s (after: torn pieces with ragged red edges at the kerb; main: whole
bodies on small pools). The grind reads on the right half.

Not rendered: katana, plasma_sword, electro_baton, claw. The take launch started 02:46 but `play_take.mjs` never
spawned a Godot in 27 min (no output after the flags line; the machine was full of other lanes' Godots, most likely
the memory-budget wait), so no fatality seconds exist for them. Stopped at 03:13 (own PIDs only). Next:
`tools/melee/fatal_takes.sh katana plasma_sword electro_baton claw` under the lane lock on a quieter machine.
