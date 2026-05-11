extends Node2D

const MAX_VISIBLE_TEXT := 80

@onready var bubble_card: PanelContainer = $BubbleCard
@onready var message_label: Label = $BubbleCard/Margin/MessageLabel

var hide_token := 0


func _ready() -> void:
	hide_bubble()


func show_message(text: String) -> void:
	hide_token += 1
	var current_token := hide_token
	message_label.text = _truncate_text(text)
	bubble_card.visible = true
	await get_tree().create_timer(3.0).timeout
	if current_token == hide_token:
		hide_bubble()


func hide_bubble() -> void:
	bubble_card.visible = false


func _truncate_text(text: String) -> String:
	var clean_text := text.replace("\n", " ").replace("\r", " ").strip_edges()
	if clean_text.length() > MAX_VISIBLE_TEXT:
		return clean_text.substr(0, MAX_VISIBLE_TEXT - 3) + "..."
	return clean_text
