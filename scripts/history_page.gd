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
	var student_summary = AppState.current_students[AppState.current_student_index]
	var student_id = student_summary["id"]

	var filter := get_selected_filter()
	var events = Database.get_student_history(student_id, filter)

	var text := ""

	for event in events:
		text += "%s (%s) %s\n" % [
			format_history_date(event["event_date"]),
			format_event_type(event["event_type"]),
			event["event_text"]
		]

	history_label.text = text
	
func get_selected_filter() -> String:
	match filter_option_button.selected:
		1:
			return "goals"
		2:
			return "mastery"
		3:
			return "interactions"
		4:
			return "competence"
		_:
			return "all"


func format_event_type(event_type: String) -> String:
	match event_type:
		"goal":
			return "Mål"
		"interaction":
			return "Interaksjon"
		"mastery":
			return "Mestring"
		"competence":
			return "Kompetansemål"
		_:
			return event_type


func format_history_date(date: String) -> String:
	if date == "":
		return ""

	var parts := date.split("-")
	if parts.size() != 3:
		return date

	return "%d." % int(parts[2])
