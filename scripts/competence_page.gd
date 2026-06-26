extends Control

@onready var competence_goals_container: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/CompetenceGoalsComtainer
@onready var close_button: Button = $MarginContainer/ScrollContainer/VBoxContainer/CloseButton
@onready var title_label: Label = $MarginContainer/ScrollContainer/VBoxContainer/TitleLabel

var competence_goal_scene = preload("res://scenes/competence_goal_item.tscn")
var current_student_id: int = -1

func _ready() -> void:
	var student_summary = AppState.current_students[AppState.current_student_index]
	current_student_id = student_summary["id"]

	close_button.pressed.connect(_on_close_button_pressed)

	load_competence_goals()
	
func load_competence_goals() -> void:
	var goals = Database.get_competence_goals(AppState.selected_subject_id)

	for goal in goals:
		var assessment = Database.get_competence_assessment(
			current_student_id,
			AppState.selected_subject_id,
			goal["id"]
		)

		var achievement_level := "not_assessed"
		var comment := ""

		if not assessment.is_empty():
			achievement_level = assessment["achievement_level"]
			comment = assessment["comment"]

		var item = competence_goal_scene.instantiate()
		competence_goals_container.add_child(item)

		item.setup(
			goal["id"],
			goal["description"],
			achievement_level,
			comment
		)

func _on_close_button_pressed() -> void:
	save_all_assessments()
	get_tree().change_scene_to_file("res://scenes/student_page.tscn")


func save_all_assessments() -> void:
	for child in competence_goals_container.get_children():
		if child is CompetenceGoalItem:
			Database.save_competence_assessment(
				current_student_id,
				AppState.selected_subject_id,
				child.competence_goal_id,
				child.get_achievement_level(),
				child.get_comment(),
				Time.get_date_string_from_system()
			)
