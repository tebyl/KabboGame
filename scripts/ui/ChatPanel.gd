extends CanvasLayer

signal chat_submitted(text: String)
signal chat_focus_changed(focused: bool)

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const ChatManagerScript := preload("res://scripts/data/ChatManager.gd")
const MAX_TEXT_LENGTH := ChatManagerScript.MAX_TEXT_LENGTH
const MAX_VISIBLE_MESSAGES := 40
const COLOR_CHAT_BG := Color(0.02, 0.12, 0.24, 0.98)
const COLOR_CHAT_BODY := Color(0.01, 0.05, 0.11, 0.98)
const COLOR_CHAT_BORDER := Color(0.12, 0.78, 1.0, 1.0)
const COLOR_CHAT_BUTTON := Color(0.03, 0.35, 0.68, 1.0)
const COLOR_CHAT_SUCCESS := Color(0.20, 0.70, 0.16, 1.0)
const COLOR_CHAT_TEXT := Color(0.96, 0.98, 1.0, 1.0)
const COLOR_CHAT_MUTED := Color(0.66, 0.78, 0.90, 1.0)
const SENDER_COLORS := {
	"Mira": "ff7bd5",
	"Luna": "66f3ff",
	"Invitado": "ffd86b",
	"Sistema": "9db8d6",
}

var minimized: bool = false
var last_message_text: String = "Chat"
var counter_label: Label

@onready var chat_card: PanelContainer = $Root/ChatCard
@onready var title_label: Label = $Root/ChatCard/Margin/VBox/Header/Title
@onready var minimize_button: Button = $Root/ChatCard/Margin/VBox/Header/MinimizeButton
@onready var minimized_label: Label = $Root/ChatCard/Margin/VBox/MinimizedLabel
@onready var message_scroll: ScrollContainer = $Root/ChatCard/Margin/VBox/MessageScroll
@onready var message_list: VBoxContainer = $Root/ChatCard/Margin/VBox/MessageScroll/MessageList
@onready var chat_input: LineEdit = $Root/ChatCard/Margin/VBox/InputRow/ChatInput
@onready var input_row: HBoxContainer = $Root/ChatCard/Margin/VBox/InputRow
@onready var send_button: Button = $Root/ChatCard/Margin/VBox/InputRow/SendButton


func _ready() -> void:
	_apply_premium_chat_styles()
	chat_input.max_length = MAX_TEXT_LENGTH
	chat_input.text_submitted.connect(_on_text_submitted)
	chat_input.text_changed.connect(_on_text_changed)
	chat_input.focus_entered.connect(_on_input_focus_entered)
	chat_input.focus_exited.connect(_on_input_focus_exited)
	_setup_counter_label()
	_update_input_state()
	_apply_minimized_state()


func set_messages(messages: Array) -> void:
	clear()
	for message in messages:
		if typeof(message) == TYPE_DICTIONARY:
			add_message(message)


func add_message(message: Dictionary) -> void:
	var sender: String = String(message.get("sender", "Invitado"))
	var text: String = String(message.get("text", ""))
	last_message_text = "%s: %s" % [sender, text]
	minimized_label.text = last_message_text
	var rich_label: RichTextLabel = RichTextLabel.new()
	rich_label.bbcode_enabled = true
	rich_label.fit_content = true
	rich_label.scroll_active = false
	rich_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rich_label.selection_enabled = false
	rich_label.add_theme_font_size_override("normal_font_size", 16)
	rich_label.add_theme_color_override("default_color", COLOR_CHAT_TEXT)
	rich_label.text = "[color=#%s][b]%s:[/b][/color] %s" % [
		_get_sender_color(sender),
		_escape_bbcode(sender),
		_escape_bbcode(text),
	]
	message_list.add_child(rich_label)
	_trim_visible_messages()
	_scroll_to_bottom()


func clear() -> void:
	for child in message_list.get_children():
		child.queue_free()
	last_message_text = "Chat"
	minimized_label.text = last_message_text


func focus_input() -> void:
	if minimized:
		set_minimized(false)
	chat_input.grab_focus()


func set_minimized(value: bool) -> void:
	minimized = value
	_apply_minimized_state()


func clear_input() -> void:
	chat_input.text = ""
	_update_input_state()


func _on_text_submitted(text: String) -> void:
	_submit_text(text)


func _on_send_button_pressed() -> void:
	_submit_text(chat_input.text)


func _on_minimize_button_pressed() -> void:
	set_minimized(not minimized)


func _submit_text(text: String) -> void:
	if text.strip_edges().is_empty():
		return
	chat_submitted.emit(text)
	clear_input()
	chat_input.release_focus()


func _on_input_focus_entered() -> void:
	chat_focus_changed.emit(true)


func _on_input_focus_exited() -> void:
	chat_focus_changed.emit(false)


func _on_text_changed(_text: String) -> void:
	_update_input_state()


func _setup_counter_label() -> void:
	counter_label = Label.new()
	counter_label.add_theme_color_override("font_color", COLOR_CHAT_MUTED)
	counter_label.add_theme_font_size_override("font_size", 15)
	counter_label.custom_minimum_size = Vector2(64, 0)
	counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	counter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	input_row.add_child(counter_label)
	var send_index: int = input_row.get_children().find(send_button)
	if send_index != -1:
		input_row.move_child(counter_label, send_index)


func _update_input_state() -> void:
	if not counter_label:
		return
	var length: int = chat_input.text.strip_edges().length()
	counter_label.text = "%s/%s" % [length, MAX_TEXT_LENGTH]
	send_button.disabled = length == 0


func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	message_scroll.scroll_vertical = int(message_scroll.get_v_scroll_bar().max_value)


func _trim_visible_messages() -> void:
	while message_list.get_child_count() > MAX_VISIBLE_MESSAGES:
		message_list.get_child(0).queue_free()


func _apply_minimized_state() -> void:
	message_scroll.visible = not minimized
	input_row.visible = not minimized
	minimized_label.visible = minimized
	minimize_button.text = "+" if minimized else "-"
	chat_card.offset_top = -58.0 if minimized else -250.0
	chat_card.offset_right = 360.0 if minimized else 500.0


func _apply_premium_chat_styles() -> void:
	chat_card.add_theme_stylebox_override("panel", _make_premium_stylebox(COLOR_CHAT_BG, 2, COLOR_CHAT_BORDER, 3))
	UIThemeScript.apply_texture_panel_style(chat_card, "panel_dark_9slice", 8)
	chat_card.offset_left = 14.0
	chat_card.offset_bottom = -16.0
	var margin: MarginContainer = $Root/ChatCard/Margin
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	var vbox: VBoxContainer = $Root/ChatCard/Margin/VBox
	vbox.add_theme_constant_override("separation", 8)
	var header: HBoxContainer = $Root/ChatCard/Margin/VBox/Header
	header.add_theme_constant_override("separation", 8)
	_add_header_icon()
	title_label.text = "Chat"
	title_label.add_theme_color_override("font_color", COLOR_CHAT_TEXT)
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	minimized_label.add_theme_color_override("font_color", COLOR_CHAT_MUTED)
	minimized_label.add_theme_font_size_override("font_size", 15)
	_style_premium_button(minimize_button, COLOR_CHAT_BUTTON)
	UIThemeScript.apply_texture_button_style(minimize_button, "dark", 8)
	minimize_button.custom_minimum_size = Vector2(42, 34)
	_style_premium_button(send_button, COLOR_CHAT_SUCCESS)
	UIThemeScript.apply_texture_button_style(send_button, "green", 8)
	send_button.custom_minimum_size = Vector2(92, 40)
	send_button.text = "Enviar"
	chat_input.custom_minimum_size = Vector2(0, 40)
	chat_input.placeholder_text = "Enter para chatear"
	chat_input.add_theme_color_override("font_color", COLOR_CHAT_TEXT)
	chat_input.add_theme_color_override("font_placeholder_color", COLOR_CHAT_MUTED.darkened(0.10))
	chat_input.add_theme_font_size_override("font_size", 16)
	chat_input.add_theme_stylebox_override("normal", _make_premium_stylebox(COLOR_CHAT_BODY, 2, COLOR_CHAT_BORDER.darkened(0.20), 2))
	chat_input.add_theme_stylebox_override("focus", _make_premium_stylebox(COLOR_CHAT_BODY.lightened(0.04), 2, COLOR_CHAT_BORDER, 2))
	message_scroll.custom_minimum_size = Vector2(0, 128)
	message_scroll.add_theme_stylebox_override("panel", _make_premium_stylebox(COLOR_CHAT_BODY, 2, COLOR_CHAT_BORDER.darkened(0.20), 2))
	message_scroll.get_v_scroll_bar().custom_minimum_size = Vector2(14, 0)
	message_scroll.get_v_scroll_bar().add_theme_stylebox_override("scroll", _make_premium_stylebox(Color(0.02, 0.10, 0.20, 1.0), 2, COLOR_CHAT_BORDER.darkened(0.35), 1))
	message_scroll.get_v_scroll_bar().add_theme_stylebox_override("grabber", _make_premium_stylebox(COLOR_CHAT_BORDER.darkened(0.10), 2, COLOR_CHAT_BORDER, 1))
	message_list.add_theme_constant_override("separation", 5)
	input_row.add_theme_constant_override("separation", 8)
	input_row.custom_minimum_size = Vector2(0, 42)


func _add_header_icon() -> void:
	var header: HBoxContainer = $Root/ChatCard/Margin/VBox/Header
	if header.has_node("ChatIcon"):
		return
	var texture: Texture2D = UIThemeScript.load_ui_texture("res://assets/ui/icons/icon_chat.png")
	if not texture:
		return
	var icon: TextureRect = TextureRect.new()
	icon.name = "ChatIcon"
	icon.texture = texture
	icon.custom_minimum_size = Vector2(32, 32)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	header.add_child(icon)
	header.move_child(icon, 0)


func _style_premium_button(button: Button, color: Color) -> void:
	button.add_theme_color_override("font_color", COLOR_CHAT_TEXT)
	button.add_theme_color_override("font_disabled_color", COLOR_CHAT_MUTED)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_stylebox_override("normal", _make_premium_stylebox(color, 2, COLOR_CHAT_BORDER, 2))
	button.add_theme_stylebox_override("hover", _make_premium_stylebox(color.lightened(0.12), 2, Color(1.0, 0.78, 0.20, 1.0), 2))
	button.add_theme_stylebox_override("pressed", _make_premium_stylebox(color.darkened(0.10), 2, COLOR_CHAT_BORDER.darkened(0.1), 2))
	button.add_theme_stylebox_override("disabled", _make_premium_stylebox(color.darkened(0.28), 2, COLOR_CHAT_BORDER.darkened(0.35), 1))


func _make_premium_stylebox(color: Color, radius: int, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


func _get_sender_color(sender: String) -> String:
	if SENDER_COLORS.has(sender):
		return String(SENDER_COLORS[sender])
	var hash_value: int = absi(sender.hash())
	var palette: PackedStringArray = PackedStringArray(["ffd86b", "66f3ff", "ff8acb", "a8ff8a", "c8a2ff"])
	return palette[hash_value % palette.size()]


func _escape_bbcode(value: String) -> String:
	return value.replace("[", "\\[").replace("]", "\\]")
