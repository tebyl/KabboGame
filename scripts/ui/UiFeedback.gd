class_name UiFeedback
extends RefCounted


static func pulse(node: CanvasItem) -> void:
	if not is_instance_valid(node):
		return
	var original_scale: Vector2 = node.scale
	var tween := node.create_tween()
	tween.tween_property(node, "scale", original_scale * 1.04, 0.08)
	tween.tween_property(node, "scale", original_scale, 0.12)


static func shake(node: CanvasItem) -> void:
	if not is_instance_valid(node):
		return
	var original_position: Vector2 = node.position
	var tween := node.create_tween()
	tween.tween_property(node, "position", original_position + Vector2(5, 0), 0.04)
	tween.tween_property(node, "position", original_position + Vector2(-5, 0), 0.04)
	tween.tween_property(node, "position", original_position, 0.06)


static func flash(node: CanvasItem, color: Color) -> void:
	if not is_instance_valid(node):
		return
	var original_modulate: Color = node.modulate
	var tween := node.create_tween()
	tween.tween_property(node, "modulate", color, 0.08)
	tween.tween_property(node, "modulate", original_modulate, 0.16)
