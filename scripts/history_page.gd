extends Control

@onready var filter_option_button: OptionButton = $MarginContainer/VBoxContainer/FilterContainer/FilterOptionLabel
@onready var history_label: RichTextLabel = $MarginContainer/VBoxContainer/ScrollContainer/HistoryLabel
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton

func _ready() -> void:
	filter_option_button.item_selected.connect(_on_filter_changed)
	close_button.pressed.connect(_on_close_button_pressed)

	show_history()


func _on_filter_changed(_index: int) -> void:
	show_history()


func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/student_page.tscn")


func show_history() -> void:
	history_label.text = "Historikk kommer her..."
