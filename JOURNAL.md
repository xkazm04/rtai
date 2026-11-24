# JOURNAL lane keys, run n28 (2026-11-24 16:40 to 00:40)

- 16:27 START iteration 1. Branch n28-keys at d0ab9d03a. No builder lock, no builder-calls.jsonl yet. IMAGES 0/60.
- 16:33 DECISION keys-dash: dash.cooldown_ticks 40 -> 24. Dash 10 ticks + 24 = a 34-tick press-to-press cycle, under the
  36-tick shortest gap between two troopers' rockets (n27-pressure REPORT section 2: 36 to 49 ticks after 10 s in seeds 3, 5),
  with 2 ticks of margin for the reaction and any off-by-one in when the cooldown starts. Rejected 26 (cycle exactly 36, no
  margin) and 20 (spammable faster than needed). The alternative is the one data value.
- 16:28 BUILDER RUNNING n28-01-dash since 16:28 (node pid 26160, out evidence/briefs/n28-01-dash.out)
- 16:33 Briefs drafted while the dash call runs: n28-02-homing-shard (sheet-sized edit test, legs-kept composite, cap 10
  images), n28-04-gloria-brass (concept + strips + held art, cap 12), n28-05-collar-p55 (edit + collar-only composite, cap 8).
  Gloria's own grid (part B) waits for the homing shard route verdict. The p55 run sheet audit by eye: rows 1, 2, 5, 6, 7 draw
  the collar as rope or a knotted scarf; rows 0, 3, 4 read rigid.
- 17:37 BUILDER n28-01-dash 69 $0.59 accepted (partial: value, test, decision line committed; full suites, after trace and
  mutate not run, every Godot launch waited on mem-budget from 16:44).
- 17:37 MILESTONE keys-dash 64004a59d (dash.cooldown_ticks 40 -> 24; measured shortest press to press 34 ticks by
  test_shortest_press_to_press_gap_is_burst_plus_cooldown_and_covers_a_rocket_pair; evidence 38d76f7f7).
- 17:37 FRICTION mem-budget 53 (the builder's Godot runs waited from 16:44 to 17:37; cap status 7132/8192 MB used at 17:37,
  peak 9082). git show also failed once: "packfile cannot be mapped: File too large" (memory pressure).
- 17:38 BUILDER RUNNING n28-02-homing-shard since 17:38 (node pid 11896; out evidence/briefs/n28-02-homing-shard.out).
  Brief: Part 0 = the dash checks (focused unit select + after trace, 15 min max), then the homing shard test (sheet-sized
  edits of the plasma rifle walk/run, legs-kept composite, ship only if all 16 rows pass; commit by 18:35, END 18:52).
- 17:40 NEXT: (1) when n28-02 ends (lock gone): read its report and diff, look at grid_homing_shard_64.png myself
  (hands on the weapon, rigid collar, no extra limb, sole travel = donor); log BUILDER line. (2) If it shipped: brief the
  next four weapons in the route it recommends (two weapons per call if each took < 30 min; mini-nuke, molotov, plasma
  sword, ray gun), image budget 60 - used. If it failed: decide per-row edits for the homing shard only if the images left
  allow Gloria (12) + collar (8). (3) Gloria brass brief ready: evidence/briefs/n28-04-gloria-brass.md ({COMMIT1},
  {COMMIT2}, {END} placeholders); collar brief ready: n28-05-collar-p55.md ({COMMIT}, {END}). Gloria's own grid (part B)
  brief not written yet: same route as the weapons, donor = the pistol's p70 walk/run sheets, then flip
  walk_grid.by_weapon.gloria. (4) Dash film with two troopers still owed (pressure_dash_trace after column, a 32 px/m clip).
  (5) Watch the RAM cap (GTAI_CAP_STATUS): at 17:37 it was 7.1/8.2 GB used; every Godot waits.
  Last new work committed by 22:40, final gate started by 22:55.
