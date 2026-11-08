class_name TestArt
extends RefCounted
## A texture's pixels for a test to read: the art under features/{characters,city,vehicles}/art is
## VRAM-compressed (BC7, n9), and get_pixel() on a compressed image reads nothing.


static func rgba(tex: Texture2D) -> Image:
	var img: Image = tex.get_image()
	if img.is_compressed():
		@warning_ignore("return_value_discarded")
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	return img
