# kill reel

`node tools/film/kill_reel.mjs --out=build/kreel/s6feel --weapons=claw_shock,rocket_launcher --dirs=0 --ppm=32 --after=600 --feel=on --rev=76ae91d45 --native=donor`

| weapon | side | victim | dir | px/m | outcome | kill | freeze (frames, measured) | pieces wait (row ticks) | settled | aftermath | aftermath curve (measured) | whole |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| claw_shock | after | guard | 0 | 32 | PASS | 127 | 6 | 4 (claw_throw) | +600 | 0.9 % | +20 4.8 / +40 4.8 / +80 2.1 / +150 2.1 / +300 2.1 / +600 0.9 %, stays past +600 | - |
| rocket_launcher | after | guard | 0 | 32 | PASS | 68 | 8 | 0 (rocket_gib) | +40 | 5.5 % | +20 28.3 / +40 5.8 / +80 5.9 / +150 5.9 / +300 5.9 / +600 5.5 %, stays past +600 | - |
