class_name DefaultGameData
extends RefCounted


static func get_default_inventory() -> Dictionary:
	return {
		"chair": 4,
		"table": 1,
		"sofa": 1,
		"plant": 2,
		"lamp": 1,
		"rug": 1,
	}


static func get_default_coins() -> int:
	return 300


static func get_default_room_data(profile_name: String = "Invitado") -> Dictionary:
	var now := int(Time.get_unix_time_from_system())
	return {
		"id": "room_default",
		"name": "Mi Sala",
		"description": "Una sala acogedora para conversar.",
		"owner_name": profile_name if not profile_name.strip_edges().is_empty() else "Invitado",
		"owner_id": "",
		"local_role": "owner",
		"room_type": "social",
		"mood": "relajada",
		"rating": {
			"average": 0.0,
			"count": 0,
			"total": 0,
			"votes": {},
		},
		"visits": 0,
		"visit_log": [],
		"created_at": now,
		"updated_at": now,
		"width": 10,
		"height": 10,
		"floor_type": "beige_basic",
		"wall_type": "default",
		"player_cell": { "x": 4, "y": 4 },
		"furniture": [],
	}
