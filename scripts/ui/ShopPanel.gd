extends CanvasLayer

signal buy_requested(furniture_type: String)
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")

var shop_items := []
var inventory := {}
var coins := 0
var current_category := ""

@onready var root: Control = $Root
@onready var coins_label: Label = $Root/Card/Margin/VBox/Header/CoinsLabel
@onready var categories: VBoxContainer = $Root/Card/Margin/VBox/Body/Categories
@onready var items_list: VBoxContainer = $Root/Card/Margin/VBox/Body/ItemsScroll/ItemsList


func _ready() -> void:
	$Root/Overlay.color = UIThemeScript.COLOR_OVERLAY
	UIThemeScript.apply_panel_style($Root/Card)
	UIThemeScript.apply_label(coins_label)
	hide_shop()


func show_shop(next_shop_items: Array, next_inventory: Dictionary, next_coins: int) -> void:
	shop_items = next_shop_items.duplicate(true)
	inventory = next_inventory.duplicate(true)
	coins = next_coins
	root.visible = true
	_build_categories()
	if current_category.is_empty() and not shop_items.is_empty():
		current_category = String(shop_items[0].get("category", ""))
	populate_category(current_category)


func hide_shop() -> void:
	root.visible = false


func update_state(next_inventory: Dictionary, next_coins: int) -> void:
	inventory = next_inventory.duplicate(true)
	coins = next_coins
	populate_category(current_category)


func populate_category(category: String) -> void:
	current_category = category
	coins_label.text = "Monedas: %s" % coins
	for child in items_list.get_children():
		child.queue_free()

	for item in shop_items:
		if String(item.get("category", "")) != category:
			continue
		items_list.add_child(_build_item_row(item))


func _build_categories() -> void:
	for child in categories.get_children():
		child.queue_free()

	var seen := []
	for item in shop_items:
		var category := String(item.get("category", ""))
		if seen.has(category):
			continue
		seen.append(category)
		var button := Button.new()
		button.text = category
		button.custom_minimum_size = Vector2(120, 30)
		UIThemeScript.apply_secondary_button(button)
		button.pressed.connect(populate_category.bind(category))
		categories.add_child(button)


func _build_item_row(item: Dictionary) -> PanelContainer:
	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(420, 42)
	UIThemeScript.apply_dark_panel_style(row)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	row.add_child(hbox)

	var name_label := Label.new()
	name_label.text = String(item.get("name", item.get("type", "")))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UIThemeScript.apply_label(name_label)
	hbox.add_child(name_label)

	var price := int(item.get("price", 0))
	var price_label := Label.new()
	price_label.text = "%s c" % price
	UIThemeScript.apply_label(price_label, coins < price)
	hbox.add_child(price_label)

	var furniture_type := String(item.get("type", ""))
	var owned_label := Label.new()
	owned_label.text = "Inv x%s" % int(inventory.get(furniture_type, 0))
	UIThemeScript.apply_label(owned_label, true)
	hbox.add_child(owned_label)

	var buy_button := Button.new()
	buy_button.text = "Comprar"
	buy_button.disabled = coins < price
	UIThemeScript.apply_success_button(buy_button)
	buy_button.pressed.connect(_on_buy_pressed.bind(furniture_type))
	hbox.add_child(buy_button)

	return row


func _on_buy_pressed(furniture_type: String) -> void:
	buy_requested.emit(furniture_type)


func _on_close_button_pressed() -> void:
	hide_shop()
	close_requested.emit()
