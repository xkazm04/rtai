# n31 melee 03p4: fatality play takes (main | n31 fatality)

Films in `C:/Users/kazda/kiro/gtai-masters/n31/melee/` (not in git). Both arms rendered at 02:08-02:13 from
the same tree (HEAD 498568a41 + no edits in the view paths the take draws), so the blade marks match and only
the rules differ: before = `--melee-sweep=off --kill-feed=off` (main), after = HEAD defaults.
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
same way for a moment. Next: `build/n31/03p4/takes.sh katana plasma_sword electro_baton claw` once the tree
parses (about 5 min per weapon, both arms).

Scenarios: `node tools/tests/run_scenarios.mjs --quiet-wait=1` at 02:22-02:29 (HEAD 9a3268812 + 04d's
then uncommitted view edits): `scenario-tests: 68 passed (headless)`, exit 0; quest1_input ok, city_parity_ref
ok, rig_stress and city_chase ok (no CONTENDED). Part 0 (deploy_ohm / deploy_kerf) moved no pinned digest:
no re-pin, no decisions line.
