@abstract class_name PlatformBackend
extends RefCounted
## The platform interface (STM-02). Platform owns exactly one backend at a time:
## SteamBackend (steam tag + init ok), NullBackend otherwise, FakeBackend in tests.
## Cloud saves use Steam Auto-Cloud (SAV-07), so the cloud surface is just where the synced
## profile lives and whether syncing is on; there is no cloud API call.

signal achievement_confirmed(id: StringName)
signal store_failed(reason: String)
signal overlay_toggled(open: bool)

enum Hardware { DESKTOP, STEAM_HARDWARE }
enum GlyphFamily { KBM, XBOX, PLAYSTATION, SWITCH, DECK }

@abstract func backend_name() -> StringName

## Brings the backend up. False means "not usable"; Platform then falls back to NullBackend.
@abstract func start() -> bool

@abstract func shutdown() -> void

## Pumps platform callbacks; called from Platform._process (STM-04).
@abstract func poll() -> void

@abstract func is_online() -> bool

## Idempotent (ACH-08): true only when this call newly unlocked `id`.
@abstract func unlock(id: StringName) -> bool

@abstract func is_unlocked(id: StringName) -> bool

@abstract func set_stat(id: StringName, value: int) -> bool

## Returns the new value.
@abstract func inc_stat(id: StringName, by: int) -> int

@abstract func get_stat(id: StringName) -> int

## Persists unlocks and stats. On failure emits store_failed and keeps them pending (ACH-08).
@abstract func flush() -> bool

@abstract func rich_presence(key: String, value: String) -> bool

@abstract func hardware() -> Hardware

## Opens the on-screen keyboard when a pad is active (STM-10). False if unsupported.
@abstract func text_input_request(prompt: String, multiline: bool) -> bool

@abstract func glyph_family() -> GlyphFamily

## Root of the synced profile (SAV-06). Includes the SteamID when Steam is up.
@abstract func profile_dir() -> String

@abstract func cloud_enabled() -> bool
