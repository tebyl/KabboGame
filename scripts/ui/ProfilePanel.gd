extends CanvasLayer

signal profile_save_requested(profile_data: Dictionary)
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")

var profile_data := {
	"name": "Invitado",
	"avatar_variant": "default",
}
var selected_variant := "default"

@onready var root: Control = $Root
@onready var name_input: LineEdit = $Root/Card/Margin/VBox/NameInput
@onready var avatar_preview: Sprite2D = $Root/Card/Margin/VBox/PreviewArea/AvatarPreview


func _ready() -> void:
	$Root/Overlay.color = UIThemeScript.COLOR_OVERLAY
	UIThemeScript.apply_panel_style($Root/Card)
	hide_panel()


func show_with_profile(next_profile_data: Dictionary) -> void:
	profile_data = next_profile_data.duplicate(true)
	selected_variant = String(profile_data.get("avatar_variant", "default"))
	name_input.text = String(profile_data.get("name", "Invitado"))
	root.visible = true
	update_preview()


func hide_panel() -> void:
	root.visible = false


func update_preview() -> void:
	var variant_path := "res://assets/sprites/player_variants/%s/south.png" % selected_variant
	var base_path := "res://assets/sprites/player/south.png"
	var texture: Texture2D = null
	if ResourceLoader.exists(variant_path):
		texture = load(variant_path)
	elif ResourceLoader.exists(base_path):
		texture = load(base_path)
	if texture:
		avatar_preview.texture = texture
		avatar_preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		avatar_preview.offset = Vector2(0, -texture.get_height() / 2.0)


func _on_variant_pressed(variant_name: String) -> void:
	selected_variant = variant_name
	update_preview()


func _on_save_button_pressed() -> void:
	var clean_name := name_input.text.strip_edges()
	profile_data["name"] = clean_name if not clean_name.is_empty() else "Invitado"
	profile_data["avatar_variant"] = selected_variant
	profile_save_requested.emit(profile_data.duplicate(true))


func _on_cancel_button_pressed() -> void:
	hide_panel()
	close_requested.emit()
