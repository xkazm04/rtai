# kill reel

`node tools/film/kill_reel.mjs --out=build/kreel/s6long --weapons=rocket_launcher --dirs=0 --ppm=32 --after=1000 --rev=76ae91d45 --native=donor`

| weapon | side | victim | dir | px/m | outcome | kill | freeze (frames, measured) | pieces wait (row ticks) | settled | aftermath | aftermath curve (measured) | whole |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| rocket_launcher | after | guard | 0 | 32 | PASS | 68 | off (feel off) | 0 (rocket_gib) | +1000 | 1.6 % | +20 28.3 / +40 5.8 / +80 5.9 / +150 5.9 / +300 5.9 / +600 5.5 / +1000 1.6 %, stays past +1000 | - |
