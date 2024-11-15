@tool
class_name MagnifyingGlass
extends ColorRect

#region Properties

@export var magnify_material: ShaderMaterial
@export var glass_size_slider: HSlider
@export var toggle_button: Button
@export var zoom_in_button: Button
@export var zoom_out_button: Button
@export var zoom_label: Label
@export var enable_keys: CheckBox
@export var zoom_in_key: OptionButton
@export var zoom_out_key: OptionButton
@export var key_buttons: VBoxContainer
@export var ratio_options: OptionButton

var zoom_level: float
var activated: bool
var save_data: MagnifySaveData

var keys_visibility_lerp: float = 0.1
var glass_visibility_lerp: float = 0.1
var show_glass: bool = false

const MIN_ZOOM = 1.0
const ZOOM_INCREMENT = 1.0
const ZOOM_ONE = MIN_ZOOM + ZOOM_INCREMENT
const MAX_ZOOM = MIN_ZOOM + ZOOM_INCREMENT * 6.0

const RATIO_WINDOW = "Godot Window"
const ONE_BY_ONE = "1 : 1"
const TWO_BY_THREE = "2 : 3"
const SEVEN_BY_FIVE = "7 : 5"
const SIXTEEN_BY_NINE = "16 : 9"

#endregion
#region Initialise & Deactivate

func initialise():
	material = magnify_material

	save_data = ResourceLoader.load("res://addons/magnify/save_data.tres")
	populate_option_button(zoom_in_key)
	populate_option_button(zoom_out_key)
	select_option_button(zoom_in_key, save_data.current_zoom_in_key)
	select_option_button(zoom_out_key, save_data.current_zoom_out_key)
	populate_ratios()

	glass_size_slider.value = save_data.current_size

	set_zoom_level(MIN_ZOOM)

	toggle_button.pressed.connect(disappear)
	zoom_in_button.pressed.connect(zoom_in)
	zoom_out_button.pressed.connect(zoom_out)
	zoom_in_key.item_selected.connect(select_zoom_in_key)
	zoom_out_key.item_selected.connect(select_zoom_out_key)
	ratio_options.item_selected.connect(update_saved_ratio)

	enable_keys.button_pressed = save_data.keys_enabled
	enable_keys.pressed.connect(save_enabled)

	tree_exiting.connect(deactivate)
	activated = true

func deactivate():
	activated = false

#endregion
#region Process & Input

func _process(delta: float) -> void:
	if (!activated):
		return

	keys_visibility_lerp = lerp_visibility(key_buttons, enable_keys.button_pressed,
		keys_visibility_lerp, delta)

	glass_visibility_lerp = lerp_visibility(self, show_glass,
		glass_visibility_lerp, delta)

	magnify_material.set_shader_parameter("alpha", glass_visibility_lerp)

	if (!visible):
		return

	var screen_size: Vector2 = Vector2(get_window().size)
	var size_ratio: Vector2 = screen_size
	if (save_data.current_ratio == ONE_BY_ONE):
		size_ratio.x = size_ratio.y * 1.0000
	elif (save_data.current_ratio == TWO_BY_THREE):
		size_ratio.x = size_ratio.y * 0.6667
	elif (save_data.current_ratio == SEVEN_BY_FIVE):
		size_ratio.x = size_ratio.y * 1.4000
	elif (save_data.current_ratio == SIXTEEN_BY_NINE):
		size_ratio.x = size_ratio.y * 1.7778

	save_data.current_size = glass_size_slider.value
	size = (size_ratio * glass_size_slider.value).round()
	var mouse_position = get_global_mouse_position() - (size / 2.0)

	global_position = mouse_position.clamp(Vector2(0.0, 0.0), screen_size - size)
	var offset = (mouse_position + size / 2.0) / screen_size
	magnify_material.set_shader_parameter("offset", offset)



func _input(event: InputEvent) -> void:
	if (!activated || !enable_keys.button_pressed):
		return

	if (event is InputEventKey && event.is_pressed()):
		if (event.keycode == save_data.zoom_in_key):
			zoom_in()
		elif (event.keycode == save_data.zoom_out_key):
			zoom_out()

func save_enabled():
	save_data.keys_enabled = enable_keys.button_pressed

#endregion
#region Set Zoom

func set_zoom_level(_zoom: float):
	zoom_level = clampf(_zoom, MIN_ZOOM, MAX_ZOOM)
	show_glass = zoom_level > MIN_ZOOM
	if (show_glass):
		magnify_material.set_shader_parameter("zoom", zoom_level)

	var int_zoom: int = int(zoom_level)
	var is_min_zoom: bool = int_zoom <= 1
	if (is_min_zoom):
		zoom_label.text = "Zoom: Off"
	else:
		zoom_label.text = "Zoom: x" + str(int_zoom)

func zoom_in():
	set_zoom_level(zoom_level + ZOOM_INCREMENT)

func zoom_out():
	set_zoom_level(zoom_level - ZOOM_INCREMENT)

func disappear():
	if (show_glass):
		set_zoom_level(MIN_ZOOM)
	else:
		set_zoom_level(ZOOM_ONE)

#endregion
#region Option Buttons Keys

func populate_option_button(button: OptionButton):
	for key in MagnifySaveData.options.keys():
		button.add_item(key)

func select_option_button(button: OptionButton, value: String):
	for i: int in range(0, button.item_count, 1):
		if (button.get_item_text(i) == value):
			button.selected = i
			return

func select_zoom_in_key(item: int):
	select_zoom_key(item, true)

func select_zoom_out_key(item: int):
	select_zoom_key(item, false)

func select_zoom_key(item: int, is_zoom_in_key: bool):
	var key: String = zoom_in_key.get_item_text(item)
	var value = MagnifySaveData.options[key]

	if (is_zoom_in_key):
		save_data.current_zoom_in_key = key
	else:
		save_data.current_zoom_out_key = key

	save_data.update()

#endregion
#region Option Button Ratio

func populate_ratios():
	ratio_options.add_item(RATIO_WINDOW)
	ratio_options.add_item(ONE_BY_ONE)
	ratio_options.add_item(TWO_BY_THREE)
	ratio_options.add_item(SEVEN_BY_FIVE)
	ratio_options.add_item(SIXTEEN_BY_NINE)
	select_option_button(ratio_options, save_data.current_ratio)

func update_saved_ratio(item: int):
	save_data.current_ratio = ratio_options.get_item_text(item)

#endregion
#region Easing Function

func lerp_visibility(object: Control, target_condition: bool, lerp: float, delta: float) -> float:
	var target = 0.0
	if (target_condition):
		target = 1.0
	if (lerp == target):
		return lerp

	lerp = move_toward(lerp, target, delta * 4)
	object.visible = lerp > 0.01
	object.modulate = Color(1, 1, 1, ease_in_out_cubic(lerp))
	return lerp

func ease_in_out_cubic(x: float) -> float:
	if (x <= 0):
		return 0
	elif (x >= 1):
		return 1
	elif (x < 0.5):
		return 4 * x * x * x
	else:
		return 1 - pow(-2 * x + 2, 3) / 2;

#endregion
