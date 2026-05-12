extends Node2D

const SaveManagerScript := preload("res://scripts/data/SaveManager.gd")
const AudioManagerScript := preload("res://scripts/data/AudioManager.gd")
const DefaultGameDataScript := preload("res://scripts/data/DefaultGameData.gd")
const InventoryManagerScript := preload("res://scripts/data/InventoryManager.gd")
const ProfileManagerScript := preload("res://scripts/data/ProfileManager.gd")
const ChatManagerScript := preload("res://scripts/data/ChatManager.gd")
const CurrencyManagerScript := preload("res://scripts/data/CurrencyManager.gd")
const FurnitureCatalogScript := preload("res://scripts/data/FurnitureCatalog.gd")
const OnboardingManagerScript := preload("res://scripts/data/OnboardingManager.gd")
const PermissionManagerScript := preload("res://scripts/data/PermissionManager.gd")
const ProgressionManagerScript := preload("res://scripts/data/ProgressionManager.gd")
const RoomManagerScript := preload("res://scripts/data/RoomManager.gd")
const RoomExportManagerScript := preload("res://scripts/data/RoomExportManager.gd")
const NPCManagerScript := preload("res://scripts/data/NPCManager.gd")
const DebugConfigScript := preload("res://scripts/data/DebugConfig.gd")
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
const ONBOARDING_PATH := "res://scenes/ui/OnboardingPanel.tscn"
const MISSIONS_PATH := "res://scenes/ui/MissionsPanel.tscn"
const ACHIEVEMENTS_PATH := "res://scenes/ui/AchievementsPanel.tscn"
const SETTINGS_PATH := "res://scenes/ui/SettingsPanel.tscn"
const NPC_MANAGER_PATH := "res://scenes/ui/NpcManagerPanel.tscn"
const ROOM_INFO_PATH := "res://scenes/ui/RoomInfoPanel.tscn"
const ROOM_EDIT_PATH := "res://scenes/ui/RoomEditPanel.tscn"
const LOADING_SCREEN_PATH := "res://scenes/ui/LoadingScreen.tscn"

var room_data := {}

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
var onboarding_panel: Node
var missions_panel: Node
var achievements_panel: Node
var settings_panel: Node
var npc_manager_panel: Node
var room_info_panel: Node
var room_edit_panel: Node
var inventory_manager
var profile_manager
var chat_manager
var currency_manager
var room_manager
var npc_manager
var onboarding_manager
var progression_manager
var audio_manager
var pending_save_data := {}
var chat_has_focus := false
var pending_hud_delete_furniture_id := ""
var reset_progress_dialog: ConfirmationDialog
var loading_screen: Node


func _ready() -> void:
	_show_loading_screen()
	_load_initial_data()
	_load_audio_manager()
	_load_onboarding_manager()
	_load_progression_manager()
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
	_load_onboarding_panel_if_available()
	_load_missions_panel_if_available()
	_load_achievements_panel_if_available()
	_load_settings_panel_if_available()
	_load_npc_manager_panel_if_available()
	_load_room_info_panel_if_available()
	_load_room_edit_panel_if_available()
	_connect_ui_signals()
	_update_progression_ui()
	_show_save_recovery_message_if_needed()
	_show_onboarding_if_needed()
	_autosave_current_room()
	await get_tree().process_frame
	_hide_loading_screen()


func _unhandled_input(event: InputEvent) -> void:
	if _handle_tester_shortcuts(event):
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ENTER:
		if not chat_has_focus and chat_panel and chat_panel.has_method("focus_input"):
			chat_panel.focus_input()
			get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_position_room()


func _load_initial_data() -> void:
	_set_loading_message("Cargando save local")
	if SaveManagerScript.has_save():
		pending_save_data = SaveManagerScript.load_game()


func _load_audio_manager() -> void:
	audio_manager = AudioManagerScript.new()
	audio_manager.setup(self)
	var settings_data: Dictionary = _get_dict_or_default(pending_save_data.get("settings"), {})
	audio_manager.load_save_data(settings_data)


func _load_onboarding_manager() -> void:
	onboarding_manager = OnboardingManagerScript.new()
	var onboarding_data: Dictionary = _get_dict_or_default(pending_save_data.get("onboarding"), {})
	onboarding_manager.setup(onboarding_data)


func _load_progression_manager() -> void:
	progression_manager = ProgressionManagerScript.new()
	var progression_data: Dictionary = _get_dict_or_default(pending_save_data.get("progression"), {})
	progression_manager.setup(progression_data)


func _load_room_manager() -> void:
	room_manager = RoomManagerScript.new()
	var profile_data: Dictionary = _get_dict_or_default(pending_save_data.get("profile"), {})
	room_manager.setup(pending_save_data, String(profile_data.get("name", "Invitado")))
	room_data = room_manager.get_current_room()


func _load_inventory() -> void:
	inventory_manager = InventoryManagerScript.new()
	var inventory_data: Dictionary = _get_dict_or_default(pending_save_data.get("inventory"), DefaultGameDataScript.get_default_inventory())
	inventory_manager.setup(inventory_data)


func _load_profile() -> void:
	profile_manager = ProfileManagerScript.new()
	var profile_data: Dictionary = _get_dict_or_default(pending_save_data.get("profile"), {})
	profile_manager.setup(profile_data)
	if room_manager and room_manager.has_method("set_profile_data"):
		room_manager.set_profile_data(profile_manager.get_profile())
		room_data = room_manager.get_current_room()


func _load_chat() -> void:
	chat_manager = ChatManagerScript.new()
	chat_manager.load_save_data([])


func _load_currency() -> void:
	currency_manager = CurrencyManagerScript.new()
	var currency_data: Dictionary = _get_dict_or_default(pending_save_data.get("currency"), {})
	currency_manager.load_save_data(currency_data)


func _load_npc_manager() -> void:
	npc_manager = NPCManagerScript.new()


func _load_room() -> void:
	_set_loading_message("Inicializando sala")
	room = ROOM_SCENE.instantiate()
	_position_room()
	room.room_data = room_data.duplicate()
	add_child(room)
	_position_room()
	room.load_room_state(room_manager.get_current_room())
	room.set_local_role(room_manager.get_current_room_role())
	room.apply_profile(profile_manager.get_profile())
	_spawn_default_npcs()
	room_manager.increment_room_visits(room_manager.get_current_room_id())
	_sync_room_visit_counter()
	if room.has_signal("player_moved"):
		room.player_moved.connect(_on_room_player_moved)


func _position_room() -> void:
	if not room:
		return
	var viewport_size := get_viewport_rect().size
	room.position = Vector2(viewport_size.x * 0.5, max(124.0, viewport_size.y * 0.22))


func _load_hud_if_available() -> void:
	_set_loading_message("Cargando interfaz")
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
	_apply_current_room_permissions()


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


func _load_onboarding_panel_if_available() -> void:
	if not ResourceLoader.exists(ONBOARDING_PATH):
		return
	onboarding_panel = load(ONBOARDING_PATH).instantiate()
	add_child(onboarding_panel)


func _load_missions_panel_if_available() -> void:
	if not ResourceLoader.exists(MISSIONS_PATH):
		return
	missions_panel = load(MISSIONS_PATH).instantiate()
	add_child(missions_panel)


func _load_achievements_panel_if_available() -> void:
	if not ResourceLoader.exists(ACHIEVEMENTS_PATH):
		return
	achievements_panel = load(ACHIEVEMENTS_PATH).instantiate()
	add_child(achievements_panel)


func _load_settings_panel_if_available() -> void:
	if not ResourceLoader.exists(SETTINGS_PATH):
		return
	settings_panel = load(SETTINGS_PATH).instantiate()
	add_child(settings_panel)


func _load_npc_manager_panel_if_available() -> void:
	if not ResourceLoader.exists(NPC_MANAGER_PATH):
		return
	npc_manager_panel = load(NPC_MANAGER_PATH).instantiate()
	add_child(npc_manager_panel)


func _load_room_info_panel_if_available() -> void:
	if not ResourceLoader.exists(ROOM_INFO_PATH):
		return
	room_info_panel = load(ROOM_INFO_PATH).instantiate()
	add_child(room_info_panel)


func _load_room_edit_panel_if_available() -> void:
	if not ResourceLoader.exists(ROOM_EDIT_PATH):
		return
	room_edit_panel = load(ROOM_EDIT_PATH).instantiate()
	add_child(room_edit_panel)


func _connect_ui_signals() -> void:
	if hud:
		hud.decorate_toggled.connect(_on_decorate_toggled)
		hud.rotate_selected_requested.connect(_on_rotate_selected_requested)
		hud.delete_selected_requested.connect(_on_delete_selected_requested)
		hud.inventory_requested.connect(_show_inventory)
		hud.save_requested.connect(_on_save_requested)
		hud.profile_requested.connect(_show_profile)
		hud.shop_requested.connect(_show_shop)
		hud.rooms_requested.connect(_show_rooms)
		hud.tutorial_requested.connect(_on_tutorial_requested)
		hud.missions_requested.connect(_show_missions)
		hud.achievements_requested.connect(_show_achievements)
		hud.settings_requested.connect(_show_settings)
		if hud.has_signal("decor_tools_requested"):
			hud.decor_tools_requested.connect(_show_decor_tools)
		if hud.has_signal("npc_manager_requested"):
			hud.npc_manager_requested.connect(_show_npc_manager)
		if hud.has_signal("room_info_requested"):
			hud.room_info_requested.connect(_on_room_info_requested)
		if hud.has_signal("reset_progress_requested"):
			hud.reset_progress_requested.connect(_on_reset_progress_requested)
		if hud.has_signal("exit_requested"):
			hud.exit_requested.connect(_on_exit_requested)
	if room and room.has_signal("room_changed"):
		room.room_changed.connect(_autosave_current_room)
		room.furniture_place_requested.connect(_on_room_furniture_place_requested)
		room.furniture_removed_to_inventory.connect(_on_room_furniture_removed_to_inventory)
		room.movement_failed.connect(_on_room_movement_failed)
		room.npc_chat_message.connect(_on_npc_chat_message)
		room.placement_failed.connect(_on_room_placement_failed)
		room.permission_denied.connect(_on_room_permission_denied)
		room.furniture_selected.connect(_on_room_furniture_selected)
		room.furniture_deselected.connect(_on_room_furniture_deselected)
		room.furniture_placed.connect(_on_room_furniture_placed)
		room.furniture_move_started.connect(_on_room_furniture_move_started)
		room.furniture_move_cancelled.connect(_on_room_furniture_move_cancelled)
		room.furniture_moved.connect(_on_room_furniture_moved)
		room.furniture_action_failed.connect(_on_room_furniture_action_failed)
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
		room_select_panel.rename_room_requested.connect(_on_rename_room_requested)
		room_select_panel.duplicate_room_requested.connect(_on_duplicate_room_requested)
		room_select_panel.delete_room_requested.connect(_on_delete_room_requested)
		room_select_panel.export_room_requested.connect(_on_export_room_requested)
		room_select_panel.import_room_requested.connect(_on_import_room_requested)
		room_select_panel.toggle_room_role_requested.connect(_on_toggle_room_role_requested)
		room_select_panel.close_requested.connect(_on_room_select_closed)
	if decor_panel:
		decor_panel.floor_type_selected.connect(_on_decor_floor_type_selected)
		decor_panel.wall_type_selected.connect(_on_decor_wall_type_selected)
		decor_panel.rotate_preview_requested.connect(room.rotate_furniture_preview)
		decor_panel.cancel_preview_requested.connect(room.cancel_furniture_preview)
		decor_panel.npcs_hidden_changed.connect(room.set_npcs_hidden_for_decoration)
		decor_panel.close_requested.connect(_on_decor_panel_closed)
	if decor_inspector_panel:
		decor_inspector_panel.move_requested.connect(room.start_move_selected_furniture)
		decor_inspector_panel.rotate_requested.connect(room.rotate_selected_furniture)
		decor_inspector_panel.delete_requested.connect(room.delete_selected_furniture)
		decor_inspector_panel.close_requested.connect(room.clear_furniture_selection)
	if onboarding_panel:
		onboarding_panel.next_requested.connect(_on_onboarding_next_requested)
		onboarding_panel.skip_requested.connect(_on_onboarding_skip_requested)
		onboarding_panel.action_requested.connect(_on_onboarding_action_requested)
	if missions_panel:
		missions_panel.claim_mission_requested.connect(_on_claim_mission_requested)
		missions_panel.close_requested.connect(_on_missions_panel_closed)
	if achievements_panel:
		achievements_panel.close_requested.connect(_on_achievements_panel_closed)
	if settings_panel:
		settings_panel.sfx_enabled_changed.connect(_on_sfx_enabled_changed)
		settings_panel.sfx_volume_changed.connect(_on_sfx_volume_changed)
		if settings_panel.has_signal("test_audio_requested"):
			settings_panel.test_audio_requested.connect(_on_test_audio_requested)
		settings_panel.close_requested.connect(_on_settings_panel_closed)
	if npc_manager_panel:
		npc_manager_panel.add_npc_requested.connect(_on_add_npc_requested)
		npc_manager_panel.remove_npc_requested.connect(_on_remove_npc_requested)
		npc_manager_panel.respawn_npcs_requested.connect(_on_respawn_npcs_requested)
		npc_manager_panel.npc_movement_toggled.connect(_on_npc_movement_toggled)
		npc_manager_panel.npc_chat_toggled.connect(_on_npc_chat_toggled)
		npc_manager_panel.close_requested.connect(_on_npc_manager_panel_closed)
	if room_info_panel:
		room_info_panel.edit_requested.connect(_on_room_info_edit_requested)
		room_info_panel.rating_changed.connect(_on_room_rating_changed)
		room_info_panel.close_requested.connect(_on_room_info_closed)
	if room_edit_panel:
		room_edit_panel.save_requested.connect(_on_room_profile_save_requested)
		room_edit_panel.close_requested.connect(_on_room_edit_closed)
	_connect_button_click_sfx(self)


func _on_room_player_moved(_cell: Vector2i) -> void:
	_play_sfx("walk_step")
	_advance_onboarding_if_step(OnboardingManagerScript.STEP_WALK)


func _on_decorate_toggled(enabled: bool) -> void:
	if enabled and not PermissionManagerScript.can_decorate(room_manager.get_current_room_role()):
		_show_toast("No tienes permiso para esta acción", "warning")
		_play_sfx("error")
		if hud and hud.has_method("set_decorate_enabled"):
			hud.set_decorate_enabled(false)
		return
	room.set_decoration_mode(enabled)
	if enabled:
		_advance_onboarding_if_step(OnboardingManagerScript.STEP_DECORATE)
	if hud and hud.has_method("set_decorate_enabled"):
		hud.set_decorate_enabled(enabled)
	if decor_panel:
		if not enabled:
			decor_panel.hide_panel()
	if decor_inspector_panel and not enabled:
		decor_inspector_panel.hide_panel()
	if inventory_panel and not enabled:
		inventory_panel.hide_inventory()


func _on_rotate_selected_requested() -> void:
	room.rotate_selected_furniture()
	_play_sfx("rotate_furniture")


func _on_delete_selected_requested() -> void:
	var selected_data: Dictionary = room.get_selected_furniture_data() if room and room.has_method("get_selected_furniture_data") else {}
	var selected_id := String(selected_data.get("id", ""))
	if selected_id.is_empty():
		pending_hud_delete_furniture_id = ""
		return
	if pending_hud_delete_furniture_id != selected_id:
		pending_hud_delete_furniture_id = selected_id
		_show_toast("Pulsa Eliminar otra vez para confirmar", "warning")
		return
	pending_hud_delete_furniture_id = ""
	room.delete_selected_furniture()


func _show_inventory() -> void:
	_hide_primary_panels(inventory_panel)
	if room and not room.decoration_mode:
		if hud and hud.has_method("set_decorate_enabled"):
			hud.set_decorate_enabled(true)
		_on_decorate_toggled(true)
	if inventory_panel:
		inventory_panel.show_inventory()
	_play_sfx("ui_open")
	if progression_manager:
		_process_progression_events(progression_manager.increment_stat("inventory_opened", 1))
	_advance_onboarding_if_step(OnboardingManagerScript.STEP_INVENTORY)


func _show_profile() -> void:
	_hide_primary_panels(profile_panel)
	if profile_panel:
		profile_panel.show_with_profile(profile_manager.get_profile())
	_play_sfx("ui_open")


func _show_shop() -> void:
	_hide_primary_panels(shop_panel)
	if shop_panel:
		shop_panel.show_shop(
			FurnitureCatalogScript.get_shop_items(),
			inventory_manager.get_items(),
			currency_manager.get_coins()
		)
	_play_sfx("ui_open")
	if progression_manager:
		_process_progression_events(progression_manager.increment_stat("shop_opened", 1))
	_advance_onboarding_if_step(OnboardingManagerScript.STEP_SHOP)


func _show_rooms() -> void:
	_sync_current_room_state()
	_hide_primary_panels(room_select_panel)
	if room_select_panel:
		room_select_panel.show_with_rooms(room_manager.get_rooms(), room_manager.get_current_room_id())
	_play_sfx("ui_open")


func _show_missions() -> void:
	_hide_primary_panels(missions_panel)
	if missions_panel and progression_manager:
		missions_panel.show_with_data(progression_manager.get_missions(), progression_manager.get_stats())
	_play_sfx("ui_open")


func _show_achievements() -> void:
	_hide_primary_panels(achievements_panel)
	if achievements_panel and progression_manager:
		achievements_panel.show_with_data(progression_manager.get_achievements(), progression_manager.get_stats())
	_play_sfx("ui_open")


func _show_settings() -> void:
	_hide_primary_panels(settings_panel)
	if settings_panel and audio_manager:
		settings_panel.show_with_settings(audio_manager.is_sfx_enabled(), audio_manager.get_sfx_volume())
	_play_sfx("ui_open")


func _show_decor_tools() -> void:
	if not PermissionManagerScript.can_decorate(room_manager.get_current_room_role()):
		_show_toast("No tienes permiso para esta acción", "warning")
		_play_sfx("error")
		return
	_hide_primary_panels(decor_panel)
	if room and not room.decoration_mode:
		if hud and hud.has_method("set_decorate_enabled"):
			hud.set_decorate_enabled(true)
		_on_decorate_toggled(true)
	if decor_panel:
		decor_panel.show_panel(room.get_floor_type(), room.get_wall_type())
	_play_sfx("ui_open")


func _show_npc_manager() -> void:
	_hide_primary_panels(npc_manager_panel)
	if npc_manager_panel and room:
		var can_manage := PermissionManagerScript.can_decorate(room_manager.get_current_room_role())
		npc_manager_panel.show_with_npcs(room.get_npc_list(), room.npc_movement_enabled, room.npc_chat_enabled, can_manage)
	_play_sfx("ui_open")


func _hide_primary_panels(except_panel: Node = null) -> void:
	if inventory_panel and inventory_panel != except_panel and inventory_panel.has_method("hide_inventory"):
		inventory_panel.hide_inventory()
	if shop_panel and shop_panel != except_panel and shop_panel.has_method("hide_shop"):
		shop_panel.hide_shop()
	if room_select_panel and room_select_panel != except_panel and room_select_panel.has_method("hide_panel"):
		room_select_panel.hide_panel()
	if profile_panel and profile_panel != except_panel and profile_panel.has_method("hide_panel"):
		profile_panel.hide_panel()
	if missions_panel and missions_panel != except_panel and missions_panel.has_method("hide_panel"):
		missions_panel.hide_panel()
	if achievements_panel and achievements_panel != except_panel and achievements_panel.has_method("hide_panel"):
		achievements_panel.hide_panel()
	if settings_panel and settings_panel != except_panel and settings_panel.has_method("hide_panel"):
		settings_panel.hide_panel()
	if npc_manager_panel and npc_manager_panel != except_panel and npc_manager_panel.has_method("hide_panel"):
		npc_manager_panel.hide_panel()
	if decor_panel and decor_panel != except_panel and decor_panel.has_method("hide_panel"):
		decor_panel.hide_panel()
	if room_info_panel and room_info_panel != except_panel and room_info_panel.has_method("hide_panel"):
		room_info_panel.hide_panel()
	if room_edit_panel and room_edit_panel != except_panel and room_edit_panel.has_method("hide_panel"):
		room_edit_panel.hide_panel()


func _on_inventory_closed() -> void:
	room.cancel_furniture_preview()
	_play_sfx("ui_close")


func _on_profile_closed() -> void:
	_play_sfx("ui_close")


func _on_shop_closed() -> void:
	_play_sfx("ui_close")


func _on_room_select_closed() -> void:
	_play_sfx("ui_close")


func _on_missions_panel_closed() -> void:
	_play_sfx("ui_close")


func _on_achievements_panel_closed() -> void:
	_play_sfx("ui_close")


func _on_settings_panel_closed() -> void:
	_play_sfx("ui_close")


func _on_npc_manager_panel_closed() -> void:
	_play_sfx("ui_close")


func _on_room_info_closed() -> void:
	_play_sfx("ui_close")


func _on_room_edit_closed() -> void:
	_play_sfx("ui_close")


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
	save_data["currency"] = currency_manager.to_save_data()
	if onboarding_manager:
		save_data["onboarding"] = onboarding_manager.to_save_data()
	if progression_manager:
		save_data["progression"] = progression_manager.to_save_data()
	if audio_manager:
		save_data["settings"] = audio_manager.to_save_data()
	SaveManagerScript.save_game(save_data)


func _on_save_requested() -> void:
	_autosave_current_room()
	_play_sfx("save")
	if onboarding_manager and onboarding_manager.get_current_step() == OnboardingManagerScript.STEP_SAVE:
		_complete_onboarding()
	_show_toast("Guardado", "success")


func _on_room_furniture_place_requested(furniture_type: String, cell: Vector2i, furniture_rotation: int) -> void:
	if not PermissionManagerScript.can_place_furniture(room_manager.get_current_room_role()):
		_show_toast("No tienes permiso para esta acción", "warning")
		_play_sfx("error")
		return
	if not inventory_manager.remove_item(furniture_type, 1):
		_show_toast("No tienes unidades disponibles", "warning")
		_play_sfx("error")
		_update_inventory_panel()
		return
	if not room.confirm_place_furniture(furniture_type, cell, furniture_rotation):
		inventory_manager.add_item(furniture_type, 1)
	_update_inventory_panel()


func _on_room_furniture_removed_to_inventory(furniture_type: String) -> void:
	inventory_manager.add_item(furniture_type, 1)
	_play_sfx("delete_furniture")
	_update_inventory_panel()


func _update_inventory_panel() -> void:
	if inventory_panel and inventory_panel.has_method("update_inventory"):
		inventory_panel.update_inventory(inventory_manager.get_items())
	if shop_panel and shop_panel.has_method("update_state"):
		shop_panel.update_state(inventory_manager.get_items(), currency_manager.get_coins())


func _on_profile_save_requested(profile_data: Dictionary) -> void:
	profile_manager.load_save_data(profile_data)
	if room_manager and room_manager.has_method("set_default_owner_name"):
		room_manager.set_default_owner_name(profile_manager.get_name())
	if room_manager and room_manager.has_method("set_profile_data"):
		room_manager.set_profile_data(profile_manager.get_profile())
	room.apply_profile(profile_manager.get_profile())
	if hud:
		hud.set_player_name(profile_manager.get_name())
		_show_toast("Perfil guardado", "success")
	_process_progression_events(progression_manager.increment_stat("profile_updates", 1))
	_apply_current_room_permissions()
	_refresh_room_select_panel()
	_autosave_current_room()
	_advance_onboarding_if_step(OnboardingManagerScript.STEP_PROFILE)
	if profile_panel:
		profile_panel.hide_panel()


func _on_chat_submitted(text: String) -> void:
	if not PermissionManagerScript.can_chat(room_manager.get_current_room_role()):
		_show_toast("No tienes permiso para esta acción", "warning")
		return
	var message: Dictionary = chat_manager.add_message(profile_manager.get_name(), text, "local")
	if message.is_empty():
		return
	_play_sfx("chat_send")
	if chat_panel and chat_panel.has_method("add_message"):
		chat_panel.add_message(message)
	if room and room.has_method("show_player_speech"):
		room.show_player_speech(String(message.get("text", "")))
	_process_progression_events(progression_manager.increment_stat("messages_sent", 1))
	_advance_onboarding_if_step(OnboardingManagerScript.STEP_CHAT)
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
	if room_manager.get_current_room_role() == PermissionManagerScript.ROLE_VISITOR:
		_show_toast("No tienes permiso para esta acción", "warning")
		_play_sfx("error")
		return

	var item := FurnitureCatalogScript.get_item(furniture_type)
	if item.is_empty():
		_show_toast("Articulo no encontrado", "error")
		_play_sfx("error")
		return

	var price := FurnitureCatalogScript.get_price(furniture_type)
	if not currency_manager.spend(price):
		_show_toast("No tienes monedas suficientes", "warning")
		_play_sfx("error")
		_update_shop_panel()
		return

	inventory_manager.add_item(furniture_type, 1)
	if hud:
		hud.set_coins(currency_manager.get_coins())
		_show_toast("Compra realizada: -%s monedas" % price, "success")
	_play_sfx("coin")
	_process_progression_events(progression_manager.increment_stat("items_bought", 1))
	_process_progression_events(progression_manager.increment_stat("coins_spent", price))
	_update_inventory_panel()
	_autosave_current_room()


func _update_shop_panel() -> void:
	if shop_panel and shop_panel.has_method("update_state"):
		shop_panel.update_state(inventory_manager.get_items(), currency_manager.get_coins())


func _on_room_movement_failed(reason: String) -> void:
	_play_sfx("error")
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
	_play_sfx("error")


func _on_room_furniture_selected(data: Dictionary) -> void:
	pending_hud_delete_furniture_id = ""
	if decor_inspector_panel and decor_inspector_panel.has_method("show_with_furniture"):
		decor_inspector_panel.show_with_furniture(data)


func _on_room_furniture_deselected() -> void:
	pending_hud_delete_furniture_id = ""
	if decor_inspector_panel and decor_inspector_panel.has_method("hide_panel"):
		decor_inspector_panel.hide_panel()


func _on_room_furniture_placed(_furniture_type: String) -> void:
	_play_sfx("place_furniture")
	_process_progression_events(progression_manager.increment_stat("furniture_placed", 1))
	_advance_onboarding_if_step(OnboardingManagerScript.STEP_PLACE_FURNITURE)


func _on_room_furniture_move_started(_data: Dictionary) -> void:
	if decor_inspector_panel and decor_inspector_panel.has_method("hide_panel"):
		decor_inspector_panel.hide_panel()


func _on_room_furniture_move_cancelled() -> void:
	_play_sfx("ui_close")


func _on_room_furniture_moved(_data: Dictionary) -> void:
	_play_sfx("place_furniture")
	_show_toast("Mueble movido", "success")


func _on_room_furniture_action_failed(reason: String) -> void:
	_show_toast(reason, "warning")
	_play_sfx("error")


func _on_decor_floor_type_selected(floor_type: String) -> void:
	if not PermissionManagerScript.can_change_floor(room_manager.get_current_room_role()):
		_show_toast("No tienes permiso para esta acción", "warning")
		_play_sfx("error")
		return
	room.set_floor_type(floor_type)
	if decor_panel:
		decor_panel.set_current_floor_type(room.get_floor_type())
	_process_progression_events(progression_manager.increment_stat("floors_changed", 1))
	_play_sfx("success")
	_show_toast("Piso actualizado", "success")


func _on_decor_wall_type_selected(wall_type: String) -> void:
	if not PermissionManagerScript.can_change_wall(room_manager.get_current_room_role()):
		_show_toast("No tienes permiso para esta acción", "warning")
		_play_sfx("error")
		return
	room.set_wall_type(wall_type)
	if decor_panel:
		decor_panel.set_current_wall_type(room.get_wall_type())
	_process_progression_events(progression_manager.increment_stat("walls_changed", 1))
	_play_sfx("success")
	_show_toast("Pared actualizada", "success")


func _on_decor_panel_closed() -> void:
	_play_sfx("ui_close")


func _on_add_npc_requested() -> void:
	if not PermissionManagerScript.can_decorate(room_manager.get_current_room_role()):
		_show_toast("No tienes permiso para esta acción", "warning")
		_play_sfx("error")
		return
	if not room or not room.has_method("add_npc"):
		return
	var npc_data := {
		"id": "local_npc_%s" % Time.get_ticks_msec(),
		"name": "Visitante",
		"avatar_variant": "mira",
		"cell": { "x": 0, "y": 0 },
	}
	room.add_npc(npc_data)
	_update_npc_manager_panel()


func _on_remove_npc_requested(npc_id: String) -> void:
	if not PermissionManagerScript.can_decorate(room_manager.get_current_room_role()):
		_show_toast("No tienes permiso para esta acción", "warning")
		_play_sfx("error")
		return
	if room and room.has_method("remove_npc"):
		room.remove_npc(npc_id)
	_update_npc_manager_panel()


func _on_respawn_npcs_requested() -> void:
	if not PermissionManagerScript.can_decorate(room_manager.get_current_room_role()):
		_show_toast("No tienes permiso para esta acción", "warning")
		_play_sfx("error")
		return
	if room and room.has_method("respawn_default_npcs"):
		room.respawn_default_npcs()
	_update_npc_manager_panel()


func _on_npc_movement_toggled(enabled: bool) -> void:
	if not PermissionManagerScript.can_decorate(room_manager.get_current_room_role()):
		_show_toast("No tienes permiso para esta acción", "warning")
		_play_sfx("error")
		_update_npc_manager_panel()
		return
	if room and room.has_method("set_npc_movement_enabled"):
		room.set_npc_movement_enabled(enabled)
	_update_npc_manager_panel()


func _on_npc_chat_toggled(enabled: bool) -> void:
	if not PermissionManagerScript.can_decorate(room_manager.get_current_room_role()):
		_show_toast("No tienes permiso para esta acción", "warning")
		_play_sfx("error")
		_update_npc_manager_panel()
		return
	if room and room.has_method("set_npc_chat_enabled"):
		room.set_npc_chat_enabled(enabled)
	_update_npc_manager_panel()


func _on_room_info_requested() -> void:
	_sync_current_room_state()
	_hide_primary_panels(room_info_panel)
	if not room_info_panel:
		return
	var current: Dictionary = room_manager.get_current_room()
	var role: String = room_manager.get_current_room_role()
	var can_edit := PermissionManagerScript.can_edit_room_profile(role)
	room_info_panel.show_with_room(current, can_edit, profile_manager.get_name())
	_play_sfx("ui_open")


func _on_room_info_edit_requested() -> void:
	if not PermissionManagerScript.can_edit_room_profile(room_manager.get_current_room_role()):
		_show_toast("No tienes permiso para editar esta sala", "warning")
		_play_sfx("error")
		return
	if room_edit_panel:
		if room_info_panel and room_info_panel.has_method("hide_panel"):
			room_info_panel.hide_panel()
		room_edit_panel.show_with_room(room_manager.get_current_room())
	_play_sfx("ui_open")


func _on_room_profile_save_requested(profile_data: Dictionary) -> void:
	var room_id: String = room_manager.get_current_room_id()
	var role: String = room_manager.get_current_room_role()
	if not PermissionManagerScript.can_edit_room_profile(role):
		_show_toast("No tienes permiso para editar esta sala", "warning")
		_play_sfx("error")
		return
	if not room_manager.update_room_profile(room_id, profile_data):
		_show_toast("No se pudo actualizar la sala", "warning")
		_play_sfx("error")
		return
	var current: Dictionary = room_manager.get_current_room()
	room_data = current.duplicate(true)
	if room:
		room.room_data["name"] = String(current.get("name", "Sala"))
		room.room_data["description"] = String(current.get("description", ""))
		room.room_data["room_type"] = String(current.get("room_type", "social"))
		room.room_data["mood"] = String(current.get("mood", "relajada"))
	if hud and hud.has_method("set_room_name"):
		hud.set_room_name(String(current.get("name", "Sala")))
	if room_info_panel and room_info_panel.has_method("update_room"):
		room_info_panel.update_room(current, true, profile_manager.get_name())
	if room_edit_panel and room_edit_panel.has_method("hide_panel"):
		room_edit_panel.hide_panel()
	_autosave_current_room()
	_show_toast("Sala actualizada", "success")
	_play_sfx("success")


func _on_room_rating_changed(value: int) -> void:
	var room_id: String = room_manager.get_current_room_id()
	var voter_id: String = profile_manager.get_name() if profile_manager else "local"
	if not room_manager.rate_room(room_id, value, voter_id):
		return
	var current: Dictionary = room_manager.get_current_room()
	room_data = current.duplicate(true)
	if room:
		room.room_data["rating"] = current.get("rating", {})
		room.room_data["updated_at"] = int(current.get("updated_at", 0))
	if room_info_panel and room_info_panel.has_method("update_room"):
		var can_edit := PermissionManagerScript.can_edit_room_profile(room_manager.get_current_room_role())
		room_info_panel.update_room(current, can_edit, profile_manager.get_name())
	_autosave_current_room()
	_show_toast("Valoración actualizada", "success")


func _update_npc_manager_panel() -> void:
	if npc_manager_panel and room and npc_manager_panel.has_method("update_npcs"):
		npc_manager_panel.update_npcs(room.get_npc_list(), room.npc_movement_enabled, room.npc_chat_enabled)


func _show_toast(text: String, toast_type: String = "info") -> void:
	if toast_panel and toast_panel.has_method("show_toast"):
		toast_panel.show_toast(text, toast_type)
	elif hud and hud.has_method("show_message"):
		hud.show_message(text)


func _play_sfx(sfx_name: String) -> void:
	if audio_manager:
		audio_manager.play_sfx(sfx_name)


func _connect_button_click_sfx(node: Node) -> void:
	for child in node.get_children():
		if child is Button and not child.pressed.is_connected(_on_ui_button_pressed):
			child.pressed.connect(_on_ui_button_pressed)
		_connect_button_click_sfx(child)


func _on_ui_button_pressed() -> void:
	_play_sfx("ui_click")


func _on_sfx_enabled_changed(enabled: bool) -> void:
	if not audio_manager:
		return
	audio_manager.set_sfx_enabled(enabled)
	_autosave_current_room()


func _on_sfx_volume_changed(value: float) -> void:
	if not audio_manager:
		return
	audio_manager.set_sfx_volume(value)
	_autosave_current_room()


func _on_test_audio_requested() -> void:
	if audio_manager and audio_manager.has_method("test_audio"):
		audio_manager.test_audio()


func _sync_current_room_state() -> void:
	if room and room.has_method("get_room_state"):
		room_manager.update_current_room(room.get_room_state())


func _load_current_room() -> void:
	if room_manager and room_manager.has_method("set_profile_data"):
		room_manager.set_profile_data(profile_manager.get_profile())
	var current_room: Dictionary = room_manager.get_current_room()
	room_data = current_room.duplicate(true)
	room.load_room_state(current_room)
	room.set_local_role(room_manager.get_current_room_role())
	room.apply_profile(profile_manager.get_profile())
	_spawn_default_npcs()
	room_manager.increment_room_visits(room_manager.get_current_room_id())
	_sync_room_visit_counter()
	if hud and hud.has_method("set_room_name"):
		hud.set_room_name(String(current_room.get("name", "Sala")))
	_apply_current_room_permissions()


func _apply_current_room_permissions() -> void:
	var role: String = room_manager.get_current_room_role() if room_manager else PermissionManagerScript.ROLE_OWNER
	if room and room.has_method("set_local_role"):
		room.set_local_role(role)
	if hud and hud.has_method("set_room_role"):
		hud.set_room_role(role)
	if hud and hud.has_method("set_decorate_available"):
		hud.set_decorate_available(PermissionManagerScript.can_decorate(role))


func _refresh_room_select_panel() -> void:
	if room_select_panel:
		room_select_panel.update_rooms(room_manager.get_rooms(), room_manager.get_current_room_id())


func _on_room_selected(room_id: String) -> void:
	_sync_current_room_state()
	if room_manager.set_current_room(room_id):
		_load_current_room()
		if room_select_panel:
			room_select_panel.hide_panel()
		_autosave_current_room()


func _on_create_room_requested(name: String, width: int, height: int) -> void:
	_sync_current_room_state()
	room_manager.set_default_owner_name(profile_manager.get_name())
	var new_room: Dictionary = room_manager.create_room_with_size(name, width, height)
	room_manager.add_room(new_room)
	room_manager.set_current_room(String(new_room.get("id", "")))
	_load_current_room()
	_refresh_room_select_panel()
	_process_progression_events(progression_manager.increment_stat("rooms_created", 1))
	_autosave_current_room()
	_show_toast("Sala creada", "success")


func _on_rename_room_requested(room_id: String, new_name: String) -> void:
	_sync_current_room_state()
	if not PermissionManagerScript.can_rename_room(room_manager.get_room_role(room_id)):
		_show_toast("No tienes permiso para esta acción", "warning")
		return
	if not room_manager.rename_room(room_id, new_name):
		return
	if room_id == room_manager.get_current_room_id():
		var current_room: Dictionary = room_manager.get_current_room()
		room_data = current_room.duplicate(true)
		if room:
			room.room_data["name"] = String(current_room.get("name", "Sala"))
		if hud and hud.has_method("set_room_name"):
			hud.set_room_name(String(current_room.get("name", "Sala")))
	_refresh_room_select_panel()
	_autosave_current_room()
	_show_toast("Sala renombrada", "success")


func _on_duplicate_room_requested(room_id: String) -> void:
	_sync_current_room_state()
	if not PermissionManagerScript.can_duplicate_room(room_manager.get_room_role(room_id)):
		_show_toast("No tienes permiso para esta acción", "warning")
		return
	var copy: Dictionary = room_manager.duplicate_room(room_id)
	if copy.is_empty():
		return
	room_manager.add_room(copy)
	_refresh_room_select_panel()
	_autosave_current_room()
	_show_toast("Sala duplicada", "success")


func _on_delete_room_requested(room_id: String) -> void:
	_sync_current_room_state()
	if not PermissionManagerScript.can_delete_room(room_manager.get_room_role(room_id)):
		_show_toast("No tienes permiso para esta acción", "warning")
		_refresh_room_select_panel()
		return
	if not room_manager.can_delete_room(room_id):
		_show_toast("No puedes borrar la ultima sala", "warning")
		_refresh_room_select_panel()
		return

	var was_current: bool = room_id == room_manager.get_current_room_id()
	if not room_manager.delete_room(room_id):
		return
	if was_current:
		_load_current_room()
	_refresh_room_select_panel()
	_autosave_current_room()
	_show_toast("Sala eliminada", "success")


func _on_export_room_requested(room_id: String) -> void:
	_sync_current_room_state()
	if not PermissionManagerScript.can_export_room(room_manager.get_room_role(room_id)):
		_show_toast("No tienes permiso para esta acción", "warning")
		return
	var exported_room: Dictionary = room_manager.export_room(room_id)
	var file_path := RoomExportManagerScript.export_room_to_file(exported_room)
	if file_path.is_empty():
		_show_toast("No se pudo exportar", "warning")
		return
	_show_toast("Sala exportada", "success")


func _on_import_room_requested() -> void:
	_sync_current_room_state()
	room_manager.set_default_owner_name(profile_manager.get_name())
	var imported_data: Dictionary = RoomExportManagerScript.import_room_from_file()
	var imported_room: Dictionary = room_manager.import_room(imported_data)
	if imported_room.is_empty():
		_show_toast("No se pudo importar", "warning")
		return
	room_manager.add_room(imported_room)
	room_manager.set_current_room(String(imported_room.get("id", "")))
	_load_current_room()
	_refresh_room_select_panel()
	_autosave_current_room()
	_show_toast("Sala importada", "success")


func _on_toggle_room_role_requested(room_id: String) -> void:
	_sync_current_room_state()
	var next_role: String = room_manager.toggle_room_role(room_id)
	if next_role.is_empty():
		return
	if room_id == room_manager.get_current_room_id():
		_apply_current_room_permissions()
	_refresh_room_select_panel()
	_autosave_current_room()
	_show_toast("Rol actualizado", "success")


func _on_room_permission_denied(_action: String) -> void:
	_show_toast("No tienes permiso para esta acción", "warning")
	_play_sfx("error")


func _process_progression_events(events: Array) -> void:
	if not progression_manager:
		return
	for event in events:
		if typeof(event) != TYPE_DICTIONARY:
			continue
		var catalog: Dictionary = event.get("catalog", {})
		match String(event.get("type", "")):
			"mission_completed":
				_play_sfx("mission_complete")
				_show_toast("Mision completada: %s" % String(catalog.get("name", "Mision")), "mission")
			"achievement_unlocked":
				_play_sfx("achievement_unlock")
				_show_toast("Logro desbloqueado: %s" % String(catalog.get("name", "Logro")), "achievement")
	_update_progression_ui()
	_autosave_current_room()


func _update_progression_ui() -> void:
	if not progression_manager:
		return
	if hud and hud.has_method("set_claimable_missions_count"):
		hud.set_claimable_missions_count(progression_manager.get_claimable_missions_count())
	if missions_panel and missions_panel.has_method("update_data"):
		missions_panel.update_data(progression_manager.get_missions(), progression_manager.get_stats())
	if achievements_panel and achievements_panel.has_method("update_data"):
		achievements_panel.update_data(progression_manager.get_achievements(), progression_manager.get_stats())


func _on_claim_mission_requested(mission_id: String) -> void:
	if not progression_manager:
		return
	var reward: Dictionary = progression_manager.claim_mission_reward(mission_id)
	if reward.is_empty():
		_show_toast("No se pudo reclamar", "warning")
		_play_sfx("error")
		return

	var reward_parts := PackedStringArray()
	if reward.has("coins"):
		var coins := int(reward.get("coins", 0))
		currency_manager.add(coins)
		if hud and hud.has_method("set_coins"):
			hud.set_coins(currency_manager.get_coins())
		reward_parts.append("+%s monedas" % coins)
		_process_progression_events(progression_manager.increment_stat("coins_earned", coins))

	if reward.has("furniture"):
		var furniture_type := String(reward.get("furniture", ""))
		if not furniture_type.is_empty():
			inventory_manager.add_item(furniture_type, 1)
			_update_inventory_panel()
			reward_parts.append("+1 %s" % furniture_type)

	_process_progression_events(progression_manager.increment_stat("mission_rewards_claimed", 1))
	_update_progression_ui()
	_autosave_current_room()
	_play_sfx("coin")
	_show_toast("Recompensa: %s" % ", ".join(reward_parts), "success")


func _show_onboarding_if_needed() -> void:
	if onboarding_manager and onboarding_panel and not onboarding_manager.is_completed():
		onboarding_panel.show_step(onboarding_manager.get_current_step())


func _on_onboarding_next_requested() -> void:
	if not onboarding_manager:
		return
	var step: String = onboarding_manager.get_current_step()
	match step:
		OnboardingManagerScript.STEP_WELCOME:
			onboarding_manager.advance_to_next_step()
			onboarding_panel.show_step(onboarding_manager.get_current_step())
			_save_onboarding_state()
		OnboardingManagerScript.STEP_SAVE:
			_complete_onboarding()
		_:
			if onboarding_panel:
				onboarding_panel.hide_panel()
			_save_onboarding_state()


func _on_onboarding_skip_requested() -> void:
	_complete_onboarding()


func _on_onboarding_action_requested(action: String) -> void:
	match action:
		"open_profile":
			if onboarding_panel:
				onboarding_panel.hide_panel()
			_show_profile()
		"open_inventory":
			_show_inventory()
		"enable_decorate":
			if hud and hud.has_method("set_decorate_enabled"):
				hud.set_decorate_enabled(true)
			_on_decorate_toggled(true)
		"open_shop":
			_show_shop()


func _advance_onboarding_if_step(step: String) -> void:
	if not onboarding_manager or onboarding_manager.is_completed():
		return
	if onboarding_manager.get_current_step() != step:
		return
	onboarding_manager.advance_to_next_step()
	if onboarding_manager.is_completed():
		if onboarding_panel:
			onboarding_panel.hide_panel()
	else:
		if onboarding_panel:
			onboarding_panel.show_step(onboarding_manager.get_current_step())
	_save_onboarding_state()


func _complete_onboarding() -> void:
	if not onboarding_manager:
		return
	onboarding_manager.complete()
	if onboarding_panel:
		onboarding_panel.hide_panel()
	_save_onboarding_state()


func _save_onboarding_state() -> void:
	_autosave_current_room()


func _on_tutorial_requested() -> void:
	if not onboarding_manager:
		return
	onboarding_manager.reset()
	if onboarding_panel:
		onboarding_panel.show_step(onboarding_manager.get_current_step())
	_save_onboarding_state()


func _on_reset_progress_requested() -> void:
	if not reset_progress_dialog:
		reset_progress_dialog = ConfirmationDialog.new()
		reset_progress_dialog.title = "Resetear progreso local"
		reset_progress_dialog.dialog_text = "Esta acción borrará salas, monedas, inventario y progreso local. ¿Continuar?"
		reset_progress_dialog.confirmed.connect(_on_reset_progress_confirmed)
		add_child(reset_progress_dialog)
	reset_progress_dialog.popup_centered(Vector2i(420, 140))


func _on_reset_progress_confirmed() -> void:
	SaveManagerScript.delete_save()
	get_tree().reload_current_scene()


func _on_exit_requested() -> void:
	get_tree().quit()


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


func _sync_room_visit_counter() -> void:
	if not room or not room_manager:
		return
	var current: Dictionary = room_manager.get_current_room()
	room.room_data["visits"] = int(current.get("visits", 0))
	room.room_data["visit_log"] = current.get("visit_log", [])


func _show_loading_screen() -> void:
	if not ResourceLoader.exists(LOADING_SCREEN_PATH):
		return
	loading_screen = load(LOADING_SCREEN_PATH).instantiate()
	add_child(loading_screen)


func _hide_loading_screen() -> void:
	if loading_screen:
		loading_screen.queue_free()
		loading_screen = null


func _set_loading_message(text: String) -> void:
	if loading_screen and loading_screen.has_method("set_message"):
		loading_screen.set_message(text)


func _show_save_recovery_message_if_needed() -> void:
	if SaveManagerScript.last_load_had_corrupt_save:
		_show_toast("Save corrupto respaldado. Se creo una demo limpia.", "warning")


func _handle_tester_shortcuts(event: InputEvent) -> bool:
	if not DebugConfigScript.DEBUG_MODE or not DebugConfigScript.ENABLE_TESTER_SHORTCUTS:
		return false
	if not (event is InputEventKey and event.pressed and not event.echo):
		return false
	match event.keycode:
		KEY_F5:
			_on_save_requested()
			get_viewport().set_input_as_handled()
			return true
		KEY_F9:
			_on_reset_progress_requested()
			get_viewport().set_input_as_handled()
			return true
		KEY_F10:
			if currency_manager:
				currency_manager.add(100)
				if hud and hud.has_method("set_coins"):
					hud.set_coins(currency_manager.get_coins())
				_autosave_current_room()
				_show_toast("+100 monedas tester", "info")
			get_viewport().set_input_as_handled()
			return true
		KEY_F11:
			_show_toast("Checklist: docs/RELEASE_CHECKLIST.md", "info")
			get_viewport().set_input_as_handled()
			return true
	return false
