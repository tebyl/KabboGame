class_name AchievementCatalog
extends RefCounted

const ACHIEVEMENTS := {
	"first_decorator": {
		"name": "Primer Decorador",
		"description": "Coloca tu primer mueble.",
		"icon_text": "D1",
		"conditions": { "furniture_placed": 1 },
	},
	"social_start": {
		"name": "Conversador",
		"description": "Envia tu primer mensaje.",
		"icon_text": "CH",
		"conditions": { "messages_sent": 1 },
	},
	"shopper": {
		"name": "Comprador Inicial",
		"description": "Compra tu primer mueble.",
		"icon_text": "$",
		"conditions": { "items_bought": 1 },
	},
	"interior_designer": {
		"name": "Disenador de Interiores",
		"description": "Coloca 10 muebles.",
		"icon_text": "10",
		"conditions": { "furniture_placed": 10 },
	},
	"room_creator": {
		"name": "Explorador de Salas",
		"description": "Crea una sala nueva.",
		"icon_text": "R",
		"conditions": { "rooms_created": 1 },
	},
	"style_editor": {
		"name": "Anfitrion",
		"description": "Cambia piso y pared.",
		"icon_text": "ST",
		"conditions": { "floors_changed": 1, "walls_changed": 1 },
	},
}


static func get_achievements() -> Dictionary:
	return ACHIEVEMENTS.duplicate(true)


static func get_achievement(achievement_id: String) -> Dictionary:
	return ACHIEVEMENTS.get(achievement_id, {}).duplicate(true)
