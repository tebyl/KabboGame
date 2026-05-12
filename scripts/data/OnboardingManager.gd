class_name OnboardingManager
extends RefCounted

const STEP_WELCOME := "welcome"
const STEP_PROFILE := "profile"
const STEP_WALK := "walk"
const STEP_INVENTORY := "inventory"
const STEP_DECORATE := "decorate"
const STEP_PLACE_FURNITURE := "place_furniture"
const STEP_SHOP := "shop"
const STEP_CHAT := "chat"
const STEP_SAVE := "save"
const STEP_DONE := "done"

const STEPS := [
	STEP_WELCOME,
	STEP_PROFILE,
	STEP_WALK,
	STEP_INVENTORY,
	STEP_DECORATE,
	STEP_PLACE_FURNITURE,
	STEP_SHOP,
	STEP_CHAT,
	STEP_SAVE,
	STEP_DONE,
]

var completed := false
var current_step := STEP_WELCOME


func setup(data: Dictionary) -> void:
	load_save_data(data)


func is_completed() -> bool:
	return completed


func get_current_step() -> String:
	return current_step


func set_step(step: String) -> void:
	current_step = step if STEPS.has(step) else STEP_WELCOME
	if current_step != STEP_DONE:
		completed = false


func advance_to_next_step() -> void:
	var index := STEPS.find(current_step)
	if index < 0:
		set_step(STEP_WELCOME)
		return
	var next_index = min(index + 1, STEPS.size() - 1)
	current_step = String(STEPS[next_index])
	if current_step == STEP_DONE:
		complete()


func complete() -> void:
	completed = true
	current_step = STEP_DONE


func reset() -> void:
	completed = false
	current_step = STEP_WELCOME


func to_save_data() -> Dictionary:
	return {
		"completed": completed,
		"current_step": current_step,
	}


func load_save_data(data: Dictionary) -> void:
	completed = bool(data.get("completed", false))
	current_step = String(data.get("current_step", STEP_WELCOME))
	if not STEPS.has(current_step):
		current_step = STEP_WELCOME
	if completed:
		current_step = STEP_DONE
