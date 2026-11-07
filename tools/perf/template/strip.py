# SCons profile for a stripped Windows release export template (perf lane, LEDGER L7).
# Usage, from a Godot 4.7.2-stable source tree with the D3D12 / AccessKit / WinRT / ANGLE deps installed
# (misc/scripts/install_*.py):
#   scons platform=windows arch=x86_64 target=template_release profile=<this file> -j8
# Only what the game never touches goes: both physics servers and navigation (the game has
# no physics body, area, ray or nav node: grep in LEDGER L7), XR, networking, video, the 3D import formats and
# the GPU/CPU texture compressors (import-time only). Kept: GDScript, D3D12 + Vulkan, glslang (RD shaders),
# text_server_adv, freetype, svg, regex (arena_tuning, quest_condition), ogg/vorbis + wav, the image decoders the
# imported textures use (png built in, webp, jpg, bcdec), mbedtls, zip, interactive_music, and astcenc (the
# statically linked ANGLE references it: the link fails without it).
# disable_3d stays off: it also drops QuadMesh (scene/resources/3d), which the 2D MultiMesh crowds use (8 refs):
# the first strip exe failed to parse those scripts. A build_profile naming the 3D node classes is the finer cut.
disable_physics_2d = "yes"
disable_physics_3d = "yes"
disable_navigation_2d = "yes"
disable_navigation_3d = "yes"
disable_xr = "yes"


module_basis_universal_enabled = "no"
module_betsy_enabled = "no"
module_bmp_enabled = "no"
module_camera_enabled = "no"
module_csg_enabled = "no"
module_cvtt_enabled = "no"
module_dds_enabled = "no"
module_enet_enabled = "no"
module_etcpak_enabled = "no"
module_fbx_enabled = "no"
module_gltf_enabled = "no"
module_godot_physics_2d_enabled = "no"
module_godot_physics_3d_enabled = "no"
module_gridmap_enabled = "no"
module_hdr_enabled = "no"
module_jolt_physics_enabled = "no"
module_jsonrpc_enabled = "no"
module_ktx_enabled = "no"
module_lightmapper_rd_enabled = "no"
module_meshoptimizer_enabled = "no"
module_mobile_vr_enabled = "no"
module_mp3_enabled = "no"
module_multiplayer_enabled = "no"
module_navigation_2d_enabled = "no"
module_navigation_3d_enabled = "no"
module_noise_enabled = "no"
module_objectdb_profiler_enabled = "no"
module_openxr_enabled = "no"
module_raycast_enabled = "no"
module_tga_enabled = "no"
module_theora_enabled = "no"
module_tinyexr_enabled = "no"
module_upnp_enabled = "no"
module_vhacd_enabled = "no"
module_webrtc_enabled = "no"
module_websocket_enabled = "no"
module_webxr_enabled = "no"
module_xatlas_unwrap_enabled = "no"
