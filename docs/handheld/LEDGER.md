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
- **Single-thread speed vs this PC** (researched n9 it5, for E15 / E18): Cinebench R23 single-core, the Deck's APU
  ~975 ([cpu-monkey](https://www.cpu-monkey.com/en/cpu-valve_steam_deck_amd_custom_apu_0405)), the 7800X3D stock 1796
  ([overclocking.com review](https://en.overclocking.com/review-amd-ryzen-7-7800x3d-the-new-king-of-gaming/5/)):
  **~1.84x** per thread (E15's model estimate was 1.6-2x). A render benchmark, not a game: the X3D's cache helps a
  game's main thread more, and the Deck's CPU clocks below 3.5 GHz when the GPU takes the 15 W, so the real gap in
  play is likely wider *(model knowledge)*. One Deck core is ~0.54 of one core here at best.
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

- **The boss camera on handheld rows (n9 it6, DECISION `handheld/boss-cam`):** the boss fights use `BossCam` (frames
  Rivet and the boss together, the screen kept on the fight's floor) on every handheld row (`boss_cam: true`); the
  desktop keeps the follow camera. Servo at t900 on `deck_bench`: the follow camera showed half the screen as paper
  past the yard's edge (also on `deck_bench_z1` and the desktop); the boss cam fills it with the yard, Servo and Rivet
  both in (t1800 too). The King's road is narrower than the 20 m-tall screen, so paper below it stays either way.
  Stills: `gtai-masters/n9/handheld/bosscam-deck-servo-before-after-40ppm-1280x800-t900.png`, `evidence/n9h/it6/bosscam/`.
  In motion (`deck-servo-40ppm-bosscam-1280x800-igpu.mp4`, 45 s, movie maker, the iGPU, 0 SCRIPT ERROR): the
  frame-to-frame luma difference over 2699 frames has no single-frame jump; its highest runs are ~0.5 s pans while
  Servo charges (~12 px a frame), continuous (`evidence/n9h/it6/bosscam/motion/`). BossCam sets the focus with no
  damping; a critically damped follow is the lever if a Deck playtest finds the charges busy (owed, not built).
  **The King clip finds a snap** (`deck-king-40ppm-bosscam-1280x800-igpu.mp4`, 45 s, 0 SCRIPT ERROR): one isolated
  frame-difference spike (20.0 at frame 155, every other frame <= 12.3) is a one-frame camera jump of ~60 px vertical
  (`motion/king-snap-frames-152-157.png`). Rivet is ~16 m from the King there, near BossCam's FAR_M 20 m switch
  (follow Rivet alone vs 0.45 of the way to the boss), the suspected cause (not yet proven). It is in BossCam itself,
  so the dev `--boss-cam` clips share it. Fix owed (it7): a damped focus, or a blended FAR_M band instead of a switch.
  **Fixed n9 it7 (2d6a14a7, DECISION handheld/boss-cam-band).** Proven first: a per-frame focus log (a temporary Log line,
  not committed) shows frame 154 at d = 19.82 m, where the focus y stepped 76 px as `at` switched from Rivet to 0.45 of
  the way to the King (the x was already held by the boss margin, so only y jumped). Now `BossCam.aim` fades the lean on a
  smoothstep between NEAR_M 14 m and FAR_M 28 m (within 14 m the framing is exactly as before); unit test: the boss closing
  0.25 m a tick from 30 to 10 m moves the focus < 0.4 m a tick. The focus log over 2700 frames: worst move 11.3 px (King),
  14.7 px (Servo's charges). Re-filmed (`deck-king-40ppm-bosscam-band-1280x800-igpu.mp4`, sim.mjs, iGPU, 0 SCRIPT ERROR) and
  read by **phase correlation** per frame (`evidence/n9h/it7/bosscam/pancorr.py`, the image shift itself, not a luma
  difference, which the ground's grain dominates under any pan): the 62 px jump at frame 155 is gone; the largest one-frame
  moves left are 24 px (frame 1265) and 20 px (707), identical in both clips, each a start from rest that then runs at
  6-10 px. **Not FeelCam** (a temporary Log on every kick and shake, `evidence/n9h/it7/bosscam/king-kicks-probe.txt`:
  the King run's kicks are 1-1.5 px and none fires at ticks 709 or 1267). The focus log shows what they are: **a step in
  the camera's speed**, not in its place: at frame 738 the focus's vertical speed goes 1.0 -> 9.9 px a frame in one frame,
  at 1280 -3.6 -> +11.2 (the boss or Rivet reaching a keep-in margin, after which the camera moves at their speed). The
  image shift reads ~2x the focus log's px (24 vs 11.2; the log converts at 40 px/m, unexplained, owed). The cure is an
  acceleration limit on the focus (a speed that ramps over a few frames), not a lagging damper: owed (it8).
  **Corrected in it8:** those two moves are **not the camera**. With the ease below on, frames 707 and 1265 read the same
  24 / 20 px; phase correlation on the ground band alone (y 420-620 of 800, no telegraph, no boss) reads -1..+1 px a
  frame through both, while the top band (the King's car and the red telegraph wedge) carries the 20 / 8 px: a large
  moving object won the whole-frame correlation. it7's tie to the focus log was a mis-mapping (its two offsets, 31 and
  15 frames, disagreed; video frame n = tick n+2). Lesson for the tool: correlate a band of static ground, not the frame.
- **The boss cam ease (n9 it8, 630f91a7, DECISION `handheld/boss-cam-ease`).** The framing itself does jolt: the focus
  log (a temporary Log line, the Deck row, 40 px/m, 2700 ticks each) shows its speed changing up to 15.4 px a tick in
  one tick (King: ticks 149, 162, 737, 1279, 1336; 15 ticks over 4 px/tick^2) and 14.6 (Servo, 19 ticks). `CamFollow`
  keeps a velocity, changes it by at most `ACCEL_PX` screen px a sim tick, brakes on the discrete square-root law and
  matches the framing's speed (no lag in a steady pan); past 10 m it cuts. It steps on the sim tick (`BossFight.now()`),
  so `deck40`'s 2-tick frames and the hit-stops move as at 60. The limit chosen by replaying the recorded framing
  through the same law (`evidence/n9h/it8/ease/sweep.py`; it reproduces the in-game 2.0 run exactly, lag 42.4 px, peak
  15.9):

  | ACCEL_PX | King: worst accel / peak speed / worst lag / ticks > 4 | Servo: the same |
  |---|---|---|
  | 0 (the framing) | 15.4 / 11.3 / 0 / 15 | 14.6 / 14.7 / 0 / 19 |
  | 2.0 | 2.0 / 15.9 / 42 / 0 | 2.0 / 22.0 / **86** (past Rivet's 1.5 m margin) / 0 |
  | **3.0 (kept)** | **3.0 / 17.3 / 28 / 0** | **3.0 / 21.1 / 28.5 / 0** |
  | 4.0 | 4.0 / 16.5 / 21 / 20 | 4.0 / 20.8 / 37 / 31 |

  In game at 3.0 (both fights, the RTX, 0 SCRIPT ERROR): King 3.1 / 17.3 / 28.3 px / 0, Servo 3.0 / 21.1 / 28.5 px / 0.
  The worst lag (0.7 m) sits inside Rivet's 1.5 m and the boss's 3 m margins, so neither leaves the screen. The cost:
  a brief catch-up after a jolt runs faster than the framing's own peak (11.3 -> 17.3 px/tick King). Hit-stops still
  stop the camera dead (the sim holds; the same with or without). Clips: `deck-king-40ppm-bosscam-ease-before-after-halfspeed.mp4`
  (the two worst jolts, half speed), `deck-king-40ppm-bosscam-ease-1280x800-igpu.mp4` (45 s). Mutation score on
  `cam_follow.gd`: 19/20 (95 %); the survivor (a hit-stop on the very first frame) then killed by a test (8c1acea1).
- **Scoping note (n9 it8): drawing between ticks, the cure for 40 Hz (E21).** `SimClock.alpha()` already exists
  (accumulator / TICK_DT) and no view reads it: every view draws the last tick, so a 25 ms frame shows 1 or 2 ticks
  of motion. Drawing at `tick - 1 + alpha` (the previous and the current tick's positions, lerped) makes each 40 Hz
  frame advance exactly 1.5 ticks (the remainder pattern 0.5, 0 alternates with the 1, 2 tick counts), at the cost of
  one tick (16.7 ms) of display latency. It is view only (SIM-03 safe; replay, parity and goldens untouched when
  alpha is not read). Size: 18 view files read sim positions directly (`.pos`: collect_call 6, souls 5, bosses 3,
  vehicles, player, combat, arena 1 each), plus the city's native buffers (vehicles, crowds) and the cameras
  (FeelCam, BossCam, CollectCallView); each needs the previous tick's copy. The camera alone is not enough: with
  only the camera smoothed, the sprites it follows (Rivet) would judder against a smooth background. Estimate:
  2-3 days with a per-tick snapshot helper and a parity-style test; until then 30 and 60 are the even modes
  (REPORT Call 4). OWED, not started. KEPT (handheld rows and `--boss-cam` only; `--boss-cam-ease=off` is the before).

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

**n9 it5: the boss count lifted (3778c3ac, DECISION `handheld/boss-count-18`).** The one text at the floor, the boss
bar's "1 / 3", draws at 18 px on the compact-HUD rows (`BossBar.count_px`; the desktop keeps 16, its right end kept on
the banner). The walk re-run (`evidence/n9h/it5/legibility-{deck,switch_handheld}/`, 0 SCRIPT ERROR): **`deck` x 9 ->
10 / cap 12 -> 13, so every text on the Deck row now has x-height >= 10 px** (the smallest are the pause card's 18 px
-, + and Toggle, x 10 / cap 13); `switch_handheld` x 8 -> 9 / cap 10 -> 12 (no text below 9 under either reading).
On the pixels of the King arena (iGPU, t = 14 s, `--seed=2`): the digit height 12 -> 13 px on `deck` (`deck_hud_full`
is the 16 px before side), 10 -> 11 px at 720p. Still: `gtai-masters/n9/handheld/count-deck-16-vs-18-crop-x4.png`.

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

## 7. Port readiness (re-laid out at n9 it10, updated n10; every claim is "on the simulator" unless it says otherwise)

| device | state on the simulator | the next step a port needs | only real hardware can prove | effort |
|---|---|---|---|---|
| Steam Deck | **plays end to end on the pad at 1280x800**, 40 px/m, vsync-locked 60 on the 2-CU iGPU with ~7 ms spare (render GPU 7.7 ms, 0.6 GB GPU memory, ~1 GB RAM with world's BC7, E20/E20b); text above Valve's 9 px; native Linux build runs in WSLg | a real Vulkan run of the Linux build (or the Windows build under Proton); vendoring GodotSteam (the Deck check and the glyph call are stubbed behind the interface, one call each, n10) | Zen 2 frame times at 4-15 W, battery hours, the first-run shader cache, suspend on SteamOS, the 90 Hz OLED | Linux + Proton check 2-3 days; Verified polish 3-5 days |
| Windows handhelds | the Deck work applies (`handheld_1080` is a handheld row); 1080p drawn at 1280x800 and scaled holds 60 at 9.9 ms GPU (E9); text x >= 12 px; 22 firmware strings from public tables pick the row by themselves (ROG Ally and Ally X, Legion Go / Go S / Go 2, AYANEO, AYN, GPD, OneXPlayer, section 9) | the firmware strings of the MSI Claw line and the ROG Xbox Ally (one device each, or a DMI dump); a controller-first shell (launch and play with no mouse); Windows display scaling 125-200 % | the Z1 / Z2 / Lunar Lake drivers, VRR, TDP presets, the 1.35x scale-up on a 7-8" panel | 1-2 days on top of the Deck |
| Switch-class | a **budget only** (`switch_handheld`: 1280x720, 30 cap, 3 threads, the iGPU): the 30 cap holds; the city 1.38 GB with BC7 (E11) | everything: the platform holder's developer program, a kit, an engine port for 4.7, CitySim for aarch64 | all of it (an A57-class core is the CPU risk) | 3-6 months per platform; $800-$10,000/yr middleware + kits under NDA |

### Steam Deck

Works on the simulator (8 pinned threads, the 2-CU Radeon iGPU, below-normal priority):
- **Framing and look.** 40 px/m on every handheld row (owner h-1 B); full draw scale; combo costs nothing measurable over
  tilt70 (E19). The boss fights frame Rivet and the boss together (BossCam, it6), the lean fades on a 14-28 m blend
  (no 76 px snap, it7) and the focus eases (jolts 15 -> 3 px/tick^2, CamFollow, it8). Clips of the King, Servo, the
  city at combo and quest 1 at 1280x800 on the iGPU (masters `frames.json`).
- **Speed and memory.** Re-based on this branch + n9-world (E20, re-taken on world's near-final head in E20b): vsync-locked
  60, render GPU ~7.7 ms, ~0.6 GB GPU shared memory, ~1 GB private RAM; world's BC7 is the memory win (E16b: -45 % GPU
  shared, -33 % RAM, render GPU -11 %). The 40 Hz row cuts GPU busy ~30 % and pinned CPU ~25 % (E5, E17, E17c) but
  judders 1:2 (E21); `deck30` is even and a further -25 % GPU busy (E21b). The CPU side is one thread: the main thread
  carries 0.53 cores at 60 Hz (E15), bounded at ~0.55-0.92 of one Deck core (E18, an estimate: the CPU-cap simulation
  freezes instead of slowing).
- **Pad-first play.** Every action on the pad (section 5); every quest 1 card (title, pause, failed, paid) walked on pad
  events alone, the pause card keeps the pad's focus; the drawn ink pad glyphs in the prompts, the controls lines and the
  ghost card per pad family (Xbox / PlayStation / Nintendo-layout, section 8); a handheld row starts pad-first (it9) and
  only a click or a key flips the prompts to the keys, trackpad motion still aims (Valve's rule, it9); rumble on the bus
  events with a level in the pause card (full / half / off); no text entry, so no on-screen keyboard is needed.
- **Legibility.** The compact ghost-form card (half the area, 18 px text kept, owner h-3 B); the runtime probe over
  quest 1's title, HUD and pause card: every x-height >= 10 px, every cap >= 13 on the Deck row (Valve's floor 9 px).
- **Platform behaviour.** A Deck picks the `deck` row by itself (Steam's `SteamDeck=1` and a 1280x800 panel, it10;
  docked it keeps the desktop); a player frame cap (device / 30 / 40 / 60) in the pause card; focus-out pauses quest 1; a 20 s
  process freeze resumes cleanly; the native Linux build (sniper-SDK `.so`, `linux-showcase`) runs the city in WSLg;
  replays hold across editor / release and Windows / Linux, the release `.so` included (E13c), and a quest 1 autosave
  resumes across the two OSes at the same hash (E14). DECISION handheld/linux-depot: a native Linux depot, Proton as
  the fallback.

Owed (in order):
1. The Linux build's real Vulkan run on a Deck or a Linux PC (WSLg has no Vulkan on D3D12); the fallback check is the
   Windows build under Proton with `driver.windows=vulkan` (D3D12 would go through vkd3d-proton).
2. Vendoring GodotSteam (STM-01), then the two stubbed calls in `steam_backend.gd`: the hardware type (the auto-pick's
   first check, n10; SDK 1.65 removed `IsSteamRunningOnSteamDeck`, section 9) and Steam Input origin glyphs for a remapped
   pad; the drawn set covers the default layouts. `SteamGlyphs` already asks `Platform.action_glyph_path` from the prompts (n10 it5), so the backend's line is the swap.
3. A `just native` recipe for the sniper-container Linux build (parity on the `.so` is proven, E13).
4. Rumble on blasts and car crashes (no bus event today).
5. If the owner picks a 40 Hz mode: every view drawn between two ticks (~2-3 days, the scoping note under E21).
6. Install size: with BC7 the pck is ~412 MB vs ~218 MB lossless (perf, n9 it9); ~155 MB download (LZMA estimate).
   Fine on every Deck model's storage; worth a line in the store page's requirements.

Only a Deck can prove: frame times on Zen 2 at 4-15 W, battery hours, the first-run shader cache, Steam Input's default
config, suspend / resume on SteamOS, the 90 Hz OLED panel.

### Windows handhelds

Works: a listed firmware model picks `handheld_1080` by itself and opens fullscreen (section 9: 22 strings from public tables; the
MSI Claw line and the ROG Xbox Ally are not); every handheld-row change applies to `handheld_1080` (40 px/m, the compact card, the drawn glyphs); the 1080p
screen drawn at 1280x800 and scaled (stretch `viewport`) holds 60 at 9.9 ms GPU where the native 1080 draw misses at
16.1 ms (E9); the 16:9 drawn frame is 1422x800 and the HUD fits (it10 still); texts measure x >= 12 px at 1080.
Owed: a controller-first shell (launch and play with no mouse); Windows display scaling at 125-200 %.
Only the hardware: the Z1 / Z2 / Lunar Lake drivers, VRR, TDP presets, the 1.35x scale-up's look on a 7-8" panel.

### Switch-class (a budget, no SDK touched)

Works as a budget: `switch_handheld` (1280x720, 30 cap, 3 threads, the iGPU) holds its 30 cap in the reel and the city;
~2.3 GB RAM + GPU memory lossless (E7), the city 1.38 GB and the reel 1.13 GB with BC7 (E11), so the 2017 console's
~3.2 GB is reachable on memory and the 2025 successor's ~9 GB is not a concern. The 40 px/m zoom and the compact card
apply; at 720p the boss count "1 / 3" draws cap 10 px (legible on a still, section 8); the Nintendo-layout names have
their own drawn cells, "+" / "-" included (assets it127).
Owed: everything a console port needs: the platform holder's developer program and a dev kit, an engine port (the
third-party console porters list Godot 4.4-4.6; the project is on 4.7), CitySim statically linked for aarch64, replay
and parity re-proved on ARM. The CPU on an A57-class core is the risk the simulator cannot model.
Effort: 3-6 months per platform (a porting studio or the porter's middleware plus our own work), $800-$10,000 a year
for middleware plus kits under NDA.

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
- **E18 (n9 it5), the slower-core sweep: DROPPED as a model** (the finding kept). `ab.mjs --rounds=3`, `deck`, city,
  1200 ticks, pinned to 2 threads (1 core + SMT), the 2-CU iGPU, below-normal priority, **bench.lock held** 04:28-04:40;
  5 of 12 runs CONTENDED (1-2 other Godot runs, labelled per run). Read per frame by
  `evidence/n9h/it5/e18/analyse.mjs` (the sim's ticks per wall second from frame 60 on: real time = 60; stalls = frames
  over 100 ms). Medians of 3, the spread in brackets:

  | cap (of one logical CPU) | frame p50 | ticks / s | stalls > 100 ms | worst frame | settled > 33 ms |
  |---|---|---|---|---|---|
  | none (uses 0.40-0.50 core) | 16.62 ms | **59.94** (59.92-59.99) | **0** (0-0) | 21-24 ms | 0 (0-2) |
  | 45 % | 16.65 ms | 47.9 (35.6-58.3) | 2 (2-39) | 0.5-3.5 s | 13 (4-77) |
  | 35 % | 16.62 ms | 52.9 (51.1-56.3) | 28 (2-36) | 0.2-1.1 s | 41 (11-44) |
  | 25 % | 16.62 ms | 55.0 (39.2-56.5) | 3 (2-51) | 0.4-1.2 s | 14 (4-61) |

  **Why dropped:** every cap leaves p50 on the 60 Hz vsync and instead freezes the game for 0.2-3.5 s at a time, and
  the result does not fall in order with the cap (45 % is worse than 25 %): Windows' hard cap lets the process run at
  full speed until its share for the interval is spent, then stops it. A slower core stretches every frame a little;
  this stretches none and stops some. It cannot place the 60 Hz break, so the 40 Hz half was not run (stopped before
  its first run, the lock released). **The finding kept:** the uncapped game's 0.40-0.50 core at 60 Hz (E15: 0.53)
  is not all work. `wall - pump` (pump = the pacing wait) shows the frame mostly waiting, and a 25 % cap still moved
  the sim at 55 ticks/s between freezes, catching up ticks without drawing. So E15's "0.85-1.05 of a Deck core" is an
  upper bound. With the sourced 1.84x (section 1), the real demand sits somewhere between ~0.3 and ~0.5 core here,
  **~0.55-0.92 of one Deck core at 60 Hz** (an estimate on a render benchmark's ratio, not a measurement). Only a
  Deck can settle it (port readiness: "real frame times on Zen 2"). `cpu_cap.ps1` stays as a sustained-throughput
  check, labelled as such. The lever stays the same: the 40 Hz row (E17) or work off the main thread.
  JSONs: `evidence/sim/e18-deck60/` (+ `e18-deck60.txt`), the analysis table `evidence/n9h/it5/e18/table.txt`.
- **E19 (n9 it5), the combo switch on the Deck row:** world's branch boots `combo` (3e02d3b8), so after the merge the
  handheld rows play the city in combo, while every Deck city number so far was tilt70. `sim.mjs --scene=city_combo`
  (new) vs `--scene=city`, `deck_bench` (uncapped: the frame is the cost), 1200 ticks, 8 pinned threads, the 2-CU
  iGPU, `ab.mjs --rounds=3`, bench.lock held 04:59-05:03, **all 6 runs CONTENDED** (1 other Godot run). Medians of 3:
  frame p50 9.21 (+-0.24) vs 9.40 (+-0.30) ms; p99 13.85 vs 14.09 ms; render GPU p50 8.39 vs 8.38 ms; process 3.91
  vs 3.98 ms; GPU shared 1055 vs 1118 MB (+-65); private RAM 1473 vs 1494 MB (+-63). **Every delta is inside the
  spread: no measured cost for combo on the Deck row**; the 60 Hz frame keeps ~7 ms of headroom on the weaker-than-Deck
  iGPU. Still at 40 px/m: `evidence/n9h/it5/combo/deck-city-combo-t14.png` (framing reads; the compact card clear of
  the street). Lossless textures on this branch: world's BC7 takes ~0.5 GB of GPU memory off both arms (E16b).
  JSONs: `evidence/sim/e19-combo-city/`.
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

- **E17c (n9 it6), the 40 Hz row on combo** (the view main plays after world's switch): `deck` vs `deck40` on
  `sim.mjs --scene=city_combo`, 1200 ticks, the iGPU, 8 pinned threads, 3 interleaved rounds, bench lock held
  05:17-05:22, all 6 runs CONTENDED (1-2 other Godots).

  | metric (median of 3, +- spread) | deck (60) | deck40 (40) | change |
  |---|---|---|---|
  | frame p50 | 16.66 +-0.02 ms | 24.94 +-0.28 ms | locked at the cap both |
  | render GPU per frame p50 | 8.73 +-0.33 ms | 8.96 +-0.12 ms | the same work per frame |
  | **GPU busy per second** (fps x render GPU) | ~524 ms (52 %) | ~358 ms (36 %) | **-32 %** |
  | **pinned CPU p50** | 6.34 +-2.71 % | 4.71 +-0.45 % | **-26 %** |
  | settled frames > 33 ms | 0 +-1 | 1 +-1 | noise |
  | private RAM / GPU shared max | 1494 / 1118 MB | 1495 / 1118 MB | the same |

  The combo view keeps the 40 Hz saving (E17 tilt70: -30 % / -24 %; E5 d9: -31 % / -26 %): three views and two zooms
  agree, so the battery-mode call (REPORT Call 4) does not depend on the view. JSONs: `evidence/n9h/it6/e17c/`.

- **E21 (n9 it7), the 40 Hz cadence and a 30 fps row.** Filmed at each row's own rate (`sim.mjs --movie-fps=<n>`, the
  movie maker hands Godot exactly 1/n s a frame, as a locked panel would): the King, the boss cam, the iGPU, 45 s of sim,
  the image shift per frame by phase correlation (`evidence/n9h/it7/bosscam/pancorr.py`). The 60 Hz tick over 25 ms
  frames runs **1, 2, 1, 2 ticks a frame** on `deck40` (899 / 900 frames), so a steady camera pan steps 10, 20, 10, 20 px:
  over consecutive panning frame pairs (both >= 6 px) the step unevenness |a-b|/max(a,b) has median **0.50** on `deck40`
  (73 % of pairs >= 0.4) against **0.00** on `deck` (60) and on the new **`deck30`** row (30 fps, 2 ticks every frame;
  2 % / 5 % of pairs >= 0.4) (`evidence/n9h/it7/cadence/cadence.txt`). The sprites step the same way (the whole view
  is drawn from the last tick). The cure for 40 Hz is drawing every view at an interpolated alpha between two sim
  states (owed, not small); 30 is the even battery mode the game can already offer (the pause card's cap has 30).
  The battery proxy (E17c recipe: `city_combo`, 1200 ticks, iGPU, 8 pinned threads, 3 interleaved rounds, bench lock
  06:33-06:37, 5 / 6 runs CONTENDED):

  | metric (median of 3, +- spread) | deck40 (40) | deck30 (30) | change |
  |---|---|---|---|
  | frame p50 | 25.07 +-0.15 ms | 33.28 +-0.09 ms | locked at the cap both |
  | render GPU per frame p50 | 8.98 +-0.29 ms | 9.01 +-0.24 ms | the same work per frame |
  | **GPU busy per second** (fps x render GPU) | ~359 ms (36 %) | ~270 ms (27 %) | **-25 %** (-48 % vs 60, E17c's 524 ms) |
  | pinned CPU p50 | 4.71 +-0.15 % | 4.32 +-0.40 % | -8 %, at the noise: the sim still ticks 60 Hz |
  | private RAM / GPU shared max | 1492 / 1118 MB | 1427 / 1054 MB | inside the +-64 MB spread |

  `over33_settled` 357 on `deck30` is the cap itself (every frame 33.3 ms), not a hitch. JSON: `evidence/n9h/it7/e21b/`.
  Kept: the `deck30` row (7a6681e2, DECISION handheld/deck30-row); the default stays `deck` (60); the pick is Call 4.

- **E20 (n9 it6), the Deck row re-based on what main will be:** a scratch worktree (`gtai-n9/tmp/handheld/mergewt`) =
  this branch at eff2388f merged with n9-world at d5006d22 (combo boot, sim bikes 6 %, BC7, the plan-pose dead, cars
  knock Rivet down, bodies stop at walls), world's native DLLs, world's `.godot` copied then `--import` (23 s, 0 errors).
  **The code merges cleanly**: only `JOURNAL.md` (add/add) and `tools/debt/baseline.json` conflict (take either side,
  re-run `debt.mjs --update`). `deck`, `city_combo`, 1200 ticks, the iGPU, 3 interleaved rounds, bench lock, 3 of 6 runs
  quiet.

  | metric (median of 3, +- spread) | this branch | + n9-world (main-to-be) | change |
  |---|---|---|---|
  | frame p50 (vsync 60) | 16.64 +-0.06 ms | 16.66 +-0.04 ms | locked both |
  | settled frames > 33 ms | 0 +-2 | 0 +-2 | the same |
  | render GPU p50 | 8.65 +-0.16 ms | 7.69 +-0.34 ms | **-11 %** |
  | GPU shared memory max | 1055 +-64 MB | 600 +-65 MB | **-43 %** |
  | private RAM max | 1430 +-64 MB | 991 +-69 MB | **-31 %** |
  | pinned CPU p50 | 6.53 +-1.32 % | 6.68 +-0.69 % | the same (bikes, knock-downs and the dead cost no measured CPU) |

  The Deck baseline after tonight's merge: vsync-locked 60 with render GPU ~7.7 ms on a GPU a quarter of a Deck's,
  ~1 GB private RAM, 0.6 GB GPU memory. E16b's BC7 gain carries through world's later work unchanged. JSONs:
  `evidence/n9h/it6/e20/`.

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
- **Pad-first on the handheld rows (n9 it9, 2f842523, DECISION `handheld/pad-first`).** Found on film: quest 1 pad-only
  on the Deck row (the pad walker: A on the title, no stick) showed the first prompt as "Walk [W A S D] to the dumpster,
  hide: [E]" for the ~6 s until the stick moved, because `LiveInput.pad_last` started false in every session and the
  title card consumed the pad's press. Valve's Deck Verified input rule (section 1): the default glyphs match the Deck's
  controls. Now `LiveInput._init` seeds `pad_last = is_handheld()` and `mouse_aims = not pad_last`; a key or the mouse
  still hands the prompts back. Before/after still `gtai-masters/n9/handheld/padfirst-deck-quest1-first-prompt-before-after-crop-x2.png`.
  Re-check: a docked Deck with a keyboard (the first device used should then win).
- **The Deck set at combo (n9 it9, iGPU, movie mode, CONTENDED):** the city (`deck-city-combo-40ppm-1280x800-igpu.mp4`)
  and quest 1 Dock 9 (`deck-quest1-dock9-combo-40ppm-1280x800-igpu.mp4`, scratch walker `evidence/n9h/it9/q1film/`).
  Looked at: at Dock 9 the top-right money + weapon cards (~340x220 px, 27 % x 27 % of 1280x800) sit over the crate row
  while the objective is the rifle; HudSee fades that corner once the crates are the goal (n8-hud), so no change. Rivet
  reads small beside the contractors on this branch (1.1 m; rivet's lane brings 1.65 m).
- **Click-only flips on the handheld rows (n9 it9, b7621d73, DECISION `handheld/click-flips`).** Valve's recommendations
  page, re-read in it9 ([recommendations](https://partner.steamgames.com/doc/steamdeck/recommendations)): prompts
  "changing between controller and keyboard/mouse icons" is listed as a common problem; "only switching to
  mouse/keyboard mode if a mouse click event is received"; mouse events should move the camera "without perturbing
  simultaneous controller functionality". `LiveInput.click_flips` (= is_handheld()): mouse motion sets `mouse_aims` but
  leaves `pad_last`; a click or a key clears it. Shown live (the pad walker + one mouse motion, iGPU; before = b7621d73~):
  `gtai-masters/n9/handheld/clickflips-deck-quest1-prompt-after-mouse-motion-before-after-crop-x2.png`. Owed with the Steam
  port: Steam Input action origins decide the glyphs.
- **A Deck picks its own row (n9 it10, DECISION `handheld/deck-auto-pick`).** Found while laying out section 7: every
  handheld-row change switched on only behind `--device=`, and a real Deck launches the game with no flags, so a Deck
  player would have got the desktop game at 32 px/m with the key prompts. Research: the Steam client on SteamOS puts
  `SteamDeck=1` in the environment of every process it starts, in game mode and desktop mode alike; players can override
  it per game (`SteamDeck=0 %command%`); SteamOS-based desktops report it too (a Bazzite user on Klei's forum), so it is
  not enough alone; Steamworks' `ISteamUtils::IsSteamRunningOnSteamDeck()` (SDK 1.52+) is the authoritative check
  ([UE forum guide](https://forums.unrealengine.com/t/steam-deck-and-ue4-ue5-a-guide/503473/10),
  [Klei forum](https://kleiforums.com/forums/topic/166396-steam-deck-linux/),
  [Unity discussion](https://discussions.unity.com/t/check-if-running-on-steam-deck/878134)). Built:
  `DeviceProfile.auto_pick(env, screen)`: `deck` when the variable is `1` and the screen is 1280x800 (either way up);
  `LaunchArgs._init` asks it only when there is no `--device=` and the variable is set, so the desktop never reaches
  the screen query. A docked Deck (a 1080p TV) and other SteamOS boxes keep the desktop row. Owed with the Steam
  port: `IsSteamRunningOnSteamDeck()` through `steam_backend.gd` as the first check. Only a Deck can prove what
  gamescope reports as the screen size in game mode (the panel is natively portrait; both ways are accepted).
  Follow-up (DECISION `handheld/deck-fills-screen`): an auto-picked Deck opens fullscreen (`fill_screen`), so desktop
  mode's taskbar does not cover a 1280x800 window; `--device=` keeps the simulator's window (live `--device=deck`:
  window 1280x800 as before). The fullscreen path is proven by a unit test only; a Deck in desktop mode proves it.
- **E20b (n9 it10), the Deck rows re-based on world's near-final head:** scratch worktree `gtai-n9/tmp/handheld/mergewt2`
  = this branch (b89d9e22) + `merge --no-commit n9-world` (code head e3c54005: BC7, combo, bikes 6 %, the dead
  redesign, the knock-down, the robe); again only JOURNAL, REPORT and the debt baseline conflict, the code merges
  cleanly. `ab.mjs --rounds=3`, city_combo, 1200 ticks, 8 pinned threads, the 2-CU iGPU, **bench lock held**, but
  **all 12 runs CONTENDED** (2-7 other Godot runs from the other lanes): the medians are indicative, the memory is not
  load-sensitive. (The branch arm picked up this iteration's launch_args edit from round 1 on; with `--device=` the
  path is the same code.) Medians of 3 (spread = max - min):

  | metric | `deck` branch | `deck` + world | `deck30` branch | `deck30` + world |
  |---|---|---|---|---|
  | frame p50 | 16.66 (+-0.07) | 16.67 (+-0.02) | 33.27 (+-0.11) | 33.29 (+-0.04) |
  | render GPU p50 | 8.89 (+-0.93) | **8.02** (+-0.10) | 8.82 (+-0.50) | **7.94** (+-0.63) |
  | GPU shared max | 1118 (+-65) MB | **601** (+-65) | 1119 (+-64) | **632** (+-65) |
  | private RAM max | 1493 (+-66) MB | **992** (+-65) | 1492 (+-68) | **1040** (+-67) |
  | pinned CPU p50 | 6.36 (+-2.4) % | 6.23 (+-0.5) | 4.21 (+-0.2) | 4.06 (+-0.8) |

  **E20 holds on world's later head:** render GPU -10 %, GPU memory -46 %, RAM -34 % on `deck`; the same on `deck30`
  (-10 % / -44 % / -30 %). Both rows hold their caps (vsync 60 at 16.7 ms; 33.3 ms at 30: its `over33_settled` ~340
  counts frames a hair over the 33 ms line, the cap itself, not misses). `deck30` costs a third less pinned CPU than
  `deck` on both trees. JSONs and the log: `evidence/n9h/it10/e20b/`.
- **Windows handhelds picking their own row (n9 it10): researched, not built (built n10 for the strings a source confirms, section 9).** Steam sets no `SteamDeck` variable on
  Windows, so an Ally / Legion Go / Claw-class handheld still needs `--device=handheld_1080` (or a settings choice).
  Probe on this PC (`evidence/n9h/it10/probe_model.gd.txt`, Godot 4.7.2): `OS.get_model_name()` on Windows returns
  the system model ("X670 AORUS ELITE AX", the same as WMI `Win32_ComputerSystem.Model`), so a model match is possible;
  `DisplayServer.screen_get_dpi()` returns the *effective* DPI (96 at 100 % scaling), not the panel's physical size,
  so "a small 1080p screen" cannot be read that way. The firmware model strings of the handhelds are **not confirmed**
  by any source found (retail SKUs only: ROG Ally RC71L, Legion Go 83E1, Claw A1M,
  [ASUS spec](https://rog.asus.com/gaming-handhelds/rog-ally/rog-ally-2023/spec),
  [comparison listing](https://comparisontabl.es/handheld-gaming-pc/msi-claw-a1m-ultra-5-135h-vs-lenovo-legion-go/)),
  so no guessed strings are shipped. The design when they are known (a DMI database or one device each): a `models`
  substring list on the `handheld_1080` row of `devices.json`, matched in `DeviceProfile.auto_pick` after the Deck
  check, fullscreen like the Deck. Owed: the strings, and the same check on a Deck's Linux DMI (`board_vendor`
  "Valve") for a launch outside Steam, unverified here.
- **E21c (n9 it10), does the boss-cam ease fix the 40 Hz cadence? No (as expected; closes it8 NEXT 2b).** The King
  on `deck40`, filmed at its own 40 fps (`sim.mjs --movie-fps=40`, 1500 ticks, the iGPU, movie mode: frame-exact,
  CONTENDED does not matter), ease on vs `--boss-cam-ease=off`. The motion read correlates a ground band only (y
  420-620 of 1280x800, `evidence/n9h/it10/e21c/pancorr_band.py`, it7's lesson: the King's car and the telegraph
  carried the whole-frame read). Pan-step unevenness over frame pairs both moving >= 6 px: ease on median **0.50**
  (mean 0.43, 72 % of pairs >= 0.4, 36 pairs), ease off median **0.50** (mean 0.45, 80 %, 35 pairs). CamFollow steps on
  sim ticks, so a 40 fps frame still shows 1 or 2 ticks of pan: only drawing between ticks fixes it (the scoping note
  under E21, ~2-3 days); `deck30` (even) stays the battery answer (Call 4). Still looked at: t15 s, the King and Rivet
  on the road, the compact card. 0 SCRIPT ERROR in both runs.
- **Mutation on `device_profile.gd` (n9 it10, at 3d235479, 30 sampled mutants, test_device_profile):** 33.3 % (10 / 30).
  The sampled mutants on the new auto-pick lines were killed; the survivors are in `_read`'s fallback defaults (every
  row sets those keys) and `apply()` (window calls, unreachable headless). `evidence/n9h/it10/gates/`.

## 9. Night n10 (2026-11-08/09): readiness without a device (every number on the simulator)

### Windows handheld model strings (`models` on the device rows, researched 2026-11-08)
What the game reads: Godot's `OS.get_model_name()` on Windows is the registry's `HKLM\Hardware\Description\System\BIOS`
`SystemProductName`, then `BaseBoardProduct` when the first is empty or a placeholder
([os_windows.cpp, 4.5-stable](https://raw.githubusercontent.com/godotengine/godot/4.5-stable/platform/windows/os_windows.cpp)).
It gives no vendor, so a string has to be unmistakable alone. The product name is what Linux calls `DMI_PRODUCT_NAME` (the
same SMBIOS field), so the kernel's tables are the public record of it.

Shipped, each from a `DMI_PRODUCT_NAME` entry; a match is `contains`, case-sensitive:

| row | string | device | source |
|---|---|---|---|
| `deck` | `Jupiter`, `Galileo` | Steam Deck LCD / OLED running Windows (no `SteamDeck` variable there); only on the 1280x800 panel | [drm_panel_orientation_quirks.c](https://raw.githubusercontent.com/torvalds/linux/master/drivers/gpu/drm/drm_panel_orientation_quirks.c) |
| `handheld_1080` | `AYANEO 2` (2 and 2S), `AYA NEO Founder`, `AYA NEO 2021` | AYANEO | same file |
| `handheld_1080` | `Loki Max`, `Loki Zero` | AYN | same file |
| `handheld_1080` | `Win600` | Anbernic | same file |
| `handheld_1080` | `G1619-01`, `G1618-03`, `G1617-01` | GPD Win Max, Win 3, Win Mini | same file |
| `handheld_1080` | `ONE XPLAYER` | OneXPlayer (and the Mini Intel: the same string) | same file |
| `handheld_1080` | `RC72LA` | ROG Ally X | the AMD PMF quirk patch, `DMI_MATCH(DMI_PRODUCT_NAME, "RC72LA")` ([LKML](https://lkml.iu.edu/hypermail/linux/kernel/2407.3/04376.html)), seen in the search index; `pmf-quirks.c` itself 404s at that path on master, so not re-read |
| `handheld_1080` | `ROG Ally RC71L` (it5) | ROG Ally (matches `ROG Ally RC71L_RC71L` too) | a `dmidecode` dump, `Product Name: ROG Ally RC71L_RC71L` ([gist](https://gist.github.com/parkerlreed/012c3fd26891d05f9d467c08d4d6520f), read verbatim) and HandyGCCS's list, both spellings ([utilities.py](https://raw.githubusercontent.com/ShadowBlip/HandyGCCS/main/src/handycon/utilities.py), lines 125-126) |
| `handheld_1080` | `ROG Xbox Ally RC73Y`, `ROG Xbox Ally X RC73X`, `ROG XBOX Ally X RC74X` (it13) | ROG Xbox Ally, Ally X (both generations; the RC74X line is capitalised XBOX in the source) | HHD reads `/sys/devices/virtual/dmi/id/product_name` and matches these substrings, with the full strings in comments (`ROG Xbox Ally RC73YA_RC73YA`, `ROG Xbox Ally X RC73XA_RC73XA`, `ROG XBOX Ally X RC74XA RC74XA`) ([rog_ally/__init__.py](https://raw.githubusercontent.com/hhd-dev/hhd/master/src/hhd/device/rog_ally/__init__.py), lines 124-151, read at 6f6045a5); `adjustor/core/const.py` lines 345-349 the same. One public source, a Linux daemon; not on a device |
| `handheld_1080` `models_exact` | `83E1` (it5) | Legion Go | InputPlumber's DMI match, `product_name: "83E1"`, `sys_vendor: LENOVO` ([50-legion_go.yaml](https://raw.githubusercontent.com/ShadowBlip/InputPlumber/main/rootfs/usr/share/inputplumber/devices/50-legion_go.yaml)); HandyGCCS line 214 |
| `handheld_1080` `models_exact` | `83L3`, `83N6`, `83Q2`, `83Q3` (it5) | Legion Go S | InputPlumber, `50-legion_go_s.yaml` (same folder) |
| `handheld_1080` `models_exact` | `83N0`, `83N1` (it5) | Legion Go 2 | InputPlumber, `50-legion_go_2.yaml` (same folder) |

Left out, with why:
- **MSI Claw (every model):** InputPlumber matches each only on the *board* name (`MS-1T41`, `MS-1T42`, `MS-1T52`, `MS-1T91`, `MS-1T8K`), which Godot only reads when the product name is a placeholder; no source read gives the product name, and no `Claw` string is in the DRM, oxpec or msi-wmi-platform tables.
- **ROG Xbox Ally / Ally X:** left out until it13, when InputPlumber's board names were the only source read. Now in the table above.
- **AYANEO `AIR`, `FLIP`, `GEEK`, `SLIDE`, `KUN`, `NEXT`:** real entries, but paired with a vendor (or a board) in the kernel and too plain alone. **GPD `WIN2`** and **`NEO-01` (OrangePi)** the same (the schema asks 6 characters at least).
- **OneXPlayer X1 / F1 / G1, AOKZOE:** `oxpec.c` lists them by *board* name, which Godot only returns when the product name is a placeholder.

So the MSI Claw line is the one still unconfirmed (it13: HHD matches it on `board_name` too; `MSI Claw A1M` and the like in its `const.py` are HHD's display labels, not firmware strings, and do not ship). One device (or a DMI dump) fills that in; no guessed string ships. `models_exact` (it5) is a second list because a Lenovo type number is 4 characters: inside a longer name it is not unmistakable, so it must be the whole name (the `models` schema floor stays 6). A source caution on these rows: InputPlumber's `product_name` is the SMBIOS field Godot reads, but it is a third-party project's table and no device of ours confirmed it.
Docked: a listed model on a screen past `MAX_PANEL_SIDE` (2560) keeps the desktop; a docked handheld on a 1080p TV cannot be told from its own panel and takes the row (`--device=desktop` opts out).

### Steam checks: the API moved under the brief (researched 2026-11-08)
- **Steamworks SDK 1.65 (July 2026) removed the dedicated Deck check**: "Removed ISteamUtils::IsRunningOnSteamDeck(). Please use other feature specific methods below"; added `IsRunningOnSteamHardware()` returning `ESteamHardwareType`, "for analytics, support or diagnostic purposes. For functional decisions, see other SDK calls", `GetSteamHardwareDefaultConfig()` "to help choose default game settings", and `IsRunningUnderProton()` (Valve's changelog as quoted by [GamingOnLinux](https://www.gamingonlinux.com/2026/07/valves-steamworks-sdk-v1-65-brings-changes-for-steam-machine-steam-frame-and-steam-deck/)). Valve's [ISteamUtils page](https://partner.steamgames.com/doc/api/ISteamUtils) reads as *deprecated* where the changelog says *removed*; that page, and the enum values (None 0, SteamDeck 1, SteamMachine 2, SteamFrame 3), were read through a summarising fetch, not verbatim: check them against the SDK header when GodotSteam is vendored.
- GodotSteam's latest is 4.24 on Steamworks 1.65; its GitHub repository was archived 2026-11-08 and the release notes point to Codeberg ([releases](https://github.com/GodotSteam/GodotSteam/releases)). STM-01 pins `v4.23.2-gde` or newer. godotsteam.com refused the fetch (403); **the method names were then read from GodotSteam 4.24's source** ([godot4 branch on Codeberg](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam.cpp), it5): `isRunningOnSteamHardware`, `getSteamHardwareDefaultConfig`, `isRunningUnderProton`, `getActionOriginFromXboxOrigin`, `getGlyphPNGForActionOrigin`, and the bound constants in the order NONE, STEAM_DECK, STEAM_MACHINE, STEAM_FRAME. That source binds names, not the numbers: the values 0-3 still want the SDK header. No `isSteamRunningOnSteamDeck` binding appears in that source, which fits the 1.65 removal.
- Glyph calls, verbatim from [ISteamInput](https://partner.steamgames.com/doc/api/isteaminput): `GetGlyphPNGForActionOrigin(eOrigin, eSize, unFlags)` "Get a local path to a PNG file for the provided origin's glyph"; the legacy call says new code should use it. `GetActionOriginFromXboxOrigin` read through the summary only.
- Built behind the interface: `PlatformBackend.Hardware` gains `STEAM_DECK` (`STEAM_HARDWARE` is now a Machine or a Frame); `DeviceProfile.auto_pick` asks `Platform.hardware()` first; `SteamBackend.hardware_of()` maps the raw type (unit-tested); `Platform.action_glyph_path()` is the glyph stub, "" = the drawn set. Each is one call to fill in `steam_backend.gd` (DECISION `handheld/steam-hardware`). **Not run against Steam: there is no Steam app here.** `action_glyph_path` has its caller since it5: `SteamGlyphs.texture(label)` in `PadGlyphArt.runs`, a Texture2D run drawn and measured like an atlas cell, so filling in the backend's one line is the whole swap (`test_steam_glyphs`, a fake backend returning a real PNG). The RichTextLabel card (`bbcode`) keeps the drawn set: an `[img]` tag names a res:// file, and Steam's glyph is a runtime image; so a remapped pad would show Steam's glyph in the prompts and the drawn one on that card.

- **ESteamHardwareType's numbers (it13):** `None = 0`, `SteamDeck = 1`, `SteamMachine = 2`, `SteamFrame = 3`, verbatim from Steamworks.NET's generated enums, which are built from the SDK headers ([SteamEnums.cs](https://raw.githubusercontent.com/rlabrecque/Steamworks.NET/master/com.rlabrecque.steamworks.net/Runtime/autogen/SteamEnums.cs)). `SteamBackend.HARDWARE_NONE` 0 and `HARDWARE_DECK` 1 match. A mirror of the header, not the header itself.

### E22 (n10 it5): the rows after the merge of `n10-world` aadc7430 (half-height walls, whole storeys); PC simulator, CONTENDED
Windowed on the 2-CU iGPU, `tools/handheld/sim.mjs --scene=city_combo --ticks=1800`, one run each, under `bench.lock`, while this lane's own four headless reels and the other lanes' runs were going. One run each is a sanity check of the rows on the new walls, **not** a cost measurement: there is no pre-merge arm in the same conditions, so the walls' cost is unmeasured.

| row | other Godot runs | frames | p50 ms | p99 ms | over 33 ms (settled) | render GPU p50 ms | GPU shared max MB |
|---|---|---|---|---|---|---|---|
| `deck` | 7 | 1750 | 16.66 | 23.42 | 13 | 8.0 | 600 |
| `deck40` | 7 | 1080 | 26.57 | 57.08 | 162 | 8.6 | 600 |
| `handheld_1080` | 9 | 991 | 27.02 | 86.68 | 287 | 9.3 | 612 |
| `switch_handheld` (30 cap) | 1 | 897 | 33.22 | 37.95 | 511 (the cap itself sits at 33.3 ms, so this column says nothing on this row) | 9.09 | 626 |

The Deck row holds its 16.7 ms lock with render GPU 8.0 ms (E20b: 7.7). **`handheld_1080` did not hold 60 here** (p50 27 ms, about 33 fps in the run) where E9 measured a 60 hold at 9.9 ms GPU; its render GPU is 9.3 ms, so the miss is on the CPU side or the machine, and the run had 9 other Godot processes against the row's below-normal priority. Not attributed (**E22b below does it: the miss did not reproduce**): it wants a re-run on a quiet machine, against a pre-merge arm, before it is called anything. (n10 it9: the interleaved A/B against a1c1edfd was set up and not run, `bench.lock` was held by perf; `height_k` is already 0.5 at a1c1edfd, so that arm would price the storeys only.)

### E22b (n10 it13): `handheld_1080` in the city, before and after the storeys; PC simulator, CONTENDED
The interleaved A/B E22 asked for: `tools/handheld/sim.mjs --device=handheld_1080 --scene=city_combo --ticks=1800`, windowed on the iGPU, under `bench.lock`, ABBA x 2 (4 runs per arm). `pre` = a1c1edfd (the merge's first parent) in a scratch worktree, `head` = aafc62cc. The two arms differ by `aadc7430`'s whole storeys only: `height_k` is 0.5 on both, so this does not price half height against full height. 1 to 6 other Godot runs were going in every run; my own evidence run was one of them. Per-run JSON: `evidence/n10h/it13/sim/ab*.json`.

| arm | runs | p50 ms (range) | p99 ms | over 33 ms (settled) | render GPU p50 ms (range) | process p50 ms (range) | frames of 1800 | draws |
|---|---|---|---|---|---|---|---|---|
| `pre` | 4 | 16.68 (16.67-16.68) | 19.89 | 3.5 | 8.65 (8.53-8.67) | 5.79 (4.27-6.95) | 1773.5 | 623 |
| `head` | 4 | 16.68 (16.66-16.70) | 19.95 | 2 | 8.84 (8.69-9.05) | 7.01 (4.85-8.13) | 1777 | 623 |

Medians over the arm's runs. **Both arms hold 60**, so E22's miss (p50 27 ms) does not reproduce and is not the storeys: it was one run with 9 other Godot processes, and contention fits, but that is not proven (no run here went past 6 others). Render GPU is **+0.19 ms on the head** and every head run is above every pre run: small, and in the direction the extra storey art would give, with 4 runs per arm and draws unchanged at 623. That is about 1 % of the 16.7 ms frame, on this iGPU, not a device. Process time differs by more than that, but its ranges overlap and it swings by nearly 2x inside an arm: noise. Run 1 (`ab1_pre`, the first run of the scratch worktree) has p99 44.9 ms and 31 frames over 33 ms where every other run is at most 20.6 and 5; it is in the medians and moves them little.

### The freeze A/B on the rows (n10 it1, read at it5; PC simulator)
Quest 1 windowed on D3D12, `deck` (`vsync: enabled`) vs the study row `deck_mailbox`, interleaved rounds of 2 runs, 4 rounds of the 5 planned (`evidence/n10h/it1/ab-vsync.txt`, the low-CPU runs' logs and thread readings in `evidence/n10h/it1/hunt/`):

| arm | runs | ok | low CPU, still pumping | low CPU, not yet started | frozen |
|---|---|---|---|---|---|
| `deck` (enabled) | 8 | 5 | 3 | 0 | **0** |
| `deck_mailbox` | 8 | 6 | 0 | 2 | **0** |

A low-CPU run is not a freeze by this harness's definition: its message loop answers, the log says quest 1 started, and the one thread reading looked at (`freeze-deck_r2-1.json`) has the main thread live at 0.054 cores; the row's focus-out pause on a hidden window fits, not proven. The per-round `frozen` counters in the file count low CPU too and are not used. 0 frozen of 8 bounds nothing tight (perf saw 5 / 20 in the editor binary and 0 / 20 in release and debug exports). **The rows keep `vsync: enabled`**: perf's freeze is the editor binary's, the Deck's path is Vulkan, and no run here shows the rows need mailbox.

### The research loop: stopped (n10 it5)
1. **Windows display scaling at 125-200 %.** The simulator cannot change the scale of a machine three other lanes are using, and a per-process scale would test a different path. Nothing measurable.
2. **The controller-first shell (launch and play with no mouse).** What it depends on is the handheld maker's launcher (the vendor's shell, Steam's Big Picture); the simulator has neither. Nothing measurable.

Two in a row with nothing the simulator can measure, so the loop stops by the brief's rule. Both stay in the port readiness table as owed.
