extends CanvasLayer

signal edit_requested
signal rating_changed(value: int)
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")

const ROOM_TYPE_LABELS := {
	"social": "Social",
	"descanso": "Descanso",
	"juegos": "Juegos",
	"estudio": "Estudio",
	"coleccion": "Colección",
	"creativo": "Creativo",
	"privado": "Privado",
}

const ROOM_MOOD_LABELS := {
	"relajada": "Relajada",
	"fiesta": "Fiesta",
	"conversacion": "Conversación",
	"decoracion": "Decoración",
	"privada": "Privada",
	"exploracion": "Exploracion",
}

@onready var panel: PanelContainer = $Root/Panel
@onready var type_accent: ColorRect = $Root/Panel/Margin/VBox/TypeAccent
@onready var title_label: Label = $Root/Panel/Margin/VBox/Title
@onready var description_label: Label = $Root/Panel/Margin/VBox/Description
@onready var owner_label: Label = $Root/Panel/Margin/VBox/Stats/Owner
@onready var type_label: Label = $Root/Panel/Margin/VBox/Stats/Type
@onready var mood_label: Label = $Root/Panel/Margin/VBox/Stats/Mood
@onready var size_label: Label = $Root/Panel/Margin/VBox/Stats/Size
@onready var furniture_label: Label = $Root/Panel/Margin/VBox/Stats/Furniture
@onready var visits_label: Label = $Root/Panel/Margin/VBox/Stats/Visits
@onready var created_at_label: Label = $Root/Panel/Margin/VBox/Stats/CreatedAt
@onready var updated_at_label: Label = $Root/Panel/Margin/VBox/Stats/UpdatedAt
@onready var visit_trend_label: Label = $Root/Panel/Margin/VBox/Stats/VisitTrend
@onready var rating_label: Label = $Root/Panel/Margin/VBox/RatingRow/RatingLabel
@onready var rating_buttons: HBoxContainer = $Root/Panel/Margin/VBox/RatingRow/Buttons
@onready var edit_button: Button = $Root/Panel/Margin/VBox/Actions/Edit

var current_voter_id := "local"


func _ready() -> void:
	UIThemeScript.apply_panel_style(panel)
	hide_panel()


func show_with_room(room_data: Dictionary, can_edit: bool, voter_id: String = "local") -> void:
	visible = true
	current_voter_id = voter_id
	update_room(room_data, can_edit)


func hide_panel() -> void:
	visible = false


func update_room(room_data: Dictionary, can_edit: bool, voter_id: String = "") -> void:
	if not voter_id.is_empty():
		current_voter_id = voter_id
	var room_type := String(room_data.get("room_type", "social"))
	var mood := String(room_data.get("mood", "relajada"))
	var rating := _normalize_rating(room_data.get("rating", {}))
	var current_vote := _get_current_vote(rating)
	title_label.text = String(room_data.get("name", "Sala"))
	description_label.text = String(room_data.get("description", ""))
	owner_label.text = "Dueño: %s" % String(room_data.get("owner_name", "Invitado"))
	type_label.text = "Tipo: %s" % String(ROOM_TYPE_LABELS.get(room_type, ROOM_TYPE_LABELS["social"]))
	mood_label.text = "Estado: %s" % String(ROOM_MOOD_LABELS.get(mood, ROOM_MOOD_LABELS["relajada"]))
	size_label.text = "Tamaño: %sx%s" % [int(room_data.get("width", 10)), int(room_data.get("height", 10))]
	furniture_label.text = "Muebles: %s" % _count_furniture(room_data)
	visits_label.text = "Visitas locales: %s" % max(0, int(room_data.get("visits", 0)))
	created_at_label.text = "Creada: %s" % _format_timestamp(int(room_data.get("created_at", 0)))
	updated_at_label.text = "Actualizada: %s" % _format_timestamp(int(room_data.get("updated_at", 0)))
	visit_trend_label.text = "Visitas recientes: %s" % _format_recent_visits(room_data.get("visit_log", []))
	rating_label.text = _format_rating(rating, current_vote)
	edit_button.visible = can_edit
	type_accent.color = _get_room_type_color(room_type)
	_refresh_rating_buttons(current_vote)


func _count_furniture(room_data: Dictionary) -> int:
	var furniture = room_data.get("furniture", [])
	return furniture.size() if furniture is Array else 0


func _refresh_rating_buttons(rating: int) -> void:
	for child in rating_buttons.get_children():
		child.queue_free()
	for value in range(1, 6):
		var button := Button.new()
		button.text = str(value)
		button.toggle_mode = true
		button.button_pressed = value == rating
		button.custom_minimum_size = Vector2(34, 28)
		UIThemeScript.apply_secondary_button(button)
		button.pressed.connect(_on_rating_pressed.bind(value))
		rating_buttons.add_child(button)


func _on_edit_pressed() -> void:
	edit_requested.emit()


func _on_close_pressed() -> void:
	hide_panel()
	close_requested.emit()


func _on_rating_pressed(value: int) -> void:
	rating_changed.emit(value)


func _normalize_rating(value) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return {
			"average": float(value.get("average", 0.0)),
			"count": max(0, int(value.get("count", 0))),
			"total": max(0, int(value.get("total", 0))),
			"votes": value.get("votes", {}) if typeof(value.get("votes", {})) == TYPE_DICTIONARY else {},
		}
	var old_rating := clampi(int(value), 0, 5)
	return {
		"average": float(old_rating),
		"count": 1 if old_rating > 0 else 0,
		"total": old_rating,
		"votes": {},
	}


func _get_current_vote(rating: Dictionary) -> int:
	var votes: Dictionary = rating.get("votes", {})
	if votes.has(current_voter_id):
		return int(votes[current_voter_id])
	if votes.has("local"):
		return int(votes["local"])
	for key in votes.keys():
		if String(key) != "legacy":
			return int(votes[key])
	return 0


func _format_rating(rating: Dictionary, current_vote: int) -> String:
	var count: int = max(0, int(rating.get("count", 0)))
	if count <= 0:
		return "Sin valoraciones"
	var average: float = float(rating.get("average", 0.0))
	var vote_text: String = " Tu voto: %s." % current_vote if current_vote > 0 else ""
	return "%.1f ★ (%s votos).%s" % [average, count, vote_text]


func _format_timestamp(timestamp: int) -> String:
	if timestamp <= 0:
		return "Sin fecha"
	var datetime := Time.get_datetime_dict_from_unix_time(timestamp)
	return "%02d/%02d/%04d %02d:%02d" % [
		int(datetime.get("day", 1)),
		int(datetime.get("month", 1)),
		int(datetime.get("year", 1970)),
		int(datetime.get("hour", 0)),
		int(datetime.get("minute", 0)),
	]


func _format_recent_visits(value) -> String:
	if typeof(value) != TYPE_ARRAY or value.is_empty():
		return "Sin historial"
	var parts := PackedStringArray()
	var start_index: int = max(0, value.size() - 3)
	for index in range(start_index, value.size()):
		var entry = value[index]
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		parts.append("%s (%s)" % [String(entry.get("date", "")), int(entry.get("count", 0))])
	return ", ".join(parts) if not parts.is_empty() else "Sin historial"


func _get_room_type_color(room_type: String) -> Color:
	match room_type:
		"descanso":
			return Color(0.34, 0.72, 0.56, 1.0)
		"juegos":
			return Color(0.94, 0.56, 0.28, 1.0)
		"estudio":
			return Color(0.42, 0.58, 0.94, 1.0)
		"coleccion":
			return Color(0.74, 0.56, 0.92, 1.0)
		"creativo":
			return Color(0.94, 0.42, 0.54, 1.0)
		"privado":
			return Color(0.52, 0.58, 0.66, 1.0)
		_:
			return Color(0.18, 0.48, 0.95, 1.0)
