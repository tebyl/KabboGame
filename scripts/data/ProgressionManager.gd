class_name ProgressionManager
extends RefCounted

const MissionCatalogScript := preload("res://scripts/data/MissionCatalog.gd")
const AchievementCatalogScript := preload("res://scripts/data/AchievementCatalog.gd")

const DEFAULT_STATS := {
	"furniture_placed": 0,
	"messages_sent": 0,
	"items_bought": 0,
	"rooms_created": 0,
	"floors_changed": 0,
	"walls_changed": 0,
	"profile_updates": 0,
	"coins_earned": 0,
	"coins_spent": 0,
	"shop_opened": 0,
	"inventory_opened": 0,
	"mission_rewards_claimed": 0,
}

var stats := {}
var missions := {}
var achievements := {}


func setup(data: Dictionary) -> void:
	load_save_data(data)


func get_stats() -> Dictionary:
	return stats.duplicate(true)


func get_missions() -> Dictionary:
	return missions.duplicate(true)


func get_achievements() -> Dictionary:
	return achievements.duplicate(true)


func increment_stat(stat_name: String, amount: int = 1) -> Array:
	if amount <= 0:
		return []
	stats[stat_name] = int(stats.get(stat_name, 0)) + amount
	return _evaluate_progression()


func complete_mission(mission_id: String) -> Dictionary:
	if not missions.has(mission_id):
		return {}
	if bool(missions[mission_id].get("completed", false)):
		return {}
	missions[mission_id]["completed"] = true
	return {
		"type": "mission_completed",
		"id": mission_id,
		"catalog": MissionCatalogScript.get_mission(mission_id),
	}


func claim_mission_reward(mission_id: String) -> Dictionary:
	if not is_mission_completed(mission_id) or is_mission_claimed(mission_id):
		return {}
	var catalog := MissionCatalogScript.get_mission(mission_id)
	var reward: Dictionary = catalog.get("reward", {}).duplicate(true)
	if reward.is_empty():
		return {}
	missions[mission_id]["claimed"] = true
	return reward


func unlock_achievement(achievement_id: String) -> Dictionary:
	if not achievements.has(achievement_id):
		return {}
	if bool(achievements[achievement_id].get("unlocked", false)):
		return {}
	achievements[achievement_id]["unlocked"] = true
	achievements[achievement_id]["unlocked_at"] = Time.get_unix_time_from_system()
	return {
		"type": "achievement_unlocked",
		"id": achievement_id,
		"catalog": AchievementCatalogScript.get_achievement(achievement_id),
	}


func is_mission_completed(mission_id: String) -> bool:
	return bool(missions.get(mission_id, {}).get("completed", false))


func is_mission_claimed(mission_id: String) -> bool:
	return bool(missions.get(mission_id, {}).get("claimed", false))


func is_achievement_unlocked(achievement_id: String) -> bool:
	return bool(achievements.get(achievement_id, {}).get("unlocked", false))


func get_claimable_missions_count() -> int:
	var count := 0
	for mission_id in missions.keys():
		if is_mission_completed(String(mission_id)) and not is_mission_claimed(String(mission_id)):
			count += 1
	return count


func get_economy_stats() -> Dictionary:
	return {
		"coins_earned": int(stats.get("coins_earned", 0)),
		"coins_spent": int(stats.get("coins_spent", 0)),
		"items_bought": int(stats.get("items_bought", 0)),
		"mission_rewards_claimed": int(stats.get("mission_rewards_claimed", 0)),
	}


func to_save_data() -> Dictionary:
	return {
		"missions": get_missions(),
		"achievements": get_achievements(),
		"stats": get_stats(),
	}


func load_save_data(data: Dictionary) -> void:
	stats = DEFAULT_STATS.duplicate(true)
	var saved_stats: Dictionary = data.get("stats", {}) if typeof(data.get("stats", {})) == TYPE_DICTIONARY else {}
	for stat_name in saved_stats.keys():
		stats[String(stat_name)] = max(0, int(saved_stats.get(stat_name, 0)))

	missions.clear()
	var saved_missions: Dictionary = data.get("missions", {}) if typeof(data.get("missions", {})) == TYPE_DICTIONARY else {}
	for mission_id in MissionCatalogScript.get_missions().keys():
		var saved_entry: Dictionary = saved_missions.get(mission_id, {}) if typeof(saved_missions.get(mission_id, {})) == TYPE_DICTIONARY else {}
		missions[mission_id] = {
			"completed": bool(saved_entry.get("completed", false)),
			"claimed": bool(saved_entry.get("claimed", false)),
			"progress": max(0, int(saved_entry.get("progress", 0))),
		}

	achievements.clear()
	var saved_achievements: Dictionary = data.get("achievements", {}) if typeof(data.get("achievements", {})) == TYPE_DICTIONARY else {}
	for achievement_id in AchievementCatalogScript.get_achievements().keys():
		var saved_achievement: Dictionary = saved_achievements.get(achievement_id, {}) if typeof(saved_achievements.get(achievement_id, {})) == TYPE_DICTIONARY else {}
		achievements[achievement_id] = {
			"unlocked": bool(saved_achievement.get("unlocked", false)),
			"unlocked_at": int(saved_achievement.get("unlocked_at", 0)),
		}
	_evaluate_progression()


func _evaluate_progression() -> Array:
	var events := []
	for mission_id in MissionCatalogScript.get_missions().keys():
		var catalog := MissionCatalogScript.get_mission(String(mission_id))
		var stat_name := String(catalog.get("stat", ""))
		var target := int(catalog.get("target", 1))
		missions[mission_id]["progress"] = min(int(stats.get(stat_name, 0)), target)
		if int(stats.get(stat_name, 0)) >= target:
			var event := complete_mission(String(mission_id))
			if not event.is_empty():
				events.append(event)

	for achievement_id in AchievementCatalogScript.get_achievements().keys():
		var achievement := AchievementCatalogScript.get_achievement(String(achievement_id))
		if _conditions_met(achievement.get("conditions", {})):
			var event := unlock_achievement(String(achievement_id))
			if not event.is_empty():
				events.append(event)
	return events


func _conditions_met(conditions) -> bool:
	if typeof(conditions) != TYPE_DICTIONARY:
		return false
	for stat_name in conditions.keys():
		if int(stats.get(String(stat_name), 0)) < int(conditions.get(stat_name, 0)):
			return false
	return true
