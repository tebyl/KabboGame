class_name MissionCatalog
extends RefCounted

const MISSIONS := {
	"place_first_furniture": {
		"name": "Primer mueble",
		"description": "Coloca tu primer mueble en una sala.",
		"stat": "furniture_placed",
		"target": 1,
		"reward": { "coins": 40 },
	},
	"send_first_message": {
		"name": "Primer saludo",
		"description": "Envia tu primer mensaje en el chat.",
		"stat": "messages_sent",
		"target": 1,
		"reward": { "coins": 25 },
	},
	"buy_first_item": {
		"name": "Primera compra",
		"description": "Compra tu primer mueble en la tienda.",
		"stat": "items_bought",
		"target": 1,
		"reward": { "coins": 35 },
	},
	"decorate_5_items": {
		"name": "Decorador inicial",
		"description": "Coloca 5 muebles en tus salas.",
		"stat": "furniture_placed",
		"target": 5,
		"reward": { "coins": 80 },
	},
	"create_second_room": {
		"name": "Mas espacio",
		"description": "Crea una segunda sala.",
		"stat": "rooms_created",
		"target": 1,
		"reward": { "coins": 60 },
	},
	"change_floor_once": {
		"name": "Nuevo piso",
		"description": "Cambia el piso de una sala.",
		"stat": "floors_changed",
		"target": 1,
		"reward": { "coins": 35 },
	},
	"change_wall_once": {
		"name": "Nueva pared",
		"description": "Cambia las paredes de una sala.",
		"stat": "walls_changed",
		"target": 1,
		"reward": { "coins": 35 },
	},
	"update_profile_once": {
		"name": "Identidad propia",
		"description": "Actualiza tu perfil.",
		"stat": "profile_updates",
		"target": 1,
		"reward": { "coins": 30 },
	},
	"visit_shop_first_time": {
		"name": "Mirar la tienda",
		"description": "Abre la tienda por primera vez.",
		"stat": "shop_opened",
		"target": 1,
		"reward": { "coins": 20 },
	},
	"open_inventory_first_time": {
		"name": "Revisar inventario",
		"description": "Abre tu inventario por primera vez.",
		"stat": "inventory_opened",
		"target": 1,
		"reward": { "coins": 20 },
	},
}


static func get_missions() -> Dictionary:
	return MISSIONS.duplicate(true)


static func get_mission(mission_id: String) -> Dictionary:
	return MISSIONS.get(mission_id, {}).duplicate(true)
