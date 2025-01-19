class_name AnchorDetector2D
extends Area2D

# Emitted when entering an anchor area.
signal anchor_detected(anchor)
# Emitted after exiting all anchor areas.
signal anchor_detached


func _on_area_entered(area) -> void:
	if area is Anchor2D:
		emit_signal("anchor_detected", area)


# When exiting an area, we have to ensure we're not entering another anchor.
func _on_area_exited(area) -> void:
	if area is Anchor2D:
		var areas: Array = get_overlapping_areas()
		# To do so, we check that's there's but one overlapping area left and that it's
		# the one passed to this callback function.
		if get_overlapping_areas().size() == 1 and area == areas[0]:
			emit_signal("anchor_detached", area)
		if get_overlapping_areas().size() == 0:
			emit_signal("anchor_detached", area)
