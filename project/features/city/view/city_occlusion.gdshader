shader_type canvas_item;
// CityOcclusion (night n8, lane city): paints the printed world back over a body behind a building.
// The screen was copied (BackBufferCopy) before any actor drew, so this is the world exactly as
// printed (look_d4 + overlays), pixel for pixel: no second print, no tone seam.

uniform sampler2D world_tex : hint_screen_texture, filter_nearest;

void fragment() {
	COLOR = vec4(texture(world_tex, SCREEN_UV).rgb, 1.0);
}
