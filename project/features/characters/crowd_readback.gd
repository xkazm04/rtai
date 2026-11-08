class_name CrowdReadback
extends RefCounted
## n9-perf F-19: reads CrowdBaker's offscreen frame back to the CPU WITHOUT stalling the main
## thread. `ViewportTexture.get_image()` is a synchronous RenderingDevice download (it flushes and
## waits for the GPU, 25 times per bake); F-19's quest-1 freeze was first caught parked inside it,
## but the same freeze still happens without it (an engine-side wait; LEDGER n9 F19). Here the copy
## is queued with `texture_get_data_async` right after the frame is drawn, and the bytes arrive in
## a callback a frame or two later (on the main thread), so nothing ever waits on a fence.
## Same bytes: the copy is recorded before the next frame redraws the viewport (the render graph
## keeps that order), so a cell holds the frame it was asked for, exactly as before.
## n9-perf it2: the DEFAULT is the synchronous get_image again: the async bytes land a frame or two
## later, and the windowed look goldens drew the crowd before the atlas was in (5 / 11 off, worst
## 6.46; sync 11 / 11). F-19 is fixed by the mailbox present (LEDGER), so the stall no longer
## freezes. `-- --crowd-readback=async` = this async path (pixel-moving until the golden frames
## wait for `pending == 0`).

var pending: int = 0
var failed: int = 0


static func async_on() -> bool:
	return LaunchArgs.value("--crowd-readback") == "async"


## Asks for the frame just drawn in `vp`; `done` is called with the Image (null on failure) when
## the GPU has it (at once on the sync arm or without a RenderingDevice).
func request(vp: SubViewport, done: Callable) -> void:
	var rd: RenderingDevice = RenderingServer.get_rendering_device()
	var tex: RID = RID()
	if rd != null:
		tex = RenderingServer.texture_get_rd_texture(vp.get_texture().get_rid())
	if not async_on() or rd == null or not tex.is_valid():
		done.call(vp.get_texture().get_image())
		return
	var fmt: RDTextureFormat = rd.texture_get_format(tex)
	var size: Vector2i = Vector2i(fmt.width, fmt.height)
	pending += 1
	var err: Error = rd.texture_get_data_async(tex, 0, _arrived.bind(size, fmt.format, done))
	if err != OK:
		pending -= 1
		failed += 1
		done.call(null)


func _arrived(
	data: PackedByteArray, size: Vector2i, format: RenderingDevice.DataFormat, done: Callable
) -> void:
	pending -= 1
	var img: Image = image_of(data, size, format)
	failed += int(img == null)
	done.call(img)


## The downloaded bytes as an Image (the formats a 2D SubViewport renders to), else null.
static func image_of(
	data: PackedByteArray, size: Vector2i, format: RenderingDevice.DataFormat
) -> Image:
	var px: int = size.x * size.y
	match format:
		RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM, RenderingDevice.DATA_FORMAT_R8G8B8A8_SRGB:
			if px > 0 and data.size() == px * 4:
				return Image.create_from_data(size.x, size.y, false, Image.FORMAT_RGBA8, data)
		RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT:
			if px > 0 and data.size() == px * 8:
				return Image.create_from_data(size.x, size.y, false, Image.FORMAT_RGBAH, data)
	return null
