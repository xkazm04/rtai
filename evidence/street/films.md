# Live gauntlet films

## Shield shove

[Watch the 15.60-second film](<C:/Users/kazda/kiro/gtai-masters/n23/street/wedge/shove-32.mp4>) · [64 px/m tell](<C:/Users/kazda/kiro/gtai-masters/n23/street/wedge/shove-film-64.png>)

Seed 7, average bot, wave 9, ticks 7425–8327 in one continuous shot. The camera holds beside the crossing. Two shield robots attack together at 4.933–6.283 s. Watch the surviving yellow-striped carrier just right of centre for the clearest pair. Its tell begins at **8.433 s** and the shove misses at **9.583 s**. It plants a new mark at **11.917 s** and hits at **12.967 s**.

| Film time | Frame | Sim tick | What is visible |
| ---: | ---: | ---: | --- |
| 9.217 s | 553 | 7963 | Last tick of the tell. The raised striped slab exposes a red strip aimed right and slightly up. Rivet has moved below its far end. The 64 px/m still catches this frame. |
| 9.567 s | 574 | 7978 | One lunge step remains. The slab has swung down over the strip, with Rivet's boots below its lower rail. The mark stays planted while the carrier advances. Rivet continues regenerating health through the miss on the next frame. |
| 12.333 s | 740 | 8138 | The same carrier has turned. A fresh strip points more steeply up and right, beneath the raised shield. The two figures are clear of the crowd at the crossing. Rivet has 125 health. |
| 12.967 s | 778 | 8176 | The slab reaches full extension, the red mark disappears and Rivet is knocked up and right. The HUD drops from 125 to 111. |

The frame trace puts the miss 0.67 m outside the side of the hit region, including Rivet's body radius. For each of these two shoves the carrier moved 0.40 m during the lunge. Adding the slab's 1.80 m reach to its final position puts the leading edge within 0.001 m of the tip marked at the tell. On screen those two tips are near (1010, 527) and (981, 492) respectively. The shield artwork partly covers the mark at full extension.

## Enemy rounds on hands

[Watch the 20.20-second film](<C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/rounds-32.mp4>) · [64 px/m still](<C:/Users/kazda/kiro/gtai-masters/n23/street/rounds/rounds-film-64.png>)

Seed 2, novice bot, wheel controls and random picks. Rivet has hands equipped on every included frame. The film opens on wave 1, ticks 291–912, and cuts at 11.333 s to wave 3, ticks 2085–2593. The second shot keeps the launcher and Rivet in the same frame. Trooper 29 fires twice. Its rockets are in flight at 15.567–17.067 s and 18.867–19.450 s.

| Film time | Frame | Sim tick | What is visible |
| ---: | ---: | ---: | --- |
| 1.233 s | 74 | 361 | The police fire from the right-hand crossing. A cream-tipped amber round has passed to the left of empty-handed Rivet over clear asphalt. Another is approaching from his right. |
| 10.600 s | 636 | 875 | Two rounds from cop 8 are visible together. One crosses the lower edge of the dark red pool, just above a fallen cop's cap. The other stands out against asphalt to Rivet's right. The still shows this volley at double the camera scale. |
| 16.200 s | 972 | 2360 | An ice-blue rocket heads down and right from the upper-left trooper, trailing a chain of blue-grey smoke puffs. A much smaller amber round is to its right. A fallen shield bearer and a blood pool lie below its path. |
| 19.133 s | 1148 | 2530 | The trooper has moved left. A second blue rocket crosses a dashed lane line toward Rivet at the lower right. Its white core, blue casing and smoke are visible against the asphalt. |

## Delivered files

| File under `C:/Users/kazda/kiro/gtai-masters/n23/street/` | Bytes | Verified content |
| --- | ---: | --- |
| `wedge/shove-32.mp4` | 41,635,683 | 936 frames, 15.600 s, 21.35 Mbit/s |
| `wedge/shove-film-64.png` | 4,180,805 | 1920 × 1080 PNG, tick 7963 |
| `rounds/rounds-32.mp4` | 49,262,112 | 1,212 frames, 20.200 s, 19.51 Mbit/s |
| `rounds/rounds-film-64.png` | 4,148,124 | 1920 × 1080 PNG, tick 875 |

Both H.264 masters decoded end to end at 1920 × 1080 and 60 fps. Each delivered file matched its inspected scratch file by SHA-256. For both stills, the tick, Rivet position, health, equipment state, active shoves and airborne rounds matched the corresponding 32 px/m movie frame.

## Capture and verification

Both films use the worktree's live gauntlet, fixed 60 Hz, `--pick-view`, D3D12, 70° tilt and a 1920 × 1080 window on the secondary display at (0, 1440). Both use the default wave timer. The bot controls all movement, attacks and picks. The scratch scene steps the session to the seek tick before attaching the regular view. The camera is the only gameplay-view setting changed for the close-ups. Frame numbers start at zero. Film time counts rendered frames, including combat hit-stop.

The capture project is the junction-based wrapper from [the stacking film](stacking-seeds.md). Its project settings differ from the worktree only in the initial viewport dimensions. The launch script, takes and per-frame traces are in `build/street/brief07/`. The scratch scene and its driver are `build/street/capture-project/street_film.tscn` and `street_film.gd`.

```powershell
$env:APPDATA='C:/Users/kazda/kiro/gtai-n23/appdata/street'
$env:GODOT_BIN='C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe'
$take='./build/street/brief07/take.ps1'
& $take -Take scout7normal -Seed 7 -Bot average -Frames 16500 -Scout
& $take -Take scout2 -Seed 2 -Bot novice -Frames 17500 -Scout
& $take -Take shove7 -Seed 7 -Bot average -Seek 7290 -Frames 1240 -Focus '307.7,0'
& $take -Take shove-still -Seed 7 -Bot average -Seek 7290 -Frames 1240 -Still 7963 -Focus '307.7,0'
& $take -Take hands -Seed 2 -Bot novice -Seek 242 -Frames 900
& $take -Take rocket -Seed 2 -Bot novice -Seek 1940 -Frames 860 -Focus '114,1'
& $take -Take rounds-still -Seed 2 -Bot novice -Seek 242 -Frames 1050 -Still 875
python build/street/brief07/cut.py shove-master shove7:150:1086
python build/street/brief07/cut.py rounds-master hands:48:728 rocket:149:681
```

The take script invokes Movie Maker with these arguments. The still runs use the same game scene, set the camera to 64 px/m, and save the viewport PNG after the requested tick draws.

```powershell
& $env:GODOT_BIN --path build/street/capture-project --fixed-fps 60 --log-file "$base.engine.log" --rendering-driver d3d12 --windowed --position 0,1440 --resolution 1920x1080 --audio-driver Dummy --write-movie "$base.avi" --quit-after $limit res://street_film.tscn -- --pick-view "--seed=$seed" "--bot=$bot"
```

The cut arguments are source name, first frame and exclusive end frame. FFmpeg trims at those frame boundaries and joins the shots at their original speed. The H.264 settings are `libx264 -preset slow -crf 19 -maxrate 24M -bufsize 32M`, with 4:2:0 limited-range BT.709 and MP4 fast start. The masters are silent.

I read four full-frame PNGs from each final encode alongside native-size details. These commands extract the eight review frames into `build/street/film-check/` and decode each master to its end.

```powershell
$b='build/street/brief07'
$q='build/street/film-check'
python "$b/inspect_frames.py" "$b/shove-master.mp4" "$b/shove7.jsonl" shove 7963 7978 8138 8176 --offset 150 --output $q
python "$b/inspect_frames.py" "$b/rounds-master.mp4" "$b/hands.jsonl" rounds-w1 361 875 --offset 48 --output $q --subject small
python "$b/inspect_frames.py" "$b/rounds-master.mp4" "$b/rocket.jsonl" rounds-w3 2360 2530 --offset -531 --output $q --subject rocket
foreach ($film in 'shove-master','rounds-master') {
    ffprobe -v error -count_frames -show_entries format=size,duration,bit_rate:stream=codec_name,width,height,pix_fmt,r_frame_rate,nb_read_frames -of json "$b/$film.mp4"
    ffmpeg -v error -xerror -threads 6 -i "$b/$film.mp4" -f null NUL
}
```
