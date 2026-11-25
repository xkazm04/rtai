# current_look.gd mutate, n30 call 08

Tests: `test_collect_call_current`. Commit 5fd6c1ea (seams `CurrentLook.k_of`, `CurrentLook.ANTIALIAS`; drawn output identical:
`draw()` runs the same `1.0 / maxf(0.01, scale)` expression via `k_of(ci)` and passes `true` via `ANTIALIAS`).

Before (n29, `evidence/n29/mutate/current_look.md`): 15/20, 5 survivors, all in `draw()`.

After, lines 13, 51, 52, 57, 60 (max 8): **killed 4 / (killed 4 + survived 1) = 80.0 %** (timeout 0, invalid 0).

| line | mutant | result |
|---|---|---|
| 57 | `scale = 1.0` -> `0.0` | killed |
| 60 | `1.0` -> `0.0` | killed |
| 60 | `/` -> `*` | killed |
| 60 | `0.01` -> `1.01` | killed |
| 52 | delete `ci.draw_polyline(..., ANTIALIAS)` -> `pass` | survived |

The `true` -> `false` antialias mutant became a constant change (line 13), pinned by `test_current_is_drawn_antialiased`
(not sampled under `--max=8`). The surviving line-52 delete needs a pixel readback, impossible with the headless dummy renderer;
not a new gap (the draw call was never observed headless).
