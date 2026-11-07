# Handheld ledger (lane `handheld`, d9, 2026-11-07)

The owner's ask: "Possibilities to port into steam deck or similar frame devices like nintendo switch
for now only on this PC simulator." There is no device here. **Every number below is "on the
simulator"** (this PC under a device profile), never a device claim. Real hardware is bought only
if the game is finished.

## 1. Research digest (sources inline; researched 2026-11-07)

Lines marked *(model knowledge)* were not checked against a source.

### Steam Deck hardware
- APU: Zen 2, 4 cores / 8 threads, 2.4-3.5 GHz; GPU 8 RDNA 2 CUs at 1.0-1.6 GHz (1.6 TFLOPS FP32); APU power 4-15 W. [steamdeck.com/tech](https://www.steamdeck.com/en/tech), [LCD spec PDF](https://cdn.steamstatic.com/steamdeck/images/press/techspecs/steamdeck_techspecs.pdf)
- 16 GB LPDDR5 shared (5500 MT/s LCD, 6400 MT/s OLED); the GPU has 1 GB reserved by default (BIOS UMA frame buffer, max 4 GB) and SteamOS moves more on demand. [Windows Central](https://www.windowscentral.com/gaming/pc-gaming/how-to-increase-vram-on-steam-deck)
- Screens: LCD 7" 1280x800 16:10 60 Hz; OLED 7.4" 1280x800 up to 90 Hz HDR. Batteries 40 Wh / 50 Wh. [spec PDF](https://cdn.steamstatic.com/steamdeck/images/press/techspecs/steamdeck_techspecs.pdf), [tech](https://www.steamdeck.com/en/tech)
- Quick access menu: refresh slider 40-60 Hz (LCD); frame limiter 1:1, 1:2, 1:4 of the refresh (60/30/15 or 40/20/10); a TDP limit and half-rate shading. [BoilingSteam](https://boilingsteam.com/steamos-3-2-introduces-flexible-refresh-rates-for-the-steam-deck), [SDHQ](https://steamdeckhq.com/tips-and-guides/the-sdhq-performance-settings-encyclopedia/)

### Steam Deck Verified (Valve's criteria, [partner.steamgames.com/doc/steamdeck/compat](https://partner.steamgames.com/doc/steamdeck/compat))
- **Input:** "your game must support Steam Deck's physical controls"; "The default controller configuration must provide users with the ability to access all content"; no in-game setting needed to turn the pad on; "On-screen glyphs must match the inputs being used"; text entry through the Steamworks on-screen keyboard (`ShowGamepadTextInput` / `ShowFloatingGamepadTextInput`, [ISteamUtils](https://partner.steamgames.com/doc/api/ISteamUtils)) or the game's own.
- **Display:** a supported resolution (1280x800 / 1280x720); "the smallest on-screen font character should never fall below 9 pixels in height at 1280x800", 12 px recommended.
- **Seamlessness:** no device warnings; any launcher fully pad-navigable (discouraged).
- **System:** runs under Proton or native; anti-cheat and some codecs are the usual blockers.
- Recommendations ([recommendations](https://partner.steamgames.com/doc/steamdeck/recommendations)): Vulkan "for best performance and battery life"; per-device graphics settings kept out of Steam Cloud; other aspect ratios; offline single-player; prompts do not flip to keyboard glyphs unless the mouse is really used.
- Suspend/resume: no published developer rule found; Valve made suspend a core feature ([TweakTown](https://www.tweaktown.com/news/80659/steam-decks-suspend-and-resume-feature-was-top-priority-for-valve/index.html)).

### Proton vs a native Linux build (Godot 4)
- Godot supports the Deck through its standard Linux export templates. [Godot consoles doc](https://docs.godotengine.org/en/4.5/tutorials/platform/consoles.html)
- Our Windows build renders on D3D12 (`rendering_device/driver.windows="d3d12"`); under Proton that runs through vkd3d-proton (D3D12 -> Vulkan) [vkd3d-proton](https://github.com/HansKristian-Work/vkd3d-proton). A native Linux export (Vulkan) or a Windows build with `driver.windows=vulkan` skips the translation *(model knowledge)*.
- Native target: Steam Linux Runtime 3.0 "sniper" (build in the sniper SDK container) [container-runtime.md](https://gitlab.steamos.cloud/steamrt/steam-runtime-tools/-/raw/de82a412b3dd1eb8d5fd9e9d7542d82fe8907ec0/docs/container-runtime.md). The CitySim GDExtension `.so` must be built on a glibc no newer than the runtime's ([Godot: compiling for Linux](https://docs.godotengine.org/en/latest/engine_details/development/compiling/compiling_for_linuxbsd.html)); a GDExtension is tied to the Godot minor version it was built for.
- Godot does **not** precompile 2D pipelines ("The engine does not currently feature precompilation for 2D elements") [pipeline_compilations](https://docs.godotengine.org/en/latest/tutorials/performance/pipeline_compilations.html): our WLD-07 prewarm (draw everything once behind the loading screen) is what covers it, and matters more on a Deck's first run (empty shader cache).
- Godot 4.5 moved gamepad input to SDL3 ([4.5 beta 2](https://www.linuxcompatible.org/story/godot-45-beta-2-released)); Steam Input shows the Deck to the game as an Xbox-style pad *(model knowledge)*.
- Steam: one depot per OS, a password beta branch first, 64-bit Linux. [platforms](https://partner.steamgames.com/doc/store/application/platforms)

### Godot knobs for a handheld
- Renderers: Compatibility "Low base cost, but high scaling cost"; Mobile medium/medium; Forward+ "Highest base cost, and low scaling cost" [renderers](https://docs.godotengine.org/en/latest/tutorials/rendering/renderers.html). Measured below (E1).
- 2D resolution: stretch `viewport` renders at the base size and scales up (cheaper); `canvas_items` renders at the screen's; `scaling_3d` does nothing for 2D. [multiple_resolutions](https://docs.godotengine.org/en/latest/tutorials/rendering/multiple_resolutions.html)
- `Engine.max_fps` "reduces power consumption" [Engine](https://docs.godotengine.org/en/latest/classes/class_engine.html); `--gpu-index` picks the adapter on Forward+/Mobile [CLI](https://docs.godotengine.org/en/latest/tutorials/editor/command_line_tutorial.html).
- Suspend: `NOTIFICATION_APPLICATION_PAUSED/RESUMED` are Android/iOS only; desktop gets `NOTIFICATION_APPLICATION_FOCUS_OUT/IN` [Node](https://docs.godotengine.org/en/latest/classes/class_node.html). A Deck suspend freezes the process without telling it *(model knowledge)*: on resume the first frame's delta is the whole sleep, and our `SimClock` already clamps it (the dropped seconds are counted; no catch-up spiral).

### Pad families, glyphs and rumble (researched iteration 4)
- Godot has no `get_joy_type()` (a proposal, [godot-proposals#8519](https://github.com/godotengine/godot-proposals/issues/8519));
  `Input.get_joy_info()` returns `raw_name`, `vendor_id`, `product_id` (desktop), `xinput_index` (Windows) and
  `steam_input_index` only for a Steam Input device ([Input.xml mirror](https://git.objectionable.solutions/Sara/api_tester/raw/branch/development/engine/doc/classes/Input.xml));
  the SDL driver had lost those keys and got them back in Aug 2025 ([patch](https://remotebranch.eu/Stowage/godot/commit/f28acf97d0de82a4e0f2b5ab9cc281603d0ea101.patch)).
  So the family is the USB vendor id (Sony 0x054C, Nintendo 0x057E) with the name as a fallback.
- SDL has `SDL_IsJoystickSteamDeck` and a Steam-virtual-gamepad check ([SDL_joystick_c.h](https://cocalc.com/github/godotengine/godot/blob/master/thirdparty/sdl/joystick/SDL_joystick_c.h)):
  under Steam Input a game sees an Xbox-style virtual pad whatever is in the player's hands, so the right glyph for a
  PlayStation pad on a Deck needs the Steam Input API (`GetGlyphForActionOrigin`, via the Steam backend): owed.
- Rumble on the Deck: the kernel's hid-steam got XInput-style rumble emulation in Jan 2023
  ([commit 9cd61c81](https://patchwork.kernel.org/project/linux-input/patch/20230126030126.895670-3-vi@endrift.com));
  SDL's Deck HIDAPI driver answers rumble "unsupported... use the full Steam Input API"
  ([SDL commit](https://cdn05042023.gitlink.org.cn/zinface/SDL/commit/41bf6b5a51d868061c767affbceea2d8735dcccd)); Steam Input
  forwarding rumble to opted-in pads was fixed in 2019 ([GamingOnLinux](https://www.gamingonlinux.com/2019/05/the-latest-steam-client-beta-fixes-rumble-support-on-linux-with-steam-input)).
  No source confirms `start_joy_vibration` reaching the Deck's motors through the virtual pad: **only a Deck can prove it**.

### Windows handhelds (by chip)
- Ryzen Z1 Extreme (Zen 4 8C/16T, 12 RDNA 3 CUs, 9-30 W) [Windows Central](https://www.windowscentral.com/gaming/pc-gaming/amd-ryzen-z2-series-leaks-alongside-the-steam-deck-2-asus-rog-ally-lenovo-legion-go-and-the-steam-deck-set-for-a-huge-boost); Ryzen Z2 Extreme (8C/16T Zen 5/5c, 16 RDNA 3.5 CUs, up to 35 W) [Tom's Hardware](https://www.tomshardware.com/pc-components/cpus/amd-announces-ryzen-z2-series-processors-for-handhelds-more-performance-better-efficiency-coming-soon); Intel Lunar Lake (Arc 140V) [gameranx](https://gameranx.com/updates/id/500265/article/msi-claw-8-ai-is-the-1st-windows-gaming-handheld-on-intels-lunar-lake/).
- Panels: 7" 1920x1080 120 Hz VRR, 8" 1920x1200 120 Hz, 8.8" 2560x1600 144 Hz. [Digit](https://www.digit.in/features/gaming/rog-ally-x-vs-legion-go-vs-msi-claw-8-ai-which-handheld-windows-gaming-pc-is-the-best-in-2025.html)
- They run the Windows build as it is; a controller-first full-screen shell on Windows 11 is now on all handhelds. [PCWorld](https://www.pcworld.com/article/2981446/xbox-fullscreen-experience-now-available-on-all-windows-handhelds.html)

### Nintendo Switch (2017) and its successor (2025): the budget and the path (no SDK touched)
- Switch: 4x Cortex-A57 at ~1.02 GHz, 3 cores for games; Maxwell GPU 307 MHz handheld / 768 MHz docked; 4 GB RAM (~3.2 GB for games, unofficial); 6.2" 1280x720. [GameSpot](https://www.gamespot.com/articles/nintendo-switch-specs-cpu-and-gpu-clock-speeds-rep/1100-6446363/), [SlashGear](https://www.slashgear.com/1495759/why-nintendo-switch-only-has-4gb-of-ram-explained), [Tom's Hardware](https://www.tomshardware.com/news/nintendo-releases-switch-console-specs,33519.html)
- Switch 2: 8x Cortex-A78C (6 for games, ~1.0-1.1 GHz measured); Ampere 1536 CUDA cores, 561 MHz handheld (1.71 TFLOPS); 12 GB LPDDR5X (9 GB for games); 7.9" 1920x1080 120 Hz. [TweakTown](https://www.tweaktown.com/news/105247/nintendo-switch-2-specs-confirmed-cpu-gpu-memory-and-restricted-performance/index.html), [TechSpot](https://www.techspot.com/community/topics/nintendos-full-switch-2-tech-specs-confirmed-nvidia-ampere-chip-with-1-536-cuda-cores-12gb-ram.292187)
- The path: Godot ships no console port ("legal liability, disproportionate cost, and open source licensing issues"); you need the platform holder's developer program (free registration at the Nintendo Developer Portal, docs after approval), NDAs, a legal entity, ratings per region; acceptance can take months. [Godot consoles](https://docs.godotengine.org/en/4.5/tutorials/platform/consoles.html), [Nintendo register](https://developer.nintendo.com/register)
- Engine port as middleware: W4 Consoles, Starter $800/yr per platform or $2,000/yr all (under $300k revenue), Pro $4,000 / $10,000; **lists Godot 4.4-4.6**; Switch 2 in beta since 2025-10-17 (needs a licensed developer with a dev kit). **This project is on 4.7**: ask before planning. [w4games.com/w4consoles](https://www.w4games.com/w4consoles), [W4 blog](https://www.w4games.com/blog/w4-games-news-1/w4-consoles-beta-support-for-the-nintendo-switch-2-87)
- Porting studios listed by Godot (port + publish, quote per project). [Godot consoles](https://docs.godotengine.org/en/4.5/tutorials/platform/consoles.html)
- CitySim on a console: no runtime-loaded `.dll/.so`, so the GDExtension is linked statically / built as an engine module with the platform toolchain for aarch64; **replay and parity determinism are proven on x86_64 only**: the SIM-05 replay and NAT-06 parity gates must be re-run on an ARM build (FMA contraction differs) *(model knowledge)*.
- Effort: 3-6 months per console platform (a non-Godot guide, [gamedo](https://gamedo-live.pages.dev/news/how-to-port-indie-game-consoles-2026)); a Deck-tuned game is the right starting point (W4 interview, [Automaton](https://automaton-media.com/en/interviews/godot-engines-key-figures-answer-a-developers-questions-about-everything-from-console-porting-and-user-support-to-ai-and-the-engines-future/)).

## 2. Device profiles (`project/data/tables/devices.json`, `--device=<id>`)

Read at boot by `DeviceProfile` (`core/platform/device_profile.gd`) through `LaunchArgs._ready`.
No flag = the `desktop` row, which applies nothing (the shipped game is untouched).

| id | window | cap | vsync | stretch | sim pin | sim GPU | what it stands for |
|---|---|---|---|---|---|---|---|
| `desktop` | - | - | - | - | - | - | the shipped game |
| `deck` | 1280x800 | 60 | on | canvas_items | 8 threads (4C/8T) | iGPU | Steam Deck at 60 Hz |
| `deck40` | 1280x800 | 40 | on | canvas_items | 8 | iGPU | the Deck's 40 Hz battery mode |
| `deck_bench` | 1280x800 | 0 | off | canvas_items | 8 | iGPU | headroom measure only |
| `handheld_1080` | 1920x1080 | 60 | on | viewport | 16 | iGPU | Windows handheld class |
| `switch_handheld` | 1280x720 | 30 | on | viewport | 3 | iGPU | a Switch-class budget (no SDK) |

## 3. The simulator (`tools/handheld/`)

- `node tools/handheld/sim.mjs --device=deck --scene=reel|city|king|servo [--ticks=1800] [--gpu=igpu|dgpu|<index>] [--threads=n] [--renderer=forward_plus|mobile|compat] [--no-device] [-- <arena args>]`
  - runs the dev arena (`res://dev/arena/arena.tscn`, the showcase build's scene) with the GUI exe through `Start-Process`, then sets `ProcessorAffinity` (the first n logical CPUs: 8 = 4 cores with SMT, a Deck) and `BelowNormal` priority;
  - renders on the CPU's own **AMD Radeon (RDNA2, 2 CUs, Godot device #1)** with `--gpu-index`: weaker than a Deck's 8 CUs, so a worst case. The image is copied to the monitor on the 4090 (a cross-adapter copy a Deck does not pay);
  - the frame log is the arena's `--frames=<json>` (FightFrames: wall, process, render CPU/GPU, draw calls), settled past the first second; `sample.ps1` samples CPU %, working set, private bytes and the GPU process memory counters once a second (and the affinity it really sees);
  - writes `evidence/sim/<label>.json` (`gtai.handheld-sim/1`), labelled `CONTENDED (n other Godot runs)` when the machine is shared.
- `node tools/handheld/ab.mjs --name=<exp> --rounds=3 --variant="<sim args>" ...`: interleaved rounds, the median per variant and the spread (max - min) as the noise.
- Tests: `node --test tools/handheld/sim.test.mjs`.
- Caveats (the simulator is not the device): Godot sizes its worker pool from the machine's 16 logical CPUs, not the affinity (a Deck makes 8); the 7800X3D's Zen 4 cores at ~5 GHz are ~2x a Deck's Zen 2 at 3.5 GHz per clock-and-IPC (*model knowledge*), so CPU numbers are optimistic and GPU numbers (2 CUs vs 8) pessimistic.

## 4. Experiments (A/B on the profile; medians over interleaved rounds, the spread is the noise)

| # | what | variants | result | verdict | commit |
|---|---|---|---|---|---|
| E0 | smoke: `deck` on the iGPU, reel 1200 ticks, 1 run | - | p50 16.64 ms (vsync 60), p99 23.4, render GPU 6.95 ms, private 986 MB, GPU shared 587 MB, CPU 4.2 % of the 8 pinned threads; CONTENDED (2 other Godot runs) | baseline | f356682c |
| E1 | renderer on the iGPU, `deck_bench` (uncapped), reel 1200 ticks, 3 interleaved rounds | Forward+ (shipped) / Mobile / Compatibility | Forward+: frame p50 7.45 ms (+-0.45), render GPU 6.69 (+-0.55), process 1.99, private 941 MB, GPU shared 587 MB. Mobile: 7.21 (+-0.38), GPU 6.34 (+-0.18), 925 MB. Compatibility: **ran on the RTX 4090** (the engine log: OpenGL picks the display's adapter, `--gpu-index` is Vulkan/D3D12 only), not comparable. All CONTENDED (1-2 other Godot runs) | **dropped**: Mobile's -5 % GPU is inside Forward+'s own spread, and a renderer switch risks the look (2D HDR, the print pass) for no measured win. The headline: the reel runs at ~134 fps uncapped on a 2-CU iGPU; a Deck has 4x the CUs | (no change) |
| E1b | Compatibility on the iGPU through a private exe copy (`gtai-d9x/handheld-godot/..._hh.exe`) with the Windows per-app GPU preference "power saving" (HKCU `DirectX\UserGpuPreferences`, that path only) | - | still the RTX 4090 (`adapter` in `evidence/sim/e1b-compat-igpu/compat-hh.json`): the preference steers DXGI, not the OpenGL ICD, on a desktop whose monitor is on the 4090 | **blocked on this PC**; owed: Compatibility on the iGPU through WSLg (Mesa's D3D12 Gallium driver can take an adapter by name) | - |
| E2 | suspend/resume on the simulator: `deck`, reel 1800 ticks, the process frozen with `NtSuspendProcess` 12 s after launch for 20 s (`--suspend=12:20`, `tools/handheld/suspend.ps1`), 1 run, quiet | - | the resume frame's wall time 20 057 ms; **the sim advanced 1 tick** over it (SimClock's clamp: no catch-up spiral, no fast-forward of the fight); the next frames 8.5 / 5.8 / 6.3 / 18.3 / 17.1 ms; exit 0, no SCRIPT ERROR (`evidence/sim/e2-suspend-deck-reel.json`) | **kept as evidence**: the game survives a Deck-style freeze today. Not measured: audio after the resume, a pad that reconnects. The game does not pause on focus-out (the Steam overlay): owed | ebcbf3e4+ |
| E4 | **the native Linux build as a SteamOS stand-in**: CitySim `.so` built in Valve's Steam Linux Runtime 3.0 "sniper" SDK container (Docker; glibc 2.31, g++ 10.3; `build/linux-so/`), `linux-showcase` export (292 MB, PCK embedded, + the 396 KB `.so`), run in WSL2/WSLg with `tools/handheld/wsl_run.sh` (`GALLIUM_DRIVER=d3d12`, `MESA_D3D12_DEFAULT_ADAPTER_NAME=AMD`), city course under `deck`, 1200 ticks, 1 run | - | boots, plays, exits; adapter "Mesa - Compatibility - D3D12 (AMD Radeon(TM) Graphics)"; frame p50 19.8 ms, p99 38.6, 20 frames > 33 ms, process 4.4 ms, 704 draw calls (`evidence/sim/e4-linux-wslg/compat-amd.json`). Without `GALLIUM_DRIVER` Mesa fell back to llvmpipe (CPU): p50 49.6 ms | **kept as the Linux path** (it builds, exports and runs). Not a renderer verdict: Compatibility through GL-on-D3D12 inside a VM, unpinned, is not a Deck's Vulkan. WSLg has no Vulkan-on-D3D12 ICD, so Forward+ on Linux is unmeasurable here | (this iteration) |
| E3 | zoom on a 7-inch 1280x800 panel: the city block under `deck` on the iGPU at 32 / 40 / 48 px/m, looked at side by side | 32 (shipped) / 40 / 48 | at 32 Rivet is ~25 px tall (~3 mm on the panel) and the cops are a blue cluster; at 48 the cops, the pedestrian, the cars and Rivet's silhouette read; 40 is between (`gtai-masters/d9/handheld/zoom-city-deck-*.png`) | **kept** (a look call, not a speed one): handheld rows carry `zoom_k` 1.5, applied to CameraRig's modes, quest 1's view and the dev arena (an explicit `--ppm` still wins); desktop `zoom_k` 1.0. Owner Call 1 | (this iteration) |
| E5 | the Deck's 40 Hz battery mode as a power proxy: city block (`--scene=city`, course bot), 1200 ticks, the iGPU, 8 pinned threads, 3 interleaved rounds (CONTENDED: 1-4 other Godot runs from other lanes, the bench lock held) | `deck` (60 cap) / `deck40` (40 cap) | frame p50 16.63 (+-0.04) vs 25.05 ms (+-0.10), both locked to the cap; render GPU per frame 9.12 vs 9.49 ms, so **GPU busy 55 % vs 38 % of each second (-31 %)**; pinned-CPU 5.81 % (+-0.22) vs 4.31 % (+-1.03): **-26 %**; RAM and GPU memory the same | KEPT as a mode (the `deck40` row, a battery option, not the default: 40 fps reads less smooth); busy time is a power proxy, not watts | 5be5495c (rows), `evidence/sim/e5e6-city/` |
| E6 | the zoom's cost: does showing 1/2.25 of the world (zoom_k 1.5) render cheaper? Same runs as E5, uncapped | `deck_bench` (zoom_k 1.5) / `deck_bench_z1` (zoom_k 1.0) | frame p50 9.55 (+-0.29) vs 9.56 (+-0.20); render GPU 8.91 (+-0.26) vs 8.88 (+-0.21); process 3.64 vs 3.78 ms: **no difference beyond the noise**. On the 2-CU iGPU the city frame is full-screen fill (ground, print grain, light), not the actor count | DROPPED as a speed lever; zoom_k 1.5 stays for legibility only (Call 1), it costs nothing | `evidence/sim/e5e6-city/e5e6-city.ab.json` |
| E7 | the Switch-class budget: `switch_handheld` (1280x720, 30 cap, **3 pinned threads**, the iGPU), the director reel and the city, 1200 ticks, 2 rounds (CONTENDED: 2-4 other Godot runs, bench lock held) | reel / city | the 30 cap holds: p50 33.35 / 33.29 ms, p99 36.8 / 37.1 ms; process (CPU frame work) 5.1 / 6.6 ms p50; render GPU 7.6 / 10.4 ms; private RAM 0.94 / 1.32 GB + GPU shared 0.58 / 0.94 GB: about 2.3 GB for the city, under the Switch's ~3.2 GB game share **on x86**. The CPU number says little: 3 Zen 4 threads at ~5 GHz against 3 Cortex-A57 cores at ~1 GHz is several times faster per core *(model knowledge: roughly 5-8x)*, so the city's 6.6 ms of frame work would be near or past the 33 ms budget on the 2017 console; the successor's A78C cores narrow that gap | a budget, not a verdict: the simulator cannot model an ARM core; the memory fits, the CPU is the risk | `evidence/sim/e7-switch-budget/` |

## 5. Controller-first play (audit 2026-11-07, `data/tables/input_actions.json`)

Godot JoyButton numbers: 0 A, 1 B, 2 X, 3 Y, 4 Back, 5 Guide, 6 Start, 7 L3, 8 R3, 9 LB, 10 RB, 11-14 d-pad; axes 0/1 left
stick, 2/3 right stick, 4 LT, 5 RT.

| action | keyboard | pad (before) | pad (now) | note |
|---|---|---|---|---|
| move | WASD / arrows | left stick + d-pad | same | |
| aim | mouse | right stick | same | push depth sets the throw reach (stick_deadzone 0.25) |
| fire | (mouse) | RT | same | |
| melee / handbrake | Space | X / B | same | |
| roll | Ctrl | B | same | B is roll on foot, handbrake driving |
| interact / car | E / F | A / Y | same | |
| sprint | Shift | L3 | same | the prompt had no L3 label: **added** |
| powers | Q / G | LB / RB | same | |
| weapon next | Tab | Back | same | weapon prev and slots 1-4: keyboard only (next cycles: all content reachable) |
| **radio next** | R | **Guide** | **R3** | Guide is a handheld's system button (Steam on a Deck; the overlay on a Windows handheld): unreachable. **Fixed** (1978ee79) |
| **reload** | R | **none** | **R3** | the gun reloads itself when empty; a manual reload had no pad button. **Fixed**: R3 is reload on foot and radio in the car, as R is on the keyboard |
| pause | Esc / P | Start | same | |

- Prompts: `ObjectiveHint` shows pad labels (A/B/X/Y, LB/RB, LT/RT, now L3/R3) when the pad was used last. They are
  **text labels, not glyph images**. Valve's rule is "glyphs must match the inputs being used": the A/B/X/Y layout
  matches a Deck and an Xbox-style pad. **Built (it4)**: `PadGlyphs` reads the first pad's family from
  `Input.get_joy_info` (vendor id; name fallback) and relabels the prompts under the handheld rows (PlayStation Cross /
  Circle / Square / Triangle, L1/R1/L2/R2, Create/Options; Nintendo layout B/A/Y/X, L/R/ZL/ZR, -/+). A Steam Input
  virtual pad reads as Xbox-style. Owed: glyph images, and a PlayStation pad behind Steam Input (the Steam API's origin
  glyphs).
- Rumble: was **none** in the game. **Built (it4)**: `HandheldRumble` (core/platform) on the Events bus, added by
  `LaunchArgs` when the device row sets `rumble` (every handheld row 1.0; desktop none): Rivet hit (0.3/0.8, 180 ms),
  a car strikes a person (killed 0.4/0.6, 160 ms; knocked 0.3/0.3, 100 ms), a tackle knock-down (0.5/0.2, 100 ms), a boss
  steps in (0.6/0.6, 500 ms), a hijack (0.3/0.1, 120 ms), the whispers spike (0.2/0, 400 ms); a weaker pulse never cuts a
  stronger running one. **Live check** (`--device=deck`, headless, the pulse count logged on exit): the King fight
  2400 ticks = **1 pulse** (the boss stepping in); the director reel 6000 ticks = **0**. Rivet's hits in the arena and
  the boss fights never reach the bus: `player_hit` is emitted only by quest 1's robo-tazer (`combat_arena.gd`) and the
  pit AI (`enemy_pit.gd`). Owed: `player_hit` at Rivet's damage chokepoint (every hit he takes), a blast and a car crash
  event, a settings toggle, and the feel on a real pad (no pad on this PC: unit-tested, never felt).
- Aim assist for twin-stick aim: not found. Owed (a design call for the owner: magnetism toward the nearest target in a cone).
- Menus and the dialogue: owed, a pad-only walk through quest 1's start, the settings panel and the dialogue box (iteration 2).
- On-screen keyboard: the game has no text entry today; nothing owed until it does.
- Pause on focus-out: **built** behind the handheld profiles (`HandheldFocusPause`, added by `LaunchArgs` when the row's
  tier is `handheld`): `NOTIFICATION_APPLICATION_FOCUS_OUT` (the Steam overlay, a Windows handheld's shell, alt-tab)
  pauses a live quest 1 run like the pause button; it never unpauses. Desktop unchanged (089afea8). Unit-tested on the
  no-run guard; owed: a live proof (a scenario that sends the focus-out to a running quest).

## 6. Text legibility at 1280x800

The project's base viewport is 1280x800 (`canvas_items` stretch), the Deck's panel exactly: the HUD draws 1:1 at its
authored sizes. Static read: `HudView` TEXT 30 / NAME 26 / WEAPON 24 px, `ObjectiveView` 24, `GhostFormHud` 18, theme
default 16 (the settings panel): the smallest em is 16 px, a cap height of about 11 px, **above Valve's 9 px minimum and
near its 12 px recommendation** (static read only; owed: a runtime probe over every Label and draw_string, and the stills).

## 7. Port readiness (filled as the loop goes)

| device | works on the simulator today | owed | only real hardware can prove | effort |
|---|---|---|---|---|
| Steam Deck | `--device=deck` (1280x800, 60 cap, vsync) and `deck40`; on 8 pinned threads + the 2-CU iGPU the reel runs vsync-locked 16.6 ms and ~134 fps uncapped (render GPU 6.7 ms); ~0.95 GB private RAM, ~0.6 GB GPU memory; the King fight and the city filmed at 1280x800; the native Linux build (sniper-SDK `.so`, `linux-showcase` export) runs the city in WSLg; a 20 s freeze resumes cleanly; focus-out pauses quest 1; the HUD's smallest text is above Valve's 9 px; every action on the pad (radio/reload fixed) | the Linux build's real Vulkan run (a Deck or a Linux PC: WSLg has no Vulkan-on-D3D12), a `just native` recipe for the sniper container build, NAT-06 parity on the Linux `.so`; or the Windows build under Proton with `driver.windows=vulkan` (D3D12 goes through vkd3d-proton); glyph images per pad type; rumble; a pad-only walk through menus/dialogue; pause on focus-out (the Steam overlay); a zoom call for the 7" panel; the settings menu's frame cap (40/60) | real frame times on Zen 2 at 4-15 W, battery hours, the shader cache's first run, Steam Input's default config, suspend/resume on SteamOS, the 90 Hz OLED | Linux build + Proton check: 2-3 days; Verified polish (glyphs, rumble, menus, focus pause): 3-5 days |
| Windows handhelds | `--device=handheld_1080` (1920x1080, stretch `viewport` = drawn at 1280x800 and scaled) | an A/B of `viewport` vs `canvas_items` at 1080p (E-next); the controller-first shell (launch and play with no mouse); Windows display scaling 125-200 % | the Z1/Z2/Lunar Lake drivers, VRR, TDP presets | 1-2 days on top of the Deck work |
| Switch-class | `--device=switch_handheld` as a budget only (1280x720, 30 cap, 3 threads, the iGPU) | everything: the platform holder's developer program, a dev kit, an engine port (W4 Consoles lists Godot 4.4-4.6, the project is 4.7), CitySim statically linked for aarch64, replay/parity re-proved on ARM, memory under ~3.2 GB (Switch) / 9 GB (successor) | all of it | 3-6 months per platform (a porting studio or W4 + our own work), $800-$10,000/yr middleware plus kits under NDA |
