extends Node

const SETTINGS_PATH := "user://settings.cfg"

var ui_scale: float = 1.5
var accent_color: Color = Color("4f8cff")


func _ready() -> void:
	load_settings()
	apply_settings()


func load_settings() -> void:
	var config := ConfigFile.new()

	var error := config.load(SETTINGS_PATH)

	if error != OK:
		return

	ui_scale = config.get_value(
		"display",
		"ui_scale",
		1.5
	)

	accent_color = config.get_value(
		"display",
		"accent_color",
		Color("4f8cff")
	)


func save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value(
		"display",
		"ui_scale",
		ui_scale
	)

	config.set_value(
		"display",
		"accent_color",
		accent_color
	)

	config.save(SETTINGS_PATH)


func apply_settings() -> void:
	get_window().content_scale_factor = ui_scale
