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

## 03p6 (03:19-)

`tools/melee/fatal_takes.sh` run unchanged (no self-held lock; the tool waited for 04f's lock between runs, so
each weapon took far longer than 5 min once 04f ran). Katana rendered: `beside_fatal_katana.mp4` 1920x1080, 35.0 s.
First fatality at 18 s (stills at 10, 14, 18, 22 s): right half (n31 fatality) shows Rivet with the blade among
cops cut into split halves, blue pieces scattered, red pools; left half (main) whole bodies on small pools. At 14 s
the right half already has more spray and loose pieces than the left. At 22 s a new cop is hit on the right
half (red spray at the blade) while the left shows none.
Plasma sword: before arm rendered (`fatalb_play_plasma_sword.mp4`), after arm still waiting for the lane lock at
03:44; electro_baton and claw not rendered.

Plasma sword rendered at 03:51: `beside_fatal_plasma_sword.mp4`, 1920x1080, 35.0 s. First fatality at 16 s (stills 12,
16, 20 s): right half shows cops burst into blue and red pieces scattered around the pools, Rivet beside them with the
yellow blade; left half whole bodies on small pools. At 20 s the right half keeps a pile of gore at the west edge, the
left a few flat pools. electro_baton and claw were NOT rendered: the lane lock was held by 04f for most of the window
(each arm waited), and the electro_baton run was stopped at 03:52 (own PID tree only, lock removed).

## 03p7 (03:58-)

Electro baton rendered: `beside_fatal_electro_baton.mp4`, 1920x1080, 35.0 s (stills at 10, 12, 13, 14, 18, 22 s).
First fatality at 13 s: on the right half (n31 fatality) the struck cop is drawn as a pale overload flash beside Rivet,
where the left (main) half shows a plain dark body. At 14 s the right half has charred dark bodies lying on the road
with fewer red pools; the left keeps red pools. No amber current was clearly visible in the 1 s stills (the effect is
short); the charred bodies are the readable part. At 18 and 22 s no fatality is in frame.
Claw rendered (03p8): `beside_fatal_claw.mp4`, 1920x1080, 35.0 s (stills at 8-22 s). First fatality at 13 s: on the right half (n31 fatality) the cop
at Rivet is raked into torn pieces beside him with red spray; at 14 s orange-and-blue pieces lie on a pool at the lower right. The left (main)
half shows whole bodies on small pools. At 10 and 12 s no fatality is in frame yet.
