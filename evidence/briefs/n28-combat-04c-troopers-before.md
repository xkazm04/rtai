# Brief n28-combat-04c: two troopers, the "before" arm by a data toggle, the table, the film

Lane `combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd), branch `n28-combat`.
Read `evidence/briefs/n28-combat-04-troopers.md` (Why, C, D, Checks, Repo law, Allowlist): this call does its parts A
(changed method, below), C and D. Part B (after) is DONE: `evidence/n28/troopers/after/{seeds/,dash_trace.json}`
(note: `dash_trace.json` holds markdown, not JSON; keep the name but say so in the table).

## A, by the director's DECISION 19:22 (the temp worktree at main segfaulted on import)
The before arm = this HEAD with `project/data/tables/rivet_motion.json` `dash.cooldown_ticks` set to 40 **uncommitted**
for the runs only: `git show d0ab9d03a:project/data/tables/rivet_motion.json > project/data/tables/rivet_motion.json`,
run, then restore at once with `git checkout -- project/data/tables/rivet_motion.json` and prove `git diff --quiet -- project/data/tables/rivet_motion.json`
(rivet_motion.json is the keys lane's file: read-only use, NEVER committed, never left modified; if anything fails, restore
first). It isolates exactly the dash change (bond/deflect commits do not touch the pressure takes). Runs (same as B):
`node tools/dev/run.mjs pressure_seeds -- --out=<abs evidence/n28/troopers/before/seeds>` and
`node tools/dev/run.mjs pressure_dash_trace -- --out=<abs evidence/n28/troopers/before/dash_trace.json> --seeds=1,2,3,4,5,6,7,8,9,10`.
Cross-check against n27's numbers (`evidence/n27-pressure/takes/seeds.md`, `dash_late.md`): seeds 3 and 5 should lose
~40 and ~50 HP; if they do not, say so loudly (the toggle would not reproduce main).

## C table, D film
As the 04 brief says. Same window for both arms (whole 25 s AND after 10 s). The film's before half is rendered with the
same toggle (restore after). Film/compare tool: `tools/gauntlet/pressure_films.mjs` or `tools/film/compare.mjs` (read
their headers). Look at the 64 px/m still pair yourself.

## Wall clock (binding)
**HARD STOP 20:40: report and END.** Commit the table + run outputs (evidence only, inert paths) by 20:30 (table first; the film after, by 20:38 or list it as left).
Rendered runs `GTAI_GODOT_EST_MB=1000`, headless 600. Before ending: `git diff --quiet -- project/data/tables/rivet_motion.json` must hold.
Commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.
