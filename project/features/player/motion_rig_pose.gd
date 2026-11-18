class_name MotionRigPose
extends RefCounted
## Last movement-specific poses on the ordinary rig feed. The sim and depth sorter keep the feet.


## Project the canvas item about its own ground pivot, after the pose and depth sort.
static func place(rig: Node2D, projection: Transform2D) -> void:
	var draw: Transform2D = rig.transform.scaled_local(projection.get_scale())
	draw.origin += projection.origin
	RenderingServer.canvas_item_set_transform(rig.get_canvas_item(), draw)
