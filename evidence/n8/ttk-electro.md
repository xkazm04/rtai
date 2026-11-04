# Electro gun TTK, tap vs held charge (range model, 24 trials a cell, iteration 9)

The range model (RangeDrill / ProjectileSim) now holds a charge gun when the lane asks
(`hold_charge`) and lands the charged round's `charge_damage`, like GunHand in the real fight.
`ttk.json` carries `electro_gun` (clicked, as before: every one of its cells is identical to
`evidence/n6/ttk.json`) and the new `electro_gun:charged` (held on). Median s (kill rate).

| target | mode | 5 m | 10 m | 20 m |
|---|---|---|---|---|
| human still | tap | 0.62 (100%) | 0.73 (100%) | 1.00 (100%) |
| human still | held charge | 1.20 (100%) | 1.32 (100%) | 1.58 (100%) |
| human strafing | tap | 1.65 (100%) | - (0%) | - (0%) |
| human strafing | held charge | 2.30 (96%) | 4.60 (100%) | 4.83 (33%) |
| robot still | tap | 5.62 (100%) | 5.75 (100%) | 6.00 (100%) |
| robot still | held charge | 4.45 (100%) | 4.58 (100%) | 4.83 (100%) |

Read: two plain taps drop a still human faster than one charged bolt (the tap, the cooldown and
0.6 s of charge). The charge pays off against a strafer past 5 m (0 -> 100 % at 10 m: the fat
charged bolt is the one that lands) and against robots. Owner call gunplay-10: keep the taps
lethal on humans (default), or make a plain bolt stun-only on humans (damage 0 on the human row)
so the charged one-shot is the only electro kill.
