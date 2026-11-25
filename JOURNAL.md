# JOURNAL lane foes (run n31, 2026-11-25 night)

## Session 1 (20:56)
- 20:57 read AGENTS, git log (HEAD ba8e470b0 = main), other lanes' journals: no NEED foes.
- 21:10 BUILDER b1-waiting (opus) launched: item 1 probe + tools/gauntlet/waiting.mjs + BEFORE on main. Brief evidence/briefs/b1-waiting.md. Lane Godot lock: build/n31/godot.lock.
- 21:00 (clock check: b1 actually launched 20:59) BUILDER b2-gait (opus) launched: item 2 two movement types (FoeGait, fight_speed_k 0.45, danger_m 4, min mode 0.6 s, settle 0.25 s, --foe-moves=legacy|split). Brief evidence/briefs/b2-gait.md. Told b1 to measure BEFORE in a --rev temp tree at ba8e470b0 since b2 edits the live tree.
- DECISION foes: items 1 and 2 built in parallel (disjoint files, shared lane Godot lock build/n31/godot.lock) to get the long items started early; item 2 is not called done before item 1's play take exists.
- 21:44 BUILDER b1-waiting 45 accepted. BEFORE (ba8e470b0, wheel, seeds 1-10): average idle share 89 % (in range 86 %), react in range p50 1.05 / p90 6.15 s, any-dist 3.37 / 8.72 s, never fired 173/569, firing/s mean 1.02 (max 4) with 6.4 ranged alive, token share 25 %, dmg waves 1-4 12.5/10.6/22.6/17.2; novice idle 91 %, dmg 17.5/16.1/33.6/26.5. evidence/n31/foes/waiting-main/waiting.md. MILESTONE item 1 numbers.
- FINDING: the idle share counts the cooldown between bursts as idle (assault rifle: burst ~0.27 s, cooldown 0.61 s), so even a non-stop shooter scores ~65-70 % idle: the <35 % bar needs an "in a fire cycle" definition (fired within burst + cooldown + 0.1 s). To fix in the item 3 measurement brief; report both.
- 21:46 BUILDER b3-takes (opus) launched: play_take scene + tools/gauntlet/play_takes.mjs, waves 1/3/6 main|HEAD sides. b2 still running (2 commits in: a4a7a3537, 09d6abdba).
