# n31 melee 02p2 part 4 - mutate melee_sweep.gd (tree da4797e05)

Command: `node tools/mutate/mutate.mjs --file=project/features/player/melee_sweep.gd --max=12 --tests=test_melee_sweep` (--max=12, not 20: the 23:15 stop; baseline green in 214 s, ~25 s a mutant).

Result line: `score 33.3% = killed 4 / (killed 4 + survived 8); timeout 0, invalid 0; 555 s`

```
  features/player/melee_sweep.gd:33 arith  - -> +  survived
  features/player/melee_sweep.gd:48 cmp_flip  != -> ==  survived
  features/player/melee_sweep.gd:55 literal  1.0 -> 0.0  survived
  features/player/melee_sweep.gd:55 literal  2 -> 3  survived
  features/player/melee_sweep.gd:55 arith  - -> +  survived
  features/player/melee_sweep.gd:55 literal  1.0 -> 0.0  survived
  features/player/melee_sweep.gd:104 boolean  true -> false  survived
  features/player/melee_sweep.gd:112 delete  out.put_8((1 if hit_any else 0) | (2 if tested else 0) | (4 if closed else 0)) -> pass  survived
  features/player/melee_sweep.gd:34 literal  0.12 -> 1.12  killed
  features/player/melee_sweep.gd:75 literal  0.5 -> 1.5  killed
  features/player/melee_sweep.gd:77 arith  - -> +  killed
  features/player/melee_sweep.gd:91 boolean  false -> true  killed
score 33.3% = killed 4 / (killed 4 + survived 8); timeout 0, invalid 0; 555 s
```

Survivors are open: window()'s first tick (line 33), track()'s idle key (48), drawn()'s side/arc literals (55), close()'s whiff flag (104) and write()'s flag byte (112) have no test that pins them; the next call adds those tests.
