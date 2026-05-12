extends CanvasLayer

signal sfx_enabled_changed(enabled: bool)
signal sfx_volume_changed(value: float)
signal test_audio_requested
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")

@onready var root: Control = $Root
@onready var card: PanelContainer = $Root/Card
@onready var title_label: Label = $Root/Card/Margin/VBox/Header/Title
@onready var close_button: Button = $Root/Card/Margin/VBox/Header/CloseButton
@onready var sfx_check: CheckBox = $Root/Card/Margin/VBox/SfxCheck
@onready var volume_slider: HSlider = $Root/Card/Margin/VBox/VolumeRow/VolumeSlider
@onready var volume_label: Label = $Root/Card/Margin/VBox/VolumeRow/VolumeLabel


func _ready() -> void:
	$Root/Overlay.color = UIThemeScript.COLOR_OVERLAY
	UIThemeScript.apply_panel_style(card)
	UIThemeScript.apply_label(title_label)
	UIThemeScript.apply_label(volume_label, true)
	UIThemeScript.apply_secondary_button(close_button)
	hide_panel()


func show_with_settings(sfx_enabled: bool, sfx_volume: float) -> void:
	sfx_check.set_pressed_no_signal(sfx_enabled)
	volume_slider.set_value_no_signal(clampf(sfx_volume, 0.0, 1.0))
	_update_volume_label()
	root.visible = true


func hide_panel() -> void:
	root.visible = false


func _update_volume_label() -> void:
	volume_label.text = "Volumen: %s%%" % int(round(volume_slider.value * 100.0))


func _on_sfx_check_toggled(button_pressed: bool) -> void:
	sfx_enabled_changed.emit(button_pressed)


func _on_volume_slider_value_changed(value: float) -> void:
	_update_volume_label()
	sfx_volume_changed.emit(value)


func _on_test_audio_pressed() -> void:
	test_audio_requested.emit()


func _on_close_button_pressed() -> void:
	hide_panel()
	close_requested.emit()
