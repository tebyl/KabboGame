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
const UI_ASSET_ROOT := "res://assets/ui"
const TEXTURE_MARGIN_DEFAULT := 8


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


static func apply_texture_panel_style(panel: PanelContainer, panel_name: String, margin: int = TEXTURE_MARGIN_DEFAULT) -> bool:
	var texture: Texture2D = load_ui_texture("%s/panels/%s.png" % [UI_ASSET_ROOT, panel_name])
	if not texture:
		return false
	panel.add_theme_stylebox_override("panel", make_texture_style(texture, margin))
	return true


static func apply_texture_button_style(button: Button, variant: String, margin: int = TEXTURE_MARGIN_DEFAULT) -> bool:
	var applied: bool = false
	for state in ["normal", "hover", "pressed", "disabled"]:
		var texture: Texture2D = load_ui_texture("%s/buttons/btn_%s_%s.png" % [UI_ASSET_ROOT, variant, state])
		if texture:
			button.add_theme_stylebox_override(state, make_texture_style(texture, margin))
			applied = true
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_pressed_color", COLOR_TEXT)
	button.add_theme_color_override("font_disabled_color", COLOR_TEXT_MUTED)
	return applied


static func apply_button_icon(button: Button, icon_name: String) -> bool:
	var texture: Texture2D = load_ui_texture("%s/icons/icon_%s.png" % [UI_ASSET_ROOT, icon_name])
	if not texture:
		return false
	button.icon = texture
	button.expand_icon = false
	return true


static func make_icon(icon_name: String, size: Vector2 = Vector2(24, 24)) -> TextureRect:
	var texture: Texture2D = load_ui_texture("%s/icons/icon_%s.png" % [UI_ASSET_ROOT, icon_name])
	return make_texture_rect(texture, size)


static func make_asset_texture_rect(path: String, size: Vector2 = Vector2(24, 24)) -> TextureRect:
	var texture: Texture2D = load_ui_texture(path)
	return make_texture_rect(texture, size)


static func make_texture_rect(texture: Texture2D, size: Vector2 = Vector2(24, 24)) -> TextureRect:
	if not texture:
		return null
	var icon: TextureRect = TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = size
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	return icon


static func load_ui_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		return null
	var resource: Resource = load(path)
	return resource as Texture2D


static func make_texture_style(texture: Texture2D, margin: int = TEXTURE_MARGIN_DEFAULT) -> StyleBoxTexture:
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = margin
	style.texture_margin_top = margin
	style.texture_margin_right = margin
	style.texture_margin_bottom = margin
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style


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
