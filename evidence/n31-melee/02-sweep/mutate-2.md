# n31 melee 02p3 part 5 - mutate melee_sweep.gd after the survivor tests (tree 14e34dcf6)

Command: `node tools/mutate/mutate.mjs --file=project/features/player/melee_sweep.gd --max=20 --tests=test_melee_sweep,test_melee_sweep_arc`
(lane lock held; temp worktree `gtai-mutate-612737eb` removed after).

Result line: `score 75.0% = killed 15 / (killed 15 + survived 5); timeout 0, invalid 0; 690 s` (02p2: 33.3 %, 4 / 12).

New tests (`project/tests/unit/test_melee_sweep_arc.gd`): the cut window's first and last tick pinned on two
hits, the state byte carries each of its three flags (8 sets -> 8 states), the side alternates, a sweep cut
short owes its whiff once; plus the drawn-arc clamp per weapon, the plasma's undrawn flank missed, and the
saw's first bite.

Survivors (open):
```
  features/player/melee_sweep.gd:41 boundary  >= -> >  survived      (cuts(): the window's first tick, inclusive)
  features/player/melee_sweep.gd:41 boolean  and -> or  survived     (cuts(): both ends)
  features/player/melee_sweep.gd:86 boundary  >= -> >  survived      (crosses(): half >= PI, full circle)
  features/player/melee_sweep.gd:86 boundary  <= -> <  survived      (crosses(): the sector's exact edge)
  features/player/melee_sweep.gd:126 delete  out.put_32(swing) -> pass  survived   (write(): the swing key)
```
Next: a cuts() test on tick window.x - 1 / window.x / window.y + 1, and a write() test that two sets differing only
in `swing` give different states.
