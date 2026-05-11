extends CanvasLayer

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")

@onready var toast_card: PanelContainer = $Root/ToastCard
@onready var message_label: Label = $Root/ToastCard/Margin/MessageLabel

var toast_token := 0


func _ready() -> void:
	UIThemeScript.apply_panel_style(toast_card)
	UIThemeScript.apply_label(message_label)
	toast_card.visible = false


func show_toast(text: String, toast_type: String = "info") -> void:
	toast_token += 1
	var current_token := toast_token
	message_label.text = text
	toast_card.add_theme_stylebox_override("panel", _style_for_type(toast_type))
	toast_card.visible = true
	await get_tree().create_timer(2.0).timeout
	if current_token == toast_token:
		toast_card.visible = false


func _style_for_type(toast_type: String) -> StyleBoxFlat:
	var color := UIThemeScript.COLOR_PRIMARY
	match toast_type:
		"success":
			color = UIThemeScript.COLOR_SUCCESS
		"warning":
			color = UIThemeScript.COLOR_WARNING
		"error":
			color = UIThemeScript.COLOR_DANGER
	return UIThemeScript._make_stylebox(color, 10, color.lightened(0.2), 1)
