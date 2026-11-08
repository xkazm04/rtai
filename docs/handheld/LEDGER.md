# Handheld ledger (lane `handheld`, d9 2026-11-07, extended n9 2026-11-08)

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
- **SteamOS Compatible** (researched n9 it2): since May 2025 (with the first third-party SteamOS handheld) Steam shows a
  pass/fail "SteamOS Compatible / Unsupported" label for non-Deck SteamOS devices: the game and all its middleware
  (launchers, anti-cheat) must run on SteamOS, native or under Proton. It is derived from the Deck review with no extra
  testing, and a Deck rating gives an equal or better SteamOS label; it says the game runs, not how well. So the Deck
  review is the one gate for every SteamOS handheld; their speed is still ours to budget (the `handheld_1080` row).
  Sources: [PCWorld](https://www.pcworld.com/article/2780157/valves-new-steamos-compatibility-ratings-go-beyond-the-steam-deck.html),
  [Windows Central](https://www.windowscentral.com/gaming/steam/valve-steamos-compatibility-system-for-non-steam-deck-devices-legion-go-s),
  [Engadget](https://engadget.com/gaming/valve-made-a-steam-deck-verified-program-for-things-that-arent-steam-decks-224535134.html).

### Proton vs a native Linux build (Godot 4)
- Godot supports the Deck through its standard Linux export templates. [Godot consoles doc](https://docs.godotengine.org/en/4.5/tutorials/platform/consoles.html)
- Our Windows build renders on D3D12 (`rendering_device/driver.windows="d3d12"`); under Proton that runs through vkd3d-proton (D3D12 -> Vulkan) [vkd3d-proton](https://github.com/HansKristian-Work/vkd3d-proton). A native Linux export (Vulkan) or a Windows build with `driver.windows=vulkan` skips the translation *(model knowledge)*.
- Native target: Steam Linux Runtime 3.0 "sniper" (build in the sniper SDK container) [container-runtime.md](https://gitlab.steamos.cloud/steamrt/steam-runtime-tools/-/raw/de82a412b3dd1eb8d5fd9e9d7542d82fe8907ec0/docs/container-runtime.md). The CitySim GDExtension `.so` must be built on a glibc no newer than the runtime's ([Godot: compiling for Linux](https://docs.godotengine.org/en/latest/engine_details/development/compiling/compiling_for_linuxbsd.html)); a GDExtension is tied to the Godot minor version it was built for.
- Godot does **not** precompile 2D pipelines ("The engine does not currently feature precompilation for 2D elements") [pipeline_compilations](https://docs.godotengine.org/en/latest/tutorials/performance/pipeline_compilations.html): our WLD-07 prewarm (draw everything once behind the loading screen) is what covers it, and matters more on a Deck's first run (empty shader cache).
- Godot 4.5 moved gamepad input to SDL3 ([4.5 beta 2](https://www.linuxcompatible.org/story/godot-45-beta-2-released)); Steam Input shows the Deck to the game as an Xbox-style pad *(model knowledge)*.
- Steam: one depot per OS, a password beta branch first, 64-bit Linux. [platforms](https://partner.steamgames.com/doc/store/application/platforms)

- **Cross-save between a Deck and a PC (it14)**: Steam Auto-Cloud names one root per path; WinAppDataRoaming is
  `%USERPROFILE%\AppData\Roaming\`, LinuxXdgDataHome is `$XDG_DATA_HOME/` (Godot's `user://` on Linux is
  `~/.local/share/RTAI Uprising`, seen in WSL). Valve's advice: one root (the Windows one) plus a Root Override per other
  OS, else the saves split by platform ([partner.steamgames.com/doc/features/cloud](https://partner.steamgames.com/doc/features/cloud));
  a Steam Flatpak moves the XDG dirs per app and breaks the mapping ([ctrl.blog](https://www.ctrl.blog/entry/flatpak-steamcloud-xdg)).
  Under Proton the Windows build writes into the prefix's AppData, so the Windows root works unchanged. E13 shows the
  sim side holds (a replay crosses Windows <-> Linux identical); a quest 1 autosave written on one OS resumes on the
  other with the same state hash, both ways (E14).
  Valve's "per-device graphics settings kept out of Steam Cloud" (recommendations, above) fits our layout as is: the
  saves are `user://profile/` (`Save.DEFAULT_ROOT`), the player settings (frame cap, rumble level, volumes) are
  `user://settings.json` (`PlayerSettings.PATH`), so the Auto-Cloud rule names `profile/` only (it15, read from the code).
- **On-screen keyboard (it15)**: the shipped game has no text entry (no `LineEdit` / `TextEdit` / `SpinBox` outside
  `dev/`, `tests/`, `addons/`), so the Verified text-entry item does not apply; a future name or chat field would
  call `ShowFloatingGamepadTextInput` through the Steam backend.

### Godot knobs for a handheld
- Renderers: Compatibility "Low base cost, but high scaling cost"; Mobile medium/medium; Forward+ "Highest base cost, and low scaling cost" [renderers](https://docs.godotengine.org/en/latest/tutorials/rendering/renderers.html). Measured below (E1).
- 2D resolution: stretch `viewport` renders at the base size and scales up (cheaper); `canvas_items` renders at the screen's; `scaling_3d` does nothing for 2D. [multiple_resolutions](https://docs.godotengine.org/en/latest/tutorials/rendering/multiple_resolutions.html)
- `Engine.max_fps` "reduces power consumption" [Engine](https://docs.godotengine.org/en/latest/classes/class_engine.html); `--gpu-index` picks the adapter on Forward+/Mobile [CLI](https://docs.godotengine.org/en/latest/tutorials/editor/command_line_tutorial.html).
- Suspend: `NOTIFICATION_APPLICATION_PAUSED/RESUMED` are Android/iOS only; desktop gets `NOTIFICATION_APPLICATION_FOCUS_OUT/IN` [Node](https://docs.godotengine.org/en/latest/classes/class_node.html). A Deck suspend freezes the process without telling it *(model knowledge)*: on resume the first frame's delta is the whole sleep, and our `SimClock` already clamps it (the dropped seconds are counted; no catch-up spiral).

### The Deck's own upscaler vs `draw_scale` (researched iteration 7)
- In Game Mode the Deck's compositor (gamescope) scales any game that renders below the panel's 1280x800; the quick
  access menu's Performance tab has a Scaling Filter (linear, nearest/integer, FSR 1.0 with a sharpness slider), and
  the FSR choice only shows when the game is below native. Desktop Mode has no gamescope, so no filter.
  Sources (user guides, not Valve docs; the menu has been renamed between SteamOS versions, so re-check on a device):
  [pimylifeup.com/steam-deck-enable-fsr](https://pimylifeup.com/steam-deck-enable-fsr/),
  [digitaltrends.com: how to turn on FSR on the Steam Deck](https://digitaltrends.com/computing/how-to-turn-on-fsr-on-the-steam-deck),
  [steamtinkerlaunch wiki: GameScope](https://github.com/sonic2kk/steamtinkerlaunch/wiki/GameScope).
- What it means here: our `draw_scale` scales inside Godot (viewport stretch, a linear filter), so the window stays
  1280x800 and gamescope has nothing to scale. The alternative is a window/resolution of 960x600 with no in-engine
  stretch: then the player chooses FSR 1.0 (sharpened) or integer scaling in the quick access menu. A Deck-only
  "render resolution" setting would give the player that choice; untested here (no gamescope on Windows; gamescope
  runs nested on Linux, a WSL experiment for later). The UI side holds either way: at 960x600 the HUD lays out smaller.

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
- CitySim on a console: no runtime-loaded `.dll/.so`, so the GDExtension is linked statically / built as an engine module with the platform toolchain for aarch64; **replay and parity determinism are proven on x86_64 only**: the SIM-05 replay and NAT-06 parity gates must be re-run on an ARM build *(model knowledge)*. Narrowed n9 it4: the CitySim core is already built with strict floating point on every compiler (NAT-07, `native/SConstruct` `strict_fp`: `/fp:strict`, `-ffp-contract=off`), so the extension itself cannot contract `a*b+c` into an FMA on ARM. The open part is the engine's own C++ math that the GDScript twin and the sim call (`Vector2.dot`, `length`, `lerp`, `rotated`): a Windows x64 engine build has no FMA in its baseline ISA, while every arm64 CPU has FMA and clang contracts within an expression by default (`-ffp-contract=on`), so the same tick can round differently on an aarch64 engine. Mitigation for a porter: build the console engine with `-ffp-contract=off` (a custom engine build is part of any console port) and re-run SIM-05 / NAT-06 on the device; an x86-recorded replay can only be expected to hold after that *(model knowledge; not measurable on this PC)*.
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
- `--project=<dir>` (it10) runs another checkout's project: an A/B arm whose import settings differ and whose code is the same (a detached scratch worktree, the `.godot` cache copied in so only the changed imports re-run).
- `--grab=<after s>:<abs .png>` (it10, `grab_window.ps1`) copies the game window's client area from the screen: what the panel shows after the engine's stretch. Movie Maker records the project's 1280x800 base whatever the window, and the arena's `--shot` grabs the drawn viewport before the scale-up, so neither shows a 16:9 or 1080 panel faithfully.
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
| E6 | the zoom's cost: does showing 1/2.25 of the world (zoom_k 1.5) render cheaper? Same runs as E5, uncapped | `deck_bench` (zoom_k 1.5) / `deck_bench_z1` (zoom_k 1.0) | frame p50 9.55 (+-0.29) vs 9.56 (+-0.20); render GPU 8.91 (+-0.26) vs 8.88 (+-0.21); process 3.64 vs 3.78 ms: **no difference beyond the noise**. On the 2-CU iGPU the city frame is full-screen fill (ground, print grain, light), not the actor count | **VOID (it7)**: zoom_k never reached the dev arena (the profile was selected after the arena read px_per_m; fixed 4a773812), so both sides ran at 32 px/m: this row compared a run with itself. Re-measured as E8c | `evidence/sim/e5e6-city/e5e6-city.ab.json` |
| E7 | the Switch-class budget: `switch_handheld` (1280x720, 30 cap, **3 pinned threads**, the iGPU), the director reel and the city, 1200 ticks, 2 rounds (CONTENDED: 2-4 other Godot runs, bench lock held) | reel / city | the 30 cap holds: p50 33.35 / 33.29 ms, p99 36.8 / 37.1 ms; process (CPU frame work) 5.1 / 6.6 ms p50; render GPU 7.6 / 10.4 ms; private RAM 0.94 / 1.32 GB + GPU shared 0.58 / 0.94 GB: about 2.3 GB for the city, under the Switch's ~3.2 GB game share **on x86**. The CPU number says little: 3 Zen 4 threads at ~5 GHz against 3 Cortex-A57 cores at ~1 GHz is several times faster per core *(model knowledge: roughly 5-8x)*, so the city's 6.6 ms of frame work would be near or past the 33 ms budget on the 2017 console; the successor's A78C cores narrow that gap | a budget, not a verdict: the simulator cannot model an ARM core; the memory fits, the CPU is the risk | `evidence/sim/e7-switch-budget/` |
| E8 | the fill-rate lever E6 pointed at: draw the 2D frame at 0.75 of the 1280x800 base (960x600, `stretch_mode` viewport + `draw_scale` 0.75) and scale it up to the panel; city, 1200 ticks, uncapped, the iGPU, 2 interleaved rounds (3 of 4 runs CONTENDED: 1 other Godot) | `deck_bench` / `deck_bench_ds75` | render GPU **9.10 (+-0.12) -> 5.27 ms (+-0.03), -42 %**; frame p50 9.68 -> 5.98 ms (-38 %), p99 14.5 -> 10.1; process 3.87 -> 2.56 ms. The cut tracks the pixel count (0.5625x) | **STUDY, not yet the baseline**. First still (it6, since deleted: superseded by the e8b stills): softer ink and grain but it reads; **and the framing moved**: a smaller `content_scale_size` also zooms the camera 1.33x (less world). E6 says the zoom does not change the cost, so the -42 % is the pixel count; a fair look A/B needs px/m x `draw_scale` so the framing holds (next) | draw_scale commit, `evidence/sim/e8-draw-scale/`. **Correction (it7)**: with zoom_k not applied in the arena, the A side ran at 32 px/m and the B side at ~43 effective; re-measured as E8c |
| E8c | E6 and E8 re-measured after the zoom fix (4a773812: the profile is selected before the arena reads px/m), same framing on every row: city, 1200 ticks, uncapped, the iGPU, 8 pinned threads, 3 interleaved rounds (11 of 12 runs CONTENDED: 2-4 other Godot; bench lock held) | `deck_bench` (48 px/m) / `deck_bench_z1` (32 px/m) / `deck_bench_ds85` (48 px/m, drawn at 1088x680) / `deck_bench_ds75` (48 px/m, drawn at 960x600) | render GPU **8.12 (+-0.49) / 9.01 (+-0.22) / 6.21 (+-0.25) / 5.14 (+-0.15) ms**; frame p50 9.19 / 9.65 / 6.78 / 5.88; p99 15.0 / 14.1 / 11.5 / 10.2; process 3.69 / 3.82 / 3.23 / 2.61 ms. Zoom: 48 px/m renders ~10 % cheaper than 32 (less world per frame), just outside the noise. Draw size: -24 % at 0.85, -37 % at 0.75, close to the pixel count (0.72x, 0.56x) less a fixed part | zoom_k 1.5 KEPT (legibility, and it does not cost: slightly cheaper). draw_scale: **a Call, not the baseline**: the look stills at the same framing (`gtai-masters/d9/handheld/e8b-deck-vs-ds75-48ppm-city-t720*.png`) show the grain, the hatched shadows and Rivet's ink line going soft at 0.75, and the HUD laying out in the smaller size (the ghost-form panel 1.33x bigger). The Deck at 60 already has headroom on a GPU 4x weaker than its own (8.1 ms of 16.6), so the lever is for the Switch-class budget or a 4-6 W battery mode | `evidence/sim/e8c-zoom-and-draw-scale/` |
| E9 | a Windows handheld's 1920x1080 panel: draw at the 1280x800 base and scale up (viewport stretch, the `handheld_1080` row) vs draw at the panel's own size (canvas_items, `handheld_1080_native`); city, 1200 ticks, 60 cap + vsync (the play rows), 16 threads, the iGPU, 2 interleaved rounds (all 4 CONTENDED: 2-3 other Godot; bench lock held) | `handheld_1080` / `handheld_1080_native` | render GPU **9.86 (+-0.18) vs 16.09 (+-0.03) ms (-39 %)**; frame p50 16.65 (vsync-locked) vs 17.44 (misses 60), p99 21.1 vs 24.7; process 4.6 vs 4.5 ms | viewport stretch KEPT on the 1080 rows (it already was the default): the native 1080 draw cannot hold 60 on this 2-CU iGPU. Owed: a still of the 1080 row (16:10 base on a 16:9 panel: bars or crop) and the look at 1.5x scale-up | `evidence/sim/e9-1080-viewport-vs-native/` |
| E10 | perf's L4 on the handheld (perf REQUEST, it5): BC7 (`compress/mode=2`, `high_quality`) for the 712 `features/{characters,city,vehicles}/art` textures, in a detached scratch worktree run with `sim.mjs --project=`; `deck_bench` (48 px/m, uncapped), the iGPU, 8 pinned threads, city and King, 1200 ticks, 3 interleaved rounds (all 12 runs CONTENDED: 1-3 other Godot; bench lock 13:19-13:27). A first run (13:00) was **VOID**: `--project` never reached Godot's `--path`, both arms ran lossless (caught by the engine's texture counter, 529 MB in both) | lossless / BC7 | **city**: Godot texture memory 529 -> 184 MB, video memory 843 -> 482 MB; process private RAM **1386 -> 898 MB**, GPU shared (system RAM the iGPU maps) **1007 -> 489 MB**: ~1.0 GB less of a UMA device's memory; render GPU **8.33 (+-0.07) -> 7.37 (+-0.37) ms (-12 %)**, frame p50 9.40 -> 8.03 (+-1.53), process 3.87 -> 3.49. **King**: texture 269 -> 123 MB, private 1004 -> 828 MB, GPU shared 643 -> 469 MB; render GPU 6.77 -> 6.66 (inside the noise), p50 7.34 -> 7.46 (wash). On the 4090 perf saw no frame change: on the 2-CU iGPU, which reads system RAM, the city's texture traffic does cost | **a Call, not the baseline** (pixels move: BC7 is lossy; import settings are project-wide, so a handheld-only BC7 means a handheld build step that rewrites the imports before export). The strongest memory lever of the day for a Switch-class budget (E7 measured ~2.3 GB for the city on x86; less the ~1.0 GB measured here on deck_bench that is ~1.3 GB: inferred, not run on the switch row). Look stills: `gtai-masters/d9/handheld/e10-city-deck-lossless-vs-bc7-48ppm*` | `evidence/sim/e10-bc7-igpu/`, the VOID run `evidence/sim/e10-VOID-both-arms-lossless/` |
| E11 | BC7 on the Switch-class row (it11; E10's arm re-synced to 9cffebaa so only the imports differ): `switch_handheld` (1280x720, 30 cap, 3 pinned threads, the iGPU, 48 px/m), the city and the director reel, 1200 ticks, 2 interleaved rounds (bench lock 13:53-14:01; 7 of 8 runs CONTENDED, 2-6 other Godot). The arms differ (the memory moved: checked before reading the frame numbers) | lossless / BC7 | **city**: private RAM **1321 -> 893 MB**, GPU shared **936 -> 482 MB**: **2.26 -> 1.38 GB** (E10 had inferred ~1.3 GB: measured 1.38); render GPU 10.20 (+-0.46) -> 9.11 (+-0.04) ms (-11 %); the 30 cap holds in both (p50 33.31 / 33.34 ms; p99 38.5 / 41.2, the BC7 arm's spread 5.3 is one contended run); process 9.4 -> 11.2 ms (+-1.65: contention, not a BC7 cost: BC7 adds no CPU work per frame). **Reel**: private 943 -> 745 MB, GPU shared 581 -> 383 MB: **1.52 -> 1.13 GB**; render GPU 7.97 -> 7.86 (wash); p50 33.36 / 33.35 | **a Call, not the baseline** (Call 6, the same lossy lever). On a 2017-class budget (~3.2 GB for the game) the city goes from about 70 % of it to about 43 % on x86; the CPU (an A57-class core) stays the risk | `evidence/sim/e11-bc7-switch/` |
| E12 | perf's L9 (their it12 FYI) on the handheld GPU (it13): the transfer workers' CPU upload buffers, stock (`GTAI_TW_TRIM_MB=0`) vs trim (32), on the **2-CU Radeon iGPU** (`--gpu-index 1`), 1280x800, 60 cap, the riot 30 s; perf's windows-bench-tw export (their head pck + the MSVC instrumented template), so the window is the Deck's but not `--device=deck`; 1 run per arm, memory only (no frame time compared: the template is ~10 % slower) | stock / trim | the stock run ends with 4 workers holding 128 + 32 + 32 + 32 = **224 MB** of staging (the 128 MB one = `vehicles/art/p70/traffic_cards.png`, as perf found on the RTX); trim frees it after load. Working set 1304 -> 1128 MB (-176), private 1328 -> 1163 (-165), **GPU shared 1006 -> 878 MB (-128)**, dedicated 82 both: on a shared-memory GPU the outlier buffer is the iGPU's own memory, so on a Deck it comes out of the 16 GB both sides share (`evidence/it13/tw-igpu/`) | supports perf's sheet-split REQUEST (the vehicles owner's change, no pixel moves) and the engine trim; not handheld's files, nothing committed in the game | - |
| E13 | **the sim is the same on Linux** (it14; the carried NAT-06 item): the official Godot 4.7.2 Linux editor (GitHub release zip, sha512 checked against the release's SHA512-SUMS, build `ed1daf0bf` as on Windows) in WSL2 Ubuntu 24.04 (glibc 2.39), the project copied to the distro's own disk with its import cache, the sniper-built `.so` (glibc 2.31) | NAT-06 parity (native `.so` vs the GDScript reference) / a replay recorded on one OS, replayed on the other (it15 correction: these logs are of the **city-block World** (`main.tscn`, `boot: booted`), not quest 1, which records through `quest1.tscn`: see E13c) | parity **exact over 1200 steps** (40 checks, 3516 floats, max diff 0.0), the planted mutation caught at step 629 (the same step as on Windows; `native/SConstruct` builds gcc with `-ffp-contract=off` and MSVC with `/fp:strict`, so no FMA fusing even at a Zen 2 `-march`); Windows -> Linux: 1800 ticks (seed 7) **identical**; Linux -> Windows: 3600 ticks (seed 11) **identical** (30 / 60 SHA-256 checkpoints over every RNG stream and every system's state, the city crowd and police included). Limits: idle input (Rivet stands; the crowd, the police and the RNG streams run, combat does not), the **debug** `.so` (the editor loads it; the release `.so` through the export: see E13b), Ubuntu not SteamOS (both glibc >= the sniper 2.31) | **kept**: a save or a replay made on a Deck reads the same on Windows and back, as far as the sim goes; NAT-06 holds on Linux | a8f9019d (`evidence/it14/linux/`) |
| E13b | the **release** `.so` through a Linux export (it14): first `linux-showcase` (it boots the dev arena, which never reads `--replay`: both runs played until my 300 s timeout, exit 124), then a new `linux-slice` preset (quest 1 as main, dab6158a; 14 s, 292 MB + the 396 KB release `.so`); the control: `windows-slice` on Windows | the two editor-recorded logs through each release export / a Windows release recording | **diverges at tick 60** (the first checkpoint) for both logs **on both OSes alike**: an editor-vs-export difference, not a Windows-vs-Linux one (the editor runs replay identical across the OSes, E13). The release exe with `--record` and `--quit-after 1800` exits 0 but writes no file, so a release-vs-release crossing is not measured | **withdrawn (it15, my mislabel)**: the two logs were recorded through `main.tscn` (the city-block World), and a slice export boots quest 1, a different simulation, so the first checkpoint differs by construction; the slice's `--record` writes nothing because `--autostart` is debug-only (`quest1_card.gd:70`: a release exe waits on the title card). No SIM-05 finding: E13c | dab6158a (`evidence/it14/linux/slice-*`) |
| E13c | **editor = release = Windows = Linux** (it15): a new `linux-dev` preset (`main.tscn`, as `windows-dev`; 292 MB + the release `.so`) and `windows-dev` (109 MB exe + 218 MB pck + the release `.dll`), both exported from this branch; for quest 1 `windows-slice` and `linux-slice` | 5 World logs (editor Win seed 7 / editor Linux seed 11 / release Win seed 13 / release Linux seed 17) and 1 quest 1 log (editor, `quest1.tscn --autostart`, 425 ticks), each replayed in every build that boots its scene | **every replay identical**: the two editor logs in the Windows and Linux release builds; the Windows release log on Linux release; the Linux release log (1496 ticks) on Linux release, Windows release and the Windows editor; the quest 1 log in the editor, `windows-slice` and `linux-slice` (exit 0 each) | **kept**: a replay or save made on any of the four (editor / shipped, Windows / Linux) reads the same on the others, release `.so` / `.dll` included. Limits: idle input (no combat in the logs), Ubuntu not SteamOS, x86_64 only; the slice cannot record in release (debug-only `--autostart`, by design) | this commit (`evidence/it15/`) |
| E14 | **a save crosses Windows <-> Linux** (it15): `dev/save_cross.gd` plays quest 1 on a scripted input tape (8 move directions, a 20-tick step, fire held every other step: not idle, the hash differs from an idle tape at 1800), autosaves through the real `Save` engine (GTSV slot + `meta.json`) and resumes through `Quest1Autosave.accept` (the title card's Continue path: re-simulate the tape, require the state hash); the Windows 4.7.2 editor and the Linux 4.7.2 editor in WSL Ubuntu | a slot written on one OS, resumed on the other, then +600 ticks | Windows seed 7, saved at tick 1800 -> Linux resumes **at 1800 with the same hash** (`13e5ad9f..`), +600 -> `300113db..` = Windows' own +600; Linux seed 11, tick 2400 -> Windows resumes the same (`4c7b248f..`), +600 -> `d16071f6..` both. Control: one payload digit flipped -> `payload hash mismatch`, quarantined, refused (exit 1) | **kept**: a Deck save resumes on the PC and back (Steam Cloud's root override, section 1, is the only missing piece). Limits: the editors (the release builds replay identical: E13c), one scripted tape, Ubuntu not SteamOS | (`evidence/it15/save-*`, `slots/`) |
| E15 | **who pays the CPU on the Deck rows** (it18; perf's `tools/perf/thread_cpu.ps1` from their worktree, read-only, per-thread CPU over 12 s, 18 s into the run): `sim.mjs --scene=city` (course bot, 48 px/m), 2400 ticks, 8 pinned threads, the 2-CU iGPU, below-normal priority, bench lock 17:51-17:54; **1 run per arm** (no spread: a single sample each), the `deck` arm CONTENDED (2 other Godot runs), `deck40` quiet | `deck` (60 cap) / `deck40` (40 cap) | `deck`: **0.53 cores, of which the engine main thread 0.527**; every other thread together 0.008 (Godot's worker pool and the D3D12 driver threads do not show above the noise). `deck40`: 0.33 cores, main thread 0.318 (-40 %, E5 said -26 % on the pinned-CPU percentage). Frame p50 16.66 / 24.92 ms (both on the cap), process 4.84 / 5.08 ms, render GPU 8.84 / 9.30 ms | **kept as a finding** (no code): the game is one-thread-bound on the CPU side, so a Deck's 4 cores give no headroom by themselves and its **single-thread** speed is what counts. *Estimate, model knowledge, not measured*: a Zen 2 core at <= 3.5 GHz does roughly 1.6-2x less per thread than this Zen 4 X3D at ~5 GHz, so ~0.53 core here is ~0.85-1.05 of one Deck core at 60 Hz (tight) and ~0.5-0.65 at 40 Hz; the Switch-class row (E7) inherits the same single-thread risk, worse. The lever if a Deck misses 60: move work off the main thread (the sim already steps in native code) or the 40 Hz row | (`evidence/it18/`) |
| E15b | does the Deck row need its other threads? (it18, the control for E15): `deck` on the city, 2400 ticks, the iGPU, pinned to **2 threads (1 core + SMT)** vs 8, thread_cpu over 12 s; **3 interleaved rounds** (t2, t8, t2, t8, t2, t8), 5 of 6 CONTENDED (1-4 other Godot runs), bench lock 17:55-17:58 and 18:00-18:05 | `deck` 2 threads / 8 threads | median the same in every round: frame p50 16.66-16.67 / 16.67-16.68 ms (60 holds on one core); main thread 0.506 / 0.469 / 0.440 vs 0.408 / 0.493 / 0.452 cores, every other thread <= 0.01. Settled frames > 33 ms **5 / 17 / 4 vs 1 / 12 / 4**, worst settled 447 / 476 / 54 vs 37 / 591 / 59 ms: round 1 alone looked like a tail cost (5 vs 1), the interleaved rounds put it **inside the contention noise** (round 2 ran beside 2-4 other Godot runs and both arms hitched) | **finding: one core holds the steady 60; no measured tail cost from losing the other cores on this machine**. Round 1's "the tail is not" (commit 80661ffc) is **withdrawn**: one run per arm, contended. A quiet-machine A/B is what would settle the tail; the Switch-class row on 3 threads (1 run, CONTENDED): 30 cap holds (p50 33.3 ms), main thread 0.304 of 0.311 cores, the same one-thread shape | (`evidence/it18/*-t2*`, `*-t8*`, `*switch_handheld*`) |

**The zoom under the it1-it6 rows (it10 note).** Every run through the dev arena before 4a773812 (it7) drew at **32 px/m**, whatever the row's `zoom_k` said: E1 (reel), E2 (reel), E4 (the city in WSLg), E5 (city) and E7 (reel, city). Their conclusions stand: E1, E5 and E7 compare rows at the same zoom, so the ratios hold; E2 and E4 are not zoom claims. The absolute numbers are at 32 px/m; E8c measured 48 px/m ~10 % cheaper in render GPU on the city, so the 48 px/m play view sits at or under them. E3 used an explicit `--ppm` per still and is unaffected.

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
  **Decision (it12, `handheld/glyph-images`)**: the text labels stay on the handheld rows; on a Steam build the glyph
  for the pad in hand is Steam Input's (`ISteamInput::GetGlyphPNGForActionOrigin` / `GetGlyphSVGForActionOrigin`,
  [ISteamInput](https://partner.steamgames.com/doc/api/isteaminput), through the Steam backend only), owed with the
  Steam port; a drawn ink glyph set is a REQUEST to the asset lane (`ui_pad_glyphs_v1`, JOURNAL it12) to replace the
  bracket text in the game's style.
- Rumble: was **none** in the game. **Built (it4)**: `HandheldRumble` (core/platform) on the Events bus, added by
  `LaunchArgs` when the device row sets `rumble` (every handheld row 1.0; desktop none): Rivet hit (0.3/0.8, 180 ms),
  a car strikes a person (killed 0.4/0.6, 160 ms; knocked 0.3/0.3, 100 ms), a tackle knock-down (0.5/0.2, 100 ms), a boss
  steps in (0.6/0.6, 500 ms), a hijack (0.3/0.1, 120 ms), the whispers spike (0.2/0, 400 ms); a weaker pulse never cuts a
  stronger running one. **Live check** (`--device=deck`, headless, the pulse count logged on exit): the King fight
  2400 ticks = **1 pulse** (the boss stepping in); the director reel 6000 ticks = **0**. Rivet's hits in the arena and
  the boss fights never reach the bus: `player_hit` is emitted only by quest 1's robo-tazer (`combat_arena.gd`) and the
  pit AI (`enemy_pit.gd`). Owed: `player_hit` at Rivet's damage chokepoint (every hit he takes), a blast and a car crash
  event, and the feel on a real pad (no pad on this PC: unit-tested, never felt). **Settings (it12, 690ea895)**: the
  pause card on a handheld tier offers "Rumble: full / half / off" (`PlayerSettings.rumble` 1 / 0.5 / 0 times the
  row's gain, saved; a file saved before the row loads full). `test_settings_panel_pad`: A cycles it on a pad with the
  focus kept, half plays a half pulse, off plays none (mutation: `evidence/it12/mutate-player-settings.log`).
  **A landed hit on a boss (it13, 7509cf49)**: it12's per-kind count showed a boss fight pulsed only on Rivet's hurts
  (King 3 = engaged 1 + hurt 2 in 2400 ticks of the boss bot). Built: `boss_hit` (0.15 / 0.35, 70 ms: lighter and
  shorter than `rivet_hurt` 0.25 / 0.55, 120 ms, so it never cuts a hurt), fed by `BossBar._process` reading the boss
  body's `hurt_tick` (set by `BossFight.hurt` only when a hit takes hp: none in a transition), a view-side read like
  HudFeed's of Rivet; no-op without a rumble row. Live under `deck` (headless, 2400 ticks, the boss bot, combo): **King
  59 = boss_hit 56 + rivet_hurt 2 + engaged 1; Servo 63 = 61 + 1 + 1**; the hurt counts are it12's exactly (no hurt
  cut, the fight unmoved) (`evidence/it13/*-rumble-deck-hit.log`). ~1.4 landed hits a second: the motor is on about
  10 % of the fight. **The rest (it14, 7ae230b4)**: measured first (the exit log names the shortest gap per kind):
  the stock gun's shortest boss-hit gap is 16 ticks (King) / 21 (Servo), but `--weapon=gatling` or `machine_pistol`
  lands one every **2 ticks** on both bosses, so the 70 ms pulses chained into one buzz (King gatling 225 pulses in
  40 s, Servo 361). Built `REST_TICKS {boss_hit: 8}` (133 ms: at most 7.5 taps a second, 63 ms quiet between taps;
  each kind rests on its own, so a hurt is never held back; 0 = before): King gatling 80 played + 145 rested (the same
  225 hits), machine pistol 105 + 112, Servo gatling 126 + 236; the stock gun 59 / 63, 0 rested (it13's exactly)
  (`evidence/it14/*-gap.log`, `before/`). Only a pad in hand can say whether 8 ticks reads as taps (one value).
- Aim assist for twin-stick aim: **exists but is never called** (corrected n9 it3; d9 read "not found"). The gunplay
  lane built it (7ed93057, the owner's decision 2 "light, pad only"): `features/combat/weapons/aim_assist.gd`
  `AimAssist.bend()`, numbers in `weapons.json` `aim_assist` (cone 8 deg, range 25 m, bends 35 % of the way, the mouse
  raw), loaded into `WeaponTable.aim_assist`; but no shipped code calls `bend()` (only `test_gunplay_weapons`), and the
  only `RangeTarget` lists live in `ProjectileSim`, which runs in the dev range views alone. So a pad aims raw today
  everywhere. Owed (designed, JOURNAL it3 NEXT): `LiveInput` bends the right stick's heading (before `pack_aim`, so a
  replay records the bent heading) with a targets Callable that each session fills from its stage's hostiles (quest 1:
  cops; the arena: its enemies and the boss), on the handheld rows (a `devices.json` field); the desktop pad as an owner
  Call (the owner's decision 2 says pad only, not handheld only).
  **Wired n9 it3 (33f80d56)** as designed: `PadAimAssist.wire(live, stage.get.bind("arena"))` in `Quest1Session.open`
  and `ArenaSession`, on every row with `aim_assist: true` (all handheld rows, tested); `test_pad_aim_assist` (the
  desktop aims raw, the targets are the living hostiles + the boss, a 5 deg offset bends toward the hostile).
  **Shown live n9 it4** (simulator, d3d12, `--boss=king`, scratch pad-event walker `evidence/n9h/it4/aimwalk/`: the
  right stick held 5 deg off the nearest living target, RT held, 24 samples 20 frames apart as Rivet closes in): on
  `deck` the heading `LiveInput._aim()` returns stays 5.00 deg off while the target is 35-29 m away (outside the 25 m
  range) and bends to **3.25 deg** from 24.4 m in (35 % of the 5 deg error removed, the cone 8 deg), mean 3.61 over the
  run; on `desktop` the same walk stays 5.00 deg throughout (assist off). Logs `aim-deck.log` / `aim-desktop.log`.
  The bend is a fixed share, not a lock: a held stick never snaps onto the target (by design: "light").
- Menus: **broken on a pad until it11, fixed** (8959a913, 47668922). Godot 4.7.2's default `ui_accept` and `ui_cancel` carry
  **no pad button** (probed on the engine: `ui_accept` = Enter, keypad Enter, Space; `ui_up/down/left/right` = the d-pad
  and the left stick; `ui_select` = Y). The title, pause and paid cards are focus-driven Buttons: a pad moved the focus
  and could press nothing, so **a Deck could not press Start** (a Verified fail: "the game must be fully usable with the
  Deck's controls"). Fix: `input_actions.json` `menu_pad` (A on `ui_accept`, B on `ui_cancel`), added at boot on every
  run (`PlayerActions.install_menu_pad`; the desktop title card already advertises the pad, and no gate sends pad
  events). Second fault in the pause card: each settings press rebuilt the rows and freed the focused button, so after
  A on "Toggle" the pad had no focus left to move; the panel now restores the focus to the same slot, and a pad button
  cancels a keyboard rebind's wait. Proven in `test_settings_panel_pad` (A cycles the frame cap 0 -> 30 -> 40 and reaches
  `Engine.max_fps`, the focus stays, the d-pad moves on; planted: no restore -> both tests fail). The dialogue box needs
  no input (its lines run on timers). On a handheld tier (955f56cb) the cards are pad first: the controls line is built
  from the bound pad buttons (`ObjectiveHint.with_keys(..., pad)`: "[L-stick] move  [R-stick] aims  [RT] fires / [X]:
  electroshock  [A]: use  [Start]: pause", relabelled for a PlayStation / Nintendo-layout pad), the focused button gets a
  4 px ink border (the default focus outline is faint at 7 inches), and the keyboard rebind rows are hidden (Valve's
  "no keyboard / mouse text" for Verified; a Deck remaps in Steam Input). **Live pad walk** (it11, `--device=deck`, pad
  events through `Input.parse_input_event` only): title focus Start -> A starts quest 1 -> Start pauses (focus Resume)
  -> d-pad up to the cap's Toggle -> A: cap 30, `Engine.max_fps` 30, the focus kept -> A: 40 / 40
  (`evidence/it11/padwalk-deck.log`, stills `gtai-masters/d9/handheld/padwalk-deck-*.png`). Owed: the same walk on a
  real pad through Steam Input (no pad on this PC). B on a pad resumes from the pause card (035643c7; pad events only,
  the keyboard's Esc is already the pause toggle). **The end cards walked live (it12)**, the same way (`evidence/it12/padwalk-deck-cards.log`,
  still `gtai-masters/d9/handheld/padwalk-deck-failed-paid-1280x800.png`): a real failure (the quest runner's fail, no
  checkpoint) shows "The line went dead." with Quit focused, A presses it; with a checkpoint Retry is focused, the d-pad
  moves Retry <-> Quit, A on Retry restarts the contract; a real success shows the paid card once the closing lines have
  played (780 frames: by design, the card waits for `lines.busy()`), Quit focused, A presses it. Every card of quest 1
  is now walked on pad events alone.
- On-screen keyboard: the game has no text entry today; nothing owed until it does.
- Pause on focus-out: **built** behind the handheld profiles (`HandheldFocusPause`, added by `LaunchArgs` when the row's
  tier is `handheld`): `NOTIFICATION_APPLICATION_FOCUS_OUT` (the Steam overlay, a Windows handheld's shell, alt-tab)
  pauses a live quest 1 run like the pause button; it never unpauses. Desktop unchanged (089afea8). Unit-tested on the
  no-run guard; proven live in `scenario_handheld_focus_pause` (e2f222df: quest 1 running, the OS focus-out
  propagated: paused with the handheld node, live without it as the planted fault; re-read n9 it2).

## 6. Text legibility at 1280x800

The project's base viewport is 1280x800 (`canvas_items` stretch), the Deck's panel exactly: the HUD draws 1:1 at its
authored sizes. Static read: `HudView` TEXT 30 / NAME 26 / WEAPON 24 px, `ObjectiveView` 24, `GhostFormHud` 18, theme
default 16 (the settings panel): the smallest em is 16 px, a cap height of about 11 px, **above Valve's 9 px minimum and
near its 12 px recommendation** (static read, d9).

**Runtime probe (n9 it2):** `TextProbe` (`dev/handheld/text_probe.gd`, tested in `test_text_probe`) walks every
visible text Control (Label, Button, RichTextLabel, LineEdit), scales its font size to window px (canvas transform x
the viewport stretch) and measures the **ink height of "H" (cap) and "x" (x-height)** from the TextServer's glyph
cache at that size. `dev/handheld/legibility_walk.gd` boots quest 1 under a device row, walks it on pad events (title
-> A -> stick -> Start) and probes each stop; the HUD's custom `draw_string` sites are not Controls, so their 10
authored sizes are measured the same way from a reviewed table (each site read in the code: HudView 22-30, the
dialogue fit 20-30, the boss bar 16 / 20, the taunt fit 18-22, the ghost card 18, the prompt 24). Valve's wording is
"the smallest on-screen font character should never fall below 9 pixels in height": the strict reading is the
x-height (a lowercase letter), the usual one the cap. Result, `--device=deck`, 1280x800, the iGPU
(`evidence/n9h/it2/legibility/legibility-deck.json`, still `gtai-masters/n9/handheld/legibility-deck-pause-1280x800.png`):

| text | font px | cap px | x-height px | verdict (x-height vs 9 / 12) |
|---|---|---|---|---|
| boss bar round count "1 / 3" (digits: cap height) | 16 | 12 | 9 | at the floor (digits read at 12) |
| ghost card name, key hint; boss taunt smallest fit; pause card -, +, Toggle | 18 | 13 | 10 | above 9 |
| boss bar name; dialogue smallest fit; title / pause controls line; settings rows | 20 | 14 | 11 | above 9 |
| unarmed label | 22 | 16 | 12 | 12 |
| objective prompt; weapon / heat / notice | 24 | 17 | 13 | 12+ |
| speaker name; head line; Start / Resume / Quit; titles | 26-56 | 18-40 | 14-30 | 12+ |

**No text on the Deck row falls below 9 px under either reading; every cap height is at or above Valve's 12 px
recommendation; the x-height is 9-11 px on 13 of the 28 probed items** (the 16-20 px fonts). Cross-checked on pixels
(the King still, `it2-king-card`): "Tonnage" x-height 10 px, "1 / 3" 12 px, "KING" 14 px: the probe's numbers. On the
7-inch panel 10 px = 1.2 mm. A larger handheld text scale (e.g. 1.15x on the 16-20 px fonts, behind the rows) is a
Call, not built: the cap reading passes everywhere, and the cards are laid out around these sizes.

**The other rows (it2, the walk on the dGPU; the draw sizes scaled by the window stretch)**
(`evidence/n9h/it2/legibility/legibility-<row>.json`): `handheld_1080` (1920x1080, the base drawn and scaled 1.35x):
every text 22 px or more, x-height >= 12, nothing near the floor. `switch_handheld` (1280x720, the 1280x800 base
scaled **0.9x**): the Controls' smallest is the pause card's 18 px buttons at 16 px = x 9 / cap 12 (at the floor);
**the boss bar's round count "1 / 3" draws at 14 px = x 8 / cap 10**: under Valve's rule read on x-height it would
fail, but it is digits only (no lowercase), so its smallest character is the cap height, 10 px. Nintendo publishes
no legibility number (its guidelines sit behind the developer program); applying the Deck's rule to the Switch-class
budget, the one site to lift on a 720p row is that count (16 -> 18 px authored, or a text scale on the row).
**Judged on the still** (the King on `switch_handheld`, iGPU, t=18 s, `evidence/n9h/it2/legibility/switch720-king-count-crop-x4.png`):
"1 / 3" reads cleanly at ~10 px digit height; **no change** (the row is a budget, not a port).

## 7. Port readiness (filled as the loop goes)

| device | works on the simulator today | owed | only real hardware can prove | effort |
|---|---|---|---|---|
| Steam Deck | **n9 (2026-11-08):** 40 px/m on every handheld row (owner h-1 B); the compact ghost-form card (half the area, 18 px text kept, h-3 B); the drawn ink pad glyphs in the prompts, the title / pause controls line and the ghost card, per pad family (Xbox / PlayStation / Nintendo-layout names, section 8); the runtime legibility probe (every text x >= 9 px, cap >= 12 on the Deck row); world's BC7 halves the city's GPU shared memory on the Deck row (E16, -48 %; E16b under the bench lock, 3 rounds: -45 % GPU shared, -33 % private RAM, render GPU -11 %); the 40 Hz row at 40 px/m cuts GPU busy -30 % and pinned CPU -24 % (E17). Before n9: `--device=deck` (1280x800, 60 cap, vsync) and `deck40`; on 8 pinned threads + the 2-CU iGPU the reel runs vsync-locked 16.6 ms and ~134 fps uncapped (render GPU 6.7 ms); ~0.95 GB private RAM, ~0.6 GB GPU memory; the King fight and the city filmed at 1280x800; the native Linux build (sniper-SDK `.so`, `linux-showcase` export) runs the city in WSLg; a 20 s freeze resumes cleanly; focus-out pauses quest 1; the HUD's smallest text is above Valve's 9 px (n9 runtime probe over quest 1's title, HUD and pause card: every x-height >= 9 px, every cap >= 12, section 6); every action on the pad (radio/reload fixed); rumble on the bus events and PlayStation / Nintendo-layout prompt names under the handheld rows (it4); the 40 Hz row cuts GPU busy 55 -> 38 % of each second and pinned CPU -26 % (E5); the 1.5x zoom cost: see E8c (E6 was void); clips of the King fight and the city at 48 px/m (it7; the it4 "48" set was really 32 px/m); every card of quest 1 (title, pause, failed, paid) walked live on pad events alone (A / B; Godot 4.7 gave the pad no `ui_accept`: fixed it11; the end cards it12) and the pause card keeps the pad's focus; a player frame cap (device / 30 / 40 / 60, it10) and a rumble level (full / half / off, it12) in the pause card on handheld rows; replays hold across editor / release and Windows / Linux, the release `.so` included (E13c), and a quest 1 autosave resumes across the two OSes at the same hash (E14); no text entry, so no on-screen keyboard is needed (it15); the CPU side is one thread: the engine main thread carries 0.527 of the 0.534 cores at 60 Hz, 0.318 of 0.33 at 40 Hz (E15, so a Deck's single-core speed decides 60, not its 4 cores) | the Linux build's real Vulkan run (a Deck or a Linux PC: WSLg has no Vulkan-on-D3D12), a `just native` recipe for the sniper container build (NAT-06 parity on the Linux `.so`: done, E13; replays cross editor / release and Windows / Linux identical, the release `.so` included, for the city-block World and quest 1: E13c); or the Windows build under Proton with `driver.windows=vulkan` (D3D12 goes through vkd3d-proton); Steam Input origin glyphs through the Steam backend (and the drawn ink set, REQUEST `ui_pad_glyphs_v1`); rumble on blasts and car crashes (no bus event) and a per-kind pulse count in the exit log (it12 live, `deck`, 2400 ticks, the boss bot: the King fight 3 pulses = boss_engaged 1 + rivet_hurt 2, Servo 2 = 1 + 1, the director reel 4 at it7: every pulse after the boss steps in is Rivet hurt; his own blows on a boss now pulse too: a light `boss_hit`, it13, King 59 = 56 landed + 2 hurts + 1 engaged, `evidence/it13/*-rumble-deck-hit.log`); the zoom call (Call 1); the BC7 call (Call 6: ~1 GB less shared memory in the city, E10) | real frame times on Zen 2 at 4-15 W, battery hours, the shader cache's first run, Steam Input's default config, suspend/resume on SteamOS, the 90 Hz OLED | Linux build + Proton check: 2-3 days; Verified polish (glyphs, rumble, menus, focus pause): 3-5 days |
| Windows handhelds | **n9:** the 40 px/m zoom, the compact card and the drawn pad glyphs apply to `handheld_1080` too (it is a handheld row); its texts measure x >= 12 px at 1080 (the probe, section 8). Before n9: `--device=handheld_1080` (1920x1080, stretch `viewport` = drawn at 1280x800 and scaled) | (E9 done: viewport stretch holds 60 at 9.9 ms GPU, the native 1080 draw misses at 16.1; it10: the 16:9 drawn frame is 1422x800 and the HUD fits, `handheld1080-city-48ppm-drawn-16x9-t720.png`); the look of the 1.35x scale-up on a real 7-8" panel; the controller-first shell (launch and play with no mouse); Windows display scaling 125-200 % | the Z1/Z2/Lunar Lake drivers, VRR, TDP presets | 1-2 days on top of the Deck work |
| Switch-class | **n9:** the 40 px/m zoom and the compact card apply; at 720p the boss count "1 / 3" draws digits at cap 10 px (x 8; judged legible on a still, section 8); the Nintendo-layout names draw their own glyphs (B / A / Y / X, L / R, ZL / ZR) but "+" / "-" and the PlayStation Create draw their own cells since n9 it4 (the asset lane's appendix, it127; before, the Xbox menu / view marks). Before n9: `--device=switch_handheld` as a budget only (1280x720, 30 cap, 3 threads, the iGPU): the 30 cap holds in the reel and the city, ~2.3 GB RAM + GPU memory on x86 (E7); with BC7 the city is 1.38 GB and the reel 1.13 GB, the cap still holds (E11, measured); the CPU on an A57-class core is the risk (not simulable) | everything: the platform holder's developer program, a dev kit, an engine port (W4 Consoles lists Godot 4.4-4.6, the project is 4.7), CitySim statically linked for aarch64, replay/parity re-proved on ARM, memory under ~3.2 GB (Switch) / 9 GB (successor; BC7 takes 0.88 GB off the city on this row, E11: 1.38 GB on x86, so the 2017 budget is reachable on memory) | all of it | 3-6 months per platform (a porting studio or W4 + our own work), $800-$10,000/yr middleware plus kits under NDA |

## 8. Night n9 (2026-11-08): the owner's picks of 2026-11-07

- **h-1 B, zoom 40 px/m:** every handheld row `zoom_k` 1.25 (was 1.5 = 48 px/m); `deck_bench_z1` stays 1.0 (study).
  Test `test_every_handheld_row_draws_at_40_ppm`. DECISION `handheld/zoom-40`.
- **h-5 A, the Linux depot:** DECISION `handheld/linux-depot`: a native Linux depot (sniper-runtime `.so`), Proton
  (the Windows build) as the fallback. **Re-check trigger: a real Vulkan run on a Deck or a Linux PC.** Until then
  both exports exist (`linux-slice`, `windows-showcase`) and nothing on Steam is set up.
- **h-3 B, the compact ghost-form card (handheld rows only):** `devices.json` `hud: compact` -> `GhostFormLayout.compact()`
  (chips r 19 at a 50 px pitch, margin 22, card 122 px, Madness bar 9 px, one name: the selected ghost's; the faces
  name the rest). Four ghosts at 1280x800, with the memo paper: **~386x208 px (30 % of the width x 26 % of the height)
  -> ~250x170 px (20 % x 21 %)**, about half the area. **Legibility, measured on the still** (zoomed crop): the name's cap
  height ~13-14 px at the unchanged 18 px font = ~1.5 mm on the Deck's 7-inch panel (216 ppi); Valve's Deck Verified
  text guidance (as read in section 1): at least 9 px, 12 px recommended at 1280x800: above both. Chips 38 px across
  (current 45 px) = 4.4 / 5.2 mm. Stills (the King, iGPU, 40 px/m, t=18 s, `deck_hud_full` left = before, `deck` right):
  `gtai-masters/n9/handheld/ghostpanel-king-deck-before-after-40ppm-1280x800.png`. The way back: `hud: full` (study row
  `deck_hud_full`). Desktop untouched (the full layout = the authored constants, `test_ghost_form_layout`).
- **The drawn pad glyphs** (`ui_pad_glyphs_v1`, the asset lane's it98 delivery, 36 cells): `PadGlyphArt` replaces the
  bracketed pad names on the handheld rows: the quest 1 objective prompt (glyphs 1.4x the 24 px text = 34 px = 4 mm),
  the title and pause cards' controls line (30 px images in a RichTextLabel), and the ghost card's key hint (LB / RB from
  the InputMap, 25 px). PlayStation / Nintendo-layout names map to their own cells (Cross, L1, ZR, ...). Stills from a
  pad-only walk (`evidence/n9h/it1/padwalk/`): `glyphs-deck-title-1280x800.png`, `legibility-deck-pause-1280x800.png` (it2, supersedes the it1 pause still),
  `glyphs-deck-quest1-prompt-40ppm-1280x800.png`, `glyphs-deck-title-and-prompt-crop-x2.png`. Steam Input origin glyphs
  still owed with the Steam port (a remapped pad). Per family (n9 it3, a sheet from `PadGlyphs.relabel` +
  `PadGlyphArt.draw_line`): Xbox / PlayStation / Nintendo-layout names each draw their own face and trigger cells;
  the atlas has no PlayStation Create and no Nintendo "+" / "-". Until n9 it4 those drew the cell of the same button
  position (the Xbox View / Menu marks: a glyph that does not match the pad in hand, against Valve's rule). n9 it4:
  first a text fallback ("[+]", 8024b1c7), then the asset lane delivered the three cells (`ui_pad_glyphs_v1` appendix,
  it127, round 20261108-0330, grade A: a round "+" key, a round "-" key, the Create pill with its burst-over-a-dot
  mark): the atlas copied as delivered (the 36 earlier cells pixel-identical, their ink boxes unchanged), the json
  re-trimmed by `glyph_inkbox.py`, `GlyphCells.PAD_CELL` maps "+" / "-" / "Create" to `pad_plus` / `pad_minus` /
  `pad_create`; every family now draws its own menu marks (test `test_each_family_draws_its_own_menu_marks`,
  provenance line, sheet `gtai-masters/n9/handheld/glyphs-deck-pad-families-controls.png`).
- **Clips at 40 px/m on the iGPU** (movie mode: frame numbers are not speed numbers): `deck-city-40ppm-1280x800-igpu.mp4`,
  `deck-king-40ppm-compact-1280x800-igpu.mp4`.
- **E16 (n9 it1), the Deck row on world's BC7 commit** (n9-world 3e02d3b8, BC7 on 772 imports, in a detached scratch
  worktree under my tmp; its `devices.json` set to `zoom_k` 1.25 locally so both arms frame at 40 px/m) vs this branch
  (lossless). `sim.mjs --device=deck --scene=city --ticks=1200`, 2 interleaved rounds per arm, the iGPU, 8 pinned
  threads; **CONTENDED** (3-6 other Godot runs up, no bench lock: memory is trustworthy, the ms are indicative).
  Confound: world's commit also turns sim bikes on at 6 % (more vehicles in the BC7 arm, so its savings are if anything
  understated).

  | metric | lossless r1 / r2 | BC7 r1 / r2 | change (median of 2) |
  |---|---|---|---|
  | frame p50 (vsync 60) | 16.65 / 16.69 ms | 16.65 / 16.66 ms | locked both |
  | frame p99 | 19.3 / 19.9 ms | 20.0 / 19.9 ms | noise |
  | render GPU p50 | 8.69 / 8.78 ms | 7.84 / 7.65 ms | **-11 %** |
  | render GPU p95 | 9.45 / 9.40 ms | 8.64 / 8.04 ms | -11 % |
  | GPU shared memory max | 1119 / 1118 MB | 568 / 601 MB | **-48 % (-534 MB)** |
  | private RAM max | 1493 / 1494 MB | 1213 / 1055 MB | -24 % (wide spread) |
  | pinned CPU p50 | 6.7 / 6.9 % | 6.3 / 5.8 % | noise |

  Kept (world's change, the owner's p-1 B): on a 16 GB shared-memory Deck the city fits in about half the GPU memory
  and the iGPU has ~1 ms more headroom. JSONs: `evidence/n9h/it1/bc7/`. Re-take under the bench lock once main has it.
- **E18 tooling (n9 it4), a slower core on this PC:** `tools/handheld/cpu_cap.ps1` puts the game in a Windows job
  object with a CPU-rate **hard cap** of N % of one logical CPU (`sim.mjs --cpu-cap=<pct>`; the JSON records
  `cpu_cap`). Checked on a busy loop: cap 50 % -> 51 % measured, 25 % -> 27 %. Smoke on the game (`deck`, city,
  600 ticks, cap 55 %, CONTENDED by 4 other Godot runs, no bench lock: indicative only): the job took the process,
  frame p50 16.68 ms (60 holds), p99 27.6 ms, 2 settled frames > 33 ms, the game used ~0.545 of a CPU (= the cap; E15's
  uncapped demand is ~0.53, so 55 % barely binds). Owed (E18): 45 / 35 / 25 % under the bench lock, interleaved, to
  find where 60 Hz and the 40 Hz row break. Caveat: a rate cap throttles in slices, so it models a slower core's
  throughput, not its latency (`evidence/n9h/it4/e18-smoke/`).
- **E16b (n9 it4), the re-take under the bench lock**, on world's later head b0f1024e (BC7 since 746c2856, plus the
  dead redesign and the car knock-down) in my own detached worktree (`gtai-n9/tmp/handheld/w16`, its `.godot` copied
  from perf's world3 at 746c2856 and re-imported, 0 SCRIPT ERROR; `devices.json` `zoom_k` 1.25 locally) vs this branch
  at 7c993d29 (lossless). `ab.mjs --rounds=3`, `sim.mjs --device=deck --scene=city --ticks=1200`, the 2-CU iGPU,
  8 pinned threads, below-normal priority, **bench.lock held** for the 6 runs; 3 of 6 runs saw 1 other Godot process
  (CONTENDED, labelled per run: lossless 1 / 3, BC7 2 / 3). Median of 3 (spread = max - min):

  | metric | lossless | BC7 | change |
  |---|---|---|---|
  | frame p50 (vsync 60) | 16.64 (+-0.04) ms | 16.66 (+-0.04) ms | locked both |
  | frame p99 | 19.86 (+-1.32) ms | 19.83 (+-0.54) ms | noise |
  | settled frames > 33 ms | 0 (+-3) | 0 (+-0) | noise (round 1, contended, had 3 in the lossless arm) |
  | render GPU p50 | 8.53 (+-0.24) ms | 7.59 (+-0.12) ms | **-11 %** (outside both spreads) |
  | GPU shared memory max | 1086 (+-64) MB | 600 (+-65) MB | **-45 % (-486 MB)** |
  | private RAM max | 1476 (+-70) MB | 991 (+-70) MB | **-33 % (-485 MB)** |
  | pinned CPU p50 | 6.34 (+-1.2) % | 5.96 (+-0.7) % | noise |

  **Confirms E16** with three rounds and the lock: the render GPU saving (-11 %) and the shared-memory halving hold,
  and the private-RAM drop that was "wide spread" in E16 is now clear of the noise (-485 MB, spreads 70 MB). Same
  confound as E16, in BC7's disfavour: world's tree also runs sim bikes at 6 % and the redesigned dead. On a Deck
  (16 GB unified, ~1 GB carved for the GPU by default, the rest shared) the city's GPU memory now fits under 0.6 GB.
  No handheld-only BC7 step is needed (world lands BC7 in every build; `tools/handheld/bc7_arm.mjs` stays as a study
  tool). JSONs and the log: `evidence/n9h/it4/e16b/`.

- **E17 (n9 it2), the 40 Hz row at the new zoom:** `deck` (60 cap) vs `deck40` (40 cap), both 40 px/m, city, 1200
  ticks, the iGPU, 8 pinned threads, 3 interleaved rounds (`tools/handheld/ab.mjs`), bench lock held about 02:05-02:12;
  **all 6 runs CONTENDED** (other lanes' Godot runs up): the ms are indicative, the ratios are what we keep.

  | metric (median of 3, +- spread) | deck (60) | deck40 (40) | change |
  |---|---|---|---|
  | frame p50 | 16.63 +-0.01 ms | 25.05 +-0.10 ms | locked at the cap both |
  | render GPU per frame p50 | 8.92 +-0.66 ms | 9.30 +-0.07 ms | the same work per frame |
  | **GPU busy per second** (fps x render GPU) | ~535 ms (54 %) | ~372 ms (37 %) | **-30 %** |
  | **pinned CPU p50** | 7.12 +-2.09 % | 5.38 +-1.10 % | **-24 %** |
  | private RAM max | 1493 MB | 1429 MB | noise (+-65) |

  Confirms E5 (d9, at 48 px/m: GPU busy 55 -> 38 %, pinned CPU -26 %) at the owner's 40 px/m: the zoom did not move
  the 40 Hz saving. The APU's power should track that busy share (inferred: only a Deck can measure watts), so the 40 Hz row is the battery mode (the player's
  frame cap in the pause card reaches it). JSONs: `evidence/n9h/it2/e17/`.

- **The keyboard twin (n9 it3, an owner Call):** `ui_kb_glyphs_v1` (the asset lane's own-list delivery, 38 cells incl.
  `move_keys`, `aim_mouse`, `mouse_left`, wide SPACE / Shift / Ctrl / Tab) draws in the same three places as the pad set,
  but only on the desktop study row `desktop_kb_glyphs` (`glyphs: kb`; `is_desktop()` stays true, nothing else is
  applied). `GlyphCells` holds both sets (atlas, ink-box json, label -> cell); `PadGlyphArt.glyph_set()` picks pad on a
  handheld row, kb on the study row, none on the shipped desktop. The key labels are what `ObjectiveHint.key_name`
  returns from the InputMap (`W A S D`, `mouse`, `LMB`, `Space`, `E`, `Escape`), so a rebind follows; a key with no cell
  stays bracketed text. Wide keys cap at 2.4 heights (SPACE was 0.55 g tall at the pad set's 1.5). Stills (RTX, 1280x800):
  `gtai-masters/n9/handheld/kbglyphs-desktop-title-after.png` vs `kbglyphs-desktop-title-before.png` (the shipped text),
  `kbglyphs-desktop-title-prompt-crop-x2.png`. Valve's rule "prompts do not flip to keyboard glyphs unless the mouse is
  really used" is about the handheld rows (they stay pad); this row is a desktop look. Owner Call: ship it on the desktop?
