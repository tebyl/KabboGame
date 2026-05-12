extends CanvasLayer

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const UiFeedbackScript := preload("res://scripts/ui/UiFeedback.gd")

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
	message_label.text = "%s %s" % [_prefix_for_type(toast_type), text]
	toast_card.add_theme_stylebox_override("panel", _style_for_type(toast_type))
	toast_card.visible = true
	UiFeedbackScript.pulse(toast_card)
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
		"mission":
			color = Color(0.56, 0.36, 0.92, 1.0)
		"achievement":
			color = Color(0.96, 0.62, 0.18, 1.0)
	return UIThemeScript._make_stylebox(color, 10, color.lightened(0.2), 1)


func _prefix_for_type(toast_type: String) -> String:
	match toast_type:
		"success":
			return "[OK]"
		"warning":
			return "[!]"
		"error":
			return "[ERROR]"
		"mission":
			return "[MISION]"
		"achievement":
			return "[LOGRO]"
		_:
			return "[INFO]"
