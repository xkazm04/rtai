# Package 7 (guns lane, n19): reloads and magazines - machine_pistol, hand_cannon, electro_gun; the magazine view

Same pipeline and law as packages 3-6; the turn kit for evidence. Re-run the audit first. Holes:
- `machine_pistol`, `hand_cannon`: reload X at p55 and p70 (no `rivet_reload_<gun>.png` / `_left.png`; they already have a `parts.mag`). 2 holes each.
- `electro_gun`: reload X at top, p55, p70 (no `parts.mag`, no reload strips). 3 holes.
Order: electro_gun (also closes the magazine placeholder for it), machine_pistol, hand_cannon. Each finished before the next.

1. Reload strips at p55 and p70 in the layout of `rivet_reload_pistol*.png` (one-hand siblings) / `rivet_reload_plasma_rifle*.png`, the magazine he swaps drawn from the gun's own `parts.mag` (electro_gun: draw its `mag.png` first, in its own materials, an energy cell, colours from its existing art; not vermilion).
2. The magazine view (`project/features/player/rivet_mag_view.gd`): with every gun that has a magazine now owning a `parts.mag`, no gun should reach the ink-block placeholder. Make the placeholder unreachable for any arsenal gun (a unit test that walks every `rivet_arsenal.json` gun with `magazine > 0` and asserts it resolves a real mag texture), and keep a safe fallback for unknown ids that logs once (`Log`). Show a still of a reload with the real magazine for each gun.

## Evidence per weapon (`C:/Users/kazda/kiro/gtai-masters/n19/guns/<gun>/`)
A reload contact sheet per pitch at 64 px/m (every reload cell, right and left, old above new), a 32 px/m clip of Rivet emptying the magazine and reloading while turning (10-40 s), `frames.json` (8-15 entries, best first). Compare new cells with the hand-made pistol reload at 64 px/m and redraw any that can be told apart.

## Acceptance
Audit: these three 0 holes; `arsenal_known_holes.json`; `evidence/arsenal/matrix_after_7.txt` (+ .json). Unit `--changed` + the mag-view test + `test_arsenal_audit` green; lint; release_compile; quick gate before each commit (`--no-godot` only for the known standalone-autoload error, said per commit). Mutate `rivet_mag_view.gd` (quote the score). One commit per change, staged per path, `.import`/`.uid` with sources.

## Law
As packages 3-6: image_gen, own-art refs, masters + manifest + prompts + provenance, script cuts at neighbour density, collar rigid, APPDATA/GODOT_BIN, d3d12, `--position 0,1440`, one Godot, own PIDs, no balance/digest change, typed GDScript + size limits + `Log`, no stash/add -A/commit -a/reset --hard/push, shared files rows only (list lines).
Report: commits, holes before/after, evidence files, mirrored cells, closest-to-tellable cells, anything left.

## Added 03:15 after package 5b/6b (binding)
Fresh full-figure image_gen drifts from the hand-made chibi Rivet (smaller helmet on longer legs, adult stance, smoother render, thinner ink, lighter orange) even when height and median tone match. So build every reload cell on a hand-made figure: base = the sibling's hand-made reload cell (`rivet_reload_pistol*.png` for one-hand guns; the closest two-hand hand-made reload for electro if it is two-hand), with only the gun and the magazine he swaps replaced (scripted composite of the gun's own held/mag art, or image_gen EDIT under a mask limited to the gun + magazine). Never regenerate the body. Disclose per cell "built on <file> cell <k>, edited <regions>". Metric gate as 6b: `cell_metrics` height, helmet ratio, bbox aspect and mean L*/C* within threshold of the base cell; plus a director sheet (base cell | new cell, bbox-cropped, same scale) per weapon and pitch.
