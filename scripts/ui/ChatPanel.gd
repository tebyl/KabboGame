extends CanvasLayer

signal chat_submitted(text: String)
signal chat_focus_changed(focused: bool)

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")

@onready var message_scroll: ScrollContainer = $Root/ChatCard/Margin/VBox/MessageScroll
@onready var message_list: VBoxContainer = $Root/ChatCard/Margin/VBox/MessageScroll/MessageList
@onready var chat_input: LineEdit = $Root/ChatCard/Margin/VBox/InputRow/ChatInput


func _ready() -> void:
	UIThemeScript.apply_panel_style($Root/ChatCard)
	chat_input.text_submitted.connect(_on_text_submitted)
	chat_input.focus_entered.connect(_on_input_focus_entered)
	chat_input.focus_exited.connect(_on_input_focus_exited)


func set_messages(messages: Array) -> void:
	clear()
	for message in messages:
		if typeof(message) == TYPE_DICTIONARY:
			add_message(message)


func add_message(message: Dictionary) -> void:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = "%s: %s" % [String(message.get("sender", "Invitado")), String(message.get("text", ""))]
	UIThemeScript.apply_label(label)
	message_list.add_child(label)
	_scroll_to_bottom()


func clear() -> void:
	for child in message_list.get_children():
		child.queue_free()


func focus_input() -> void:
	chat_input.grab_focus()


func clear_input() -> void:
	chat_input.text = ""


func _on_text_submitted(text: String) -> void:
	_submit_text(text)


func _on_send_button_pressed() -> void:
	_submit_text(chat_input.text)


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


func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	message_scroll.scroll_vertical = int(message_scroll.get_v_scroll_bar().max_value)
