class_name UITheme
extends RefCounted

const COLOR_PANEL := Color(0.08, 0.14, 0.24, 0.96)
const COLOR_PANEL_DARK := Color(0.04, 0.08, 0.15, 0.98)
const COLOR_PRIMARY := Color(0.18, 0.48, 0.95, 1.0)
const COLOR_SECONDARY := Color(0.18, 0.27, 0.42, 1.0)
const COLOR_SUCCESS := Color(0.18, 0.72, 0.42, 1.0)
const COLOR_WARNING := Color(0.95, 0.70, 0.22, 1.0)
const COLOR_DANGER := Color(0.92, 0.28, 0.32, 1.0)
const COLOR_TEXT := Color(0.94, 0.97, 1.0, 1.0)
const COLOR_TEXT_MUTED := Color(0.65, 0.74, 0.86, 1.0)
const COLOR_OVERLAY := Color(0, 0, 0, 0.45)


static func apply_panel_style(panel: PanelContainer) -> void:
	panel.add_theme_stylebox_override("panel", _make_stylebox(COLOR_PANEL, 10, Color(0.22, 0.34, 0.52), 1))


static func apply_dark_panel_style(panel: PanelContainer) -> void:
	panel.add_theme_stylebox_override("panel", _make_stylebox(COLOR_PANEL_DARK, 10, Color(0.16, 0.24, 0.38), 1))


static func apply_primary_button(button: Button) -> void:
	_apply_button_style(button, COLOR_PRIMARY)


static func apply_secondary_button(button: Button) -> void:
	_apply_button_style(button, COLOR_SECONDARY)


static func apply_danger_button(button: Button) -> void:
	_apply_button_style(button, COLOR_DANGER)


static func apply_success_button(button: Button) -> void:
	_apply_button_style(button, COLOR_SUCCESS)


static func apply_label(label: Label, muted: bool = false) -> void:
	label.add_theme_color_override("font_color", COLOR_TEXT_MUTED if muted else COLOR_TEXT)


static func apply_popup_menu_style(popup: PopupMenu) -> void:
	popup.add_theme_stylebox_override("panel", _make_stylebox(COLOR_PANEL_DARK, 8, Color(0.25, 0.38, 0.58), 1))
	popup.add_theme_stylebox_override("hover", _make_stylebox(COLOR_SECONDARY.lightened(0.08), 6, Color(0.28, 0.48, 0.76), 1))
	popup.add_theme_color_override("font_color", COLOR_TEXT)
	popup.add_theme_color_override("font_hover_color", COLOR_TEXT)
	popup.add_theme_color_override("font_separator_color", COLOR_TEXT_MUTED)
	popup.add_theme_constant_override("v_separation", 4)
	popup.add_theme_constant_override("item_start_padding", 10)
	popup.add_theme_constant_override("item_end_padding", 12)


static func _apply_button_style(button: Button, color: Color) -> void:
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_stylebox_override("normal", _make_stylebox(color, 8, color.lightened(0.12), 1))
	button.add_theme_stylebox_override("hover", _make_stylebox(color.lightened(0.12), 8, color.lightened(0.25), 1))
	button.add_theme_stylebox_override("pressed", _make_stylebox(color.darkened(0.12), 8, color.lightened(0.08), 1))
	button.add_theme_stylebox_override("disabled", _make_stylebox(COLOR_SECONDARY.darkened(0.25), 8, COLOR_SECONDARY.darkened(0.1), 1))


static func _make_stylebox(color: Color, radius: int, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
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
