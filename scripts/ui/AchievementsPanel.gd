extends CanvasLayer

signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const AchievementCatalogScript := preload("res://scripts/data/AchievementCatalog.gd")

var achievements := {}
var stats := {}

@onready var root: Control = $Root
@onready var card: PanelContainer = $Root/Card
@onready var list: VBoxContainer = $Root/Card/Margin/VBox/Scroll/List


func _ready() -> void:
	$Root/Overlay.color = UIThemeScript.COLOR_OVERLAY
	UIThemeScript.apply_panel_style(card)
	UIThemeScript.apply_label($Root/Card/Margin/VBox/Header/Title)
	UIThemeScript.apply_secondary_button($Root/Card/Margin/VBox/Header/CloseButton)
	hide_panel()


func show_with_data(next_achievements: Dictionary, next_stats: Dictionary) -> void:
	achievements = next_achievements.duplicate(true)
	stats = next_stats.duplicate(true)
	root.visible = true
	_render()


func update_data(next_achievements: Dictionary, next_stats: Dictionary) -> void:
	achievements = next_achievements.duplicate(true)
	stats = next_stats.duplicate(true)
	_render()


func hide_panel() -> void:
	root.visible = false


func _render() -> void:
	for child in list.get_children():
		child.queue_free()

	for achievement_id in AchievementCatalogScript.get_achievements().keys():
		list.add_child(_build_row(String(achievement_id)))


func _build_row(achievement_id: String) -> PanelContainer:
	var catalog := AchievementCatalogScript.get_achievement(achievement_id)
	var state: Dictionary = achievements.get(achievement_id, {})
	var unlocked := bool(state.get("unlocked", false))

	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(520, 68)
	UIThemeScript.apply_dark_panel_style(row)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	row.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	margin.add_child(hbox)

	var icon := Label.new()
	icon.custom_minimum_size = Vector2(36, 0)
	icon.text = String(catalog.get("icon_text", "?"))
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UIThemeScript.apply_label(icon)
	hbox.add_child(icon)

	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(labels)

	var title := Label.new()
	title.text = String(catalog.get("name", achievement_id))
	UIThemeScript.apply_label(title)
	labels.add_child(title)

	var description := Label.new()
	description.text = String(catalog.get("description", ""))
	UIThemeScript.apply_label(description, true)
	labels.add_child(description)

	var state_label := Label.new()
	state_label.text = "Desbloqueado" if unlocked else "Bloqueado"
	UIThemeScript.apply_label(state_label, not unlocked)
	hbox.add_child(state_label)
	return row


func _on_close_button_pressed() -> void:
	hide_panel()
	close_requested.emit()
