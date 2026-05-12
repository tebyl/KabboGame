class_name AudioManager
extends RefCounted

const DebugConfigScript := preload("res://scripts/data/DebugConfig.gd")

const SFX_PATHS := {
	"ui_click": "res://assets/audio/sfx/ui_click.wav",
	"ui_open": "res://assets/audio/sfx/ui_open.wav",
	"ui_close": "res://assets/audio/sfx/ui_close.wav",
	"success": "res://assets/audio/sfx/success.wav",
	"error": "res://assets/audio/sfx/error.wav",
	"coin": "res://assets/audio/sfx/coin.wav",
	"place_furniture": "res://assets/audio/sfx/place_furniture.wav",
	"rotate_furniture": "res://assets/audio/sfx/rotate_furniture.wav",
	"delete_furniture": "res://assets/audio/sfx/delete_furniture.wav",
	"chat_send": "res://assets/audio/sfx/chat_send.wav",
	"mission_complete": "res://assets/audio/sfx/mission_complete.wav",
	"achievement_unlock": "res://assets/audio/sfx/achievement_unlock.wav",
	"save": "res://assets/audio/sfx/save.wav",
	"walk_step": "res://assets/audio/sfx/walk_step.wav",
}

const POOL_SIZE := 6

var sfx_enabled := true
var sfx_volume := 0.8
var audio_players: Array[AudioStreamPlayer] = []
var sfx_cache := {}
var parent_node: Node


func setup(parent: Node) -> void:
	parent_node = parent
	if not parent_node:
		return
	for i in range(POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.volume_db = _volume_to_db(sfx_volume)
		parent_node.add_child(player)
		audio_players.append(player)


func play_sfx(sfx_name: String) -> void:
	if not sfx_enabled:
		_debug_audio("audio disabled: %s" % sfx_name)
		return
	if not SFX_PATHS.has(sfx_name):
		_debug_audio("audio key missing: %s" % sfx_name)
		return
	var stream := _get_stream(sfx_name)
	if not stream:
		return
	var player := _get_available_player()
	if not player:
		return
	player.stream = stream
	player.volume_db = _volume_to_db(sfx_volume)
	player.play()
	_debug_audio("audio played: %s" % sfx_name)


func test_audio() -> void:
	play_sfx("ui_click")


func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled


func is_sfx_enabled() -> bool:
	return sfx_enabled


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	for player in audio_players:
		player.volume_db = _volume_to_db(sfx_volume)


func get_sfx_volume() -> float:
	return sfx_volume


func to_save_data() -> Dictionary:
	return {
		"sfx_enabled": sfx_enabled,
		"sfx_volume": sfx_volume,
	}


func load_save_data(data: Dictionary) -> void:
	if typeof(data) != TYPE_DICTIONARY:
		return
	set_sfx_enabled(bool(data.get("sfx_enabled", true)))
	set_sfx_volume(float(data.get("sfx_volume", 0.8)))


func _get_stream(sfx_name: String) -> AudioStream:
	if sfx_cache.has(sfx_name):
		return sfx_cache[sfx_name]
	var path := String(SFX_PATHS.get(sfx_name, ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		_debug_audio("audio file missing: %s" % path)
		return null
	var stream: AudioStream = load(path)
	sfx_cache[sfx_name] = stream
	_debug_audio("audio loaded: %s" % path)
	return stream


func _get_available_player() -> AudioStreamPlayer:
	for player in audio_players:
		if not player.playing:
			return player
	return audio_players[0] if not audio_players.is_empty() else null


func _volume_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0
	return linear_to_db(clampf(value, 0.0, 1.0))


func _debug_audio(message: String) -> void:
	if DebugConfigScript.DEBUG_MODE:
		print(message)
