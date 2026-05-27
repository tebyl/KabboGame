extends CanvasLayer

signal chat_submitted(text: String)
signal chat_focus_changed(focused: bool)

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const ChatManagerScript := preload("res://scripts/data/ChatManager.gd")
const MAX_TEXT_LENGTH := ChatManagerScript.MAX_TEXT_LENGTH
const MAX_VISIBLE_MESSAGES := 40

var minimized := false
var last_message_text := "Chat"
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
	UIThemeScript.apply_panel_style(chat_card)
	UIThemeScript.apply_label(title_label)
	UIThemeScript.apply_label(minimized_label, true)
	UIThemeScript.apply_secondary_button(minimize_button)
	UIThemeScript.apply_primary_button(send_button)
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
	last_message_text = "%s: %s" % [String(message.get("sender", "Invitado")), String(message.get("text", ""))]
	minimized_label.text = last_message_text
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = last_message_text
	UIThemeScript.apply_label(label)
	message_list.add_child(label)
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
	UIThemeScript.apply_label(counter_label, true)
	counter_label.custom_minimum_size = Vector2(64, 0)
	counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	input_row.add_child(counter_label)
	var send_index := input_row.get_children().find(send_button)
	if send_index != -1:
		input_row.move_child(counter_label, send_index)


func _update_input_state() -> void:
	if not counter_label:
		return
	var length := chat_input.text.strip_edges().length()
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
	chat_card.offset_top = -48.0 if minimized else -180.0
	chat_card.offset_right = 320.0 if minimized else 380.0
