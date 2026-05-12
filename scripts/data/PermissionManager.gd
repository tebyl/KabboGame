class_name PermissionManager
extends RefCounted

const ROLE_OWNER := "owner"
const ROLE_VISITOR := "visitor"


static func sanitize_role(role: String) -> String:
	return ROLE_OWNER if role == ROLE_OWNER else ROLE_VISITOR


static func get_effective_role(profile_data: Dictionary, room_data: Dictionary) -> String:
	var profile_id := String(profile_data.get("id", "")).strip_edges()
	var owner_id := String(room_data.get("owner_id", "")).strip_edges()
	var profile_name := String(profile_data.get("name", "")).strip_edges()
	var owner_name := String(room_data.get("owner_name", "")).strip_edges()
	var requested_role := sanitize_role(String(room_data.get("local_role", ROLE_OWNER)))
	var is_real_owner := false

	if not profile_id.is_empty() and not owner_id.is_empty():
		is_real_owner = profile_id == owner_id
	elif not profile_name.is_empty() and not owner_name.is_empty():
		is_real_owner = profile_name == owner_name

	if not is_real_owner:
		return ROLE_VISITOR
	return ROLE_VISITOR if requested_role == ROLE_VISITOR else ROLE_OWNER


static func can_walk(role: String) -> bool:
	return [ROLE_OWNER, ROLE_VISITOR].has(sanitize_role(role))


static func can_chat(role: String) -> bool:
	return [ROLE_OWNER, ROLE_VISITOR].has(sanitize_role(role))


static func can_decorate(role: String) -> bool:
	return sanitize_role(role) == ROLE_OWNER


static func can_place_furniture(role: String) -> bool:
	return sanitize_role(role) == ROLE_OWNER


static func can_move_furniture(role: String) -> bool:
	return sanitize_role(role) == ROLE_OWNER


static func can_rotate_furniture(role: String) -> bool:
	return sanitize_role(role) == ROLE_OWNER


static func can_delete_furniture(role: String) -> bool:
	return sanitize_role(role) == ROLE_OWNER


static func can_change_floor(role: String) -> bool:
	return sanitize_role(role) == ROLE_OWNER


static func can_change_wall(role: String) -> bool:
	return sanitize_role(role) == ROLE_OWNER


static func can_rename_room(role: String) -> bool:
	return sanitize_role(role) == ROLE_OWNER


static func can_edit_room_profile(role: String) -> bool:
	return sanitize_role(role) == ROLE_OWNER


static func can_delete_room(role: String) -> bool:
	return sanitize_role(role) == ROLE_OWNER


static func can_duplicate_room(role: String) -> bool:
	return sanitize_role(role) == ROLE_OWNER


static func can_export_room(role: String) -> bool:
	return sanitize_role(role) == ROLE_OWNER
