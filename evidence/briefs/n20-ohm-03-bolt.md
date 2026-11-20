# Brief n20-ohm-03: the spectral bolt: from the fork, thin first link, heavy forks, staggered links, marked victims

Worktree `C:\Users\kazda\kiro\gtai-wt\n20-ohm`, branch `n20-ohm` (your previous session wired the spectral body:
OhmCharge, the jar overlay, OhmSpirit; read `git log --oneline -8` and its commits first). Plate:
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\ohm_c.png`, the attack inset bottom right: the bolt leaves the two
copper prongs and chains through three guards, each lit where it is struck. VISUAL ONLY: no sim, replay, parity or
digest moves; `OhmStage`'s bolt path, timing, targets and damage are unchanged. Everything below applies only under
`GhostLook.spectral(&"ohm")`; legacy (`OhmView` today) must draw exactly as now.

Environment as before: `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/ohm`, `GODOT_BIN=...4.7.2...console.exe`,
d3d12 to render, `--position 0,1440` when windowed, one Godot at a time, own PIDs only.

## Status at 01:50 (director)
Your previous (wire) session was stopped at 01:46 by a session cut, without a final report. Its last commits:
`2f96cf6fd` (top-view staff/hem/vent), `48a243bc1` (merge flight), `c92cff898` (merge flight 1b `d2a44407e`),
`e80cec55e` (jar overlay on the shared spectral sprite). The tree was clean. Verify, do not assume: at 01:50 the
director found `ohm_rig.gd` still missing ~28 of the 30 `##` lines removed in 95eaebf58, and `OhmView._sparks()`
(ohm_view.gd:70) still called with no spectral guard. Check each Step 0 bullet against HEAD, finish what is open,
re-shoot the wire stills you change (`n20/ohm/wire/`), then go on to Build. If `ohm_view.gd` would pass 200 lines,
put the spectral code in `ohm_bolt_draw.gd` / a new `ohm_` file.
Hard stop: commit what is finished by 03:05 at the latest and report; the director's session ends at 03:17.

## What last night's film showed wrong (n19 `ohm_attack_32.mp4`, `ohm_close_64.mp4`), to fix
- the bright first link hides the forks to the other two guards;
- sparks cover the falling bodies; two branch endpoints merge into the effects;
- the bolt starts from the old electrode fingers; tonight it must leave the staff's FORK.

## Step 0: fixes to your previous package (the director looked at every still in `n20/ohm/wire/`), one commit
- Under spectral, OhmView must NOT draw the legacy fingertip tell (`_sparks`: the white glint and the two white
  reach lines at ground level beside his hem, visible in every wire still). The charge tell is the jars now.
- Top view: the staff must run AHEAD along his facing like a walking stick (the pole within about 15 deg of +x,
  the fork about 1.0 m ahead and 0.35 m right), not 45 deg out to his right as in `ohm_top_idle_full.png`.
- Top view: the jars light as small dots; each jar top should light as a full circle (the whole magenta area of
  `body_jars.png`), so from above they read as three lit circles on his back at 32 px/m.
- The flight tail is a detached dash about 1 m behind him in both views; it must start at the hem's tip and
  continue it (tune `tail.anchor_m` / length in the ohm row of `ghost_hover.json`; if the root itself is wrong in
  flight's code, write that in your report as a NEED for flight, do not edit their files).
- Restore the doc comments you deleted from `ohm_rig.gd` in 95eaebf58 (every `##` line removed there). If the file
  then exceeds the size limit, move code (not comments) out into an `ohm_` file.
- Flight's package 1b IS in (`d2a44407e` on n20-flight): GhostDrawn now loads `<card>_spec_hover` (+`_left`) /
  `_spec_act` itself under spectral (`pose` -1 = col 0 idle, col 1 at or above 0.5 m/s; act wins), `sprite()`,
  public `instant_windup` (0 for spectral Ohm), GhostFlight.tail points()/half_widths(). Merge it. Then prefer
  flight's path: let GhostDrawn draw Ohm's spectral cells and hang OhmJars + the halo on `drawn.sprite()`, and cut
  OhmDrawn down to what flight does not do (jar overlay, lean/bank if flight lacks it). Keep it only if the
  stills would get worse; say which and why. Make sure exactly ONE body sprite draws (no double figure).
- (Old note, same thing:) if `n20-flight` has landed its package 1b (`git log HEAD..n20-flight`: public `GhostDrawn.instant_windup`,
  `sprite()`, `pose`, spec-sheet loading), merge it and replace the private `drawn._instant_windup` / `drawn._tick`
  access in `ohm_rig.gd` with the public API.

## Build
1. **Fork tip per cell.** Extend `tools/art/ohm_spectral_cut.py` (deterministic) to find the copper prongs in every
   cut cell (the copper/orange pixels: the two largest copper blobs) and write `fork_px` (the midpoint of the two
   prong tips, cell px) and `prongs_px` (each tip) per cell into `ohm_spec_cells.json`, and the staff's fork tip in
   `art/ohm/spectral/parts.json`. Re-run it; the PNGs must come out byte-identical (show the hashes).
2. **Bolt from the fork** (new `ohm_bolt_draw.gd`, used by `OhmView` under spectral; keep `ohm_view.gd` under 200
   lines). Tilt views: the fork tip from the shown cell (`fork_px` mapped through the drawn sprite's transform; the
   strike column's cell, mirrored for left octants). Top view: OhmSpirit's staff fork in world px. Two thin prong
   strokes leave the two copper tips and join a short way ahead, then the bolt goes on to the first body (the
   sim's `bolt_path[1]`), as now but from the fork.
3. **Weights.** The first link (fork to first body) is the THINNEST stroke: about 0.6 of the current widths. Each
   fork link (body to body) is at least as heavy: 1.0. (The ghost_attacks `branch_k` stays for legacy; put the
   spectral constants in `ohm_bolt_draw.gd`.)
4. **Stagger.** Link i appears LINK_TICKS = 2 ticks after link i-1 (drawing only; the sim already resolved all of
   it on the press), and each link's fade counts from its own appearance, so the eye follows the chain 1 -> 2 -> 3.
5. **Victims visible.** No flash disc or spark ON a body. Each struck body gets a thin ring or rim light around it
   (white-teal, ink-edged, radius about the body's radius + 0.15 m) that holds for the stun (read the fighter's stun
   state if the view can, else the stun_s from ghost_attacks), fading in its last 0.3 s. Sparks: three to five
   short ones thrown OUTWARD from the ring, never inward over the body, gone within 0.2 s. A killed body gets the
   ring for 0.3 s only and nothing over the falling figure.
6. **The press.** At the bolt tick: the fork flares (a white-teal star at the prongs, 3 ticks) and the jars empty
   (OhmCharge already); the staff thrust follows (already in OhmSpirit / the strike column). The car case (nothing
   in the cone, a car burns): same fork, one link to the car, ring on the car's contact point.
7. **Cancelled cast** (`--ohm-bolt-delay=on` and the cast interrupted): no bolt; the jars vent amber (OhmCharge.vent)
   and the fork sputters three short AMBER sparks. Never teal. Check the struck column shows briefly so it is not
   missed (the n19 film: it snapped straight to the hurt pose).
8. Reduced motion: no stagger flicker, one still jag (as legacy does).

## Acceptance (quote every result)
1. `node tools/godot/check.mjs` on changed `.gd`; `node tools/lint/lint.mjs`; `node tools/tests/run_unit.mjs --changed`.
   Add `test_ohm_bolt_draw.gd`: first-link width < fork-link width; link i hidden before 2*i ticks and shown after;
   no ring or spark centre inside a body's radius; amber (not teal) on cancel.
2. Scenario suite (incl. the replay) green: `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`.
3. **The strip** (the owner judges this): through `ghost_review.tscn --ghost=ohm --take=attack --ghost-look=spectral`,
   top view and 70 deg tilt, 32 px/m: frames at jars one, two, three full, the press tick, and press +2, +4, +6
   frames, all three links and all three victims visible. Compose each view as one horizontal PNG strip with a small
   label per frame into `C:\Users\kazda\kiro\gtai-masters\n20\ohm\bolt\cast_strip_top_32.png` and
   `cast_strip_tilt70_32.png`, plus the same press +4 frame at 64 px/m as `press4_close_64.png`. Also one frame of
   the delayed cast interrupted (`--ohm-bolt-delay=on`) showing the amber vent: `cancel_vent_32.png`.
4. `node tools/gate/quick.mjs` before each commit; commits staged per path: (a) the cut-script fork points,
   (b) the spectral bolt. Then `node tools/mutate/mutate.mjs --file=features/souls/ohm_bolt_draw.gd` and quote the
   score.

Up to 75 minutes; if short, commit what is finished and say where you stopped.

## Report
Commits, the strip paths, test/lint/scenario/mutate results, and what in the frames still does not match the plate.
