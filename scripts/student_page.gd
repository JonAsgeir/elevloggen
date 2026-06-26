extends Control

@onready var student_name_label: Label = $MarginContainer/VBoxContainer/StudentNameLabel
@onready var subject_label: Label = $MarginContainer/VBoxContainer/SubjectLabel
@onready var birthdate_label: Label = $MarginContainer/VBoxContainer/BirthdateLabel
@onready var grade_goal_label: Label = $MarginContainer/VBoxContainer/GradeGoalContainer/GradeGoalLabel

@onready var edit_grade_goal_button: Button = $MarginContainer/VBoxContainer/GradeGoalContainer/EditGradeGoalButton
@onready var grade_goal_dialog: AcceptDialog = $GradeGoalDialog
@onready var grade_goal_line_edit: LineEdit = $GradeGoalDialog/VBoxContainer/GradeGoalLineEdit

@onready var contact_mother_checkbox: CheckBox = $MarginContainer/VBoxContainer/ContactContainer/ContactMotherCheckBox
@onready var contact_father_checkbox: CheckBox = $MarginContainer/VBoxContainer/ContactContainer/ContactFatherCheckBox

@onready var goal_text_edit: TextEdit = $MarginContainer/VBoxContainer/GoalContainer/GoalTextEdit
@onready var goal_completed_button: Button = $MarginContainer/VBoxContainer/GoalContainer/VBoxContainer/GoalCompletedButton
@onready var goal_not_completed_button: Button = $MarginContainer/VBoxContainer/GoalContainer/VBoxContainer/GoalNotCompletedButton

@onready var previous_student_button: Button = $MarginContainer/VBoxContainer/NextStudentButtonCointainer/PreviousStudentButton
@onready var next_student_button: Button = $MarginContainer/VBoxContainer/NextStudentButtonCointainer/NextStudentButton

@onready var goal_comment_dialog: AcceptDialog = $GoalCommentDialog
@onready var goal_comment_text_edit: TextEdit = $GoalCommentDialog/GoalCommentContainer/GoalCommentTextEdit

@onready var mastery_text_edit: TextEdit = $MarginContainer/VBoxContainer/MasteryContainer/MasteryTextEdit
@onready var mastery_yes_button: Button = $MarginContainer/VBoxContainer/MasteryContainer/MasteryButtonContainer/MasteryYesButton
@onready var mastery_no_button: Button = $MarginContainer/VBoxContainer/MasteryContainer/MasteryButtonContainer/MasteryNoButton

@onready var interaction_text_edit: TextEdit = $MarginContainer/VBoxContainer/InteractionContainer/InteractionTextEdit
@onready var positive_interaction_button: Button = $MarginContainer/VBoxContainer/InteractionContainer/InteractionButtonContainer/PositiveInteractionButton
@onready var negative_interaction_button: Button = $MarginContainer/VBoxContainer/InteractionContainer/InteractionButtonContainer/NegativeInteractionButton

@onready var notes_button: Button = $MarginContainer/RightButtonsContainer/NotesButton
@onready var notes_dialog: AcceptDialog = $NotesDialog
@onready var notes_text_edit: TextEdit = $NotesDialog/VBoxContainer/NotesTextEdit

@onready var competence_button: Button = $MarginContainer/RightButtonsContainer/CompetenceButton

var current_student_id: int = -1
var pending_goal_result: String = ""

func _ready() -> void:
	# SIGNALS
	contact_mother_checkbox.toggled.connect(_on_contact_changed)
	contact_father_checkbox.toggled.connect(_on_contact_changed)
	previous_student_button.pressed.connect(_on_previous_student_button_pressed)
	next_student_button.pressed.connect(_on_next_student_button_pressed)
	goal_completed_button.pressed.connect(_on_goal_completed_button_pressed)
	goal_not_completed_button.pressed.connect(_on_goal_not_completed_button_pressed)
	goal_comment_dialog.confirmed.connect(_on_goal_comment_confirmed)
	mastery_yes_button.pressed.connect(_on_mastery_yes_button_pressed)
	mastery_no_button.pressed.connect(_on_mastery_no_button_pressed)
	positive_interaction_button.pressed.connect(_on_positive_interaction_button_pressed)
	negative_interaction_button.pressed.connect(_on_negative_interaction_button_pressed)
	edit_grade_goal_button.pressed.connect(_on_edit_grade_goal_button_pressed)
	grade_goal_dialog.confirmed.connect(_on_grade_goal_dialog_confirmed)
	notes_button.pressed.connect(_on_notes_button_pressed)
	notes_dialog.confirmed.connect(_on_notes_dialog_confirmed)
	competence_button.pressed.connect(_on_competence_button_pressed)
	
	show_current_student()


func show_current_student() -> void:
	if AppState.current_students.is_empty():
		student_name_label.text = "Ingen elever i dette faget"
		subject_label.text = AppState.selected_subject_name
		current_student_id = -1
		return

	var student_summary = AppState.current_students[AppState.current_student_index]
	current_student_id = student_summary["id"]

	var student = Database.get_student_in_subject(
	current_student_id,
	AppState.selected_subject_id
	)

	student_name_label.text = student["first_name"] + " " + student["last_name"]
	subject_label.text = "Fag: " + AppState.selected_subject_name
	birthdate_label.text = "Fødselsdato: " + student["birthdate"]
	grade_goal_label.text = "Karaktermål: " + str(student["grade_goal"])

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

func save_mastery_observation(status: String) -> void:
	if current_student_id == -1:
		return

	Database.add_mastery_observation(
		current_student_id,
		AppState.selected_subject_id,
		status,
		mastery_text_edit.text.strip_edges(),
		Time.get_date_string_from_system()
	)

	mastery_text_edit.text = ""

func save_interaction(type: String) -> void:
	if current_student_id == -1:
		return

	Database.add_interaction(
		current_student_id,
		AppState.selected_subject_id,
		type,
		interaction_text_edit.text.strip_edges(),
		Time.get_date_string_from_system()
	)

	interaction_text_edit.text = ""

func _on_edit_grade_goal_button_pressed() -> void:
	grade_goal_line_edit.text = grade_goal_label.text.replace("Karaktermål: ", "")
	grade_goal_dialog.popup_centered()


func _on_grade_goal_dialog_confirmed() -> void:
	var new_grade_goal := grade_goal_line_edit.text.strip_edges()

	Database.update_grade_goal(
		current_student_id,
		AppState.selected_subject_id,
		new_grade_goal
	)

	grade_goal_label.text = "Karaktermål: " + new_grade_goal
	
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
	else:
		get_tree().change_scene_to_file("res://scenes/statistics_page.tscn")


func _on_previous_student_button_pressed() -> void:
	save_current_goal()

	if AppState.current_student_index > 0:
		AppState.current_student_index -= 1

	show_current_student()

func _on_goal_completed_button_pressed() -> void:
	pending_goal_result = "completed"
	goal_comment_text_edit.text = ""
	goal_comment_dialog.popup_centered()


func _on_goal_not_completed_button_pressed() -> void:
	pending_goal_result = "not_completed"
	goal_comment_text_edit.text = ""
	goal_comment_dialog.popup_centered()


func _on_goal_comment_confirmed() -> void:
	Database.complete_active_goal(
		current_student_id,
		AppState.selected_subject_id,
		pending_goal_result,
		Time.get_date_string_from_system(),
		goal_comment_text_edit.text.strip_edges()
	)

	goal_text_edit.text = ""
	pending_goal_result = ""

func _on_mastery_yes_button_pressed() -> void:
	save_mastery_observation("mastery")

func _on_mastery_no_button_pressed() -> void:
	save_mastery_observation("no_mastery")

func _on_positive_interaction_button_pressed() -> void:
	save_interaction("positive")


func _on_negative_interaction_button_pressed() -> void:
	save_interaction("negative")

func _on_notes_button_pressed() -> void:
	if current_student_id == -1:
		return

	notes_text_edit.text = Database.get_student_notes(current_student_id)
	notes_dialog.popup_centered()


func _on_notes_dialog_confirmed() -> void:
	if current_student_id == -1:
		return

	Database.update_student_notes(
		current_student_id,
		notes_text_edit.text.strip_edges()
	)
	
func _on_competence_button_pressed() -> void:
	save_current_goal()
	get_tree().change_scene_to_file("res://scenes/competence_page.tscn")
