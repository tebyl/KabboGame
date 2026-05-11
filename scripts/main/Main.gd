extends Node2D

const SaveManagerScript := preload("res://scripts/data/SaveManager.gd")
const InventoryManagerScript := preload("res://scripts/data/InventoryManager.gd")
const ProfileManagerScript := preload("res://scripts/data/ProfileManager.gd")
const ChatManagerScript := preload("res://scripts/data/ChatManager.gd")
const CurrencyManagerScript := preload("res://scripts/data/CurrencyManager.gd")
const FurnitureCatalogScript := preload("res://scripts/data/FurnitureCatalog.gd")
const RoomManagerScript := preload("res://scripts/data/RoomManager.gd")
const NPCManagerScript := preload("res://scripts/data/NPCManager.gd")
const ROOM_SCENE := preload("res://scenes/room/Room.tscn")
const HUD_PATH := "res://scenes/ui/GameHUD.tscn"
const INVENTORY_PATH := "res://scenes/ui/InventoryPanel.tscn"
const PROFILE_PATH := "res://scenes/ui/ProfilePanel.tscn"
const CHAT_PATH := "res://scenes/ui/ChatPanel.tscn"
const SHOP_PATH := "res://scenes/ui/ShopPanel.tscn"
const ROOM_SELECT_PATH := "res://scenes/ui/RoomSelectPanel.tscn"
const TOAST_PATH := "res://scenes/ui/ToastPanel.tscn"
const DECOR_PATH := "res://scenes/ui/DecorPanel.tscn"
const DECOR_INSPECTOR_PATH := "res://scenes/ui/DecorInspectorPanel.tscn"

const DEFAULT_INVENTORY := {
	"chair": 5,
	"sofa": 2,
	"table": 2,
	"desk": 1,
	"bed": 1,
	"plant": 3,
	"big_plant": 1,
	"lamp": 2,
	"bookshelf": 1,
	"rug": 1,
	"red_rug": 1,
	"blue_rug": 1,
}

var room_data := {
	"id": "default_room",
	"name": "Mi Sala",
	"width": 10,
	"height": 10,
	"floor_type": "beige_basic",
	"player_start": Vector2i(4, 4),
}

var room
var hud: Node
var inventory_panel: Node
var profile_panel: Node
var chat_panel: Node
var shop_panel: Node
var room_select_panel: Node
var toast_panel: Node
var decor_panel: Node
var decor_inspector_panel: Node
var inventory_manager
var profile_manager
var chat_manager
var currency_manager
var room_manager
var npc_manager
var pending_save_data := {}
var chat_has_focus := false


func _ready() -> void:
	_load_initial_data()
	_load_room_manager()
	_load_inventory()
	_load_profile()
	_load_chat()
	_load_currency()
	_load_npc_manager()
	_load_room()
	_load_hud_if_available()
	_load_inventory_panel_if_available()
	_load_profile_panel_if_available()
	_load_chat_panel_if_available()
	_load_shop_panel_if_available()
	_load_room_select_panel_if_available()
	_load_toast_panel_if_available()
	_load_decor_panel_if_available()
	_load_decor_inspector_panel_if_available()
	_connect_ui_signals()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ENTER:
		if not chat_has_focus and chat_panel and chat_panel.has_method("focus_input"):
			chat_panel.focus_input()
			get_viewport().set_input_as_handled()


func _load_initial_data() -> void:
	if SaveManagerScript.has_save():
		pending_save_data = SaveManagerScript.load_game()


func _load_room_manager() -> void:
	room_manager = RoomManagerScript.new()
	room_manager.setup(pending_save_data)
	room_data = room_manager.get_current_room()


func _load_inventory() -> void:
	inventory_manager = InventoryManagerScript.new()
	var inventory_data: Dictionary = _get_dict_or_default(pending_save_data.get("inventory"), DEFAULT_INVENTORY)
	inventory_manager.setup(inventory_data)


func _load_profile() -> void:
	profile_manager = ProfileManagerScript.new()
	var profile_data: Dictionary = _get_dict_or_default(pending_save_data.get("profile"), {})
	profile_manager.setup(profile_data)


func _load_chat() -> void:
	chat_manager = ChatManagerScript.new()
	var chat_data: Array = _get_array_or_default(pending_save_data.get("chat"), [])
	chat_manager.load_save_data(chat_data)


func _load_currency() -> void:
	currency_manager = CurrencyManagerScript.new()
	var currency_data: Dictionary = _get_dict_or_default(pending_save_data.get("currency"), {})
	currency_manager.load_save_data(currency_data)


func _load_npc_manager() -> void:
	npc_manager = NPCManagerScript.new()


func _load_room() -> void:
	room = ROOM_SCENE.instantiate()
	room.position = Vector2(640, 170)
	room.room_data = room_data.duplicate()
	add_child(room)
	room.load_room_state(room_manager.get_current_room())
	room.apply_profile(profile_manager.get_profile())
	_spawn_default_npcs()
	if room.has_signal("player_moved"):
		room.player_moved.connect(_on_room_player_moved)


func _load_hud_if_available() -> void:
	if not ResourceLoader.exists(HUD_PATH):
		return
	hud = load(HUD_PATH).instantiate()
	add_child(hud)
	if hud.has_method("setup"):
		hud.setup(room_data)
	if hud.has_method("set_player_name"):
		hud.set_player_name(profile_manager.get_name())
	if hud.has_method("set_coins"):
		hud.set_coins(currency_manager.get_coins())


func _load_inventory_panel_if_available() -> void:
	if not ResourceLoader.exists(INVENTORY_PATH):
		return
	inventory_panel = load(INVENTORY_PATH).instantiate()
	add_child(inventory_panel)
	if inventory_panel.has_method("setup_inventory"):
		inventory_panel.setup_inventory(inventory_manager.get_items())


func _load_profile_panel_if_available() -> void:
	if not ResourceLoader.exists(PROFILE_PATH):
		return
	profile_panel = load(PROFILE_PATH).instantiate()
	add_child(profile_panel)


func _load_chat_panel_if_available() -> void:
	if not ResourceLoader.exists(CHAT_PATH):
		return
	chat_panel = load(CHAT_PATH).instantiate()
	add_child(chat_panel)
	if chat_panel.has_method("set_messages"):
		chat_panel.set_messages(chat_manager.get_messages())


func _load_shop_panel_if_available() -> void:
	if not ResourceLoader.exists(SHOP_PATH):
		return
	shop_panel = load(SHOP_PATH).instantiate()
	add_child(shop_panel)


func _load_room_select_panel_if_available() -> void:
	if not ResourceLoader.exists(ROOM_SELECT_PATH):
		return
	room_select_panel = load(ROOM_SELECT_PATH).instantiate()
	add_child(room_select_panel)


func _load_toast_panel_if_available() -> void:
	if not ResourceLoader.exists(TOAST_PATH):
		return
	toast_panel = load(TOAST_PATH).instantiate()
	add_child(toast_panel)


func _load_decor_panel_if_available() -> void:
	if not ResourceLoader.exists(DECOR_PATH):
		return
	decor_panel = load(DECOR_PATH).instantiate()
	add_child(decor_panel)


func _load_decor_inspector_panel_if_available() -> void:
	if not ResourceLoader.exists(DECOR_INSPECTOR_PATH):
		return
	decor_inspector_panel = load(DECOR_INSPECTOR_PATH).instantiate()
	add_child(decor_inspector_panel)


func _connect_ui_signals() -> void:
	if hud:
		hud.decorate_toggled.connect(_on_decorate_toggled)
		hud.rotate_selected_requested.connect(room.rotate_selected_furniture)
		hud.delete_selected_requested.connect(room.delete_selected_furniture)
		hud.inventory_requested.connect(_show_inventory)
		hud.save_requested.connect(_on_save_requested)
		hud.profile_requested.connect(_show_profile)
		hud.shop_requested.connect(_show_shop)
		hud.rooms_requested.connect(_show_rooms)
	if room and room.has_signal("room_changed"):
		room.room_changed.connect(_autosave_current_room)
		room.furniture_place_requested.connect(_on_room_furniture_place_requested)
		room.furniture_removed_to_inventory.connect(_on_room_furniture_removed_to_inventory)
		room.movement_failed.connect(_on_room_movement_failed)
		room.npc_chat_message.connect(_on_npc_chat_message)
		room.placement_failed.connect(_on_room_placement_failed)
		room.furniture_selected.connect(_on_room_furniture_selected)
		room.furniture_deselected.connect(_on_room_furniture_deselected)
	if inventory_panel:
		inventory_panel.furniture_selected.connect(room.start_furniture_preview)
		inventory_panel.close_requested.connect(_on_inventory_closed)
	if profile_panel:
		profile_panel.profile_save_requested.connect(_on_profile_save_requested)
		profile_panel.close_requested.connect(_on_profile_closed)
	if chat_panel:
		chat_panel.chat_submitted.connect(_on_chat_submitted)
		chat_panel.chat_focus_changed.connect(_on_chat_focus_changed)
	if shop_panel:
		shop_panel.buy_requested.connect(_on_shop_buy_requested)
		shop_panel.close_requested.connect(_on_shop_closed)
	if room_select_panel:
		room_select_panel.room_selected.connect(_on_room_selected)
		room_select_panel.create_room_requested.connect(_on_create_room_requested)
		room_select_panel.close_requested.connect(_on_room_select_closed)
	if decor_panel:
		decor_panel.floor_type_selected.connect(_on_decor_floor_type_selected)
		decor_panel.wall_type_selected.connect(_on_decor_wall_type_selected)
		decor_panel.rotate_preview_requested.connect(room.rotate_furniture_preview)
		decor_panel.cancel_preview_requested.connect(room.cancel_furniture_preview)
		decor_panel.close_requested.connect(_on_decor_panel_closed)
	if decor_inspector_panel:
		decor_inspector_panel.rotate_requested.connect(room.rotate_selected_furniture)
		decor_inspector_panel.delete_requested.connect(room.delete_selected_furniture)
		decor_inspector_panel.close_requested.connect(room.clear_furniture_selection)


func _on_room_player_moved(_cell: Vector2i) -> void:
	pass


func _on_decorate_toggled(enabled: bool) -> void:
	room.set_decoration_mode(enabled)
	if hud and hud.has_method("set_decorate_enabled"):
		hud.set_decorate_enabled(enabled)
	if decor_panel:
		if enabled:
			decor_panel.show_panel(room.get_floor_type(), room.get_wall_type())
		else:
			decor_panel.hide_panel()
	if decor_inspector_panel and not enabled:
		decor_inspector_panel.hide_panel()
	if inventory_panel:
		if enabled:
			inventory_panel.show_inventory()
		else:
			inventory_panel.hide_inventory()


func _show_inventory() -> void:
	if inventory_panel:
		inventory_panel.show_inventory()


func _show_profile() -> void:
	if profile_panel:
		profile_panel.show_with_profile(profile_manager.get_profile())


func _show_shop() -> void:
	if shop_panel:
		shop_panel.show_shop(
			FurnitureCatalogScript.get_shop_items(),
			inventory_manager.get_items(),
			currency_manager.get_coins()
		)


func _show_rooms() -> void:
	_sync_current_room_state()
	if room_select_panel:
		room_select_panel.show_with_rooms(room_manager.get_rooms(), room_manager.get_current_room_id())


func _on_inventory_closed() -> void:
	room.cancel_furniture_preview()


func _on_profile_closed() -> void:
	pass


func _on_shop_closed() -> void:
	pass


func _on_room_select_closed() -> void:
	pass


func _autosave_current_room() -> void:
	if not room or not room.has_method("get_room_state"):
		return
	_sync_current_room_state()
	var room_save: Dictionary = room_manager.to_save_data()
	var save_data := {
		"version": 2,
		"current_room_id": room_save.get("current_room_id", "room_default"),
		"rooms": room_save.get("rooms", []),
	}
	save_data["inventory"] = inventory_manager.to_save_data()
	save_data["profile"] = profile_manager.to_save_data()
	save_data["chat"] = chat_manager.to_save_data()
	save_data["currency"] = currency_manager.to_save_data()
	SaveManagerScript.save_game(save_data)


func _on_save_requested() -> void:
	_autosave_current_room()
	_show_toast("Guardado", "success")


func _on_room_furniture_place_requested(furniture_type: String, cell: Vector2i, furniture_rotation: int) -> void:
	if not inventory_manager.remove_item(furniture_type, 1):
		_show_toast("No tienes unidades disponibles", "warning")
		_update_inventory_panel()
		return
	if not room.confirm_place_furniture(furniture_type, cell, furniture_rotation):
		inventory_manager.add_item(furniture_type, 1)
	_update_inventory_panel()


func _on_room_furniture_removed_to_inventory(furniture_type: String) -> void:
	inventory_manager.add_item(furniture_type, 1)
	_update_inventory_panel()


func _update_inventory_panel() -> void:
	if inventory_panel and inventory_panel.has_method("update_inventory"):
		inventory_panel.update_inventory(inventory_manager.get_items())
	if shop_panel and shop_panel.has_method("update_state"):
		shop_panel.update_state(inventory_manager.get_items(), currency_manager.get_coins())


func _on_profile_save_requested(profile_data: Dictionary) -> void:
	profile_manager.load_save_data(profile_data)
	room.apply_profile(profile_manager.get_profile())
	if hud:
		hud.set_player_name(profile_manager.get_name())
		_show_toast("Perfil guardado", "success")
	_autosave_current_room()
	if profile_panel:
		profile_panel.hide_panel()


func _on_chat_submitted(text: String) -> void:
	var message: Dictionary = chat_manager.add_message(profile_manager.get_name(), text, "local")
	if message.is_empty():
		return
	if chat_panel and chat_panel.has_method("add_message"):
		chat_panel.add_message(message)
	if room and room.has_method("show_player_speech"):
		room.show_player_speech(String(message.get("text", "")))
	_autosave_current_room()


func _on_npc_chat_message(sender: String, text: String) -> void:
	var message: Dictionary = chat_manager.add_message(sender, text, "npc")
	if message.is_empty():
		return
	if chat_panel and chat_panel.has_method("add_message"):
		chat_panel.add_message(message)


func _on_chat_focus_changed(focused: bool) -> void:
	chat_has_focus = focused
	if room and room.has_method("set_input_blocked"):
		room.set_input_blocked(focused)


func _on_shop_buy_requested(furniture_type: String) -> void:
	var item := FurnitureCatalogScript.get_item(furniture_type)
	if item.is_empty():
		_show_toast("Articulo no encontrado", "error")
		return

	var price := int(item.get("price", 0))
	if not currency_manager.spend(price):
		_show_toast("No tienes monedas suficientes", "warning")
		_update_shop_panel()
		return

	inventory_manager.add_item(furniture_type, 1)
	if hud:
		hud.set_coins(currency_manager.get_coins())
		_show_toast("Compra realizada", "success")
	_update_inventory_panel()
	_autosave_current_room()


func _update_shop_panel() -> void:
	if shop_panel and shop_panel.has_method("update_state"):
		shop_panel.update_state(inventory_manager.get_items(), currency_manager.get_coins())


func _on_room_movement_failed(reason: String) -> void:
	match reason:
		"bloqueado":
			_show_toast("Esa celda esta ocupada", "warning")
		"sin_ruta":
			_show_toast("No hay camino disponible", "warning")
		"fuera":
			_show_toast("Fuera de la sala", "warning")
		_:
			_show_toast("No se puede caminar ahi", "warning")


func _on_room_placement_failed(reason: String) -> void:
	_show_toast(reason, "warning")


func _on_room_furniture_selected(data: Dictionary) -> void:
	if decor_inspector_panel and decor_inspector_panel.has_method("show_with_furniture"):
		decor_inspector_panel.show_with_furniture(data)


func _on_room_furniture_deselected() -> void:
	if decor_inspector_panel and decor_inspector_panel.has_method("hide_panel"):
		decor_inspector_panel.hide_panel()


func _on_decor_floor_type_selected(floor_type: String) -> void:
	room.set_floor_type(floor_type)
	if decor_panel:
		decor_panel.set_current_floor_type(room.get_floor_type())
	_show_toast("Piso actualizado", "success")


func _on_decor_wall_type_selected(wall_type: String) -> void:
	room.set_wall_type(wall_type)
	if decor_panel:
		decor_panel.set_current_wall_type(room.get_wall_type())
	_show_toast("Pared actualizada", "success")


func _on_decor_panel_closed() -> void:
	if hud and hud.has_method("set_decorate_enabled"):
		hud.set_decorate_enabled(false)
	room.set_decoration_mode(false)
	if inventory_panel:
		inventory_panel.hide_inventory()
	if decor_inspector_panel:
		decor_inspector_panel.hide_panel()


func _show_toast(text: String, toast_type: String = "info") -> void:
	if toast_panel and toast_panel.has_method("show_toast"):
		toast_panel.show_toast(text, toast_type)
	elif hud and hud.has_method("show_message"):
		hud.show_message(text)


func _sync_current_room_state() -> void:
	if room and room.has_method("get_room_state"):
		room_manager.update_current_room(room.get_room_state())


func _on_room_selected(room_id: String) -> void:
	_sync_current_room_state()
	if room_manager.set_current_room(room_id):
		var next_room: Dictionary = room_manager.get_current_room()
		room.load_room_state(next_room)
		room.apply_profile(profile_manager.get_profile())
		_spawn_default_npcs()
		if hud and hud.has_method("set_room_name"):
			hud.set_room_name(String(next_room.get("name", "Sala")))
		if room_select_panel:
			room_select_panel.hide_panel()
		_autosave_current_room()


func _on_create_room_requested() -> void:
	_sync_current_room_state()
	var new_room: Dictionary = room_manager.create_room("Nueva Sala", 10, 10)
	room_manager.add_room(new_room)
	room_manager.set_current_room(String(new_room.get("id", "")))
	room.load_room_state(new_room)
	room.apply_profile(profile_manager.get_profile())
	_spawn_default_npcs()
	if hud and hud.has_method("set_room_name"):
		hud.set_room_name(String(new_room.get("name", "Nueva Sala")))
	if room_select_panel:
		room_select_panel.update_rooms(room_manager.get_rooms(), room_manager.get_current_room_id())
	_autosave_current_room()


func _spawn_default_npcs() -> void:
	if room and npc_manager and room.has_method("spawn_npcs"):
		room.spawn_npcs(npc_manager.get_default_npcs())


func _get_dict_or_default(value, fallback: Dictionary) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return value
	return fallback.duplicate(true)


func _get_array_or_default(value, fallback: Array) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return value
	return fallback.duplicate(true)
