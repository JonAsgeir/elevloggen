extends Control

@onready var scale_option_button: OptionButton = $MarginContainer/VBoxContainer/Scale/ScaleOptionButton
@onready var color_picker_button: ColorPickerButton = $MarginContainer/VBoxContainer/Color/ColorPickerButton
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton


func _ready() -> void:
	setup_scale_options()

	color_picker_button.color = Settings.accent_color

	scale_option_button.item_selected.connect(_on_scale_option_button_item_selected)
	color_picker_button.color_changed.connect(_on_color_picker_button_color_changed)
	back_button.pressed.connect(_on_back_button_pressed)


func setup_scale_options() -> void:
	scale_option_button.clear()

	var scale_values := [
		0.75,
		1.0,
		1.25,
		1.5,
		1.75,
		2.0,
		2.25,
		2.5,
		2.75,
		3.0
	]

	for scale_value in scale_values:
		scale_option_button.add_item(
			"%d %%" % roundi(scale_value * 100)
		)

		scale_option_button.set_item_metadata(
			scale_option_button.item_count - 1,
			scale_value
		)

		if is_equal_approx(scale_value, Settings.ui_scale):
			scale_option_button.select(
				scale_option_button.item_count - 1
			)


func _on_scale_option_button_item_selected(index: int) -> void:
	var scale_value: float = scale_option_button.get_item_metadata(index)

	Settings.ui_scale = scale_value
	Settings.save_settings()

	get_window().content_scale_factor = scale_value


func _on_color_picker_button_color_changed(color: Color) -> void:
	Settings.accent_color = color
	Settings.save_settings()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
