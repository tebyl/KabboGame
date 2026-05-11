class_name ProfileManager
extends RefCounted

const DEFAULT_PROFILE := {
	"name": "Invitado",
	"avatar_variant": "default",
}

const VALID_VARIANTS := ["default", "blue", "green", "red", "yellow", "purple"]

var profile := DEFAULT_PROFILE.duplicate(true)


func setup(data: Dictionary) -> void:
	load_save_data(data)


func get_profile() -> Dictionary:
	return profile.duplicate(true)


func get_name() -> String:
	return String(profile.get("name", DEFAULT_PROFILE["name"]))


func set_name(value: String) -> void:
	var clean_name := value.strip_edges()
	if clean_name.is_empty():
		clean_name = DEFAULT_PROFILE["name"]
	if clean_name.length() > 16:
		clean_name = clean_name.substr(0, 16)
	profile["name"] = clean_name


func get_avatar_variant() -> String:
	return String(profile.get("avatar_variant", DEFAULT_PROFILE["avatar_variant"]))


func set_avatar_variant(value: String) -> void:
	profile["avatar_variant"] = value if VALID_VARIANTS.has(value) else DEFAULT_PROFILE["avatar_variant"]


func to_save_data() -> Dictionary:
	return get_profile()


func load_save_data(data: Dictionary) -> void:
	profile = DEFAULT_PROFILE.duplicate(true)
	if typeof(data) != TYPE_DICTIONARY:
		return
	set_name(String(data.get("name", DEFAULT_PROFILE["name"])))
	if data.has("avatar_variant"):
		set_avatar_variant(String(data.get("avatar_variant", DEFAULT_PROFILE["avatar_variant"])))
	elif data.has("shirt_color"):
		set_avatar_variant(_variant_from_old_shirt_color(String(data.get("shirt_color", "default"))))
	else:
		set_avatar_variant(DEFAULT_PROFILE["avatar_variant"])


func _variant_from_old_shirt_color(value: String) -> String:
	return value if VALID_VARIANTS.has(value) else DEFAULT_PROFILE["avatar_variant"]
