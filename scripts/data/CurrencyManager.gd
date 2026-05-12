class_name CurrencyManager
extends RefCounted

const DefaultGameDataScript := preload("res://scripts/data/DefaultGameData.gd")

const DEFAULT_COINS := 300

var coins := DEFAULT_COINS


func setup(initial_coins: int) -> void:
	set_coins(initial_coins)


func get_coins() -> int:
	return coins


func get_summary() -> Dictionary:
	return { "coins": coins }


func can_afford(amount: int) -> bool:
	return amount >= 0 and coins >= amount


func spend(amount: int) -> bool:
	if amount <= 0 or not can_afford(amount):
		return false
	coins -= amount
	return true


func add(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount


func set_coins(value: int) -> void:
	coins = max(0, value)


func to_save_data() -> Dictionary:
	return { "coins": coins }


func load_save_data(data: Dictionary) -> void:
	if typeof(data) != TYPE_DICTIONARY:
		coins = DefaultGameDataScript.get_default_coins()
		return
	set_coins(int(data.get("coins", DefaultGameDataScript.get_default_coins())))
