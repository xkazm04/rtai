# Ohm spectral p70 left

## References

1. `masters:n20/concepts/ohm_c.png`
2. `masters:n6/ghost-forms/gen/r4/out/ohm_parts.png`
3. `project/features/souls/art/view/p70/ohm_act.png`

## Prompt

Image 1 is the character to match: OHM, the Lightning Rod, a stooped old robot wizard who is a floating teal spectre: cracked round goggles, a short bristly cable-wire beard, riveted shoulder plates over a long ragged insulating coat of rubber sheets whose hem frays into teal mist and a few loose wires, NO LEGS AND NO FEET, three big glass capacitor jars in a row on his back joined by curling hoses, and in his right hand a tall staff (his own right hand in every cell: when he faces left the staff is on the far side of his body from the viewer in the toward row and on the near side in the away row) that is a lightning rod ending in a FORKED tip of two copper prongs. Image 2 shows the ink, fill and print style of our game sprites: match that style, not its robot. Image 3 shows the layout of our character sheets: three rows, one per facing direction, the same figure in every row.

Draw a character sprite sheet of OHM: a grid of 6 columns and 3 rows of equal cells, one full figure centred alone in each cell with green margin all round, every figure the same size and the same scale, all seen from a camera high above and in front, looking down at 70 degrees (a steep top-down three-quarter view: the top of the head, the shoulders and the tops of the three jars are clearly visible, the coat is foreshortened).

Rows, top to bottom: row 1, he faces three-quarters toward the viewer and to the LEFT; row 2, left side profile, facing LEFT; row 3, three-quarters away from the viewer and to the LEFT (we see his back and the jars).

Columns, the same in every row: column 1, hovering idle: stooped, the staff held upright beside him in his right hand, the coat hanging still into its misty hem; column 2, drifting forward: leaning forward from the waist, the staff held out ahead of him at an angle like a walking stick whose foot hangs just above the ground, the coat hem and beard streaming backwards; column 3, charged: standing tall, the staff raised high overhead in his right hand, the forked copper tip pointing up; column 4, the thrust: lunging forward, both hands on the staff, thrusting it straight out ahead at shoulder height, the forked tip foremost; column 5, recovery: hunched, pulling the staff back across his chest, the coat swinging forward; column 6, struck: thrown backwards off balance, head tipped back, the staff swinging away from him, the coat hem flaring forward.

In every cell the insides of the three glass jars on his back are painted flat solid magenta (#FF00FF), an even placeholder colour with no glow and no shading, only inside the jar glass, wherever the jars can be seen from that angle. The hem of the coat ends in short ink-outlined teal wisps about a third of his height below the coat and never touches the bottom of the cell; there is nothing under him.

Style: a sprite sheet for a shipped top-down action game, in a hand-inked comic print style: bold black brush-ink outlines around every shape, flat and lightly shaded fills, light cross-hatching, a hint of risograph print grain. Match the ink and fill of image 2, not its character. The background of the whole sheet is one flat, even chroma green (#00B140): no shadow, no gradient, no ground, no floor glow, nothing drawn on the green. The figure is a translucent glowing TEAL (#2EC4B6) spectre lit from within, the black ink linework visible through the glow, faint worn steel and rust inside it; only the two copper prongs of the staff keep their own copper colour. Every edge of the figure, including the misty hem, is closed by a bold black ink outline, so it stands cleanly off the green. Original design. No text, no letters, no numbers, no labels, no grid lines, no borders, no watermark.

## Take review

- Take 1, rejected. In the toward-left row the charged pose turns its goggles back toward screen-right. The staff also jumps across the body between drift and charged.
- Take 2, rejected. The toward-left idle and charged cells keep the far hand on the pole, and the jar bank reads clearly in the away row. In away idle, drift and charged, the near hand hangs open while the far hand still holds the pole. The 64 px/m comparison also shows the toward and away thrusts pointing almost horizontally across the screen.
- Take 3, rejected. The toward-row idle and charged poses hold the rod on screen-left, then the struck pose grips it on screen-right with the other arm. The near hand is open again in away idle.

The spectral renderer keeps the existing mirror. The raw sheets are `masters:n20/verdicts/ohm_left/ohm_spec_p70_left_t1.png` through `ohm_spec_p70_left_t3.png`. The comparison at `masters:n20/verdicts/ohm_left_vs_mirror_p70.png` shows take 2 beside the shipped cells and their mirrors, using the shipped coat-height calibration and empty jars.
