extends Control

@onready var competence_goals_container: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/CompetenceGoalsComtainer

var competence_goal_scene = preload("res://scenes/competence_goal_item.tscn")

func _ready() -> void:
	if AppState.selected_subject_id == -1:
		AppState.selected_subject_id = Database.get_subject_id("Matematikk")
		AppState.selected_subject_name = "Matematikk"

	load_competence_goals()
	
func load_competence_goals() -> void:
	var goals = Database.get_competence_goals(AppState.selected_subject_id)

	for goal in goals:
		var item = competence_goal_scene.instantiate()

		competence_goals_container.add_child(item)

		item.setup(
			goal["id"],
			goal["description"]
		)
