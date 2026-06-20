extends Control

@onready var student_name_label: Label = $MarginContainer/VBoxContainer/StudentNameLabel
@onready var subject_label: Label = $MarginContainer/VBoxContainer/SubjectLabel
@onready var birthdate_label: Label = $MarginContainer/VBoxContainer/BirthdateLabel
@onready var grade_goal_label: Label = $MarginContainer/VBoxContainer/GradeGoalLabel

@onready var contact_mother_checkbox: CheckBox = $MarginContainer/VBoxContainer/ContactContainer/ContactMotherCheckBox
@onready var contact_father_checkbox: CheckBox = $MarginContainer/VBoxContainer/ContactContainer/ContactFatherCheckBox

@onready var goal_text_edit: TextEdit = $MarginContainer/VBoxContainer/GoalContainer/GoalTextEdit
@onready var goal_completed_button: Button = $MarginContainer/VBoxContainer/GoalContainer/VBoxContainer/GoalCompletedButton
@onready var goal_not_completed_button: Button = $MarginContainer/VBoxContainer/GoalContainer/VBoxContainer/GoalNotCompletedButton

@onready var previous_student_button: Button = $MarginContainer/VBoxContainer/NextStudentButtonCointainer/PreviousStudentButton
@onready var next_student_button: Button = $MarginContainer/VBoxContainer/NextStudentButtonCointainer/NextStudentButton

var current_student_id: int = -1

func _ready() -> void:
	# SIGNALS
	contact_mother_checkbox.toggled.connect(_on_contact_changed)
	contact_father_checkbox.toggled.connect(_on_contact_changed)
	previous_student_button.pressed.connect(_on_previous_student_button_pressed)
	next_student_button.pressed.connect(_on_next_student_button_pressed)
	
	show_current_student()


func show_current_student() -> void:
	if AppState.current_students.is_empty():
		student_name_label.text = "Ingen elever i dette faget"
		subject_label.text = AppState.selected_subject_name
		current_student_id = -1
		return

	var student_summary = AppState.current_students[AppState.current_student_index]
	current_student_id = student_summary["id"]

	var student = Database.get_student(current_student_id)

	student_name_label.text = student["first_name"] + " " + student["last_name"]
	subject_label.text = "Fag: " + AppState.selected_subject_name
	birthdate_label.text = "Fødselsdato: " + student["birthdate"]
	grade_goal_label.text = "Karaktermål: 0"

	contact_mother_checkbox.button_pressed = student["contact_mother"] == 1
	contact_father_checkbox.button_pressed = student["contact_father"] == 1

	var active_goal: Dictionary = Database.get_active_goal(
		current_student_id,
		AppState.selected_subject_id
	)

	if active_goal.is_empty():
		goal_text_edit.text = ""
	else:
		goal_text_edit.text = active_goal["goal_text"]

func save_current_goal() -> void:
	if current_student_id == -1:
		return

	Database.save_active_goal(
		current_student_id,
		AppState.selected_subject_id,
		goal_text_edit.text,
		Time.get_date_string_from_system()
	)

	
func _on_contact_changed(_button_pressed: bool) -> void:
	if current_student_id == -1:
		return

	Database.update_parent_contact(
		current_student_id,
		contact_mother_checkbox.button_pressed,
		contact_father_checkbox.button_pressed
	)

func _on_next_student_button_pressed() -> void:
	save_current_goal()

	if AppState.current_student_index < AppState.current_students.size() - 1:
		AppState.current_student_index += 1

	show_current_student()


func _on_previous_student_button_pressed() -> void:
	save_current_goal()

	if AppState.current_student_index > 0:
		AppState.current_student_index -= 1

	show_current_student()
