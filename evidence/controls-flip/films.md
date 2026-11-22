# Quest 1 and arena control films

The two wheel films and their 32 px/m stills use `7847148d9`. The legacy take uses `979ca87d0`, and the separate 64 px/m arena take uses `9f47d79a7`. The two wheel films omit the controls flag. The comparison passes `--controls=legacy`. Each film uses D3D12, 1920 × 1080, 60 fixed frames per second, tilt 70 and 32 px/m. Frame numbers below start at zero.

## What the game shows

Quest 1 starts on hands. Its first story gun comes from Brass’s dialogue. Its first physical pickup is a contractor’s rifle at Dock 9. The dev driver advances the existing quest pad through the intervening travel and dialogue, re-taps the semi-auto trigger in the Dock 9 fight, then walks Rivet to the first drop and presses Use. Its scrolls use the mouse event bound to `weapon_next` through `LiveInput`. The quest supplies the loot and draws its own HUD.

The pickup and the wheel update run at different points in the tick. `project/boot/collect_call/stage_actions.gd` passes the use press to `CombatArena.grab_rifle`, which equips the rifle. On the following tick the wheel follows the equipped weapon. A regular `WeaponPickups` floor item uses a different path and stays stowed under wheel controls. Quest 1’s shipped rifle pickup therefore cannot demonstrate the requested stowed pickup.

The readout opens at simulation tick 0. It holds full opacity through tick 36, fades over the next 24 ticks and disappears at tick 60. A cycle press restarts the timer even when Hands is the only entry. Quest 1 opens with Hands alone. The arena opens with Hands highlighted above its carried pistol.

## Films and stills

All filenames in the tables resolve under `C:/Users/kazda/kiro/gtai-masters/n23/controls/`. Each film command below follows `node build/b5-films/capture.mjs`. The encoding and still commands follow the runner source below.

| File | Capture arguments | Length and frames | Verbatim film.log status |
|---|---|---|---|
| `quest1_wheel.mp4` | `quest1_wheel --rev=HEAD` | 24.083 s, 1,445 | `# exit 0, 142.2 s` |
| `arena_wheel.mp4` | `arena_wheel --rev=HEAD` | 16.183 s, 971 | `# exit 0, 94.9 s` |
| `quest1_legacy.mp4` | `quest1_legacy --rev=HEAD` | 12.017 s, 721 | `# exit 0, 73.4 s` |
| `wheel_hands_64.png` source take | `wheel_hands_64 --rev=HEAD` | 16.183 s, 971 | `# exit 0, 94.2 s` |

The dev verdicts are quoted in take order.

```text
ok exit 0; SCRIPT ERROR 0; unknown arg 0; flags checked: 2 against KNOWN_FLAGS (res://dev/controls/quest_opening_film.gd)
ok exit 0; SCRIPT ERROR 0; unknown arg 0; flags checked: 4 against KNOWN_FLAGS (res://dev/controls/arena_opening_film.gd)
ok exit 0; SCRIPT ERROR 0; unknown arg 0; flags checked: 3 against KNOWN_FLAGS (res://dev/controls/quest_opening_film.gd)
ok exit 0; SCRIPT ERROR 0; unknown arg 0; flags checked: 4 against KNOWN_FLAGS (res://dev/controls/arena_opening_film.gd)
```

| Still | Source frame | What is visible |
|---|---:|---|
| `quest1_wheel_opening.png` | Quest 271 | Factory Row, 31 frames after the card. Hands is the sole highlighted entry beside the weapon ticket. |
| `quest1_wheel_hands.png` | Quest 829 | After holstering Brass's gift, Hands is highlighted and Gloria is listed below. |
| `quest1_wheel_approach.png` | Quest 1060 | Rivet approaches on hands. The Dock 9 objective prompts him to grab the rifle with E. |
| `quest1_wheel_pickup.png` | Quest 1096 | The pickup has already selected Assault Rifle. Rivet has yet to scroll again. |
| `quest1_wheel_select.png` | Quest 1375 | A manual scroll has returned to Assault Rifle. The muzzle flashes with 29 rounds left. |
| `arena_wheel_hands.png` | Arena 30 | Rivet stands at the range entrance. Hands is highlighted above the dimmed Pistol entry. |
| `arena_wheel_select.png` | Arena 621 | The first pistol muzzle flash and the Pistol highlight share the frame. |
| `wheel_hands_64.png` | Arena at 64 px/m, 877 | Rivet is empty-handed after holstering. Hands is highlighted above the carried pistol. |
| `card_wheel.png` | Title 4 | The four-line desktop card at the original 1280 × 800. Movie writer reported `5 frames at 60 FPS`, exit 0. |

## Film timeline

**Quest 1, default wheel**

| Film frames | Simulation ticks | Action |
|---|---|---|
| 0–239 | Before the first tick | Hold the wheel help card for four seconds. |
| 240–719 | 0–479 | Start with Hands highlighted, then let the opening readout fade. Primary is held on ticks 110–154 for three swings. Two quick claws follow on ticks 205 and 277. Rivet walks toward the first objective. |
| 720–1029 | 8379–8689 | The quest pad plays through to Brass handing Rivet Gloria, which equips immediately. Scroll to Hands at frame 815, back to Gloria at 907 and fire at 958. |
| 1030–1083 | 13270–13324 | The second travel cut ends at the first contractor drop. Scroll to Hands and approach the rifle. |
| 1084–1085 | 13325–13326 | Use equips the assault rifle while the wheel still reports Hands. On the next tick the wheel highlights Assault Rifle. |
| 1179–1444 | 13420–13685 | Scroll to Hands at frame 1179, Gloria at 1254 and Assault Rifle at 1329. Fire at 1374, 1389, 1404, 1419 and 1434. |

**Arena, default wheel.** The range opens on Hands at tick 0, with Hands highlighted and the carried pistol listed below. Rivet walks at tick 45, holds primary on ticks 270–379 and taps quick claw at 422. Seven hits land. The scroll at tick 580 draws the pistol. It fires at 620, 655, 700, 745, 790 and 825. The scroll at tick 864 holsters the pistol and highlights Hands. Film frames and simulation ticks coincide.

**Quest 1, legacy.** Frames 0–239 show the legacy card. The same opening inputs run from frame 240 through 719. At frame 395 the primary press has produced zero swings. At frame 530 the two quick claws have produced two. Frame 720 ends the take on Factory Row.

## Verification and changes

The quest and arena each reported zero hidden body-frames. I reviewed consecutive-frame contact sheets covering all 1,445 quest frames and 971 arena frames in the replacement films. I also inspected the opening at full opacity, the fade boundary and the selected stills. The legacy film retains its earlier review. Each delivered gameplay still matches its indicated source frame pixel for pixel. FFprobe confirmed H.264 at 1920 × 1080 and 60/1 fps with AAC audio in all three masters. Godot logged resource leaks during shutdown. The quest also logged a ghost-sheet asset warning. The master index contains 15 entries and all named media and before-image references resolve.

At `755ff6c26`, `node tools/tests/run_unit.mjs --changed` ran the full suite and reported 3,649 passed, zero failed and two skipped. The opening fade test checks ticks −1 through 61 and both cycle directions with Hands alone. The pilot HUD test now expects the readout at tick 1. The wheel stores the scroll tick alongside its existing switch tick, outside replay serialization. Reviewing quest frame 240 revealed a one-frame delay when the HUD was attached mid-frame. Commit `7847148d9` applies the same opacity before the first draw. A new test covers attachment at ticks 0, 48 and 60. The final changed suite reported 3,650 passed, zero failed and two skipped.

The three scenario runs passed. Their complete serialized tapes matched the captures from before the wheel change.

| Scenario | Ticks | Final state digest | SHA-256 of replay file, before and after |
|---|---:|---|---|
| `replay_60s` | 3,600 | `cbeb734ff9b97c41645f735114692ea3b9e7cc6578750f32d8d9f31d69844e85` | `73e204a23a6b82a9fcc2cfcf0bc2f025e647b1a0001c86df9499099510d318ed` |
| `quest1_input` | 19,024 | `37bf8deacaad2f480055af695e77aa9296bb08c4f6b681c57344832333d4664a` | `20561e3c8181bf05eca4cc61610fe651bd139399d196ac2f7f24dfcbb4a2391a` |
| `rivet_deflect` | 2,400 | `4352a44470140d68f6ba237fb842cfb9745b557caefca284a81da77f039fd7ae` | `e733e3db2a689694c3a482f4110a9f2870b0b23032214c1d51e76108372a26b4` |

The deflect scenario keeps its tape in memory. An inspection script saved the log passed into its replay check, then called the original check. The other two files came directly from the scenarios. On the changed readout lines at `755ff6c26`, mutation testing killed 8/(8+0) (`--lines=29,31`). On the additional draw callbacks at `7847148d9` it killed 2/(2+0) (`--lines=30,34`). Both runs used `node tools/mutate/mutate.mjs --file=features/player/wheel_readout_view.gd --max=20 --tests=test_wheel_readout_fade`.

The quest card and its unit test changed at `dda3339d4`. The existing `SLICE__CONTROLS_WHEEL` and `SLICE__CONTROLS_WHEEL_PAD` keys resolve their source through `QuestText`. Their English strings live in `project/boot/quest1_controls_text.gd`. Gamepad weapon cycling uses Back (button 4 on `weapon_next`, defined at line 292 of `project/data/tables/input_actions.json`). The GUT inventory correction is in `evidence/controls-flip/tests.md` at `95b58b7dc`.

The previously staged guard scene, script and UID landed at `b2c15d2f3`. The quest and arena opening scenes, scripts, shared input helper and UIDs under `project/dev/controls/` landed at `9f47d79a7`. The opening walk visibility change landed at `979ca87d0`. Both dev-line increases used the debt tool to update `tools/debt/baseline.json`.

- `node tools/tests/run_unit.mjs --changed` ran the full suite. The runner reported 3,648 passed, zero failed and two skipped. GUT marked one of the counted passes risky because it made no assertion.
- `node tools/tests/run_scenarios.mjs --only=replay_60s,rivet_pickup,rivet_switch,quest1_input` passed all four scenarios. The 3,600-tick replay ended at `cbeb734ff9b97c41`.
- `node tools/mutate/mutate.mjs --file=boot/quest1_controls_text.gd --max=20 --lines=15-19,24 --tests=test_quest1_card` found no eligible mutations on the changed string lines, so their score is undefined (0/0). Repeating with `--lines=42` killed 1/(1+0) on the existing glyph resolver branch.

## Reproduction

Run from the controls worktree at the filmed commit. Set the lane environment in PowerShell.

```powershell
$env:APPDATA='C:/Users/kazda/kiro/gtai-n23/appdata/controls'
$env:GODOT_BIN='C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe'
```

The stock `film.mjs quest1` entry records even-tick stills. The stock arena reel chooses the sidearm before its gun beat. For the custom scenes, the capture command uses the same `--rev=HEAD` resolver from `tools/film/film.mjs` and the checked entry runner from `tools/dev/run.mjs`. Godot’s movie writer records the rendered viewport and audio. The runner writes each full launch command, exit status and game log to `build/b5-films/<take>/film.log`.

Save the following as `build/b5-films/capture.mjs` to repeat the capture.

```js
import { copyFileSync, existsSync, mkdirSync, readdirSync, readFileSync, symlinkSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { basename, join, resolve } from 'node:path';
import { parseArgv, pinRev } from '../../tools/film/film.mjs';
import { main as dev } from '../../tools/dev/run.mjs';
import { describe, runGodot } from '../../tools/lib/godot.mjs';

const [take, rev] = process.argv.slice(2);
const valid = ['quest1_wheel', 'arena_wheel', 'quest1_legacy', 'wheel_hands_64'];
if (!valid.includes(take) || !rev?.startsWith('--rev=')) throw Error('supply a take and --rev=HEAD');
const {flags} = parseArgv([rev]);
const pinned = pinRev(flags);
if (pinned.error) throw Error(pinned.error);
console.log(pinned.line);
// Movie Maker sizes its writer from project.godot. Mount the pinned files in build/,
// as tools/film/ghost_films.mjs does, with only the two capture dimensions overridden.
const source = join(flags.tree, 'project');
const stage = resolve('build/b5-films', basename(flags.tree) + '-1080');
const project = join(stage, 'project');
mkdirSync(project, {recursive:true});
for (const f of readdirSync(source, {withFileTypes:true})) {
  const src = join(source, f.name), dst = join(project, f.name);
  if (existsSync(dst)) continue;
  if (f.isDirectory()) symlinkSync(src, dst, 'junction');
  else copyFileSync(src, dst);
}
const config = readFileSync(join(source, 'project.godot'), 'utf8');
writeFileSync(join(project, 'project.godot'), config
  .replace(/viewport_width=\d+/, 'viewport_width=1920')
  .replace(/viewport_height=\d+/, 'viewport_height=1080'));
const dir = resolve('build/b5-films', take);
mkdirSync(dir, { recursive: true });
const arena = take === 'arena_wheel' || take === 'wheel_hands_64';
const entry = arena ? 'arena_opening_film' : 'quest_opening_film';
const args = [entry, '--windowed', '--timeout=1100', '--view=tilt70',
  '--ppm=' + (take === 'wheel_hands_64' ? 64 : 32),
  ...(arena ? ['--loadout=pistol', '--clean'] : []),
  ...(take === 'quest1_legacy' ? ['--controls=legacy'] : [])];
const movie = join(dir, take + '.avi');
const runner = async (args, opts) => {
  if (args.includes('--import')) return runGodot(args, {...opts, cwd: flags.tree});
  const full = ['--windowed', '--rendering-driver', 'd3d12', '--position', '0,1440',
    '--resolution', '1920x1080', '--write-movie', movie, ...args];
  console.log('godot --path project ' + full.join(' '));
  const res = await runGodot(full, {...opts, cwd: stage});
  writeFileSync(join(dir, 'film.log'), pinned.line + '\n# ' + full.join(' ') + '\n# ' + describe(res) + '\n' + res.out);
  return res;
};
process.exitCode = await dev(args, {runner, projectDir: source, logDir: dir});
if (process.exitCode === 0) {
  const stream = JSON.parse(execFileSync('ffprobe', ['-v','error','-select_streams','v:0',
    '-show_entries','stream=width,height,avg_frame_rate','-of','json',movie])).streams[0];
  if (stream.width !== 1920 || stream.height !== 1080 || stream.avg_frame_rate !== '60/1')
    throw Error('Movie Maker wrote ' + JSON.stringify(stream));
}
```

```powershell
node build/b5-films/capture.mjs quest1_wheel --rev=HEAD
node build/b5-films/capture.mjs arena_wheel --rev=HEAD
node build/b5-films/capture.mjs quest1_legacy --rev=HEAD
node build/b5-films/capture.mjs wheel_hands_64 --rev=HEAD
```

## Encoding and frame extraction

In PowerShell, `$masters` is the delivery directory. The stills below are whole decoded frames at the source resolution. The three MP4s retain the game audio. The 64 px/m still comes from a separate render of the same arena inputs.

```powershell
$masters='C:/Users/kazda/kiro/gtai-masters/n23/controls'
foreach ($take in @('quest1_wheel','arena_wheel','quest1_legacy')) {
  $avi="build/b5-films/$take/$take.avi"
  ffmpeg -y -loglevel error -i $avi -map 0:v:0 -map '0:a?' -c:v libx264 -threads 4 -preset fast -crf 16 -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart "$masters/$take.mp4"
}
function Still($film,$frame,$name) {
  ffmpeg -y -loglevel error -i $film -vf "select=eq(n\,$frame)" -fps_mode passthrough -frames:v 1 "$masters/$name.png"
}
Still "$masters/quest1_wheel.mp4" 271 quest1_wheel_opening
Still "$masters/quest1_wheel.mp4" 829 quest1_wheel_hands
Still "$masters/quest1_wheel.mp4" 1060 quest1_wheel_approach
Still "$masters/quest1_wheel.mp4" 1096 quest1_wheel_pickup
Still "$masters/quest1_wheel.mp4" 1375 quest1_wheel_select
Still "$masters/arena_wheel.mp4" 30 arena_wheel_hands
Still "$masters/arena_wheel.mp4" 621 arena_wheel_select
Still "build/b5-films/wheel_hands_64/wheel_hands_64.avi" 877 wheel_hands_64
```

The replacement `card_wheel.png` uses the original title scene, desktop canvas and capture position. Its still is frame 4 of a five-frame 1280 × 800 title run at `dda3339d4`.

```powershell
$cardDir=(New-Item -ItemType Directory -Force build/b5-films/card).FullName
& $env:GODOT_BIN --path project --rendering-driver d3d12 --position 0,1440 --resolution 1280x800 --fixed-fps 60 --write-movie "$cardDir/wheel.png" --quit-after 5 res://boot/quest1.tscn -- --view=tilt70
Copy-Item "$cardDir/wheel00000004.png" "$masters/card_wheel.png"
```

## Guard film (1080p)

The gameplay take is `guard_pose.mp4` at 32 px/m. The close-up is `guard_pose_64.mp4` at 64 px/m. From the controls worktree, use the lane environment above and a separate PNG sequence for each take.

```powershell
$b8 = Join-Path (Get-Location) 'build/dev/b8'
& $env:GODOT_BIN --path project --windowed --rendering-driver d3d12 --position 0,1440 --resolution 1920x1080 --audio-driver Dummy --fixed-fps 60 res://dev/controls/guard_pose_film.tscn -- "--out=$b8/32" --ppm=32 --view=tilt70 --movie --size=1920x1080 --seconds=20
& $env:GODOT_BIN --path project --windowed --rendering-driver d3d12 --position 0,1440 --resolution 1920x1080 --audio-driver Dummy --fixed-fps 60 res://dev/controls/guard_pose_film.tscn -- "--out=$b8/64" --ppm=64 --view=tilt70 --movie --size=1920x1080 --seconds=20
foreach ($ppm in 32,64) {
  $film = if ($ppm -eq 32) { 'guard_pose' } else { 'guard_pose_64' }
  ffmpeg -framerate 60 -start_number 1 -i "$b8/$ppm/t%04d.png" -frames:v 1200 -c:v libx264 -threads 4 -preset fast -crf 16 -pix_fmt yuv420p -movflags +faststart "$b8/$film.mp4"
  ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,pix_fmt,avg_frame_rate,duration,nb_frames -of compact=p=0 "$b8/$film.mp4"
}
```

```text
guard_pose.mp4    codec_name=h264|width=1920|height=1080|pix_fmt=yuv420p|avg_frame_rate=60/1|duration=20.000000|nb_frames=1200
guard_pose_64.mp4 codec_name=h264|width=1920|height=1080|pix_fmt=yuv420p|avg_frame_rate=60/1|duration=20.000000|nb_frames=1200
```

| Beat | Simulation tick | MP4 frame (zero-based) |
|---|---:|---:|
| Guard starts to rise | 60 | 59 |
| Guard held, arms crossed at the start of the eight-facing turn | 120 | 119 |
| Ninth deflection breaks the meter and Rivet staggers | 646 | 645 |

The guard drops at tick 420 and rises again at 480. The volley starts at 510. After the break, Rivet recovers to standing with guard down through tick 1200. I inspected all six decoded stills in `build/dev/b8/`. Rivet stays centered in both takes, with the guard meter below him and no dialogue covering the action. Both captures exited 0 with the same stage tape. Godot logged a ghost-sheet warning during setup and resource leaks at shutdown.
