extends Control

@onready var subject_label: Label = $MarginContainer/ScrollContainer/VBoxContainer/HeaderLabel
@onready var low_positive_interactions_label: Label = $MarginContainer/ScrollContainer/VBoxContainer/LowInteractionLabel


func _ready() -> void:
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
