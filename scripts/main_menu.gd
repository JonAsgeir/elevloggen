extends Control

@onready var vbox: VBoxContainer = $MarginContainer/CenterContainer/VBoxContainer/SubjectButtons
@onready var settings_button: Button = $MarginContainer/SettingsButton

func _ready() -> void:
	load_subject_buttons()
	settings_button.pressed.connect(_on_settings_button_pressed)

func load_subject_buttons() -> void:
	var subjects = Database.get_subjects()
	
	for subject in subjects:
		var button := Button.new()
		button.text = subject["name"]
		button.pressed.connect(_on_subject_pressed.bind(subject["id"], subject["name"]))
		vbox.add_child(button)

func _on_subject_pressed(subject_id: int, subject_name: String) -> void:
	AppState.selected_subject_id = subject_id
	AppState.selected_subject_name = subject_name
	AppState.current_students = Database.get_students_in_subject(subject_id)
	AppState.current_student_index = 0

	print("Valgt fag: ", subject_name)
	print("Antall elever: ", AppState.current_students.size())

	get_tree().change_scene_to_file("res://scenes/student_page.tscn")
	
func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_page.tscn")
	
	
