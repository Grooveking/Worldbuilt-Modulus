extends Node2D

const MODS_FOLDER_NAME := "mods"
const MAX_VISIBLE_MODS := 6

const MOD_CATALOG_SCRIPT := preload(
	"res://addons/worldbuilt_modulus/core/mod_catalog.gd"
)

const MOD_SETTINGS_SCRIPT := preload(
	"res://addons/worldbuilt_modulus/core/mod_settings.gd"
)

const TITLE_POSITION := Vector2(35.0, 92.0)
const EMPTY_MESSAGE_POSITION := Vector2(35.0, 118.0)
const MOD_ROW_START_POSITION := Vector2(35.0, 100.0)
const RESTART_MESSAGE_POSITION := Vector2(35.0, 220.0)
const OPEN_FOLDER_POSITION := Vector2(35.0, 160.0)
const BACK_POSITION := Vector2(35.0, 187.0)

const MOD_ROW_SIZE := Vector2(220.0, 9.0)

const MOD_LIST_SIZE := Vector2(
	220.0,
	MOD_ROW_SIZE.y * MAX_VISIBLE_MODS + 4.0
)

const LABEL_WIDTH := 220.0
const LABEL_HEIGHT := 20.0

var _main_menu_buttons: Array[Button] = []
var _mod_row_buttons: Array[Button] = []

var _button_template: Button
var _mod_catalog := MOD_CATALOG_SCRIPT.new()
var _mod_settings := MOD_SETTINGS_SCRIPT.new()

var _installed_mods: Array[Dictionary] = []
var _restart_required := false

var _mod_scroll: ScrollContainer
var _mod_list: VBoxContainer

var _save_icon: Sprite2D


func setup(
	start_button: Button,
	delete_button: Button,
	mods_button: Button
) -> void:
	_button_template = start_button

	_save_icon = get_node_or_null(
		"/root/Menu/saveIcon"
	) as Sprite2D

	_main_menu_buttons = [
		start_button,
		delete_button,
		mods_button
	]

	_add_label(
		"ModsTitle",
		"MODS",
		TITLE_POSITION,
		10
	)

	_add_label(
		"EmptyMessage",
		"NO MODS INSTALLED",
		EMPTY_MESSAGE_POSITION,
		5
	)

	_add_label(
		"RestartMessage",
		"RESTART REQUIRED",
		RESTART_MESSAGE_POSITION,
		5
	)

	_build_mod_list()

	var restart_message := get_node(
		"RestartMessage"
	) as Label

	restart_message.hide()

	_add_button(
		"OpenFolderButton",
		"OPEN FOLDER",
		OPEN_FOLDER_POSITION,
		_open_mods_folder
	)

	_add_button(
		"BackButton",
		"BACK",
		BACK_POSITION,
		close
	)

	hide()


func open() -> void:
	_refresh_mod_list()

	for button in _main_menu_buttons:
		button.hide()

	if _save_icon != null:
		_save_icon.hide()

	show()


func close() -> void:
	hide()

	for button in _main_menu_buttons:
		button.show()

	if _save_icon != null:
		_save_icon.show()


func _add_label(
	node_name: String,
	label_text: String,
	label_position: Vector2,
	font_size: int
) -> void:
	var label := Label.new()

	label.name = node_name
	label.text = label_text
	label.position = label_position
	label.size = Vector2(
		LABEL_WIDTH,
		LABEL_HEIGHT
	)

	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	label.add_theme_font_override(
		"font",
		_button_template.get_theme_font("font")
	)

	label.add_theme_font_size_override(
		"font_size",
		font_size
	)

	add_child(label)


func _add_button(
	node_name: String,
	button_text: String,
	button_position: Vector2,
	callback: Callable
) -> Button:
	var button := _button_template.duplicate(0) as Button

	if button == null:
		push_error(
			"[Modulus] Could not create button: %s"
			% node_name
		)
		return null

	button.name = node_name
	button.text = button_text
	button.position = button_position
	button.pressed.connect(callback)

	var hover_script = load("res://addons/worldbuilt_modulus/core/mods_button.gd")
	button.set_script(hover_script)

	add_child(button)

	return button




func _build_mod_list() -> void:
	_mod_scroll = ScrollContainer.new()
	_mod_scroll.name = "ModListScroll"
	_mod_scroll.position = MOD_ROW_START_POSITION
	_mod_scroll.size = MOD_LIST_SIZE

	_mod_scroll.horizontal_scroll_mode = (
		ScrollContainer.SCROLL_MODE_DISABLED
	)

	_mod_scroll.vertical_scroll_mode = (
		ScrollContainer.SCROLL_MODE_AUTO
	)

	_mod_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	_mod_scroll.clip_contents = true

	add_child(_mod_scroll)

	_mod_list = VBoxContainer.new()
	_mod_list.name = "ModList"

	_mod_list.custom_minimum_size.x = MOD_LIST_SIZE.x - 8.0

	_mod_list.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	_mod_list.size_flags_vertical = (
		Control.SIZE_SHRINK_BEGIN
	)

	_mod_list.add_theme_constant_override(
		"separation",
		0
	)

	_mod_scroll.add_child(_mod_list)


func _refresh_mod_list() -> void:
	_clear_mod_rows()

	var empty_message := get_node_or_null(
		"EmptyMessage"
	) as Label

	if empty_message == null:
		push_warning(
			"[Modulus] Could not find EmptyMessage."
		)
		return

	if not _ensure_mods_directory():
		empty_message.text = "MOD FOLDER ERROR"
		empty_message.show()
		return

	_installed_mods = _mod_catalog.scan_directory(
		_get_mods_directory()
	)

	for manifest in _installed_mods:
		var mod_id := str(manifest["id"])

		manifest["enabled"] = _mod_settings.is_enabled(
			mod_id
		)

	if _installed_mods.is_empty():
		empty_message.text = "NO VALID MODS"
		empty_message.show()

		if _mod_scroll != null:
			_mod_scroll.hide()

		return

	empty_message.hide()

	if _mod_scroll != null:
		_mod_scroll.show()

	for index in range(_installed_mods.size()):
		_add_mod_row(
			index,
			_installed_mods[index]
		)


func _add_mod_row(
	index: int,
	manifest: Dictionary
) -> void:
	var mod_id := str(manifest["id"])

	var row_button := _button_template.duplicate(0) as Button

	if row_button == null:
		push_error(
			"[Modulus] Could not create a row for %s."
			% mod_id
		)
		return

	row_button.show()

	row_button.name = "ModRow%d" % index
	row_button.position = Vector2.ZERO
	row_button.custom_minimum_size = Vector2(
		MOD_LIST_SIZE.x - 8.0,
		MOD_ROW_SIZE.y
	)
	row_button.size_flags_horizontal = Control.SIZE_FILL
	row_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	row_button.clip_text = true
	row_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	_hide_button_frame(row_button)
	_update_mod_row_text(row_button, manifest)

	row_button.pressed.connect(
		_toggle_mod.bind(mod_id)
	)

	if _mod_list == null:
		push_error("[Modulus] Mod list was not created.")
		row_button.queue_free()
		return

	_mod_list.add_child(row_button)
	_mod_row_buttons.append(row_button)


func _hide_button_frame(button: Button) -> void:
	var frame := button.get_node_or_null(
		"NinePatchRect"
	) as CanvasItem

	if frame != null:
		frame.hide()


func _update_mod_row_text(
	button: Button,
	manifest: Dictionary
) -> void:
	var state_marker := (
		"[X]"
		if bool(manifest["enabled"])
		else "[ ]"
	)

	button.text = "%s %s V%s" % [
		state_marker,
		str(manifest["name"]).to_upper(),
		str(manifest["version"])
	]


func _toggle_mod(mod_id: String) -> void:
	var manifest := _find_mod(mod_id)

	if manifest.is_empty():
		push_warning(
			"[Modulus] Could not find mod: %s"
			% mod_id
		)
		return

	var new_state := not bool(
		manifest["enabled"]
	)

	if not _mod_settings.set_enabled(
		mod_id,
		new_state
	):
		return

	manifest["enabled"] = new_state
	_restart_required = true

	var restart_message := get_node_or_null(
		"RestartMessage"
	) as Label

	if restart_message != null:
		restart_message.show()

	_refresh_mod_list()


func _find_mod(mod_id: String) -> Dictionary:
	for manifest in _installed_mods:
		if str(manifest["id"]) == mod_id:
			return manifest

	return {}


func _clear_mod_rows() -> void:
	for button in _mod_row_buttons:
		button.queue_free()

	_mod_row_buttons.clear()


func _get_mods_directory() -> String:
	var game_directory := (
		OS.get_executable_path().get_base_dir()
	)

	return game_directory.path_join(
		MODS_FOLDER_NAME
	)


func _ensure_mods_directory() -> bool:
	var create_error := DirAccess.make_dir_recursive_absolute(
		_get_mods_directory()
	)

	if create_error == OK:
		return true

	push_error(
		"[Modulus] Could not create the mods folder: %s"
		% error_string(create_error)
	)

	return false


func _open_mods_folder() -> void:
	if not _ensure_mods_directory():
		return

	var open_error := OS.shell_open(
		_get_mods_directory()
	)

	if open_error != OK:
		push_error(
			"[Modulus] Could not open the mods folder: %s"
			% error_string(open_error)
		)