# Bare-hands tracer and stacked-pick counter

At tick 306 of seed 7, patrol cop 9 fired a small assault-rifle round while Rivet had hands equipped. The new frame shows an amber rim around a pale-gold core. The full-size frame contains 25 pixels of each tracer colour, `#e08a1e` and `#ffe6a8`. All 63 changed pixels lie within the round's 11 × 8 pixel bounds. [Original still](<C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/rounds-hands-before-32.png>) · [New still](<C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/rounds-hands-after-32.png>) · [4× before and after](../../build/street/crop/hands-pair-2.png)

The original capture driver reproduced the 1920 × 1080 frame at 32 px/m, 70° tilt, and screen point (1080.065, 559.1787). Both captures recorded state hash `10be94993ec996f010945aab44e46eb13990219938b2113134fb024713962a4a`. [Capture log](../../build/street/brief06/capture.log)

| Commit | Change |
| --- | --- |
| `cc205aac9` | `ShotDraw.bare` uses the gun tracer's 9.0 rim and 4.0 core widths for enemy rounds. The fallback in `FxView._shots` calls it. Rivet's round uses its original 4.0 ink line. |
| `25c5addbe` | Appended the four supplied gauntlet decisions to `docs/decisions.md`. |
| `a51a6b1b9` | Added one assertion for the first stacked offer in `test_gauntlet_pick_view.gd`. |

The pick-view test checks the first offer's index and total directly after three stacked waves clear. Its existing caption check follows the player through all three offers. The archived survivor was line 145, the reset of `owed_total`. The requested mutation changes the reset of `owed_index` on line 146. [Archived mutation log](../../build/street/mutate-progress.log)

## Checks

- The seed-7 average bot finished ten waves at tick 11474 before and after the rendering change. `cmp` exited 0 for the two 7,372-byte result files. Both have SHA-256 `dd403c5e28824601477efd6d9e24fc6532317500c11a22ccbd482523da9f471e`. [Before](../../build/street/brief06/seed7-before.json) · [After](../../build/street/brief06/seed7-after.json)
- The scenario suite matched the previous run at 65 passed, 0 failed. The 60-second replay finished 3,600 ticks and all 60 checkpoints with digest `cbeb734ff9b97c41`. [Scenario log](../../build/street/brief06/scenarios.log)
- `node tools/gate/quick.mjs` passed on both rendering files and on the pick-view test. [Rendering check](../../build/street/brief06/quick-0.log) · [Test check](../../build/street/brief06/quick-b.log)
- `node tools/tests/run_unit.mjs --changed` selected the full fast suite. GUT reported 3,642 passed, 0 failed and 2 skipped. [Unit results](../../build/street/brief06/unit-changed.log)

The capped mutation runs write each verdict and the final score to its own log. [Counter](../../build/street/brief06/counter.log) · [Composer](../../build/street/brief06/composer.log) · [Shot drawing](../../build/street/brief06/shot.log) · [Shove zone](../../build/street/brief06/shove.log) · [Offer eligibility](../../build/street/brief06/draw.log)
