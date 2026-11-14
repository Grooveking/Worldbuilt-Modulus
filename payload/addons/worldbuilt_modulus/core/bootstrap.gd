extends Node

const LOADER_NAME := "Worldbuilt: Modulus"
const LOADER_VERSION := "0.2.0"

const MAIN_MENU_PATH := "res://scenes/menu.tscn"
const MOD_MENU_SCRIPT_PATH := (
	"res://addons/worldbuilt_modulus/ui/mod_menu.gd"
)

const MOD_RUNTIME_SCRIPT := preload(
	"res://addons/worldbuilt_modulus/core/mod_runtime.gd"
)

const START_BUTTON_PATH := NodePath("StartButton")
const DELETE_BUTTON_PATH := NodePath("DeleteSave")
const MODS_BUTTON_PATH := NodePath("ModsButton")
const MODS_BUTTON_OFFSET := Vector2(0.0, 54.0)
const LOADER_LOGO_PATH := (
	"res://addons/worldbuilt_modulus/assets/modulus.png"
)

const LOGO_SIZE := Vector2(256.0, 32.0)

var _mod_runtime := MOD_RUNTIME_SCRIPT.new()

func _init() -> void:
	_mod_runtime.load_enabled_mods(self)

func _ready() -> void:
	print(
		"[%s] Bootstrap loaded. Version %s"
		% [LOADER_NAME, LOADER_VERSION]
	)

	get_tree().scene_changed.connect(
		_on_scene_changed
	)

	call_deferred("_add_mods_button")

	
func _add_loader_logo(current_scene: Node) -> void:
	print("[Modulus] Logo function called.")
	print("[Modulus] Scene: ", current_scene.scene_file_path)
	print("[Modulus] Title found: ",
	
	current_scene.has_node("TitleWorldbuilt"))

	if current_scene.has_node("ModulusLogo"):
		return

	var title := current_scene.get_node_or_null(
		"TitleWorldbuilt"
	) as Sprite2D
	
	var image := Image.new()
	var error := image.load(LOADER_LOGO_PATH)

	print("[Modulus] Image load result: ", error_string(error))

	if error != OK:
		push_error("[Modulus] Failed to load image.")
		return

	print("[Modulus] Image dimensions: ", image.get_size())

	var texture := ImageTexture.create_from_image(image)

	print("[Modulus] Texture created successfully.")

	if texture == null:
		push_error("[Modulus] Texture creation failed.")
		return

	print("[Modulus] Creating TextureRect.")

	var logo := TextureRect.new()

	logo.name = "ModulusLogo"
	logo.texture = texture

	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	#logo.size = LOGO_SIZE
	logo.custom_minimum_size = LOGO_SIZE

	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var title_height := (
		title.texture.get_height() * title.scale.y
	)

	var logo_height := 32.0
	var spacing := -90.0

	logo.position = Vector2(
		title.position.x,
		title.position.y + title_height / 2.0 + spacing + logo_height / 2.0
	)

	var subtitle := Label.new()
	subtitle.name = "ModulusSubtitle"
	subtitle.text = "LOADER VER. " + str(LOADER_VERSION)

	# Reuse the game's font
	subtitle.add_theme_font_override(
		"font",
		preload("res://fonts/worldbuiltFont.png")
	)

	subtitle.add_theme_font_size_override("font_size", 5)

	# Position it underneath the logo
	subtitle.position = Vector2(
		logo.position.x + 48.0,
		logo.position.y + LOGO_SIZE.y + 2.0
	)

	current_scene.add_child(subtitle)

	print("[Modulus] Adding logo to scene.")

	current_scene.add_child(logo)

	print("[Modulus] Logo successfully added.")


func _on_scene_changed() -> void:
	call_deferred("_add_mods_button")


func _add_mods_button() -> void:
	var current_scene := get_tree().current_scene

	if current_scene == null:
		return

	if current_scene.scene_file_path != MAIN_MENU_PATH:
		return

	_add_loader_logo(current_scene)

	if current_scene.has_node(MODS_BUTTON_PATH):
		return

	var start_button := current_scene.get_node_or_null(
		START_BUTTON_PATH
	) as Button

	var delete_button := current_scene.get_node_or_null(
		DELETE_BUTTON_PATH
	) as Button

	if start_button == null:
		push_warning(
			"[Modulus] Could not find StartButton."
		)
		return

	if delete_button == null:
		push_warning(
			"[Modulus] Could not find DeleteSave."
		)
		return

	var mods_button := start_button.duplicate(0) as Button

	if mods_button == null:
		push_warning(
			"[Modulus] Could not create ModsButton."
		)
		return

	mods_button.name = "ModsButton"
	mods_button.text = "MODS"

	var hover_script = load("res://addons/worldbuilt_modulus/core/mods_button.gd")
	mods_button.set_script(hover_script)

	current_scene.add_child(mods_button)

	mods_button.position = (
		start_button.position
		+ MODS_BUTTON_OFFSET
	)

	var mod_menu := _create_mod_menu(
		current_scene,
		start_button,
		delete_button,
		mods_button
	)

	if mod_menu == null:
		mods_button.queue_free()
		return

	mods_button.pressed.connect(
		Callable(mod_menu, "open")
	)

	print("[Modulus] Added the MODS button and menu.")


func _create_mod_menu(
	current_scene: Node,
	start_button: Button,
	delete_button: Button,
	mods_button: Button
) -> Node2D:
	var mod_menu_script := load(
		MOD_MENU_SCRIPT_PATH
	) as Script

	if mod_menu_script == null:
		push_error(
			"[Modulus] Could not load mod_menu.gd."
		)
		return null

	var mod_menu := mod_menu_script.new() as Node2D

	if mod_menu == null:
		push_error(
			"[Modulus] Could not create the mod menu."
		)
		return null

	mod_menu.name = "UnboundModMenu"
	current_scene.add_child(mod_menu)

	mod_menu.call(
		"setup",
		start_button,
		delete_button,
		mods_button
	)

	return mod_menu