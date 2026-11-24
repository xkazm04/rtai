# Brief n27-02b `floor-glow` (resume of warm-light): the warm pools as floor light under the actors

HARD STOP: 05:22 local (stop work, write the report, END). LAST COMMIT: 05:17. Commit the glow by 05:10. Check `date` often.
Same environment, allowlist, forbidden list and repo law as `evidence/briefs/n27-02-warm-light.md`. The schema enum change you made is accepted (yard-owned table's schema).

## Verdict on call 02
Accepted as a measured step (tool, numbers, frame cost, films), but the owner's pick is NOT met yet: in `light_before_after_32ppm.png` the after row is barely warmer, the mid-yard pools are invisible, the gate lamp pool is weaker than before, and the hall front spills bands of amber onto the black void north of the hall. Your finding explains it: the light layer tints actors too, so amber strong enough to read turns the cops purple. Keep the actor-side light where it is now (it passes the bars).

## The task: add the warmth on the FLOOR, under the actors
In `project/boot/prologue/**` (yard-owned; never `project/core/**` or `project/features/**`), give the dressing a floor glow: for each pool of the `line_fire` row, draw a soft warm radial glow as part of the ground (z below every actor, prop shadow and cover art that stands on the floor is fine either way; actors must not be touched by it), additive or screen-like blend (`CanvasItemMaterial.BLEND_MODE_ADD` or a premultiplied radial gradient texture built once at load: a `GradientTexture2D` fill radial is fine, it is light, not art). Data in the row: per kind a `floor_glow` object (`color`, `radius_m`, `strength`) so it can be tuned or switched off (`strength` 0 = off, the actor light unchanged); extend the schema. Then:
1. Fire pools: the glow reads as a large warm amber pool on the floor at 32 px/m (radius about 10 to 12 m, the warm core about 3 to 4 m), visibly brighter and warmer than the floor between pools; the mid-yard fires (arm cable, burnt pickup, scrap skip, conveyor tail) visible as pools.
2. Lamps: a clear warm pool under each lamp, the gate lamp at least as visible as in the BEFORE frame.
3. Nothing lights the void: clip the glow to the floor (the yard rect, or skip any glow pixel outside the drawn ground); the hall-front actor light spill onto the black void north of the hall: if it comes from the pool kinds you set, pull those pools' centres or radius so it stays on the floor, or say why it cannot.
4. Ground shade stays 0.81. The mood comes from the light: say in numbers how much warmer and brighter the floor is inside a fire pool core vs between pools (mean L* and mean hue/chroma of floor pixels with actors masked out), before and after.
5. Bars re-measured with your paired tool (`evidence/yard27/dusk_contrast.py`): patrol blue >= 65 % outside and inside a pool, hue 200 to 250 in a pool, rifle >= 100 %, pellet >= 90 %. A floor glow raises the floor's luminance behind a cop: if a bar drops, lower that kind's `strength`, not the actor-light rows.
6. Seed-7 pilot end tick 11701 unchanged (render only). Frame cost: one paired round is enough if it is drawn once (a few sprites); three if you used a shader.
7. A unit test that the glow nodes exist per pool, sit under the actor layer's z, and vanish at `strength` 0.
8. Re-render `evidence/yard27/light_before_after_32ppm.png` as THREE rows (n26 HEAD `cc99f1dbc` light | call 02 light | floor glow) at the same gate, mid, front ticks, and the master `light_mid_32ppm_before_after.mp4` replaced by n26-vs-glow (keep its frames.json entry, update its note), `light_front_64ppm.png` re-rendered. LOOK at every frame and name what you see.
9. `node tools/gate/quick.mjs` green, commit per part. Mutate if you changed a `.gd` under `project/boot/prologue`: `node tools/mutate/mutate.mjs --file=<it> --max=20 --lines=<changed>` (skip it after 05:12, say so).

## Report (final message, then END)
Commits, the glow values, floor warmth numbers, the bar table, what you saw in each frame, ffprobe line, seed-7 end tick, frame cost, what was not done.
