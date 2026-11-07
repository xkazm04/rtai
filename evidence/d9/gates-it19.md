# Gates it19 (d9 rivet, 2026-11-07 15:21-15:26, code 6443bc82: the electro baton v3 strips; docs since)

- Director reel `res://dev/arena/arena.tscn --quit-after 20000 -- --bot=reel --reel=director --loadout=pistol --rigs
  --view=<top|tilt70|combo>` (headless): 19 chapters started, 19/19 fully down in each view (electro_baton at tick
  6240: 1/1 down); 0 SCRIPT ERROR; 0 `p_frame`; the 2 known `^ERROR` lines each (`reel-director-it19-<view>.log`).
  Note: `--quit-after 14000` (the brief's number) ends the headless run at chapter 17-18 (tick ~5940), before the
  baton chapter; the it16 gates used 20000 too.
- Unit, full no-arg run: 1706 passed, 0 failed (50.5 s).
- Lint: 15/15.
- Evidence run not re-run: strips (art) and docs only since the it16 evidence PASS on 0ee23a95; `top` draws no strip
  (RivetStrips.strip_of returns "" without an art key), so the look goldens cannot move.
