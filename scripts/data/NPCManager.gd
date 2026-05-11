class_name NPCManager
extends RefCounted

const DEFAULT_NPCS := [
	{ "id": "mira", "name": "Mira", "avatar_variant": "green", "cell": { "x": 2, "y": 2 } },
	{ "id": "pixel", "name": "Pixel", "avatar_variant": "purple", "cell": { "x": 7, "y": 3 } },
	{ "id": "nova", "name": "Nova", "avatar_variant": "yellow", "cell": { "x": 5, "y": 7 } },
	{ "id": "neo", "name": "Neo", "avatar_variant": "red", "cell": { "x": 6, "y": 5 } },
	{ "id": "luna", "name": "Luna", "avatar_variant": "blue", "cell": { "x": 3, "y": 6 } },
]

const CHAT_LINES := [
	"Hola",
	"Linda sala",
	"Decoramos?",
	"Me gusta este lugar",
	"Estoy explorando",
	"Buen diseno",
	"Que buena onda",
	"Voy a mirar por aca",
]


func get_default_npcs() -> Array:
	return DEFAULT_NPCS.duplicate(true)


func get_random_chat_line() -> String:
	return CHAT_LINES.pick_random()


func get_random_idle_line() -> String:
	return get_random_chat_line()
