extends VBoxContainer
class_name CompetenceGoalItem

@onready var description_label: Label = $HBoxContainer/DescriptionLabel
@onready var achievement_option_button: OptionButton = $HBoxContainer/AchievementOptionButton
@onready var comment_text_edit: TextEdit = $CommentTextEdit
@onready var toggle_comment_check_button: CheckButton = $HBoxContainer/ToggleCommentCheckButton

var competence_goal_id: int = -1


func _ready() -> void:
	if achievement_option_button.item_count == 0:
		achievement_option_button.add_item("Ikke vurdert")
		achievement_option_button.add_item("Lav")
		achievement_option_button.add_item("Middels")
		achievement_option_button.add_item("Høy")
	
	comment_text_edit.visible = false
	toggle_comment_check_button.toggled.connect(_on_toggle_comment_toggled)

func setup(goal_id: int, description: String, achievement_level: String = "not_assessed", comment: String = "") -> void:
	competence_goal_id = goal_id
	description_label.text = description
	comment_text_edit.text = comment

	match achievement_level:
		"low":
			achievement_option_button.select(1)
		"medium":
			achievement_option_button.select(2)
		"high":
			achievement_option_button.select(3)
		_:
			achievement_option_button.select(0)


func get_achievement_level() -> String:
	match achievement_option_button.selected:
		1:
			return "low"
		2:
			return "medium"
		3:
			return "high"
		_:
			return "not_assessed"

func get_comment() -> String:
	return comment_text_edit.text.strip_edges()

func _on_toggle_comment_toggled(button_pressed: bool) -> void:
	comment_text_edit.visible = button_pressed
