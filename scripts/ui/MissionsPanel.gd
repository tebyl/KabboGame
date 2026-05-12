extends CanvasLayer

signal claim_mission_requested(mission_id: String)
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const MissionCatalogScript := preload("res://scripts/data/MissionCatalog.gd")

var missions := {}
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


func show_with_data(next_missions: Dictionary, next_stats: Dictionary) -> void:
	missions = next_missions.duplicate(true)
	stats = next_stats.duplicate(true)
	root.visible = true
	_render()


func update_data(next_missions: Dictionary, next_stats: Dictionary) -> void:
	missions = next_missions.duplicate(true)
	stats = next_stats.duplicate(true)
	_render()


func hide_panel() -> void:
	root.visible = false


func _render() -> void:
	for child in list.get_children():
		child.queue_free()

	for mission_id in MissionCatalogScript.get_missions().keys():
		list.add_child(_build_row(String(mission_id)))


func _build_row(mission_id: String) -> PanelContainer:
	var catalog := MissionCatalogScript.get_mission(mission_id)
	var state: Dictionary = missions.get(mission_id, {})
	var target := int(catalog.get("target", 1))
	var progress := int(state.get("progress", min(int(stats.get(String(catalog.get("stat", "")), 0)), target)))
	var completed := bool(state.get("completed", false))
	var claimed := bool(state.get("claimed", false))
	var reward: Dictionary = catalog.get("reward", {})

	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(520, 86)
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

	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(labels)

	var title := Label.new()
	title.text = String(catalog.get("name", mission_id))
	UIThemeScript.apply_label(title)
	labels.add_child(title)

	var description := Label.new()
	description.text = String(catalog.get("description", ""))
	UIThemeScript.apply_label(description, true)
	labels.add_child(description)

	var reward_text := "%s/%s - %s" % [progress, target, _reward_to_text(reward)]
	if claimed:
		reward_text += " - Reclamada"
	elif completed:
		reward_text += " - Lista"
	var detail := Label.new()
	detail.text = reward_text
	UIThemeScript.apply_label(detail, true)
	labels.add_child(detail)

	var claim_button := Button.new()
	claim_button.text = "Reclamar"
	claim_button.disabled = not completed or claimed
	UIThemeScript.apply_success_button(claim_button)
	claim_button.pressed.connect(_on_claim_pressed.bind(mission_id))
	hbox.add_child(claim_button)
	return row


func _reward_to_text(reward: Dictionary) -> String:
	if reward.has("coins"):
		return "+%s monedas" % int(reward.get("coins", 0))
	if reward.has("furniture"):
		return "+1 %s" % String(reward.get("furniture", "mueble"))
	return "Sin recompensa"


func _on_claim_pressed(mission_id: String) -> void:
	claim_mission_requested.emit(mission_id)


func _on_close_button_pressed() -> void:
	hide_panel()
	close_requested.emit()
