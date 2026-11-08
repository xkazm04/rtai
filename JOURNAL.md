# JOURNAL: night n10, lane world

MILESTONE [21:05] Session opened (runner calls it iteration 4; this worktree had no JOURNAL and no commits past c394af55, so nothing was lost from earlier iterations: start at item 1).

## Reading the frames
- d10/block70 h05 (half height): the wall band is a dark squashed strip. The p70 strip is 4 storeys cut to 768x297 and drawn over a 76 px wall: every storey about 19 px tall, windows squat.
- Heights after height_k 0.5: shop 4.25-5 m, tenement 6.5-8 m, tall 8.5-10.5 m, so canvas wall (32 px/m, lift_k/ground_k) about 49-121 px.

## Item 1, the wall art at half height
- Tool `tools/art/city_facade_storeys.py` cuts the r2 elevations into upper + ground storey rows (bay 256 px wide, native aspect). `FacadeStoreys` stacks them from the ground, as many upper storeys as fit. Tenement 2 storeys at 76-93 px, tall ground + upper rows, shop one storey.
- FRICTION: the machine is badly contended (a plain `--import` passed 200 s and was killed; grep over project/tests times out).

MILESTONE [21:45] Item 1 done (aadc7430): half-height walls stack whole storeys. Filmed at 32 and 48 px/m, lint 15/15, the three selected unit files green. DECISION world/half-height-storeys.
MILESTONE [21:47] Item 2 first fix: the "fallen lamp" is the game's own pole shadow (`ChunkLift.draw` shadow path), not the test scene. cast_m 0.7, no blob. DECISION world/pole-cast-short.

## Item 2 audit so far (from the block70 stills at 32 px/m; NOT yet measured)
- Lamp post CARD is still a stub about one person tall: a 5 m post should stand well over the people. Needs art.
- Still to check: parked cars at the kerb, kerb furniture, fire escape (`props` has no row: stays flat), roof edges, contact shadows.

REQUEST 1 -> assets: a tall street lamp for the true 70-degree camera, 5 facings on one strip like `project/features/city/art/view/p70/prop_lamp_post.png` (the same five facings and the same order, foot at the cell's bottom centre, transparent ground), tall thin post about 3 x a person's drawn height, one arm with a dome head, grey-print ink look; size about 900 x 640 for the strip. Reference: that strip and `C:\Users\kazda\kiro\gtai-masters\n10\world\lamp_cast_32_after.png` for the stub it replaces.

FRICTION [21:50] A long assert line failed gdformat, so the pre-commit hook refused the shadow-fix commit while the outer command still exited 0. Check `git log` after every commit here.

NEXT: (1) Finish the item 2 audit by measured gap (parked cars, kerb furniture, fire escapes, roof edges, contact shadows); the lamp card waits on REQUEST 1. (2) Item 3 the dead: `StreetDeadPlan.draw` (`project/features/characters/street_dead_plan.gd:101`) rotates a plan pose freely (`blow.angle() - head + jitter`). Restrict that to a small set of screen headings picked from the blow's screen direction, drop the free jitter there, keep n9's spread, mirror the same rule in `street_quest_dead_plan.gd`. Judge which headings read right at 70 from stills first, then REQUEST poses drawn for this camera; research the classic three-quarter-RPG corpse techniques before fixing the set. (3) Item 4 movement angle. Gates still owed: full unit run, scenarios, parity, evidence run, director reel x3.

---- session 22:10 (iteration 8) ----
MILESTONE [22:12] Shadow fix landed after the hook refusal (20c868c6). Lint 15/15 in the hook.

## Item 2 audit (real city, combo, block70 focus, 32 px/m; this session's still `gtai-n10/tmp/world/audit/now32_t200.png`)
Looked at by eye in one still, NOT measured; "biggest first" here means by share of the screen and how plan the thing reads.
| what | state at combo | verdict |
|---|---|---|
| roofs and roof gear (tanks, vents, solar) | drawn straight down, covers most of the screen | biggest plan read left; needs new art, cannot be fixed in code: Call |
| lamp post card | foot and globe still read from above, a stub about one person tall | REQUEST 1 still open |
| fire escape | `props` has no row, stays flat | not seen in this frame; not counted yet |
| parked cars | cards, windscreen and side show | stands, no gap seen |
| kerb furniture (bin, payphone, hydrant, bollard, box) | cards | stands, no gap seen |
| contact shadows | props and cars hatch down-right; bodies had none | the dead get one now (item 3) |

## Item 3 research (the dead)
Two web searches. What they confirmed: death art is drawn per facing from the game's own camera (8 directions typical, 16 at most), frozen on the last frame, and the shadow is a separate layer or a plain ellipse. What they did NOT reach: how any shipped isometric game seats its corpses or sorts them under the living; that part is my reasoning, not a source.
Applied: (1) a corpse is never turned to a free angle: few headings, picked by the blow's screen octant; (2) no head toward the camera (the upside-down face was the worst read); (3) a separate shadow layer, the pose's own silhouette, down the city's sun direction. The art is still PLAN poses, so this is the code half: poses drawn for this camera are REQUEST 2.

REQUEST 2 -> assets: the dead for the true 70-degree camera, one sheet per body class as `dead_plan_v1` (same 13 classes + contractor, same 5 poses A-E, same cell 384 x 384, pelvis at the cell centre, transparent, no blood), redrawn so the body is seen from a camera 20 degrees off straight down: the side of the torso and limbs nearest the viewer just visible, feet toward the viewer, head away. Head toward the top for A-D, head right for E (the headings the game now uses; it mirrors, it never turns E). Reference: `project/features/characters/art/view/plan/dead_ped_suit.png` and `C:\Users\kazda\kiro\gtai-n10\tmp\world\audit\dead_crop.png`. ped_suit first as a test of the look.

## Item 4 movement angle: first read (code trace only, nothing filmed or measured yet)
- Vehicles: the trace found no wheel animation at all (cards move rigidly), so no wheel drift to fix there; the atlas art itself was not inspected.
- Walkers and Rivet: the walk phase advances by ground distance and the card is drawn unsquashed, so the camera squashes foot art and displacement together: the view's ground_k adds no drift by itself.
- Facings are 8 octants (5 drawn, 3 mirrored); a run off an octant snaps to the nearest, up to 22.5 degrees off, so the feet stride along the drawn octant and sidestep the true path. Not measured on film. Suspected cheap residual: only `RUN_ROW_K` corrects the non-profile rows, walks have no per-row factor (up to about 6 % at 70 by arithmetic, unconfirmed).
- `rivet_walk` MAX_CYCLES_S 2.0 lets feet slide by design between about 1.8 and 2.5 m/s.
