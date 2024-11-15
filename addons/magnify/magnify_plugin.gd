@tool
class_name MagnifyPlugin
extends EditorPlugin

const MAGNIFY_SCENE = preload("res://addons/magnify/magnify.tscn")
const PLUGIN_NAME = "Magnify"

var magnify_instance: ColorRect

func is_valid(godot_object: Object) -> bool:
	if (godot_object == null || !is_instance_valid(godot_object) || godot_object.is_queued_for_deletion()):
		return false
	return true

func _enter_tree():
	print("Activated: " + PLUGIN_NAME)
	magnify_instance = MAGNIFY_SCENE.instantiate() as ColorRect
	EditorInterface.get_editor_main_screen().add_child(magnify_instance)
	_make_visible(false)
	magnify_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL
	magnify_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	var glass: MagnifyingGlass = magnify_instance.get_child(1).get_child(0) as MagnifyingGlass
	glass.initialise()

func _exit_tree():
	print("Deactivated: " + PLUGIN_NAME)
	if (is_valid(magnify_instance)):
		magnify_instance.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if (is_valid(magnify_instance)):
		magnify_instance.visible = visible

func _get_plugin_name():
	return PLUGIN_NAME

func _get_plugin_icon():
	return load("res://addons/magnify/icon.png")
