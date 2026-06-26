extends Control

@onready var subject_label: Label = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/HeaderLabel
@onready var low_positive_interactions_label: Label = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/LowInteractionLabel

@onready var back_button: Button = $MarginContainer/VBoxContainer/NavigationButtonsContainer/BackButton
@onready var main_menu_button: Button = $MarginContainer/VBoxContainer/NavigationButtonsContainer/MainMenuButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/NavigationButtonsContainer/QuitButton

func _ready() -> void:
	#SIGNALS
	back_button.pressed.connect(_on_back_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	#subject_label.text = "Fag: " + AppState.selected_subject_name
	show_statistics()


func show_statistics() -> void:
	var students := Database.get_students_with_fewest_positive_interactions(
		AppState.selected_subject_id,
		30,
		3
	)

	var text := "Færrest positive interaksjoner siste 30 dager:\n\n"

	for student in students:
		text += "%s %s: %d\n" % [
			student["first_name"],
			student["last_name"],
			student["positive_count"]
		]

	low_positive_interactions_label.text = text
	
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/student_page.tscn")


func _on_main_menu_button_pressed() -> void:
	AppState.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
