extends CanvasLayer

signal next_requested
signal skip_requested
signal action_requested(action: String)

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const OnboardingManagerScript := preload("res://scripts/data/OnboardingManager.gd")

var current_step := OnboardingManagerScript.STEP_WELCOME
var current_action := ""

@onready var root: Control = $Root
@onready var overlay: ColorRect = $Root/Overlay
@onready var card: PanelContainer = $Root/Card
@onready var title_label: Label = $Root/Card/Margin/VBox/TitleLabel
@onready var body_label: Label = $Root/Card/Margin/VBox/BodyLabel
@onready var next_button: Button = $Root/Card/Margin/VBox/Buttons/NextButton
@onready var skip_button: Button = $Root/Card/Margin/VBox/Buttons/SkipButton


func _ready() -> void:
	overlay.color = UIThemeScript.COLOR_OVERLAY
	UIThemeScript.apply_panel_style(card)
	UIThemeScript.apply_label(title_label)
	UIThemeScript.apply_label(body_label, true)
	UIThemeScript.apply_primary_button(next_button)
	UIThemeScript.apply_secondary_button(skip_button)
	hide_panel()


func show_step(step: String) -> void:
	current_step = step
	current_action = ""
	match step:
		OnboardingManagerScript.STEP_WELCOME:
			set_step_content("Bienvenido a KabboLike", "Crea tu sala, decora y conversa con visitantes.", "Comenzar")
		OnboardingManagerScript.STEP_PROFILE:
			current_action = "open_profile"
			set_step_content("Personaliza tu perfil", "Elige tu nombre y color de camisa.", "Abrir perfil")
		OnboardingManagerScript.STEP_WALK:
			set_step_content("Camina por la sala", "Haz click en una celda del piso para moverte.", "Entendido")
		OnboardingManagerScript.STEP_INVENTORY:
			current_action = "open_inventory"
			set_step_content("Tu inventario", "Aqui estan los muebles que tienes disponibles.", "Abrir inventario")
		OnboardingManagerScript.STEP_DECORATE:
			current_action = "enable_decorate"
			set_step_content("Modo Decora", "Activa Decora para colocar y mover muebles.", "Activar Decora")
		OnboardingManagerScript.STEP_PLACE_FURNITURE:
			set_step_content("Coloca un mueble", "Selecciona un mueble y haz click en el piso.", "Entendido")
		OnboardingManagerScript.STEP_SHOP:
			current_action = "open_shop"
			set_step_content("Tienda", "Compra nuevos muebles con monedas.", "Abrir tienda")
		OnboardingManagerScript.STEP_CHAT:
			set_step_content("Chat", "Escribe un mensaje y presiona Enter.", "Entendido")
		OnboardingManagerScript.STEP_SAVE:
			set_step_content("Guarda tu progreso", "Tu sala se guarda automaticamente, pero tambien puedes guardar manualmente.", "Finalizar")
		_:
			hide_panel()
			return

	overlay.visible = step == OnboardingManagerScript.STEP_WELCOME or step == OnboardingManagerScript.STEP_PROFILE
	_position_card_for_step(step)
	root.visible = true


func hide_panel() -> void:
	root.visible = false


func set_step_content(title: String, body: String, action_text: String = "") -> void:
	title_label.text = title
	body_label.text = body
	next_button.text = action_text if not action_text.is_empty() else "Siguiente"


func _position_card_for_step(step: String) -> void:
	if step == OnboardingManagerScript.STEP_WELCOME or step == OnboardingManagerScript.STEP_PROFILE:
		card.anchor_left = 1.0
		card.anchor_right = 1.0
		card.anchor_top = 1.0
		card.anchor_bottom = 1.0
		card.offset_left = -388.0
		card.offset_top = -214.0
		card.offset_right = -28.0
		card.offset_bottom = -44.0
		return
	card.anchor_left = 0.0
	card.anchor_right = 0.0
	card.anchor_top = 1.0
	card.anchor_bottom = 1.0
	card.offset_left = 16.0
	card.offset_top = -214.0
	card.offset_right = 376.0
	card.offset_bottom = -44.0


func _on_next_button_pressed() -> void:
	if not current_action.is_empty():
		action_requested.emit(current_action)
	else:
		next_requested.emit()


func _on_skip_button_pressed() -> void:
	skip_requested.emit()
