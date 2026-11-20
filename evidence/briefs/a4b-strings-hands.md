# Brief a4b (resume of a4-strings): the strings must leave from TWO hands

You built the strings (cd85c4d85) and the evidence (`dent_tether_strap_vs_strings_32.mp4`,
`scratch/a4/`). The director looked at `scratch/a4/dent_tether_strap_vs_strings_64.jpg` and the 5 m /
20 m pairs: under `--dent-tether=strings` the body still shows the STEER ONE HAND pose (one arm
reaching, the other hidden behind him), so all four strings leave from ONE fist, even at 64 px/m.
The owner's Puppeteer plate (`C:\Users\kazda\kiro\gtai-masters\n20\concepts\dent_c.png`, bottom
right) has his two hands apart, each holding two strings; the turn reads because the hands tilt.
Without that the side-by-side does not answer the owner's question fairly.

Same machine rules and repo law as a4 (APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/dent, d3d12,
`--position 0,1440`, one Godot at a time, PID kills only, stage per path, quick gate before each
commit, never push). Render only; strap path and legacy untouched.

1. Under `tether_look == strings` while steering, the spectral tilt body uses the **STEER TWO HANDS**
   act cell (`dent_sp_act` fourth column: COCK, JAB, STEER1, STEER2) for every facing, and `left_px` / `hand_px` are that cell's two
   drawn hands (measure the hand points per facing in both pitches, as `DentStringSteer.OPEN_55/70`
   do; mirrored cards swap hands). The two hands must sit at least 0.45 m apart on screen at
   32 px/m in profile facings. The top rig: the two arms reach forward apart, one pair of strings
   from each fist.
2. String core 2 px (not 1) at 32 px/m, ink 3 px total, scaled with ppm. Keep the corner rings.
3. Re-shoot with your `tools/film/dent_tether_films.mjs`: same seed/ticks, overwrite
   `dent_tether_strap_vs_strings_32.mp4/.jpg`, `scratch/a4/dent_tether_strap_vs_strings_64.*` and
   the four pair stills; re-run `dent_tether_eval.py` so `strings_eval.json` has the new widths,
   overlap counts and draw cost (CONTENDED).
4. Re-run the legacy byte compare (ticks 160, 200) and `test_dent_strings`; quick gate; commit.
5. `tools/film/dent_tether_probe.gd` is untracked: if the films need it, it must live where lint and
   the release rules see it (`project/dev/ghost-powers/dent_tether_probe.gd`, dev-only), committed
   with its `.uid`; else delete it. Commit `dent_tether_films.mjs` / `dent_tether_eval.py` (tools,
   Dent-named).

Stop at 25 minutes with what is done; report the shas, the new stills and numbers.
